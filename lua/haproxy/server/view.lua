--- @module server

local class   = require('pl.class')
local stringx = require('pl.stringx')

local Response = require('haproxy.server.response')
local http     = require('haproxy.server.http')

class.View()

function View:dispatch(request, context)
  local method = request.method:lower()
  if self[method] then
    return self[method](self, request, context)
  end
  local methods = stringx.join(', ', self:methods())
  return Response(http.status.METHOD_NOT_ALLOWED, '', { Allow = methods })
end

function View:options(request)
  local methods = stringx.join(', ', self:methods())
  return Response(http.status.NO_CONTENT, '', {
    Allow = methods,
    ['Content-Length'] = 0,
  })
end

function View.new(name)
  local cls = class(View)
  cls._name = name
  cls.as_view = function(request, context) return cls():dispatch(request, context) end
  return cls
end

function View:methods()
  local methods = {}
  for _, method in pairs(http.method) do
    if self[method:lower()] then
      methods[#methods + 1] = method
    end
  end
  table.sort(methods)
  return methods
end

return View
