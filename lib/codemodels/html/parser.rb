require 'java'
require 'jars/jericho-html-3.3.jar'
require 'codemodels'
require 'codemodels/html/monkey_patching'

module CodeModels
module Html

class TextBlock
	attr_accessor :source
	attr_accessor :value

	def begin_point=(data)
		@source = SourceInfo.new unless @source
		@source.begin_point= data
	end

	def end_point=(data)
		@source = SourceInfo.new unless @source
		@source.end_point= data
	end	
end

class ::Java::NetHtmlparserJericho::Element 

	def text_blocks(code)
		blocks = []
		break_content(self,code).each do |s,e|
			text = code[s,e-s]			
			unless text==nil or text.strip.empty?
				block = TextBlock.new
				block.value = text
				block.source = SourceInfo.new
				block.source.position = SourcePosition.from_code_indexes(code,s,e-1)

				blocks << block
			end
		end
		blocks
	end

	private

	def break_content(node,code)
		text_inside = code[(node.begin)...(node.end)]
		#puts "Text inside #{node.name} ^#{text_inside}^ It has child elements #{node.child_elements}"
		i  = text_inside.first_index('>') 
		raise "No '>' found in node #{node}, text inside: '#{text_inside}'" unless i
		#puts "Index i: #{i}"
		raise "No Fixnum" unless node.begin.is_a?(Fixnum)
		raise "No Fixnum" unless i.is_a?(Fixnum)
		start_index = node.begin+i+1
		li = text_inside.last_index('<')
		#puts "Index li: #{li}"
		end_index    = node.begin+li
		#puts "Indexes #{start_index} #{end_index}"
		#puts "Content of #{node.name} ^#{code[start_index,end_index-start_index]}^"

		# no content
		return [] if start_index==end_index

		if node.child_elements.count==0
			return [[start_index,end_index]]
		else
			segments = []
			# before the first
			segments << [start_index,node.child_elements.first.begin]
			# between children
			for i in 0...(node.child_elements.count-1)
				s = node.child_elements[i].end
				e = node.child_elements[i+1].begin
				segments << [s,e]
			end
			# after the last
			i_last = node.child_elements.size-1
			last_child = node.child_elements[i_last]
			segments << [last_child.end,end_index]			
		end
		segments
	end

end

