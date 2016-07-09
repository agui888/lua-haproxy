local App     = require('haproxy.app')
local stats   = require('haproxy.stats')
local View    = require('haproxy.embed.view')
local jsonify = require('haproxy.embed.jsonify')
local process = require('haproxy.process')

local views   = require('haproxy.apps.stats.views')

local StatsView = View.new('StatsView')

local app = App('stats')

function StatsView:get(request, context)
  return jsonify(context.stats:stats())
end

app:register_init(function()
  core.ctx.stats = stats.Client(process.stats_socket())
end)

app:register_routes({
  ['/']                                         = StatsView.as_view,
  ['/info']                                     = views.InfoView.as_view,
  ['/backends']                                 = views.ProxyView.as_view,
  ['/backends/:backend']                        = views.ProxyView.as_view,
  ['/backends/:backend/servers']                = views.ServerView.as_view,
  ['/backends/:backend/servers/:server']        = views.ServerView.as_view,
  ['/backends/:backend/servers/:server/weight'] = views.ServerWeightView.as_view,
  ['/backends/:backend/servers/:server/state']  = views.ServerStateView.as_view,
  ['/frontends']                                = views.ProxyView.as_view,
  ['/frontends/:frontend']                      = views.ProxyView.as_view,
})

return app
