--- Service wraps the service configuration and HTTP router.
-- @classmod haproxy.Service
-- @pragma nostrip

local router = require('router')

local class  = require('pl.class')

local pretty = require('pl.pretty')

local Request  = require('haproxy.embed.request')
local Response = require('haproxy.embed.response')
local http     = require('haproxy.embed.http')
local core     = require('haproxy.core')
local util     = require('haproxy.util')

local Service = class()

--- Initialize a new API instance.
-- @tparam table config application configuration
-- @function Service.new
function Service:_init()
  self.router = router.new()
  self.actions = {}
end

Service.new = Service

--- Dispatch a request to the router and return the response.
-- @param request HTTP request
-- @treturn Response the API response
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
-- @tparam ?string prefix prepend routes with given prefix
-- @usage Service:register_routes({ ['/info'] = api_info }, '/api')
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

--- Mount an application.
-- Mounting an application adds its routes to the top-level router.
-- @param app application module
-- @tparam ?string prefix Prepend routes with this prefix.
function Service:mount(app, prefix)
  local prefix = prefix or ''

  if util.has_function(app, 'init') then app.init() end

  local prefixed_routes = {}
  for route, view in pairs(app.routes) do
    prefixed_routes[prefix .. route] = view
  end
  self:register_routes(prefixed_routes)
end

function Service:mount_app(app, prefix)
  for _, action in ipairs(app.actions) do
    -- Prefix action with app namespace.
    action[1] = app.name .. '.' .. action[1]
    core.register_action(table.unpack(action))
  end
end

--- Serve a request.
-- @param applet HAProxy AppletHTTP instance
function Service:serve(applet)
  local request = Request.from_applet(applet)
  local response = self:dispatch(request)
  response:render(applet)
end

return Service
