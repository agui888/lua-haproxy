local App      = require('haproxy.app')
local core     = require('haproxy.core')
local util     = require('haproxy.util')

local http     = require('haproxy.embed.http')
local Response = require('haproxy.embed.response')
local View     = require('haproxy.embed.view')

local app = App('uname')

local UnameView = View.new('UnameView')

function UnameView:get(request, context)
  return Response(http.status.OK, core.ctx.uname, { ['Content-Type'] = 'text/plain', })
end

app:register_init(function()
  core.ctx.uname = util.uname()
end)

app:register_routes({
  ['/'] = UnameView.as_view,
})

return app
