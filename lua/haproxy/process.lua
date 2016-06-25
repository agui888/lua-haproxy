--- Inspect the parent HAProxy process.
--- @module haproxy.process
local M = {}

--- Return the command line used to invoke HAProxy.
-- @treturn string
function M.cmdline()
  local f = assert(io.open('/proc/self/cmdline', 'rb'))
  local s = f:read('*a')
  f:close()
  return s
end

--- Return the current loaded configuration. Assembles all configuration files
-- passed on the command line.
-- @treturn string
function M.config()
  local cmdline = M.cmdline()
  local files = {}
  local previous
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

return M
