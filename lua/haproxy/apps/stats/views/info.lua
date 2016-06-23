local View    = require('haproxy.server.view')
local jsonify = require('haproxy.server.jsonify')

local InfoView = View.new('InfoView')

function InfoView:get(request, context)
  return jsonify(context.stats:info())
end

return InfoView
