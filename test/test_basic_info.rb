require 'test_helper'
 
class TestBasicInfo < Test::Unit::TestCase

	include TestHelper
	include CodeModels
	include CodeModels::Html

	def test_source_line
		code = %q{<html>
			<body>
				<p>ciao
					come
					stai?</p>
				<p>io bene</p>
				<div><p>
					<span></span>
				</p></div>
			</body>
			</html>}
		r = Html.parse_code(code)
		assert_class HtmlDocument, r
		span = nil
		r.traverse {|n| span = n if n.is_a?(Node) && n.name=='span'}
		assert_not_nil span
		assert_equal 8,span.source.position.begin_point.line
		assert_class Node, span.eContainer
		assert_equal 'p',span.eContainer.name
		assert_equal 7,span.eContainer.source.position.begin_point.line # p
		assert_equal 'div',span.eContainer.eContainer.name
		assert_equal 7,span.eContainer.eContainer.source.position.begin_point.line # div
		assert_equal 'body',span.eContainer.eContainer.eContainer.name
		assert_equal 2,span.eContainer.eContainer.eContainer.source.position.begin_point.line # body
	end

	def test_source_line_of_text_elements
		code = %q{<html>
			<body>
				<p>ciao
					come
					stai?</p>
				<p>io bene</p>
				<div><p>
					<span></span>
				</p></div>
			</body>
			</html>}
		r = Html.parse_code(code)
		assert_class HtmlDocument, r
		body = nil
		r.traverse {|n| body = n if n.is_a?(Node) && n.name=='body'}
		assert_not_nil body
		first_p = body.all_children[0]
		first_p_text = first_p.all_children[0]
		assert_class Text,first_p_text
		assert_equal 3,first_p_text.source.position.begin_point.line
		assert_equal 5,first_p_text.source.position.end_point.line
	end	

	def test_artifact_final_host_is_set_correctly_for_all
		r = AngularJs.parser_considering_angular_embedded_code.parse_file('test/data/puzzle.html')
		r.traverse(:also_foreign) do |n|
			assert_equal 'test/data/puzzle.html',n.source.artifact.final_host.filename, "Node with wrong final_host: #{n}"
		end
	end

end