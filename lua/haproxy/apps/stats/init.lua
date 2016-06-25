local stats   = require('haproxy.stats')
local View    = require('haproxy.embed.view')
local jsonify = require('haproxy.embed.jsonify')

local views   = require('haproxy.apps.stats.views')

local StatsView = View.new('StatsView')

local function init()
  core.ctx.stats = stats.Client('/tmp/haproxy.sock')
end

function StatsView:get(request, context)
  return jsonify(context.stats:stats())
end

return {
  init = init,
  routes = {
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
  }
}
