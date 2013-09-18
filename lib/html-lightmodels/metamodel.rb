require 'rgen/metamodel_builder'
require 'lightmodels'

module LightModels

module Html

class Attribute < RGen::MetamodelBuilder::MMBase
	has_attr 'name', String
	has_attr 'value', String
end

class Element < RGen::MetamodelBuilder::MMBase
end

class Node < Element
	has_attr 'name', String
	contains_many_uni 'attributes', Attribute
	contains_many_uni 'children', Element
end

class Text < Element
	has_attr 'value', String
end

class Document < RGen::MetamodelBuilder::MMBase
	contains_many_uni 'children', Element
end

class DTD < Element
	has_attr 'name', String
end

end

end