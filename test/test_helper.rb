require 'html-lightmodels'

module TestHelper

require 'lightmodels'

include LightModels

def assert_metamodel(name,attrs,refs)
	assert Html.const_defined?(name), "Metaclass '#{name}' not found"
	c = Html.const_get name

	assert_all_attrs attrs, c
	assert_all_refs  refs, c	
	c
end

def assert_class(expected_class,node)
	assert node.class==expected_class, "Node expected to have class #{expected_class} instead it has class #{node.class}"
end

def relative_path(path)
	File.join(File.dirname(__FILE__),path)
end

def assert_all_attrs(expected,c)
	actual = c.ecore.eAllAttributes
	assert_equal expected.count,actual.count,"Expected #{expected.count} attrs, found #{actual.count}. They are #{actual.name}"
	expected.each do |e|
		assert actual.find {|a| a.name==e}, "Attribute #{e} not found"	
	end
end

def assert_all_refs(expected,c)
	actual = c.ecore.eAllReferences
	assert_equal expected.count,actual.count,"Expected #{expected.count} refs, found #{actual.count}. They are #{actual.name}"
	expected.each do |e|
		assert actual.find {|a| a.name==e}, "Reference #{e} not found"	
	end
end

def assert_ref(c,name,type,many=false)
	ref = c.ecore.eAllReferences.find {|r| r.name==name}
	assert ref, "Reference '#{name}' not found"	
	assert_equal type.ecore.name,ref.eType.name
	assert_equal many, ref.many
end

def assert_attr(c,name,type,many=false)
	att = c.ecore.eAllAttributes.find {|a| a.name==name}	
	assert_equal type.name,att.eType.name
	assert_equal many, att.many
end

def assert_map(exp,map)
	assert_equal exp.count,map.count, "Expected to have keys: #{exp.keys}, it has #{map}"
	exp.each do |k,v|
		assert_equal exp[k],map[k], "Expected #{k} to have #{exp[k]} instances, it has #{map[k.to_s]}. Map: #{map}"
	end
end

def assert_code_map_to(code,exp)
	r = Html.parse_code(code)
	#ser = LightModels::Serialization.jsonize_obj(r)
	#puts "Code <<<#{code}>>> -> #{JSON.pretty_generate(ser)}"
	map = r.values_map
	assert_map(exp,map)
end

end