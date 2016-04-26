--- @module server

local json = require('dkjson')

local http     = require('server.http')
local response = require('server.response')

--- Check if `value` is a table.
-- @param value object
-- @treturn bool `true` or `false`
local function is_table(value) return type(value) == 'table' end

--- Build a JSON response.
-- Sets `Content-Type: application/json` and `Content-Length` based on the
-- length of the serialized obj. If `obj` is a table, sorts the keys. 
-- @param obj object to serialize
-- @treturn Response the JSON response
function jsonify(obj)
  local json_encode_state = {}
  if is_table(obj) then
    local keys = {}
    local n = 0
    for k, _ in pairs(obj) do
      n = n + 1
      keys[n] = k
    end
    table.sort(keys)
    json_encode_state = { keyorder = keys }
  end
  local body = json.encode(obj, json_encode_state)
  local headers = {
    ['Content-Length'] = body:len(),
    ['Content-Type']   = 'application/json',
  }
  local response = Response(http.status.OK, body, headers)
  return response
end

return jsonify
