--- @module server

local class = require('pl.class')

local http = require('haproxy.server.http')

--- A Response represents an API response.
-- @type Response
class.Response()

--- Construct an API response.
-- @tparam[opt=200] int status_code HTTP status code
-- @tparam[opt=''] string body response body
-- @tparam[opt={}] table headers response headers
-- @usage response = Response(HTTP_STATUS.OK, 'Hello world!', {})
-- @function Response.new
-- @see HTTP_STATUS
function Response:_init(status_code, body, headers)
  self.status_code = status_code or http.status.OK
  self.body = body or ''
  self.headers = headers or { ['Content-Length'] = self.body:len(), }
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
