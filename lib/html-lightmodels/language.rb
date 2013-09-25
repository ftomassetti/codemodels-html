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

end
end

puts "invoking register language..."
LightModels.register_language(LightModels::Html::LANGUAGE)