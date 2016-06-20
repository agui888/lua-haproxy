local process = require('haproxy.process')

local M = {}

function M.init(ctx)
  core.ctx.config = process.config()
end

function M.service(applet)
  applet:set_status(200)
  applet:add_header('Content-Length', string.len(core.ctx.config))
  applet:add_header('Content-Type', 'text/plain')
  applet:start_response()
  applet:send(core.ctx.config)
end

return M
