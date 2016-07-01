local util = require('haproxy.util')

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
  return util.cat(files)
end

--- Attempt to locate the process's stats socket.
-- @treturn string path to socket
function M.stats_socket()
  local config = M.config()
  return string.match(config, 'stats%s+socket%s+(%S+)')
end

return M
