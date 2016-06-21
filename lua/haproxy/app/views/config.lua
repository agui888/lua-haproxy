local Response = require('haproxy.server.response')
local View     = require('haproxy.server.view')

local ConfigView = View.new('ConfigView')

function ConfigView:get(request, context)
  return Response(200, core.ctx.config)
end

return ConfigView
