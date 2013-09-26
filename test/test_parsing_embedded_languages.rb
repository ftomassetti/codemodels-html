require 'test_helper'
require 'js-lightmodels'
 
class TestParsingEmbeddedLanguages < Test::Unit::TestCase

	include TestHelper
	include LightModels
	include LightModels::Html

	def test_source_line
		p = AngularJs.parser_considering_angular_embedded_code
		code = 
	 %q{<html>
			<body ng-app="puzzleApp">
				<ul id="types">
					<li ng-repeat="t in types" ng-class="{'selected': t.id == type}">
						<a ng-href="#/{{t.id}}">{{t.title}}</a>
					</li>
				</ul>
			</body>
		</html>}

		r = p.parse_code(code)
		li = r.all_children_deep.find {|n| n.is_a?(Node) && n.name=='li'}
		assert_not_nil li
		a = li.attributes.find {|a| a.name=='ng-repeat'}
		assert_not_nil a
		assert_equal 1,a.foreign_asts.count
		assert_class LightModels::Js::InInfixExpression,a.foreign_asts[0]
	end

end