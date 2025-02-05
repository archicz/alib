json = {}

function json.EncodeValue(value)
	local function IsInteger(value)
		return type(value) == "number" and (value % 1) == 0
	end

	if type(value) == "string" then
		return '"' .. value:gsub('"', '\\"') .. '"'
	elseif IsInteger(value) then
		return tostring(value)
	elseif type(value) == "number" then
		return string.format("%.10g", value)
	elseif type(value) == "table" then
		return json.EncodeTable(value)
	elseif type(value) == "boolean" then
		return value and "true" or "false"
	elseif value == nil then
		return "null"
	else
		error("Unsupported data type: " .. type(value))
	end
end

function json.EncodeTable(tbl)
	local isArray = #tbl > 0
	local result = {}

	if isArray then
		for _, v in ipairs(tbl) do
			table.insert(result, json.EncodeValue(v))
		end

		return "[" .. table.concat(result, ",") .. "]"
	else
		for k, v in pairs(tbl) do
			table.insert(result, '"' .. tostring(k) .. '":' .. json.EncodeValue(v))
		end

		return "{" .. table.concat(result, ",") .. "}"
	end
end

function json.Encode(tbl)
	return json.EncodeTable(tbl)
end