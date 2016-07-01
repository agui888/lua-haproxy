local util = require('haproxy.util')

local stringx = require('pl.stringx')

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

--- Return list of files used to configure the running process.
-- @treturn table
function M.config_files()
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
  return files
end

--- Return the current loaded configuration. Assembles all configuration files
-- passed on the command line.
-- @treturn string
function M.config()
  local files = M.config_files()
  return util.cat(files)
end

--- Return the current loaded configuration as a walkable table organized by
-- filename.
-- @treturn table
function M.config_lines()
  local results = {}
  local files = M.config_files()
  for _, filename in ipairs(files) do
    local file = util.cat({filename})
    results[filename] = stringx.splitlines(file)
  end
  return results
end

--- Attempt to locate the process's stats socket.
-- @treturn string path to socket
function M.stats_socket()
  local config = M.config()
  return string.match(config, 'stats%s+socket%s+(%S+)')
end

return M
