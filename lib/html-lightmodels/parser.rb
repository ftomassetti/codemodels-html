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

def self.node_to_model(node)
	case node
	when Nokogiri::HTML::Document
		model = Html::Document.new
		translate_many(node,model,:children)		
		model
	when Nokogiri::XML::Element
		model = Html::Node.new
		model.name = node.name
		translate_many(node,model,:children)
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

end

end