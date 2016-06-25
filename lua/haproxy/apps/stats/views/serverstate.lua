local http     = require('haproxy.embed.http')
local jsonify  = require('haproxy.embed.jsonify')
local Response = require('haproxy.embed.response')
local View     = require('haproxy.embed.view')

local ServerStateView = View.new('ServerStateView')

function ServerStateView:get(request, context)
  return jsonify(context.stats:get_state(request.view_args.backend, request.view_args.server))
end

function ServerStateView:patch(request, context)
  local data = request:json()
  context.stats:set_weight(request.view_args.backend, request.view_args.server, data.current)
  return Response(http.status.OK)
end

return ServerStateView
