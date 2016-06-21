--- @module app

local router = require('router')

local class  = require('pl.class')
local tablex = require('pl.tablex')

local Response = require('haproxy.server.response')
local http     = require('haproxy.server.http')
local stats    = require('haproxy.stats')

--- Service wraps the service configuration and HTTP router.
-- HAProxy initializes an instance of this class on startup.
-- @type Service
local Service = class()

--- Initialize a new API instance.
-- @tparam table config application configuration
-- @usage service = Service({ stats_socket = '/run/haproxy.sock' })
-- @function Service.new
-- @see init
function Service:_init(config)
  self.router = router.new()
  self.config = config
  self.stats  = stats.Client(self.config:get('stats_socket'))
end

Service.new = Service

--- Dispatch a request to the router and return the response.
-- @tparam string method HTTP method
-- @tparam string path URL path
-- @treturn Response the API response
-- @usage response = service:dispatch('GET', '/info')
function Service:dispatch(request)
  local view, view_args = self.router:resolve(request.method, request.path)
  -- unknown method
  if view == nil then
    return Response(http.status.NOT_IMPLEMENTED)
  -- unknown route
  elseif not view then
    return Response(http.status.NOT_FOUND)
  end
  request.view_args = view_args
  return view(request, self)
end

--- Register routes.
-- @tparam table routes routes to register
-- @usage Service:register_routes({ ['/info'] = get_info })
function Service:register_routes(routes)
  -- We defer method handling to views. Configure the router to send all methods
  -- to each view.
  local matches = {}
  for _, method in pairs(http.method) do
    matches[method] = {}
    for url, view in pairs(routes) do
      matches[method][url] = view
    end
  end
  self.router:match(matches)
end

function Service:serve(applet)
  local request = Request.from_applet(applet)
  local response = self:dispatch(request)
  response:render(applet)
end

return Service
