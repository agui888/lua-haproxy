--- HTTP request
-- @classmod haproxy.server.Request
-- @pragma nostrip

local json = require('dkjson')

local Set     = require('pl.set')
local class   = require('pl.class')
local stringx = require('pl.stringx')
local tablex  = require('pl.tablex')
local url     = require('pl.url')

local http    = require('haproxy.server.http')

--- A Request represents an API request.
local Request = class()

function Request:_init(request)
  local fields = Set{
    'method',
    'path',
    'data',
    'headers',
    'args',
    'form',
    'view_args',
  }
  for k, v in pairs(request) do
    if fields[k] then
      self[k] = v
    end
  end
end

--- Parse request query string.
-- @tparam string qs query string
-- @treturn table parsed results
function Request.parse_query_string(qs)
  local result = {}
  if not qs then
    return result
  end
  local args = stringx.split(url.unquote(qs), '&')
  for _, pair in pairs(args) do
    local k, _, v = stringx.partition(pair, '=')
    result[k] = v
  end
  return result
end

--- Construct a Request from an AppletHTTP instance.
-- @tparam AppletHTTP applet
-- @treturn Request
function Request.from_applet(applet)
  local unsafe_methods = Set{http.method.PATCH, http.method.POST, http.method.PUT}
  local request = Request{
    method  = applet.method,
    path    = applet.path,
    headers = applet.headers,
    args    = Request.parse_query_string(applet.qs),
  }
  if unsafe_methods[applet.method] then
    request.data = applet:receive()
  end
  return request
end

--- Decode JSON data in request body.
-- @tparam ?bool force Decode request data as JSON regardless of Content-Type.
-- @treturn table decoded data
function Request:json(force)
  -- Because headers can have multiple values, HAProxy provides values as a
  -- 0-indexed array.
  if tablex.find(self.headers['content-type'], 'application/json', 0) or force then
    return json.decode(self.data)
  end
  return nil
end

Request.new = Request

return Request
