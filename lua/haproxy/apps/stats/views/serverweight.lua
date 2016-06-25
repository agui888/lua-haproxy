local http     = require('haproxy.embed.http')
local jsonify  = require('haproxy.embed.jsonify')
local Response = require('haproxy.embed.response')
local View     = require('haproxy.embed.view')

local ServerWeightView = View.new('ServerWeightView')

function ServerWeightView:get(request, context)
  return jsonify(context.stats:get_weight(request.view_args.backend, request.view_args.server))
end

function ServerWeightView:patch(request, context)
  local data = request:json()
  context.stats:set_weight(request.view_args.backend, request.view_args.server, data.current)
  return Response(http.status.OK)
end

return ServerWeightView
