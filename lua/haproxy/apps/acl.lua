local core = require('haproxy.core')

local pretty = require('pl.pretty')
local inspect = require('inspect')

local stats = require('haproxy.stats')
local util  = require('haproxy.util')

local function test_headers(acl, method, txn)
  local headers = txn.http:req_get_headers()
  for name, values in pairs(headers) do
    for _, value in pairs(values) do
      if value == txn.f[method](txn.f, table.unpack(acl.args)) then
        local check = acl:match(value)
        if check:find('match=yes') then
          local data = txn:get_priv() or {}
          data[#data+1] = acl
          txn:set_priv(data)
        end
      end
    end
  end
end

local function test_method(acl, method, txn)
  local fetch = txn.f[method](txn.f, table.unpack(acl.args))
  local check = acl:match(fetch)
  if check:find('match=yes') then
    local data = txn:get_priv() or {}
    data[#data+1] = acl
    txn:set_priv(data)
  end
end

local function action(txn)
  -- Construct ACLs.
  local data = core.ctx.stats:execute('show acl')
  core.ctx.acls = stats.parse_acls(data)
  -- Attempt to match request against ACLs.
  for _, acl in ipairs(core.ctx.acls) do
    -- Convert dot notation methods to fetch names.
    local method = acl.method:gsub('%.', '_')
    if util.has_function(txn.f, method) then

      -- Match header ACLs.
      if method:match('hdr') then
        test_headers(acl, method, txn)
      else
        test_method(acl, method, txn)
      end

    else
      txn:Warning('cannot match ACL method \'' .. method .. '\' to internal fetch method')
    end
  end
  for _, acl in ipairs(txn:get_priv()) do
    txn:Info('request matched ' .. tostring(acl))
  end
end

return {
  action = action,
}
