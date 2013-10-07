# In this file we specify the rules which permits
# to recognize embedded Javascript in the HTML according
# to the idioms of the AngularJS project

require 'jars/jericho-html-3.3.jar'
require 'codemodels/js'

module CodeModels
module Html

module AngularJs

def self.attribute_value_pos(code,n)
	bi = n.getValueSegment.begin
	ei = n.getValueSegment.end-1
	#puts "ATTVALUE<<#{code[bi...ei]}>> #{SourcePosition.from_code_indexes(code,bi,ei)} @@@#{code}@@@"
	SourcePosition.from_code_indexes(code,bi,ei)
end

def self.parser_considering_angular_embedded_code
	js_parser = CodeModels::Js::DefaultParser
	js_expression_parser = CodeModels::Js::ExpressionParser

	p = Parser.new
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n,code|
		n.name=='ng-app' ? attribute_value_pos(code,n) : nil
	end
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n,code|
		n.name=='ng-repeat' ? attribute_value_pos(code,n) : nil
	end
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n,code|
		n.name=='ng-show' ? attribute_value_pos(code,n) : nil
	end
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n,code|
		n.name=='ng-class' ? attribute_value_pos(code,n) : nil
	end	
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n,code|
		n.name=='ng-model' ? attribute_value_pos(code,n) : nil
	end	
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n,code|
		n.name=='ng-click' ? attribute_value_pos(code,n) : nil
	end			
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n,code|
		n.name=='ng-include' ? attribute_value_pos(code,n) : nil
	end		

	p.register_embedded_parser(Java::NetHtmlparserJericho::Element,js_expression_parser) do |n,code|		
		res = []
		if n.name!='script'
			n.text_blocks(code).each do |tb|	
				tb_start = tb.source.position.begin_point.to_absolute_index(code)	
				tb.value.scan( /\{\{[^\}]*\}\}/ ).each do |content|		
					start_index = $~.offset(0)[0]+2+tb_start
					end_index   = start_index+content.length-5
					#puts "ELEMENT<<#{code[start_index..end_index]}>> #{SourcePosition.from_code_indexes(code,start_index,end_index)}"
					res << SourcePosition.from_code_indexes(code,start_index,end_index)
				end
			end
		end
		res
	end
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n,code|
		content = n.value
		bi = n.getValueSegment.begin
		res = []
		content.scan( /\{\{[^\}]*\}\}/ ).each do |content|			
			start_index = $~.offset(0)[0]+2+bi
			end_index   = start_index+content.length-5	
			#puts "ATTRIBUTE<<#{code[start_index..end_index]}>>"		
			res << SourcePosition.from_code_indexes(code,start_index,end_index)
		end
		res
	end	
	p
end

end
end
end