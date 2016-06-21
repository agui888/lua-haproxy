local class    = require('pl.class')
local plconfig = require('pl.config')
local tablex   = require('pl.tablex')

--- `Config` represents the application configuration.
-- `Config` is a simple table wrapper that provides sensible defaults and
-- methods to load configuration from multiple sources.
-- @type Config
local Config = class()

--- Default application configuration.
Config.defaults = {
  stats_socket         = '/run/haproxy/admin.sock', -- path to stats socket (`/run/haproxy/admin.sock`)
  stats_socket_timeout = 3,                         -- seconds to timeout stats connections (`3`)
}

--- Initialize a new configuration.
-- If `config` is not set, initialize a new configuration using
-- `Config.defaults`.
-- @tparam[opt] table config
-- @see Config.defaults
-- @function Config.new
function Config:_init(config)
  self._config = config or tablex.copy(self.defaults)
end

Config.new = Config

--- Load application configuration from environment variables.
-- Environment variables take the form `HAPROXY_API_<OPTION>`, e.g.,
-- `HAPROXY_API_STATS_SOCKET`.
function Config:from_env()
  for k, v in pairs(self.defaults) do
    local envvar = os.getenv('HAPROXY_API_' .. k:upper())
    if envvar then
      self:set(k, envvar)
    end
  end
end

--- Load application configuration from `filename`.
-- @tparam string filename path to configuration file
function Config:from_file(filename)
  local user_config = plconfig.read(filename) or {}
  tablex.merge(self.defaults, user_config, true)
  for k, v in pairs(user_config) do
    self:set(k, v)
  end
end

--- Retrieve a configuration item.
-- @tparam string name option name
-- @return configuration item
function Config:get(name)
  return self._config[name]
end

--- Set a configuration item.
-- @tparam string name option name
-- @param value option value
function Config:set(name, value)
  self._config[name] = value
end

return Config
