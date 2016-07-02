local core     = require('haproxy.core')
local process  = require('haproxy.process')
local http     = require('haproxy.embed.http')
local Response = require('haproxy.embed.response')
local View     = require('haproxy.embed.view')

local ConfigView = View.new('ConfigView')

function ConfigView:get(request, context)
  return Response(http.status.OK, core.ctx.config, { ['Content-Type'] = 'text/plain', })
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
