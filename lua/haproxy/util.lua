local M = {}

function M.uname()
  local f = assert(io.popen('uname -s', 'r'))
  local os_name = assert(f:read('*a'))
  f:close()
  return os_name
end

function M.has_function(obj, method)
  return type(obj) == 'table' and obj[method] and type(obj[method]) == 'function'
end

return M
