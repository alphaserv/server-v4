module("as.models", package.seeall)

Name = as.baseModel.BaseModel:subclass("Name")

function Name:getName()
	return "name"
end

function Name.model()
	return Name()
end
