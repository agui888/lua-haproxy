--- Somewhat RESTful API for HAProxy.
-- @script haproxy-api
-- @usage
-- global
--   stats socket /run/haproxy/admin.sock mode 660 level admin
--   lua-load /etc/haproxy/haproxy-api.lua
--
-- frontend example
--   http-request use-service lua.haproxy-api
local core    = require('haproxy.core')

local Request = require('haproxy.server.request')
local http    = require('haproxy.server.http')
local Service = require('haproxy.service')
local views   = require('haproxy.apps.views')
local config  = require('haproxy.middleware.config')
local uname   = require('haproxy.middleware.uname')

-- declared here to satisfy strict mode
local service

--- Initialize the service.
-- Load the API configuration and routing table.
-- HAProxy executes this function once on startup.
-- @usage core.register_init(init)
function init()
  config.init()
  uname.init()

  service = Service()
  service:register_routes({
    ['/config']                                   = views.ConfigView.as_view,
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
    ['/uname']                                    = views.UnameView.as_view,
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
