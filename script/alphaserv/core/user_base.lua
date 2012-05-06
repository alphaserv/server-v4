module("alpha.user", package.seeall)

user_base_obj = class.new(nil, {

	--[[!
		Property: user_id
		The id of the authenticated user in the database, -1 if not authenticated
	]]
	user_id = -1,
	
	__init = function() end,
	
	--[[!
		Function: auth
		Authenticate the user and set the <user_id>.
		
		Parameters:
			self -
			user_id - the user id
	]]
	
	auth = function(self, user_id)
		self.user_id = user_id
	end,
	
	--[[!
		Function: has_permission
		Check if the user has the permission to execute a specific action
		
		Parameters:
			self -
			name - name of the object
			id - the additional object_id or -1

		Return:
			true - Has access
			false - Deny
	]]
	has_permission = function(self, name, id)
		return true
	end,

	--[[!
		Function: comparepassword
		compares the passwords
		
		Parameters:
			self -
			password1 - the password entered by the user
			password2 - the password from, the database?
	]]
	
	comparepassword = function(self, pass1, pass2)
		return pass1 == pass2
	end,

})
