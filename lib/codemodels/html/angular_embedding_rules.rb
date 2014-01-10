# In this file we specify the rules which permits
# to recognize embedded Javascript in the HTML according
# to the idioms of the AngularJS project

require 'jars/jericho-html-3.3.jar'
require 'codemodels/js'

module CodeModels
module Html

module AngularJs

def self.attribute_value_pos(code,n)
	begin
		bi = n.java_method(:getValueSegment).call.begin
		ei = n.java_method(:getValueSegment).call.end-1
		SourcePosition.from_code_indexes(code,bi,ei)
	rescue
		# TODO more investigation needed
		return nil
	end
end

def self.parser_considering_angular_embedded_code
	js_parser = CodeModels::Js::DefaultParser
	js_expression_parser = CodeModels::Js::ExpressionParser

	p = Parser.new

	ng_attribute_base_names = 'app','repeat','show','class','model','click','include'
	ng_attribute_names = []
	ng_attribute_base_names.each do |n|
		ng_attribute_names<<"ng:#{n}"
		ng_attribute_names<<"ng-#{n}"
	end

	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n,code|
		ng_attribute_names.include?(n.name) ? attribute_value_pos(code,n) : nil
	end

	p.register_embedded_parser(Java::NetHtmlparserJericho::Element,js_expression_parser) do |n,code|		
		res = []
		if n.name!='script'
			n.text_blocks(code).each do |tb|	
				tb_start = tb.source.position.begin_point.to_absolute_index(code)	
				res.concat(instances_of_escaped_text(code,tb.value,tb_start))
			end
		end
		res
	end
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n,code|
		content = n.value
		if n.getValueSegment
			bi = n.getValueSegment.begin
			instances_of_escaped_text(code,content,bi)
		else
			[]
		end
	end	
	p
end

private

def self.instances_of_escaped_text(code,content,bi)
#	puts "content '#{content}'"
#	puts "content from code '#{code[bi,content.length]}'"
	matchdata_open = content.match('{{')
	return [] unless matchdata_open
	p_start = matchdata_open.begin(0)
#	puts "after open '#{content[p_start..-1]}'"
	matchdata_end = content[p_start..-1].match('}}')
	return [] unless matchdata_end
    p_end   = matchdata_end.begin(0)
    if (p_end+3)==content.length
    	remaining_content = ''
    else
    	remaining_content = content[(p_end+2)..-1]
    end
 #   puts "remaining_content: '#{remaining_content}'"
    start_in_content = p_start+2
    end_in_content   = p_start+p_end-1
#  puts "BLOCK IN CONTENT '#{content[start_in_content..end_in_content]}'"  
    block = SourcePosition.from_code_indexes(code,bi+start_in_content,bi+end_in_content)
#    puts "BLOCK IN CODE    '#{code[(bi+start_in_content)..(bi+end_in_content)]}'"
    [block].concat(instances_of_escaped_text(code,remaining_content,bi+end_in_content+3))
end

end
end
end