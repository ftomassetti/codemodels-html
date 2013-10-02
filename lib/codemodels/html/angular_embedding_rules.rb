# In this file we specify the rules which permits
# to recognize embedded Javascript in the HTML according
# to the idioms of the AngularJS project

require 'jars/jericho-html-3.3.jar'
require 'codemodels/js'

module CodeModels
module Html

CodeModels.enable_foreign_asts(Attribute)
CodeModels.enable_foreign_asts(Node)

module AngularJs

def self.parser_considering_angular_embedded_code
	js_parser = CodeModels::Js::DefaultParser
	js_expression_parser = CodeModels::Js::ExpressionParser

	p = Parser.new
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n,code|
		n.name=='ng-app' ? n.value : nil
	end
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n,code|
		n.name=='ng-repeat' ? n.value : nil
	end
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n,code|
		n.name=='ng-show' ? n.value : nil
	end
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n,code|
		n.name=='ng-class' ? n.value : nil
	end	
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n,code|
		n.name=='ng-model' ? n.value : nil
	end	
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n,code|
		n.name=='ng-click' ? n.value : nil
	end			
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n,code|
		n.name=='ng-include' ? n.value : nil
	end		
	# p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n,code|
	# 	if n.name=='ng-href'
	# 		raise "Expected to start with '#/{{', instead '#{n.value}'" unless n.value.start_with?('#/{{')
	# 		raise "Expected to end with '}}', instead '#{n.value}'" unless n.value.end_with?('}}')
	# 		n.value.remove_prefix('#/{{').remove_postfix('}}')
	# 	else
	# 		nil
	# 	end
	# end
	p.register_embedded_parser(Java::NetHtmlparserJericho::Element,js_expression_parser) do |n,code|		
		res = []
		if n.name!='script'
			n.text_blocks(code).each do |tb|			
				tb.value.scan( /\{\{[^\}]*\}\}/ ).each do |content|		
					#puts "FROM ELEMENT <<<#{n}>>> '#{content}'"
					res << content.remove_prefix('{{').remove_postfix('}}')
				end
			end
		end
		res
	end
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n,code|
		content = n.value
		res = []
		content.scan( /\{\{[^\}]*\}\}/ ).each do |content|			
			#puts "FROM ATTRIBUTE <<<#{n}>>> '#{content}'"
			res << content.remove_prefix('{{').remove_postfix('}}')
		end
		res
	end	
	p
end

end
end
end