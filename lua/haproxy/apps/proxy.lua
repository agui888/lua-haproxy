local View     = require('haproxy.server.view')
local Response = require('haproxy.server.response')
local http     = require('haproxy.server.http')
local jsonify  = require('haproxy.server.jsonify')
local stats    = require('haproxy.stats')

local ProxyView = View.new('ProxyView')

function ProxyView:get(request, context)
  if request.path:find("/backends") then
    if request.view_args.backend then
      return jsonify(context.stats:get_backend(request.view_args.backend))
    end
    return jsonify(context.stats:get_backends())
  end

  if request.view_args.frontend then
    return jsonify(context.stats:get_frontend(request.view_args.frontend))
  end
  return jsonify(context.stats:get_frontends())
end

return ProxyView
