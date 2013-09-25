require 'lightmodels'

module LightModels
module Html

class HtmlLanguage < Language
	def initialize
		super('Html')
		@extensions << 'html'
		@parser = LightModels::Html::Parser.new
	end
end

LANGUAGE = HtmlLanguage.new
LightModels.register_language LANGUAGE

end
end