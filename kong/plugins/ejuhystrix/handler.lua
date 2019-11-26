---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by wuxin.
--- DateTime: 2019-11-14 18:12
---

local cjson = require "cjson.safe"
-- local cjson = require "cjson"

local kong = kong


local ejuhystrix = {}
ejuhystrix.VERSION = "1.0"



function ejuhystrix:header_filter(conf)
    -- response code
    local respStatus = ngx.status
    if respStatus < conf.skipFilterWhenLess then
       return
    end
    -- 清空header中的content-length

    ngx.header.content_length=nil
    ngx.header.content_type = "application/json; charset=utf-8"

end



function ejuhystrix:body_filter(conf)

   -- response code
    local respStatus = ngx.status
    if respStatus < conf.skipFilterWhenLess then
        return
    end

    local result = [[{"code":-1}]]
    local errMapStr = conf.response
    local errMap,decodeErr = cjson.decode(errMapStr)
    if  decodeErr then
        -- 解析出错
        kong.log.err("解析配置出错：",errMapStr, " 错误信息：", decodeErr )
    else
        local resultJson = errMap[tostring(respStatus)] or errMap["-1"]
        result = cjson.encode(resultJson)
    end


    ngx.arg[1] = result

    -- nginx内容是流式，多次输出，输出一次调用一次; 如果是错误，则结束流
     ngx.arg[2] = true

     kong.log.err("response status is  ", ngx.status, " replace to : " ,ngx.arg[1] )

end

return ejuhystrix