class Parser < CodeModels::Parser

	def initialize
		@embedded_parsers = Hash.new do |h,k|
			h[k] = []
		end
	end

	def parse_file(path)
		code = IO.read(path)
		parse_artifact(FileArtifact.new(path,code))
	end

	def raw_node_tree(code)
		Java::net.htmlparser.jericho.Config.IsHTMLEmptyElementTagRecognised = true
		xhtml = Java::net.htmlparser.jericho.Config::CompatibilityMode::XHTML
		Java::net.htmlparser.jericho.Config.CurrentCompatibilityMode = xhtml
		reader = java.io.StringReader.new code
		source = Java::net.htmlparser.jericho.Source.new reader
		source
	end

	def parse_code(code)
		parse_artifact(FileArtifact.new('<code>',code))
	end

	def parse_artifact(artifact)
		source = raw_node_tree(artifact.code)
		node_to_model(source,artifact.code,artifact)
	end

	# It operates on original node, not on the model obtained because
	# it could have less information. For example in parsing scripts I need the
	# raw content
	def register_embedded_parser(node_class,embedded_parser,&selector)
		@embedded_parsers[node_class] << {embedded_parser: embedded_parser, selector: selector}
	end

	def self.node_content(node,code)
		pos = node_content_pos(node,code)
		code[pos[0]..pos[1]]
	end

	def self.node_content_pos(node,code)
		text_inside = code[(node.begin)...(node.end)]
		i  = text_inside.first_index('>') 
		start_index = node.begin+i+1
		li = text_inside.last_index('<')
		end_index    = node.begin+li-1
		raise "problem" if start_index>end_index
		#content = code[start_index,end_index-start_index]
		[start_index,end_index]
	end

	private

	def add_source_info(node,model,code,artifact)
		return if model==nil
		model.language = LANGUAGE
		model.source = CodeModels::SourceInfo.new
		model.source.artifact = artifact
		model.source.position = SourcePosition.from_code_indexes(code,node.begin,node.end)
	end

	def analyze_content(model,node,code,artifact)
		node.text_blocks(code).each do |tb|
			raise "GOTCHA #{node.name} TEXT INSIDE '#{code[(node.begin)..(node.end)]}'" if (tb.value=='</head>')
			t = Html::Text.new
			t.value = tb.value

			t.language = LANGUAGE
			t.source = tb.source
			t.source.artifact = artifact

			model.addChildren(t)
		end
	end

	def node_to_model(node,code,artifact)
		if node.is_a? Java::NetHtmlparserJericho::Source
			model = Html::HtmlDocument.new
			translate_many(code,node,model,:children,node.child_elements,artifact)
			model
		elsif node.is_a? Java::NetHtmlparserJericho::Element
			if node.name=='!doctype'
				model = Html::DTD.new
				# I am naughty... and waiting for the Jericho parser to fix
				# how they parse doctypes
				model.name = 'html'
				model		
			elsif node.name=='script'
				model = Html::Script.new	
				model.name = node.name
				# something is obfuscating the attributes method... damn...
				attributes_method = node.java_method(:getAttributes)
				attributes = attributes_method.call		
				raise "Error, Attributes expected, instead it is '#{attributes.class}'. Node class #{node.class}" unless attributes.is_a?(Java::NetHtmlparserJericho::Attributes)
				if attributes.get('type') && attributes.get('type').value=='text/ng-template'
					content_pos = Parser.node_content_pos(node,code)
					#raise "mismatch" unless content==embedded_artifact.code
					embedded_artifact = EmbeddedArtifact.new
					embedded_artifact.host_artifact = artifact
					si = content_pos[0]
					while code[si]==' '||code[si]=="\t"||code[si]=="\r"||code[si]=="\n"
						si+=1
					end
					embedded_artifact.position_in_host = SourcePosition.from_code_indexes(code,si,content_pos[1])
					script_doc = parse_artifact(embedded_artifact)				
					model.addForeign_asts script_doc
				end
			else			
				model = Html::Node.new
				analyze_content(model,node,code,artifact)
				model.name = node.name		
				translate_many(code,node,model,:children,node.child_elements,artifact)
			end		
			translate_many(code,node,model,:attributes,artifact)
			model	
		elsif node.is_a? Java::NetHtmlparserJericho::Attribute
			model = Html::Attribute.new
			model.name  = node.name
			model.value = node.value
			model				
		else
			raise "Unknown node class: #{node.class}"
		end

		add_source_info(node,model,code,artifact)
		check_foreign_parser(node,code,model,artifact)
		model
	end

	def check_foreign_parser(node,code,model,artifact)
		@embedded_parsers[node.class].each do |ep|
			selector = ep[:selector]
			embedded_parser = ep[:embedded_parser]
			embedded_position = selector.call(node,code)
			if embedded_position
				unless embedded_position.is_a?(Array)
					embedded_position = [embedded_position]
				end
				embedded_position.each do |ep|
					embedded_artifact = EmbeddedArtifact.new
					embedded_artifact.host_artifact = artifact
					embedded_artifact.position_in_host = ep
					begin
						embedded_root = embedded_parser.parse_artifact(embedded_artifact)
					rescue Exception => e
						raise "Problem embedded in '#{node}' at #{model.source.position} parsing '#{embedded_artifact.code}', from position #{ep}: #{e.inspect}"
					end
					model.addForeign_asts(embedded_root)
				end
			end
		end
	end

	def translate_many(code,node,model,dest,node_value=(node.send(dest)),artifact)
		return unless node_value!=nil
		node_value.each do |el|
			model_el = node_to_model(el,code,artifact)
			model.send(:"add#{dest.to_s.proper_capitalize}", model_el) if model_el!=nil
		end
	end

end # class Parser

DefaultParser = Parser.new

def self.parse_artifact(artifact)
	DefaultParser.parse_artifact(artifact)
end

def self.parse_code(code)
	parse_file(code,'<code>')
end

def self.parse_file(code,filename)
	parse_artifact(FileArtifact.new(filename,code))
end

def self.raw_node_tree(code)
	DefaultParser.raw_node_tree(code)
end

end
end