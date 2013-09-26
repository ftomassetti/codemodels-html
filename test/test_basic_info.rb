require 'test_helper'
 
class TestBasicInfo < Test::Unit::TestCase

	include TestHelper
	include LightModels
	include LightModels::Html

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
		assert_equal 8,span.source.begin_pos.line
		assert_class Node, span.eContainer
		assert_equal 'p',span.eContainer.name
		assert_equal 7,span.eContainer.source.begin_pos.line # p
		assert_equal 'div',span.eContainer.eContainer.name
		assert_equal 7,span.eContainer.eContainer.source.begin_pos.line # div
		assert_equal 'body',span.eContainer.eContainer.eContainer.name
		assert_equal 2,span.eContainer.eContainer.eContainer.source.begin_pos.line # body
	end

end