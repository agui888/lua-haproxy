--- HTTP response
-- @classmod haproxy.server.Response
-- @pragma nostrip

local class  = require('pl.class')
local tablex = require('pl.tablex')

local http = require('haproxy.server.http')

--- A Response represents an API response.
local Response = class()

--- Construct an API response.
-- @tparam[opt=200] int status_code HTTP status code
-- @tparam[opt=''] string body response body
-- @tparam[opt={}] table headers response headers
-- @usage response = Response(http.status.OK, 'Hello world!', {})
-- @function Response.new
-- @see http.status
function Response:_init(status_code, body, headers)
  self.status_code = status_code or http.status.OK
  self.body = body or ''
  local default_headers = { ['Content-Length'] = self.body:len() }
  self.headers = tablex.update(default_headers, headers or {})
end

Response.new = Response

--- Render and serve an API response.
-- @param applet the HAProxy applet context
function Response:render(applet)
  applet:set_status(self.status_code)
  for header, value in pairs(self.headers) do
    applet:add_header(header, value)
  end
	applet:start_response()
	applet:send(self.body)
end

return Response
