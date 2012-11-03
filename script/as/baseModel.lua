module("as.baseModel", package.seeall)

BaseModel = newclass("BaseModel")

function BaseModel:getName()
	error("table name not set!")
end

function BaseModel.model()
	return BaseModel()
end

function BaseModel:instantiate(properties)
	local class = self.model()
	
	for name, value in pairs(properties) do
		class[name] = value
	end
	
	return class
end

function BaseModel:instantiateAll(rows)
	local result = {}
	
	for i, row in ipairs(rows) do
		result[i] = self:instantiate(row)
	end
	
	return result
end

function BaseModel:findAllByAttributes(attr)
	return self:instantiateAll(
		as.database.findAllByAttributes(self, attr)
	)
end

function BaseModel:findByAttributes(attr)
	return self:findAllByAttributes(attr)[1]
end

function BaseModel:findByID(id)
	return self:findByAttributes( {id=id})
end

