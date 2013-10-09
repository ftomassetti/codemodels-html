require 'test_helper'
 
class TestInfoExtraction < Test::Unit::TestCase

	include TestHelper
	include CodeModels

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

	def test_no_extraneous_values
		code = IO.read('test/data/puzzle.html')
		r = Html.parse_code(code)
		r.traverse(:also_foreign) do |node|
			node.collect_values_with_count.each do |value,count|
				node_code = node.source.code
				unless node_code.include?(value.to_s)
					fail("Value '#{value}' expected in #{node}. Artifact: #{node.source.artifact}, abspos: #{node.source.position(:absolute)}, code: '#{node_code}'")
				end
			end
		end
	end

end