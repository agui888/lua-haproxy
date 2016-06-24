--- @module app

local router = require('router')

local class  = require('pl.class')

local Request  = require('haproxy.server.request')
local Response = require('haproxy.server.response')
local http     = require('haproxy.server.http')
local core     = require('haproxy.core')
local util     = require('haproxy.util')

--- Service wraps the service configuration and HTTP router.
-- HAProxy initializes an instance of this class on startup.
-- @type Service
local Service = class()

--- Initialize a new API instance.
-- @tparam table config application configuration
-- @function Service.new
-- @see init
function Service:_init()
  self.router = router.new()
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
  return view(request, core.ctx)
end

--- Register routes.
-- @tparam table routes routes to register
-- @usage Service:register_routes({ ['/info'] = get_info })
function Service:register_routes(routes, prefix)
  local prefix = prefix or ''
  -- We defer method handling to views. Configure the router to send all methods
  -- to each view.
  local matches = {}
  for _, method in pairs(http.method) do
    matches[method] = {}
    for url, view in pairs(routes) do
      matches[method][prefix .. url] = view
    end
  end
  self.router:match(matches)
end

function Service:mount(app, prefix)
  local prefix = prefix or ''

  if util.has_function(app, 'init') then app.init() end

  local prefixed_routes = {}
  for route, view in pairs(app.routes) do
    prefixed_routes[prefix .. route] = view
  end
  self:register_routes(prefixed_routes)
end

function Service:serve(applet)
  local request = Request.from_applet(applet)
  local response = self:dispatch(request)
  response:render(applet)
end

return Service
