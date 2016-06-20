local _core = core or {}

-- Shared state between middleware.
_core.ctx = {}

-- amalg: start
--
-- Problem: amalg executes a script (`lua -l amalg`) to identify its
-- dependencies However, HAProxy API functions are only available in an HAProxy
-- execution context.
--
-- Solution: stub a `core` table to satisfy execution at build time. The table's
-- metatable will provide anonymous functions to satisfy calls like
-- `core.register_service()`.
--
-- This block will be removed from the amalgamated output.
setmetatable(_core, { __index = function() return function() return end end })
-- amalg: end
return _core
