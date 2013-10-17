require 'test_helper'
require 'codemodels/js'
 
class TestParsingEmbeddedLanguages < Test::Unit::TestCase

	include TestHelper
	include CodeModels
	include CodeModels::Html


	def test_begin_index
		code = "<sliding-puzzle api />"
		assert_equal 0,code.first_index('<')
		assert_equal 1,code.first_index('s')
		assert_equal 8,code.first_index('-')
		assert_equal 20,code.first_index('/')
		assert_equal 21,code.first_index('>')
	end	

end