require 'test_helper'
 
class TestParsingPuzzle < Test::Unit::TestCase

	include TestHelper
	include CodeModels
	include CodeModels::Html

	def test_root_structure
		code = IO.read('test/data/puzzle.html')
		r = Html.parse_code(code)
		assert_class HtmlDocument, r

		# child 0: <!DOCTYPE html>
		assert_equal 2, r.children.count
		assert_class Node, r.children[1] 	
		assert_equal 'html', r.children[1].name
	end

	def test_body_tag
		code = IO.read('test/data/puzzle.html')
		r = Html.parse_code(code)

		body = nil
		r.traverse do |n|
			body=n if n.is_a?(Node) && n.name=='body'
		end
		assert_not_nil body
		assert_equal 1,body.attributes.count
		assert_equal 'ng-app',body.attributes[0].name
		assert_equal 'puzzleApp',body.attributes[0].value

		assert body.all_children.include?(body.attributes[0])
		assert body.all_children_deep.include?(body.attributes[0])

		assert body.values_map.has_key?('ng-app')
		assert body.values_map.has_key?('puzzleApp')
	end

	def test_no_double_foreign_asts
		code = IO.read('test/data/puzzle.html')
		r = AngularJs.parser_considering_angular_embedded_code.parse_code(code)
		r.traverse do |n|
			fa = n.class.ecore.eAllReferences.select{|ref|ref.name=='foreign_asts'}
			fail("Node #{n} has #{fa.count} references with the name 'foreign_asts'") if fa.count > 1
		end
	end

	def test_js_names_title
		code = IO.read('test/data/puzzle.html')
		r = AngularJs.parser_considering_angular_embedded_code.parse_code(code)
		jstitles = r.all_children_deep_also_foreign.select {|n| n.is_a?(CodeModels::Js::Name) && n.identifier=='title'}
		assert_equal 2,jstitles.count
	end

end