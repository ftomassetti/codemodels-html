require 'lightmodels'

module LightModels

module Html

EXTENSION = 'html'

def self.handle_models_in_dir(src,error_handler=nil,model_handler)
	LightModels::ModelBuilding.handle_models_in_dir(src,EXTENSION,error_handler,model_handler) do |src|
		root = parse_file(src)
		LightModels::Serialization.rgenobject_to_model(root)
	end
end

def self.generate_models_in_dir(src,dest,model_ext="#{EXTENSION}.lm",max_nesting=500,error_handler=nil)
	LightModels::ModelBuilding.generate_models_in_dir(src,dest,EXTENSION,model_ext,max_nesting,error_handler) do |src|
		root = parse_file(src)
		LightModels::Serialization.rgenobject_to_model(root)
	end
end

def self.generate_model_per_file(src,dest,model_ext="#{EXTENSION}.lm",max_nesting=500,error_handler=nil)
	LightModels::ModelBuilding.generate_model_per_file(src,dest,max_nesting,error_handler) do |src|
		root = parse_file(src)
		LightModels::Serialization.rgenobject_to_model(root)
	end
end

end

end