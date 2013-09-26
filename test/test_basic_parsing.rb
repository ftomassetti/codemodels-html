require 'test/unit'
require 'lightmodels'
require 'html-lightmodels'
require 'test_helper'
 
class TestBasicParsing < Test::Unit::TestCase

	include TestHelper
	include LightModels
	include LightModels::Html

	def test_basic_document
		code = "<html></html>"
		r = Html.parse_code(code)
		assert_class HtmlDocument, r
		assert_equal 1, r.children.count
		assert_class Node, r.children[0] 	
		assert_equal 'html', r.children[0].name
	end

	def test_basic_attributes
		code = "<html id='ciao'></html>"
		r = Html.parse_code(code)
		html = r.children[0] 
		assert_equal 1, html.attributes.count
		assert_equal "id", html.attributes[0].name
		assert_equal "ciao", html.attributes[0].value
	end	

	def test_basic_text
		code = "<html>ciao</html>"
		r = Html.parse_code(code)
		html = r.children[0] 
		assert_equal 1, html.children.count
		assert_class Text, html.children[0]
		assert_equal 'ciao', html.children[0].value
	end

	def test_basic_dtd
		code = "<!DOCTYPE html>"
		r = Html.parse_code(code)
		dtd = r.children[0] 
		assert_class DTD, dtd
		assert_equal 'html', dtd.name
	end

	def test_parse_scripts
		code = "<html><head><script type='text/ng-template' id='sliding-puzzle'>\n<a/>\n</script></head></html>"
		r = Html.parse_code(code)
		script = r.children[0].children[0].children[0]		
		assert_class Script, script
		assert_class HtmlDocument, script.foreign_asts[0]
		assert_class Node, script.foreign_asts[0].children[0]
		assert_equal 'a', script.foreign_asts[0].children[0].name
	end

end