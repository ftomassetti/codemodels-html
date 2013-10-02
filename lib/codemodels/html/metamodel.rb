require 'rgen/metamodel_builder'
require 'codemodels'

module CodeModels
module Html

class HtmlNode < CodeModels::CodeModelsAstNode
end

class Attribute < HtmlNode
	has_attr 'name', String
	has_attr 'value', String
end

class Element < HtmlNode
end

class Node < Element
	has_attr 'name', String
	contains_many_uni 'attributes', Attribute
	contains_many_uni 'children', Element
end

class Text < Element
	has_attr 'value', String
end

class Document < HtmlNode
	contains_many_uni 'children', Element
end

class HtmlDocument < Document
end

class XmlDocument < Document
end

class DTD < Element
	has_attr 'name', String
end

class Script < Node	
end

#CodeModels.enable_foreign_asts(Script)

end
end