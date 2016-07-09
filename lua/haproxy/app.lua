local class = require('pl.class')

local App = class.new()

App.new = App

function App:_init(name)
  self.name         = name
  self.actions      = {}
  self.converters   = {}
  self.fetches      = {}
  self.init         = nil
  self.services     = {}
  self.tasks        = {}
  self.routes       = {}
end

function App:register_action(name, actions, func)
  self.actions[#self.actions + 1] = { name, actions, func }
end

function App:register_converter(f)
  self.converters[#self.converters + 1] = f
end

function App:register_fetch(f)
  self.fetches[#self.fetches + 1] = f
end

function App:register_init(f)
  self.init = f
end

function App:register_service(f)
  self.services[#self.services + 1] = f
end

function App:register_task(f)
  self.tasks[#self.tasks + 1] = f
end

function App:register_routes(routes)
  self.routes = routes
end

return App
