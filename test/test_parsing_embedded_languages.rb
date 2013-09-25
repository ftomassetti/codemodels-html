require 'test/unit'
require 'lightmodels'
require 'html-lightmodels'
require 'test_helper'
 
class TestParsingEmbeddedLanguages < Test::Unit::TestCase

	include TestHelper
	include LightModels
	include LightModels::Html

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

		r = Html.parse_code(code)
		raise "Check that embedded nodes are there"
	end

end