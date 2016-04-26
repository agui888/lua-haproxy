local View     = require('server.view')
local Response = require('server.response')
local http     = require('server.http')
local jsonify  = require('server.jsonify')

local haproxy  = require('client')

local ProxyView = View.new('ProxyView')

function ProxyView:get(request, context)
  if request.path:find("/backends") then
    if request.view_args.backend then
      return jsonify(context.haproxy:get_backend(request.view_args.backend))
    end
    return jsonify(context.haproxy:get_backends())
  end

  if request.view_args.frontend then
    return jsonify(context.haproxy:get_frontend(request.view_args.frontend))
  end
  return jsonify(context.haproxy:get_frontends())
end

return ProxyView
