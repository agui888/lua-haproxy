--- Simple class-based views.
-- @classmod haproxy.server.View

local class   = require('pl.class')
local stringx = require('pl.stringx')

local Response = require('haproxy.server.response')
local http     = require('haproxy.server.http')

local View = class()

--- Dispatch a request to the method handler.
-- @tparam haproxy.server.Request request
-- @tparam table context request context (i.e., shared state)
-- @treturn haproxy.server.Response
-- @see haproxy.core.ctx
function View:dispatch(request, context)
  local method = request.method:lower()
  if self[method] then
    return self[method](self, request, context)
  end
  local methods = stringx.join(', ', self:methods())
  return Response(http.status.METHOD_NOT_ALLOWED, '', { Allow = methods })
end

--- Default handler for OPTIONS requests.
-- Returns HTTP 204 No Content and a list of allowed methods.
-- @tparam haproxy.server.Request request
-- @treturn haproxy.server.Response
function View:options(request)
  local methods = stringx.join(', ', self:methods())
  return Response(http.status.NO_CONTENT, '', {
    Allow = methods,
  })
end

--- Create a new named View (i.e., subclass of View).
-- @tparam string name
-- @treturn haproxy.server.View
function View.new(name)
  local cls = class(View)
  cls._name = name
  cls.as_view = function(request, context) return cls():dispatch(request, context) end
  return cls
end

--- Initialize and immediately dispatch the view.
-- Useful for assigning a class-based view to a route.
--
-- **NOTE:** This is a class method, not an instance method. It does not take an
-- implicit self argument.
-- @function as_view
-- @tparam haproxy.server.Request request
-- @tparam table context request context (i.e., shared state)
-- @treturn haproxy.server.Response
-- @see haproxy.core.ctx
-- @todo Customize LDoc to mark this as a class method.
-- @usage response = MyView.as_view(request, context)

--- Return list of methods handled by the view.
-- @treturn table list of available methods
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
