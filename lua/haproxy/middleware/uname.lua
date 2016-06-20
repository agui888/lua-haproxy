local core = require('haproxy.core')
local util = require('haproxy.util')

local M = {}

function M.init()
  core.ctx.uname = util.uname()
end

function M.service(applet)
  applet:set_status(200)
  applet:add_header('Content-Length', string.len(core.ctx.uname))
  applet:add_header('Content-Type', 'text/plain')
  applet:start_response()
  applet:send(core.ctx.uname)
end

return M
