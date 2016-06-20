local M = {}

function M.uname()
  local f = assert(io.popen('uname -s', 'r'))
  local os_name = assert(f:read('*a'))
  f:close()
  return os_name
end

return M
