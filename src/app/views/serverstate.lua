local http     = require('server.http')
local jsonify  = require('server.jsonify')
local Response = require('server.response')
local View     = require('server.view')

local haproxy  = require('client')

local ServerStateView = View.new('ServerStateView')

function ServerStateView:get(request, context)
  return jsonify(context.haproxy:get_state(request.view_args.backend, request.view_args.server))
end

function ServerStateView:patch(request, context)
  local data = request:json()
  context.haproxy:set_weight(request.view_args.backend, request.view_args.server, data.current)
  return Response(http.status.OK)
end

return ServerStateView
