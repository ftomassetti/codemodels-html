require 'test/unit'
require 'lightmodels'
require 'html-lightmodels'
require 'test_helper'
 
class TestInfoExtraction < Test::Unit::TestCase

	include TestHelper
	include LightModels

	def test_snippet_1
		code = %q{
			<html>
			<body>
				<p>ciao!</p>
			</body>
			</html>
		}
		assert_code_map_to(code, {
			'html' =>1,
			'body' =>1,
			'p' => 1,
			'ciao!'=> 1
		})		
	end

end