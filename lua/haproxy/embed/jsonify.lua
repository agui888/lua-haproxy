--- Embedded HTTP server.
-- @module haproxy.embed

local json = require('dkjson')

local http     = require('haproxy.embed.http')
local Response = require('haproxy.embed.response')

--- Check if `value` is a table.
-- @param value object
-- @treturn bool `true` or `false`
local function is_table(value) return type(value) == 'table' end

--- Build a JSON response.
-- Sets `Content-Type: application/json` and `Content-Length` based on the
-- length of the serialized obj. If `obj` is a table, sorts the keys. 
-- @param obj object to serialize
-- @treturn Response the JSON response
-- @function jsonify
local function jsonify(obj)
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
    ['Content-Type'] = 'application/json',
  }
  return Response(http.status.OK, body, headers)
end

-- @export
return jsonify
