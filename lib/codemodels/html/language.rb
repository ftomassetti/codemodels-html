require 'codemodels'

module CodeModels
module Html

class HtmlLanguage < Language
	def initialize
		super('Html')
		@extensions << 'html'
		@parser = CodeModels::Html::Parser.new
	end
end

LANGUAGE = HtmlLanguage.new
CodeModels.register_language LANGUAGE

end
end