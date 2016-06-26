local core     = require('haproxy.core')
local util     = require('haproxy.util')

local http     = require('haproxy.embed.http')
local Response = require('haproxy.embed.response')
local View     = require('haproxy.embed.view')

local UnameView = View.new('UnameView')

function UnameView:get(request, context)
  return Response(http.status.OK, core.ctx.uname, { ['Content-Type'] = 'text/plain', })
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
