--- Extends HAProxy core API.
--- @module haproxy.core
local core = _G['core'] or {}

--- Use `core.ctx` to share state between apps.
core.ctx = {}

-- Problem: amalg executes a script (`lua -l amalg`) to identify its
-- dependencies However, HAProxy API functions are only available in an HAProxy
-- execution context.
--
-- Solution: stub a `core` table to satisfy execution at build time. The table's
-- metatable will provide anonymous functions to satisfy calls like
-- `core.register_service()`.
if package.loaded['amalg'] then
  setmetatable(core, { __index = function() return function() return end end })
end

return core
