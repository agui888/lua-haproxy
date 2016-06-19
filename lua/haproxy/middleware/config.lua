function get_cmdline()
  local f = assert(io.open('/proc/self/cmdline', 'rb'))
  local s = f:read('*a')
  f:close()
  return s
end

function get_config()
  local cmdline = get_cmdline()
  local files = {}
  local token, previous
  local remainder = false
  for token in string.gmatch(cmdline, '%g+') do
    -- -- signifies that the remaining arguments are configuration files.
    if token == '--' then
      remainder = true
    elseif previous == '-f' or remainder then
      files[#files+1] = token
    end
    previous = token
  end
  local config = ''
  for _, file in ipairs(files) do
    local f = assert(io.open(file, 'r'))
    config = config .. f:read('*a')
    f:close()
  end
  return config
end

local config

core.register_init(function()
  config = get_config()
end)

core.register_service('config', 'http', function(applet)
  applet:set_status(200)
  applet:add_header('Content-Length', string.len(config))
  applet:add_header('Content-Type', 'text/plain')
  applet:start_response()
  applet:send(config)
end)
