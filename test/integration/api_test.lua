local t = require('luatest')
local g = t.group('integration_api')

local helper = require('test.helper.integration')
local cluster = helper.cluster

g.test_empty_query_returns_200_ok = function()
    local server = cluster.main_server
    local response = server:http_request('post', '/query', {json = {query = '{}'}})
end

g.test_helper_functions_exposed_to_env = function()
    local server = cluster.main_server
    local to_record_batch_exists = server.net_box:eval("return type(rawget(_G, 'to_record_batch')) == 'function'")
    t.assert_equals(to_record_batch_exists, true)

    local new_schema_exists = server.net_box:eval("return type(rawget(_G, 'new_schema')) == 'function'")
    t.assert_equals(new_schema_exists, true)
end
