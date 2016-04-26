--- Somewhat RESTful API for HAProxy.
-- @script haproxy-api
-- @usage
-- global
--   stats socket /run/haproxy/admin.sock mode 660 level admin
--   lua-load /etc/haproxy/haproxy-api.lua
--
-- frontend example
--   http-request use-service lua.haproxy-api

local Request  = require('server.request')
local http     = require('server.http')

local Config  = require('app.config')
local Service = require('app.service')
local views   = require('app.views')


-- declared here to satisfy strict mode
local service

--- Initialize the service.
-- Load the API configuration and routing table.
-- HAProxy executes this function once on startup.
-- @usage core.register_init(init)
function init()
  local config = Config()
  config:from_file(os.getenv('HAPROXY_API_CONFIG') or 'haproxy-api.ini')
  -- Override with environment variables.
  config:from_env()
  service = Service(config)
  service:register_routes({
    ['/info']                                     = views.InfoView.as_view,
    ['/stats']                                    = views.StatsView.as_view,
    ['/backends']                                 = views.ProxyView.as_view,
    ['/backends/:backend']                        = views.ProxyView.as_view,
    ['/backends/:backend/servers']                = views.ServerView.as_view,
    ['/backends/:backend/servers/:server']        = views.ServerView.as_view,
    ['/backends/:backend/servers/:server/weight'] = views.ServerWeightView.as_view,
    ['/backends/:backend/servers/:server/state']  = views.ServerStateView.as_view,
    ['/frontends']                                = views.ProxyView.as_view,
    ['/frontends/:frontend']                      = views.ProxyView.as_view,
  })
end

--- The main service entry point.
-- @param applet HAProxy applet context
-- @usage core.register_service('haproxy-api', 'http', main)
function main(applet)
  service:serve(applet)
end

core.register_init(init)
core.register_service('haproxy-api', 'http', main)
