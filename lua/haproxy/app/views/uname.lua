local Response = require('haproxy.server.response')
local View     = require('haproxy.server.view')

local UnameView = View.new('UnameView')

function UnameView:get(request, context)
  return Response(200, core.ctx.uname)
end

return UnameView
