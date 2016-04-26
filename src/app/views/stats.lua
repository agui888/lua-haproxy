local View    = require('server.view')
local jsonify = require('server.jsonify')

local StatsView = View.new('StatsView')

function StatsView:get(request, context)
  return jsonify(context.haproxy:stats())
end

return StatsView
