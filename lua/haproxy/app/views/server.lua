local http     = require('server.http')
local jsonify  = require('server.jsonify')
local Response = require('server.response')
local View     = require('server.view')

local haproxy  = require('client')

local ServerView = View.new('ServerView')

function ServerView:get(request, context)
  if request.view_args.server then
    return jsonify(context.haproxy:get_server(request.view_args.backend, request.view_args.server))
  end
  return jsonify(context.haproxy:get_servers(request.view_args.backend))
end

function ServerView:patch(request, context)
  local data = request:json()
  local backend = context.haproxy:get_backend(request.view_args.backend)
  if data.status == ('DOWN' or 'MAINT') then
    context.haproxy:disable_server(backend.pxname, request.view_args.server)
  elseif data.status == 'UP' then
    context.haproxy:enable_server(backend.pxname, request.view_args.server)
  else
    return Response(http.status.BAD_REQUEST)
  end
  return Response(http.status.OK)
end

return ServerView
