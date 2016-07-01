--- Utilities used by other modules.
--- @module haproxy.util
local M = {}

--- Calls uname to return the current operating system.
-- @treturn string
function M.uname()
  local f = assert(io.popen('uname -s', 'r'))
  local os_name = assert(f:read('*a'))
  f:close()
  return os_name
end

--- Concatenate multiple files.
-- @tparam table files
-- @treturn string
function M.cat(files)
  local config = ''
  for _, file in ipairs(files) do
    local f = assert(io.open(file, 'r'))
    config = config .. f:read('*a')
    f:close()
  end
  return config
end

--- Return whether a table contains the named function.
-- @tparam table obj to inspect
-- @tparam string method function name to check
-- @treturn boolean
function M.has_function(obj, method)
  return type(obj) == 'table' and obj[method] and type(obj[method]) == 'function'
end

return M
