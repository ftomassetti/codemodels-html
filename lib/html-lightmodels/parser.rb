require 'jars/jericho-html-3.3.jar'
require 'lightmodels'

class ::String

	def first_index(sub)
		(0...(self.length-1)).each do |i|
			return i if self[i,self.length-1].start_with?(sub)
		end
		nil
	end

	def last_index(sub)
		last = nil
		(0...(self.length-1)).each do |i|
			last=i if self[i,self.length-1].start_with?(sub)
		end
		last
	end	

end

module LightModels
module Html

class Parser < LightModels::Parser

def initialize
	@embedded_parsers = Hash.new do |h,k|
		h[k] = []
	end
end

def parse_file(path)
	parse_code(IO.read(path))
end

def parse_code(code)
	Java::net.htmlparser.jericho.Config.IsHTMLEmptyElementTagRecognised = true
	xhtml = Java::net.htmlparser.jericho.Config::CompatibilityMode::XHTML
	Java::net.htmlparser.jericho.Config.CurrentCompatibilityMode = xhtml
	reader = java.io.StringReader.new code
	source = Java::net.htmlparser.jericho.Source.new reader
	node_to_model(source,code)
end

# It operates on original node, not on the model obtained because
# it could have less information. For example in parsing scripts I need the
# raw content
def register_embedded_parser(node_class,embedded_parser,&selector)
	@embedded_parsers[node_class] << {embedded_parser: embedded_parser, selector: selector}
end

def node_content(node,code)
	text_inside = code[(node.begin)..(node.end)]
	i  = text_inside.first_index('>') 
	start_index = node.begin+i+1
	li = text_inside.last_index('<')
	end_index    = node.begin+li
	content = code[start_index,end_index-start_index]
	content = "" unless content
	content
end

private

def add_source_info(node,model,code)
	return if model==nil
	model.language = LANGUAGE
	model.source = LightModels::SourceInfo.new
	model.source.begin_pos = absolute_pos_to_position(node.begin,code)
	model.source.end_pos   = absolute_pos_to_position(node.end,code)
end

def break_content(node,code)
	text_inside = code[(node.begin)..(node.end)]
	#puts "Text inside #{node.name} ^#{text_inside}^ It has child elements #{node.child_elements}"
	i  = text_inside.first_index('>') 
	#puts "Index i: #{i}"
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

def analyze_content(model,node,code)
	break_content(node,code).each do |s,e|
		text = code[s,e-s]
		#puts "TEXT ^#{text}^"
		unless text==nil or text.strip.empty?
			t = Html::Text.new
			t.value = text
			model.addChildren(t)
		end
	end
end

def node_to_model(node,code)
	if node.is_a? Java::NetHtmlparserJericho::Source
		model = Html::HtmlDocument.new
		translate_many(code,node,model,:children,node.child_elements)
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
			if node.attributes.get('type') && node.attributes.get('type').value=='text/ng-template'
				content = node_content(node,code)
				script_doc = parse_code(content)				
				model.addForeign_asts script_doc
			end
		else			
			model = Html::Node.new
			analyze_content(model,node,code)
			model.name = node.name		
			translate_many(code,node,model,:children,node.child_elements)
		end		
		translate_many(code,node,model,:attributes)
		model	
	elsif node.is_a? Java::NetHtmlparserJericho::Attribute
		model = Html::Attribute.new
		model.name  = node.name
		model.value = node.value
		model				
	else
		raise "Unknown node class: #{node.class}"
	end

	add_source_info(node,model,code)
	check_foreign_parser(node,code,model)
	model
end

def check_foreign_parser(node,code,model)
	@embedded_parsers[node.class].each do |ep|
		selector = ep[:selector]
		embedded_parser = ep[:embedded_parser]
		embedded_code = selector.call(node,code)
		if embedded_code
			embedded_root = embedded_parser.parse_code(embedded_code)
			model.addForeign_asts(embedded_root)
		end
	end
end

def absolute_pos_to_position(abspos,code)
	p = LightModels::Position.new
	count = 0
	ln = nil
	cn = nil
	code.lines.each_with_index do |l,i|
		count+=l.length
		if count>=abspos
			ln = i
			cn = abspos-l.length-count
			break
		end
	end
	raise "It should not be nil: abs pos #{abspos}, code length #{code.length}" unless ln
	p.line   = ln+1
	p.column = cn+1
	p
end

def translate_many(code,node,model,dest,node_value=(node.send(dest)))
	return unless node_value!=nil
	#puts "Considering #{model.class}.#{dest} (#{node_value.class})"
	node_value.each do |el|
		#puts "\t* #{el.class}"
		model_el = node_to_model(el,code)
		model.send(:"add#{dest.to_s.proper_capitalize}", model_el) if model_el!=nil
	end
end

end # class Parser

DefaultParser = Parser.new

def self.parse_code(code)
	DefaultParser.parse_code(code)
end

end
end