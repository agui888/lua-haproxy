local View    = require('server.view')
local jsonify = require('server.jsonify')

local InfoView = View.new('InfoView')

function InfoView:get(request, context)
  return jsonify(context.haproxy:info())
end

return InfoView
