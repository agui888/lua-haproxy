--- Stats socket client.
-- @module haproxy.stats
local class   = require('pl.class')
local stringx = require('pl.stringx')
local tablex  = require('pl.tablex')

local core = require('haproxy.core')
local util = require('haproxy.util')

--- HAProxy stats types.
-- These are integer codes used by the stats interface (specifically `show
-- stat`) to represent the source of each datum.
-- @see haproxy 1.6.3: include/proto/dumpstats.h
local stats_types = {
  FRONTEND = 0, -- frontend
  BACKEND  = 1, -- backend
  SERVER   = 2, -- server
  SOCKET   = 3, -- socket
}

--- Parse HAProxy info output to a table.
-- The JSON representation of this table would be a sorted hash.
-- @tparam string data key-value data
-- @tparam[opt=':'] string sep key-value separator
-- @treturn table parsed data
local function parse_info(data, sep)
  local sep = sep or ':'
	local result = {}
  data = stringx.strip(data)
  for line in stringx.lines(data) do
    local k, _, v = stringx.partition(line, sep)
    v = stringx.strip(v)
    if tonumber(v) then
      v = tonumber(v)
    end
    result[k] = v
  end
	return result
end

--- Convert HAProxy stats CSV output to a table.
-- The JSON representation of this table would be an array of hashes.
-- @tparam string csv CSV data
-- @tparam[opt=','] string sep CSV separator
-- @treturn table parsed data
local function parse_stats(csv, sep)
  local results = {}
  local headers, _, data = stringx.partition(csv, '\n')
  local sep = sep or ','
  data = stringx.strip(data)
  headers = stringx.lstrip(headers, '# ')
  headers = stringx.rstrip(headers, sep)
  headers = stringx.split(headers, sep)
  for line in stringx.lines(data) do
    local result = {}
    local fields = stringx.rstrip(line, sep)
    fields = stringx.split(fields, sep)
    for i, field in ipairs(fields) do
      if tonumber(field) then
        field = tonumber(field)
      end
      result[headers[i]] = field
    end
    results[#results+1] = result
  end
  return results
end

--- HAProxy stats socket client
-- @type Client
local Client = class()

--- Create a new HAProxy client.
-- @tparam string address stats interface address
-- @tparam[opt] int stats interface port
-- @tparam[opt] int stats connection timeout in seconds
-- @function Client.new
function Client:_init(address, port, timeout)
  self.address = address or '/run/haproxy/admin.sock'
  self.port    = port or nil
  self.timeout = timeout or 3
end

Client.new = Client

--- Create a new TCP `Socket` instance. If running inside HAProxy, use the
-- LuaSocket-compatible `Socket` class. Otherwise, use LuaSocket.
-- @treturn Socket
-- @see haproxy_lua: `Socket`
-- @see luarock: LuaSocket
function Client.tcp()
  if util.has_function(core, 'tcp') then
    -- running inside HAProxy
    return core.tcp()
  end
  -- running outside HAProxy
  local socket = require('socket')
  return socket.tcp()
end

--- Execute an HAProxy stats command. Used by higher-level methods such as
-- `Client:stats`.
-- @tparam string command command to execute
-- @treturn string string response
function Client:execute(command)
  local socket = self.tcp()
  if self.port then
    socket:connect(self.address, self.port)
  else
    socket:connect(self.address)
  end
  socket:settimeout(self.timeout)
  socket:send(command .. '\n')
  local response = socket:receive('*a')
  socket:close()
  return response
end

--- Returns table of parsed stats results.
-- @see Client:execute
-- @treturn table parsed stats results
function Client:stats()
  return parse_stats(self:execute('show stat'))
end

--- Returns table of parsed HAProxy instance information.
-- @see Client:execute
-- @treturn table parsed HAProxy instance info
function Client:info()
  return parse_info(self:execute('show info'))
end

--- Place `backend/server` in maintenace.
-- @tparam string backend backend name
-- @tparam string server server name
function Client:disable_server(backend, server)
  return self:execute('disable server ' .. backend .. '/' .. server)
end

--- Place `backend/server` in traffic.
-- @tparam string backend backend name
-- @tparam string server server name
function Client:enable_server(backend, server)
  return self:execute('enable server ' .. backend .. '/' .. server)
end

--- Filter stats for all proxies.
-- @tparam int type_ stats type
-- @treturn table
-- @see stats_types
-- @local
function Client:get_proxies(type_)
  return tablex.filter(self:stats(),
                       function(proxy) return proxy.type == type_ end)
end

--- Return a specific proxy.
-- @tparam int type_ stats type
-- @tparam string id_or_name ID or name
-- @treturn table
-- @local
function Client:get_proxy(type_, id_or_name)
  local proxies = self:get_proxies(type_)

  if not id_or_name then
    return proxies
  end

  if tonumber(id_or_name) then
    return tablex.filter(proxies, function(proxy) return proxy.iid == tonumber(id_or_name) end)[1]
  else
    return tablex.filter(proxies, function(proxy) return proxy.pxname == id_or_name end)[1]
  end
end

--- List all backends.
-- @treturn table
function Client:get_backends()
  return self:get_proxies(stats_types.BACKEND)
end

--- List all frontends.
-- @treturn table
function Client:get_frontends()
  return self:get_proxies(stats_types.FRONTEND)
end

--- Show a specific backend.
-- @param id_or_name backend ID or name
-- @treturn table
function Client:get_backend(id_or_name)
  return self:get_proxy(stats_types.BACKEND, id_or_name)
end

--- Retrieve a specific frontend.
-- @param id_or_name frontend ID or name
-- @treturn table
function Client:get_frontend(id_or_name)
  return self:get_proxy(stats_types.FRONTEND, id_or_name)
end

--- Retrieve a specific server.
-- @tparam string backend backend name
-- @param id_or_name integer server ID or string name
-- @treturn table
function Client:get_server(backend, id_or_name)
  local stats = self:stats()
  local backend = self:get_backend(backend)
  if tonumber(id_or_name) then
    return tablex.filter(stats, function(i) return i.iid == backend.iid and i.type == stats_types.SERVER and i.sid == tonumber(id_or_name) end)[1]
  else
    return tablex.filter(stats, function(i) return i.iid == backend.iid and i.type == stats_types.SERVER and i.svname == id_or_name end)[1]
  end
end

--- Retrieve all servers belonging to a backend.
-- @tparam string backend
-- @treturn table
function Client:get_servers(backend)
  local backend = self:get_backend(backend)
  local servers = tablex.filter(
    self:stats(),
    function(i) return i.iid == backend.iid and i.type == stats_types.SERVER end
  )
  return servers
end

--- Retrieve the current and initial server weights.
-- @tparam string backend
-- @tparam string server
-- @treturn table
function Client:get_weight(backend, server)
  local response = self:execute('get weight ' .. backend .. '/' .. server)
  local current, initial = response:match('(%d+) %(initial (%d+)%)')
  return tablex.map(tonumber, { current = current, initial = initial })
end

--- Set a server's weight.
-- @tparam string backend
-- @tparam string server
-- @param weight integer weight (`1`) or string percentage (`100%`)
function Client:set_weight(backend, server, weight)
  self:execute('set weight ' .. backend .. '/' .. server .. ' ' .. weight)
end

--- Retrieve a server's current state.
-- @tparam string backend
-- @tparam string server
-- @treturn table
-- @fixme not implemented
function Client:get_state(backend, server)
  local response = self:execute('show servers state ' .. backend)
  local _, _, data = stringx.partition(response, '\n')
  return parse_stats(data, ' ')
end

-- @section end 

--------------------------------------------------------------------------------
-- public interface
--------------------------------------------------------------------------------

--- @export
return {
  Client      = Client,
  stats_types = stats_types,
  parse_info  = parse_info,
  parse_stats = parse_stats,
}
