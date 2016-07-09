local App      = require('haproxy.app')
local core     = require('haproxy.core')
local process  = require('haproxy.process')
local http     = require('haproxy.embed.http')
local Response = require('haproxy.embed.response')
local View     = require('haproxy.embed.view')

local app = App('config')

local ConfigView = View.new('ConfigView')

function ConfigView:get(request, context)
  return Response(http.status.OK, core.ctx.config, { ['Content-Type'] = 'text/plain', })
end

app:register_init(function()
  core.ctx.config = process.config()
end)

app:register_routes({
  ['/'] = ConfigView.as_view,
})

return app
