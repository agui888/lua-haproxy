local config = require('haproxy.middleware.config')
local uname = require('haproxy.middleware.uname')

-- Shared state between middleware.
core.ctx = {}

function init()
  config.init()
  uname.init()
end

function register_services()
  core.register_service('config', 'http', config.service)
  core.register_service('uname', 'http', uname.service)
end

core.register_init(init)
register_services()
