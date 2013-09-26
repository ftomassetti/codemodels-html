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

	js_expression_parser = LightModels::Js::DefaultParser

	p = Parser.new
	p.register_embedded_parser(Java::NetHtmlparserJericho::Attribute,js_expression_parser) do |n|
		n.name=='ng-repeat' ? n.value : nil
	end
	p
end

end
end
end