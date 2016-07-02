local class  = require('pl.class')

--- Inspect the parent HAProxy process.
--- @module haproxy.process
local M = {}

M.Config = class.new()

function M.Config:_init(files)
  self.config = {}
  for _, file in ipairs(files) do
    local fragment = { file = file, lines = {}, }
    for line in io.lines(file) do
      fragment.lines[#fragment.lines+1] = line
    end
    self.config[#self.config+1] = fragment
  end
end

function M.Config:__tostring()
  local lines = {}
  for _, fragment in ipairs(self.config) do
    for _, line in ipairs(fragment.lines) do
      lines[#lines+1] = line
    end
  end
  return table.concat(lines, '\n')
end

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
-- @treturn process.Config
function M.config()
  local files = M.config_files()
  return M.Config(files)
end

--- Attempt to locate the process's stats socket.
-- @treturn string path to socket
function M.stats_socket()
  local config = M.config()
  return string.match(tostring(config), 'stats%s+socket%s+(%S+)')
end

return M
