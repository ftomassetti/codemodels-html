require 'test_helper'
 
class TestParsingPuzzle < Test::Unit::TestCase

	include TestHelper
	include LightModels
	include LightModels::Html

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
	

end