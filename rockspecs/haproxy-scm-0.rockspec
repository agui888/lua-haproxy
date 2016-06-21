package = 'haproxy'
version = 'scm-0'
source = {
  url = 'https://github.com/benwebber/haproxy.lua/',
}
description = {
  summary  = 'High-level Lua client for HAProxy',
  homepage = 'https://github.com/benwebber/haproxy.lua/',
  license  = 'MIT',
}
dependencies = {
  'lua >= 5.2',
  'penlight >= 1.3',
}
build = {
  type = 'builtin',
  modules = {
    ['haproxy']                   = 'lua/haproxy/init.lua',
    ['haproxy.middleware.config'] = 'lua/haproxy/middleware/config.lua',
    ['haproxy.middleware.uname']  = 'lua/haproxy/middleware/uname.lua',
    ['haproxy.process']           = 'lua/haproxy/process.lua',
    ['haproxy.stats']             = 'lua/haproxy/stats.lua',
  },
  copy_directories = {
    'doc',
    'spec',
  },
}
