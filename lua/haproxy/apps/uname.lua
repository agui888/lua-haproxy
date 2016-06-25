local core     = require('haproxy.core')
local util     = require('haproxy.util')

local Response = require('haproxy.server.response')
local View     = require('haproxy.server.view')

local UnameView = View.new('UnameView')

function UnameView:get(request, context)
  return Response(200, core.ctx.uname)
end

local function init()
  core.ctx.uname = util.uname()
end

return {
  init   = init,
  routes = {
    ['/'] = UnameView.as_view,
  }
}