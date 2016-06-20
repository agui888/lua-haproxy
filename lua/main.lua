local config = require('haproxy.middleware.config')
local uname = require('haproxy.middleware.uname')

-- amalg: start
--
-- Problem: amalg executes a script (`lua -l amalg`) to identify its
-- dependencies However, HAProxy API functions are only available in an HAProxy
-- execution context.
--
-- Solution: stub a `core` table to satisfy execution at build time. The table's
-- metatable will provide anonymous functions to satisfy calls like
-- `core.register_service()`.
--
-- This block will be removed from the amalgamated output.
core = {}
setmetatable(core, { __index = function() return function() return end end })
-- amalg: end

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
