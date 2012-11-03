
module("quotes", package.seeall)

function get_random_quote(category)

	local res = alpha.db:query([[
		SELECT
			quote
		FROM
			master_quotes
		WHERE
			category = ?
	]], category)

	res = res:fetch()
	
	return res[ math.random( #res ) ].quote
end

function get_quote(category, id)

	local res = alpha.db:query([[
		SELECT
			quote
		FROM
			master_quotes
		WHERE
			id = ?
	]], id)

	res = res:fetch()
	
	if not res or not res[1] or not res[1].quote then
		return "Could not find joke %(1)q :(" % { id }
	end
	
	return res[1].quote
end

function add_quote(category, text)
	return alpha.db:query([[
		INSERT INTO
			master_quotes
			(
				category,
				quote
			)
		VALUES
			(
				?,
				?
			)]], category, text)
end
