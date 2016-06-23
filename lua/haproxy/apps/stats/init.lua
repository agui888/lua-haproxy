local View    = require('haproxy.server.view')
local jsonify = require('haproxy.server.jsonify')

local views   = require('haproxy.apps.stats.views')

local StatsView = View.new('StatsView')

function StatsView:get(request, context)
  return jsonify(context.stats:stats())
end

return {
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
