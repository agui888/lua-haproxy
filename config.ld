-- vim: set ft=lua: --
project = 'lua-haproxy'
description = 'lua-haproxy 0.1.0'
title = 'lua-haproxy documentation'
style = '!fixed'
use_markdown_titles = true
format = 'markdown'
unqualified = true
file = 'lua/'
sort = true
merge = true

custom_see_handler('^luarock: (.*)$', function(rock)
  local url = ('https://luarocks.org/modules/luarocks/%s'):format(rock)
  return rock, url
end)

custom_see_handler('^haproxy_lua: (.*)$', function(text)
  local api_url = 'http://www.arpalert.org/src/haproxy-lua-api/1.6/#%s'
  local anchor = text:gsub('`', '')
  local text = text:gsub('`', '<code>', 1)
  local text = text:gsub('`', '</code>', 1)
  local link = '<em>How Lua runs in HAProxy</em>: ' .. text
  local url = api_url:format(anchor)
  return link, url
end)

custom_see_handler('^haproxy (%d%.%d%.%d): (.*)$', function(version, filename)
  local haproxy_gitweb = 'http://git.haproxy.org/?p=%s;a=blob;f=%s;hb=v%s'
  local repo = 'haproxy-' .. version:match('^(%d%.%d)') .. '.git'
  local url = haproxy_gitweb:format(repo, filename, version)
  local link = 'HAProxy ' .. version .. ' source: <code>' .. filename .. '</code>'
  return link, url
end)
