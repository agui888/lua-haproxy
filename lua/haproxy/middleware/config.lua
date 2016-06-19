local process = require('haproxy.process')

local config

core.register_init(function()
  config = process.config()
end)

core.register_service('config', 'http', function(applet)
  applet:set_status(200)
  applet:add_header('Content-Length', string.len(config))
  applet:add_header('Content-Type', 'text/plain')
  applet:start_response()
  applet:send(config)
end)
