module("as.models", package.seeall)

User = as.baseModel.BaseModel:subclass("User")

function User:findByName(name)
	local name = Name():findByAttributes({name = name})

	if name == nil then
		return nil
	end
	
	return self:findById(name.user_id)
end

function User:getName()
	return "user"
end

function User.model()
	return User()
end
