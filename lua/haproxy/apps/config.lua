local core     = require('haproxy.core')
local process  = require('haproxy.process')
local Response = require('haproxy.server.response')
local View     = require('haproxy.server.view')

local ConfigView = View.new('ConfigView')

function ConfigView:get(request, context)
  return Response(200, core.ctx.config)
end

local function init()
  core.ctx.config = process.config()
end

return {
  init   = init,
  routes = {
    ['/'] = ConfigView.as_view,
  }
}