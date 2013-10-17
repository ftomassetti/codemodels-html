require 'test_helper'
require 'codemodels/js'
 
class TestParsingEmbeddedLanguages < Test::Unit::TestCase

	include TestHelper
	include CodeModels
	include CodeModels::Html

	def setup
		@p = AngularJs.parser_considering_angular_embedded_code
	end

	def test_source_line
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

		r = @p.parse_code(code)
		li = r.all_children_deep.find {|n| n.is_a?(Node) && n.name=='li'}
		assert_not_nil li
		a = li.attributes.find {|a| a.name=='ng-repeat'}
		assert_not_nil a
		assert_equal 1,a.foreign_asts.count
		assert_class CodeModels::Js::InInfixExpression,a.foreign_asts[0]
	end

	def test_multiple_angular_expressions_in_attr
		code = %q{<sliding-puzzle api="puzzle.api" size="{{puzzle.rows}}x{{puzzle.cols}}" src="{{puzzle.src}}"></sliding-puzzle>}

		r = @p.parse_code(code)
		assert_class HtmlDocument,r
		assert_class Node,r.children[0]		
		att_size = r.children[0].attributes.find {|a| a.name=='size'}
		att_src = r.children[0].attributes.find {|a| a.name=='src'}
		assert_equal 2,att_size.foreign_asts.count
		assert_equal 1,att_src.foreign_asts.count
	end

	def test_parsing_empty_attr
		code = %q{<sliding-puzzle api />}

		r = @p.parse_code(code)
		# it does not crash? It is ok!
	end	

end