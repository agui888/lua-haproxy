--- Somewhat RESTful API for HAProxy.
-- @script lua-haproxy-api
-- @usage
-- global
--   stats socket /run/haproxy/admin.sock mode 660 level admin
--   lua-load /etc/haproxy/lua-haproxy-api.lua
--
-- frontend example
--   http-request use-service lua.haproxy-api
local core    = require('haproxy.core')

local Service = require('haproxy.service')
local config  = require('haproxy.apps.config')
local stats   = require('haproxy.apps.stats')
local uname   = require('haproxy.apps.uname')
local acl     = require('haproxy.apps.acl')

-- declared here to satisfy strict mode
local service = Service()

service:mount(acl)

--- Initialize the service.
-- Load the API configuration and routing table.
-- HAProxy executes this function once on startup.
-- @usage core.register_init(init)
local function init()
  service:mount(config, '/config')
  service:mount(stats, '/stats')
  service:mount(uname, '/uname')
end

--- The main service entry point.
-- @param applet HAProxy applet context
-- @usage core.register_service('haproxy-api', 'http', main)
local function main(applet)
  service:serve(applet)
end

core.register_init(init)
core.register_service('haproxy-api', 'http', main)
