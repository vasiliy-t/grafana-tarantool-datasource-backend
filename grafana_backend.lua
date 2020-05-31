local cartridge = require("cartridge")
local icu_date = require("icu-date")
local errors = require("errors")
local err_httpd = errors.new_class("httpd error")

local function init(opts)
    local httpd = cartridge.service_get("httpd")
    if not httpd then
        return nil, err_httpd:new("not initialized")
    end

    -- in case of "browser" access set CORS headers
    httpd:route({path="/query", method="OPTIONS"}, function(req)
            return {
                body = "",
                status = 200,
                headers = {
                    ["Access-Control-Allow-Origin"] = "*", 
                    ["Access-Control-Allow-Methods"] = "*",
                    ["Access-Control-Allow-Headers"] = "*",
                }
            }
        end
    )

    local date, _ = icu_date.new({locale = 'en_US'})
    httpd:route(
        {path = "/query", method="POST"}, 
        function(req)
            local lgi = require("lgi")
            local Arrow = lgi.Arrow
            local payload = req:json()

            local env = {}

            local range = payload.range or {}
            local from = range.from or nil
            local to = range.to or nil

            local from_millis = 0
            if from ~= nil then
                date:parse(icu_date.formats.iso8601(), from)
                from_millis = date:get_millis()
            end
            
            local to_millis = 0
            if to ~= nil then 
                date:parse(icu_date.formats.iso8601(), to)
                to_millis = date:get_millis()
            end

            local targets = payload.targets or {}
            local res = {}
            for _, target in ipairs(targets) do
                local q = target.query
                local refId = target.refId
            
                local env = {
                    req = {
                        from = from_millis,
                        to = to_millis
                    }
                }
                env = setmetatable(env, {__index = _G})
                local ok, builder = pcall(setfenv(loadstring(q), env))
                if ok == false then
                    return {
                        body = require("json").encode(
                            {
                                ["error"] = tostring(builder),
                            }
                        ),
                        status = 400,
                        headers = {
                            ["Content-Type"] = "application/json",
                            ["Access-Control-Allow-Origin"] = "*", 
                            ["Access-Control-Allow-Methods"] = "*",
                            ["Access-Control-Allow-Headers"] = "*",
                        }
                    }
                end
            
                local t = Arrow.Table.new_record_batches(builder:get_schema(), {builder:flush()})
            
                local buffer = Arrow.ResizableBuffer.new(16)
                local output = Arrow.BufferOutputStream.new(buffer)
                local writer = Arrow.RecordBatchFileWriter.new(output, builder:get_schema())
            
                writer:write_table(t)
                writer:close()
                output:close()

                local df = require("digest").base64_encode(
                    buffer:get_data():get_data(), {nopad = true, nowrap = true}
                )
                res[refId] = {
                    ['refId'] = refId,
                    ["dataframes"] = {df},
                }
            end
        
            return {
                body = require("json").encode(
                    {
                        ["results"] = res
                    }
                ),
                status = 200,
                headers = {
                    ["Content-Type"] = "application/json",
                    ["Access-Control-Allow-Origin"] = "*", 
                    ["Access-Control-Allow-Methods"] = "*",
                    ["Access-Control-Allow-Headers"] = "*",
                }
            }
        end
    )

    return true
end

return {
    init = init
}
