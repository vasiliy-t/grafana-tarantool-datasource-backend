local t = require('luatest')
local g = t.group('integration_api')

local helper = require('test.helper.integration')
local cluster = helper.cluster

g.test_empty_query_returns_200_ok = function()
    local server = cluster.main_server
    local response = server:http_request('post', '/query', {json = {query = '{}'}})
end
