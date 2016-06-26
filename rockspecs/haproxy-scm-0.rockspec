package = 'haproxy'
version = 'scm-0'
source = {
  url = 'https://github.com/benwebber/lua-haproxy/',
}
description = {
  summary  = 'High-level Lua client for HAProxy',
  homepage = 'https://github.com/benwebber/lua-haproxy/',
  license  = 'MIT',
}
dependencies = {
  'dkjson',
  'router',
  'lua >= 5.3',
  'penlight >= 1.3',
}
build = {
  type = 'builtin',
  modules = {
    ['haproxy']                               = 'lua/haproxy/init.lua',
    ['haproxy.apps.config']                   = 'lua/haproxy/apps/config.lua',
    ['haproxy.apps.stats']                    = 'lua/haproxy/apps/stats/init.lua',
    ['haproxy.apps.stats.views']              = 'lua/haproxy/apps/stats/views/init.lua',
    ['haproxy.apps.stats.views.info']         = 'lua/haproxy/apps/stats/views/info.lua',
    ['haproxy.apps.stats.views.proxy']        = 'lua/haproxy/apps/stats/views/proxy.lua',
    ['haproxy.apps.stats.views.server']       = 'lua/haproxy/apps/stats/views/server.lua',
    ['haproxy.apps.stats.views.serverstate']  = 'lua/haproxy/apps/stats/views/serverstate.lua',
    ['haproxy.apps.stats.views.serverweight'] = 'lua/haproxy/apps/stats/views/serverweight.lua',
    ['haproxy.core']                          = 'lua/haproxy/core.lua',
    ['haproxy.embed.http']                    = 'lua/haproxy/embed/http.lua',
    ['haproxy.embed.jsonify']                 = 'lua/haproxy/embed/jsonify.lua',
    ['haproxy.embed.request']                 = 'lua/haproxy/embed/request.lua',
    ['haproxy.embed.response']                = 'lua/haproxy/embed/response.lua',
    ['haproxy.embed.view']                    = 'lua/haproxy/embed/view.lua',
    ['haproxy.process']                       = 'lua/haproxy/process.lua',
    ['haproxy.service']                       = 'lua/haproxy/service.lua',
    ['haproxy.stats']                         = 'lua/haproxy/stats.lua',
    ['haproxy.util']                          = 'lua/haproxy/util.lua',
  },
  install = {
    bin = {
      ['lua-haproxy-api'] = 'lua/main.lua',
    },
  },
  copy_directories = {
    'doc',
    'spec',
  },
}
