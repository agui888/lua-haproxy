local http     = require('haproxy.server.http')
local jsonify  = require('haproxy.server.jsonify')
local Response = require('haproxy.server.response')
local View     = require('haproxy.server.view')
local stats    = require('haproxy.stats')

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
