--- @module server

local json = require('dkjson')

local Set     = require('pl.set')
local class   = require('pl.class')
local stringx = require('pl.stringx')
local tablex  = require('pl.tablex')
local url     = require('pl.url')

local http    = require('server.http')

--- A Request represents an API request.
-- @type Request
class.Request()

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
