local http     = require('haproxy.server.http')
local jsonify  = require('haproxy.server.jsonify')
local Response = require('haproxy.server.response')
local View     = require('haproxy.server.view')
local stats    = require('haproxy.stats')

local ServerView = View.new('ServerView')

function ServerView:get(request, context)
  if request.view_args.server then
    return jsonify(context.stats:get_server(request.view_args.backend, request.view_args.server))
  end
  return jsonify(context.stats:get_servers(request.view_args.backend))
end

function ServerView:patch(request, context)
  local data = request:json()
  local backend = context.stats:get_backend(request.view_args.backend)
  if data.status == ('DOWN' or 'MAINT') then
    context.stats:disable_server(backend.pxname, request.view_args.server)
  elseif data.status == 'UP' then
    context.stats:enable_server(backend.pxname, request.view_args.server)
  else
    return Response(http.status.BAD_REQUEST)
  end
  return Response(http.status.OK)
end

return ServerView
