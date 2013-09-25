require 'lightmodels'
require 'nokogiri'

module LightModels
module Html

def self.parse_file(path)
	parse_code(IO.read(path))
end

def self.parse_code(code)
	node_doc = Nokogiri::HTML(code)
	node_to_model(node_doc)
end

def self.add_source_info(node,model)
	return if model==nil
	model.language = LANGUAGE
	model.source = LightModels::SourceInfo.new

	model.source.begin_pos = LightModels::Position.new 
	model.source.begin_pos.line = node.line if node.respond_to?(:line)

	# bp = node.getAbsolutePosition
	# ep = node.getAbsolutePosition+node.length

	# class << instance.source
	# 	attr_accessor :code
	# 	def to_code
	# 		@code
	# 	end
	# end
	# instance.source.code = code[bp..ep]

	# instance.source.begin_pos = LightModels::Position.new
	# instance.source.begin_pos.line = node.lineno
	# instance.source.begin_pos.column = node.position+1
	# instance.source.end_pos = LightModels::Position.new	
	# instance.source.end_pos.line = node.lineno+newlines(code,bp,ep)-1
	# instance.source.end_pos.column = column_last_char(code,bp,ep)
end

def self.node_to_model(node)
	case node
	when Nokogiri::HTML::Document
		model = Html::HtmlDocument.new
		translate_many(node,model,:children)		
		model
	when Nokogiri::XML::Document
		model = Html::XmlDocument.new
		translate_many(node,model,:children)		
		model	
	when Nokogiri::XML::Element
		if node.name=='script'
			model = Html::Script.new		
			if node.attributes['type'].value=='text/ng-template'
				raise "Script expected to have one child, it has: #{node.children.count} #{node.children}" unless node.children.count==1
				raise "TextExpected into Script" unless node.children[0].is_a?(Nokogiri::XML::Text)
				script_doc = Nokogiri::XML(node.children[0].content)					
				model.root = node_to_model(script_doc)
			end
			# other script types are ignored...
		else
			model = Html::Node.new
			translate_many(node,model,:children)
		end
		model.name = node.name		
		translate_many(node,model,:attributes,node.attributes.values)
		model		
	when Nokogiri::XML::Attr
		model = Html::Attribute.new
		model.name = node.name
		model.value = node.value
		model
	when Nokogiri::XML::Text
		if node.content.strip.empty?
			nil
		else
			model = Html::Text.new
			model.value = node.content
			model		
		end
	when Nokogiri::XML::DTD
		model = Html::DTD.new
		model.name = node.name
		model
	else
		raise "Unknown node class: #{node.class}"
	end

	add_source_info(node,model)
	model
end

private

def self.translate_many(node,model,dest,node_value=(node.send(dest)))
	#puts "Considering #{model.class}.#{dest} (#{node_value.class})"
	node_value.each do |el|
		#puts "\t* #{el.class}"
		model_el = node_to_model(el)
		model.send(:"add#{dest.to_s.proper_capitalize}", model_el) if model_el!=nil
	end
end

class Parser < LightModels::Parser

	def parse_code(code)
		LightModels::Html.parse_code(code)
	end

end

end
end