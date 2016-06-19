function uname()
  local f = assert(io.popen('uname -s', 'r'))
  local os_name = assert(f:read('*a'))
  f:close()
  return os_name
end

local os_name

core.register_init(function()
  os_name = uname()
end)

core.register_service('uname', 'http', function(applet)
  applet:set_status(200)
  applet:add_header('Content-Length', string.len(os_name))
  applet:add_header('Content-Type', 'text/plain')
  applet:start_response()
  applet:send(os_name)
end)
