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

--- Return whether a table contains the named function.
-- @tparam table obj to inspect
-- @tparam string method function name to check
-- @treturn boolean
function M.has_function(obj, method)
  return type(obj) == 'table' and obj[method] and type(obj[method]) == 'function'
end

return M
