local View    = require('haproxy.server.view')
local jsonify = require('haproxy.server.jsonify')

local StatsView = View.new('StatsView')

function StatsView:get(request, context)
  return jsonify(context.stats:stats())
end

return StatsView
