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

	def test_js_names_title_position_relative
		code = IO.read('test/data/puzzle.html')
		r = AngularJs.parser_considering_angular_embedded_code.parse_code(code)
		jstitles = r.all_children_deep_also_foreign.select {|n| n.is_a?(CodeModels::Js::Name) && n.identifier=='title'}

		assert_equal SourcePoint.new(1,3),jstitles[0].source.begin_point(:relative)
		assert_equal SourcePoint.new(1,7),jstitles[0].source.end_point(:relative)
		assert_equal SourcePoint.new(1,8),jstitles[1].source.begin_point(:relative)
		assert_equal SourcePoint.new(1,12),jstitles[1].source.end_point(:relative)		
	end

	def test_js_names_title_position_absolute
		code = IO.read('test/data/puzzle.html')
		r = AngularJs.parser_considering_angular_embedded_code.parse_code(code)
		jstitles = r.all_children_deep_also_foreign.select {|n| n.is_a?(CodeModels::Js::Name) && n.identifier=='title'}

		assert_equal SourcePoint.new(15,31),jstitles[0].source.begin_point(:absolute)
		assert_equal SourcePoint.new(15,35),jstitles[0].source.end_point(:absolute)
		assert_equal SourcePoint.new(33,18),jstitles[1].source.begin_point(:absolute)
		assert_equal SourcePoint.new(33,22),jstitles[1].source.end_point(:absolute)		
	end	

	def test_js_names_title_code
		code = IO.read('test/data/puzzle.html')
		r = AngularJs.parser_considering_angular_embedded_code.parse_code(code)
		jstitles = r.all_children_deep_also_foreign.select {|n| n.is_a?(CodeModels::Js::Name) && n.identifier=='title'}
		assert_equal 'title',jstitles[0].source.code
		assert_equal 'title',jstitles[1].source.code
	end

end