local View    = require('haproxy.embed.view')
local jsonify = require('haproxy.embed.jsonify')

local InfoView = View.new('InfoView')

function InfoView:get(request, context)
  return jsonify(context.stats:info())
end

return InfoView
