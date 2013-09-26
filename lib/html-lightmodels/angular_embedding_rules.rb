# In this file we specify the rules which permits
# to recognize embedded Javascript in the HTML according
# to the idioms of the AngularJS project

require 'jars/jericho-html-3.3.jar'
require 'js-lightmodels'

module LightModels
module Html
module AngularJs

def self.parser_considering_angular_embedded_code
	LightModels.enable_foreign_asts(Attribute)

	js_parser = LightModels::Js::DefaultParser
	js_expression_parser = LightModels::Js::ExpressionParser

	p = Parser.new
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n|
		n.name=='ng-repeat' ? n.value : nil
	end
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n|
		n.name=='ng-class' ? n.value : nil
	end	
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n|
		n.name=='ng-model' ? n.value : nil
	end	
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n|
		n.name=='ng-click' ? n.value : nil
	end		
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n|
		if n.name=='ng-href'
			raise "Expected to start with '#/{{', instead '#{n.value}'" unless n.value.start_with?('#/{{')
			raise "Expected to end with '}}', instead '#{n.value}'" unless n.value.end_with?('}}')
			n.value.remove_prefix('#/{{').remove_postfix('}}')
		else
			nil
		end
	end

	p
end

end
end
end