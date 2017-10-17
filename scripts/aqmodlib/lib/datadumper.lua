--[[
rewrite of DataDumper.lua (http://lua-users.org/wiki/DataDumper)
to make it store ASCII-compatible strings (special characters are being
escaped properly and such)

There are a few changes:

  + 'fastmode' removed. It seemed unnecessary, and fastmode
    sometimes yielded ambigious data, so better remove it.
    try not to fix a broken car when you can buy yourself a
    brandnew mercedes

  + serialized strings (including stuff yielded by string.dump) now
    contains escaped special characters. that makes it possible to
    save the data in a plaintext file, and actually share it without
    having to worry about encoding too much.
    (one of my favourite pet peeves with the original datadumper)

  + new function argument 'ignore_undumpable'.
    using this function will make datadumper continue dumping
    even when it finds non-dumpable data, such as userdata, C-functions,
    etc. In place of the serialized data, it will show up
    as '<errormessage>', such as "{foo='<cannot dump given function>'}".
    Using this mode is __NOT__ recommended in production code;
    It's merely here to be able to inspect large tables (such as _G).

    NOTE: using 'ignore_undumpable' __WILL__ result in errornous
    Lua syntax if a non-dumpable value was encountered.
    Use this mode at your own risk!


  + major syntactical rewrite. let's not fool anyone, the old version
    was as readable as a pool of mud



All these additions make it possible to use this version of
DataDumper as a data serialization utility!

-----------------------------------------------------
Same license as the original version, etc blahblahblah
Just use it :-)

Copyright (c) 2007 Olivetti-Engineering SA

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
]]

-- FG: adapted for use in Aquaria

local dumplua_closure = [[
    local closures = {}
    local function closure(t)
        closures[#closures+1] = t
        t[1] = assert(loadstring(t[1]))
        return t[1]
    end

    for _,t in pairs(closures) do
        for i=2, #t do
            debug.setupvalue(t[1], i-1, t[i])
        end
    end
]]

local lua_reserved_keywords = {
    'and',    'break',  'do',
    'else',   'elseif', 'end',
    'false',  'for',    'function',
    'if',     'in',     'local',
    'nil',    'not',    'or',
    'repeat', 'return', 'then',
    'true',   'until',  'while',
}

local c_functions = {}
local _globals = {
    '_G',        'string',  'table',
    'math'--[[,      'io',      'os',
    'coroutine', 'package', 'debug',]]
}

for _,lib in pairs(_globals) do
    local t = _G[lib] or {}
    lib = lib .. "."
    if lib == "_G." then lib = "" end
    for k,v in pairs(t) do
        if type(v) == 'function' and not pcall(string.dump, v) then
            c_functions[v] = lib .. k
        end
    end
end

local function keys(t)
    local res = {}
    local oktypes = {
        stringstring = true,
        numbernumber = true,
    }
    local function cmpfct(a,b)
        if oktypes[type(a)..type(b)] then
            return a < b
        else
            return type(a) < type(b)
        end
    end
    for k in pairs(t) do
        res[#res+1] = k
    end
    table.sort(res, cmpfct)
    return res
end

local DD = {}

function DD.dump(value, ignore_undumpable, varname, ident)
    local defined, dumplua = {}
    -- Local variables for speed optimization
    local string_format, type, string_dump, string_rep =
          string.format, type, string.dump, string.rep
    local tostring, pairs, table_concat =
          tostring, pairs, table.concat
    local keycache, strvalcache, out, closure_cnt = {}, {}, {}, 0
    setmetatable(strvalcache, {
        __index = function(t,value)
            local res = string_format('%q', value)
            t[value] = res
            return res
        end
    })
    local fcts = {}
    fcts['string'] =
        function(value)
            local ord = function(_c)
                return tonumber(string.byte(_c))
            end
            local in_ch = function(_c, _chars)
                local r = false
                for _, _ch in pairs(_chars) do
                    if _c == _ch then
                        return true
                    end
                end
                return false
            end
            local s = ""
            string.gsub(value, ".", function(c)
                local byte = string.byte(c)
                local valid = in_ch(c, {
                    [[.]], -- a dot
                    [[']], -- a single quote
                    [[ ]], -- space
                    [[/]], -- a slash
                    [[-]], -- a dash
                    [[=]], -- equal sign
                })
                if byte and ((byte >= 48) and (byte <= 122)) or valid then
                    s = s .. c
                else
                    local fmt = string_format("\\%d", byte)
                    s = s .. fmt
                end
            end)
            return string_format([["%s"]], s)
        end

    fcts['number'] =
        function(value)
            return value
        end

    fcts['boolean'] =
        function(value)
            return tostring(value)
        end

    fcts['nil'] =
        function(value)
            return 'nil'
        end

    fcts['function'] =
        function(value)
            local ret = ""
            -- string.dump will croak if the function
            -- is defined natively, so pcall this shit
            local ok, dumped = pcall(string.dump, value)
            if ok then
                ret = fcts.string(dumped)
                return string.format([[loadstring(%s)]], ret)
            else
                return string.format("<%s>", dumped);
            end
        end

    fcts['table'] =
        function(value, ident, path)
            local function test_defined(value, path)
                if defined[value] then
                    if path:match("^getmetatable.*%)$") then
                        out[#out+1] = string_format("s%s, %s)\n",
                                            path:sub(2,-2),
                                            defined[value])
                    else
                        out[#out+1] = path .. " = " .. defined[value] .. "\n"
                    end
                    return true
                end
                defined[value] = path
            end
            if test_defined(value, path) then
                return "nil"
            end
            -- Table value
            local sep, str, numidx, totallen = " ", {}, 1, 0
            local meta, metastr = getfenv().getmetatable(value) --[[(debug or getfenv()).getmetatable(value)]]
            if meta then
                ident = ident + 1
                metastr = dumplua(meta, ident, "getmetatable("..path..")")
                totallen = totallen + #metastr + 16
            end
            for _, key in pairs(keys(value)) do
                local val = value[key]
                local s = ""
                local subpath = path
                if key == numidx then
                    subpath = tostring(subpath) .. "[" .. numidx .. "]"
                    numidx = numidx + 1
                else
                    s = keycache[key]
                    if not s:match "^%[" then
                        subpath = subpath .. "."
                    end
                    subpath = subpath .. s:gsub("%s*=%s*$","")
                end
                s = s .. dumplua(val, ident+1, subpath)
                str[#str+1] = s
                totallen = totallen + #s + 2
            end
            if totallen > 80 then
                sep = "\n" .. string_rep("  ", ident+1)
            end
            str = "{" .. sep ..
                    table_concat(str, ","..sep) .. " " ..
                    sep:sub(1,-3) .. "}"
            if meta then
                sep = sep:sub(1,-3)
                return "setmetatable(" .. sep .. str ..
                       "," .. sep .. metastr .. sep:sub(1,-3)..")"
            end
            return str
        end

    fcts['userdata'] =
        function(value)
            if ignore_undumpable then
                return string.format("<%s>", tostring(value))
            else
                error("Cannot dump userdata")
            end
        end

    fcts['thread'] =
        function()
            if ignore_undumpable then
                return string.format("<%p>", value)
            else
                error("Cannot dump threads")
            end
        end

    local function make_key(t, key)
        local s
        if type(key) == 'string' and key:match('^[_%a][_%w]*$') then
            s = key .. "="
        else
            s = "[" .. dumplua(key, 0) .. "]="
        end
        t[key] = s
        return s
    end

    for _, k in ipairs(lua_reserved_keywords) do
        keycache[k] = '["'..k..'"] = '
    end

    function dumplua(value, ident, path)
        return fcts[type(value)](value, ident, path)
    end

    if varname == nil then
        varname = "return "
    elseif varname:match("^[%a_][%w_]*$") then
        varname = varname .. " = "
    end
    setmetatable(keycache, {__index = make_key })
    local items = {}
    for i=1,10 do
        items[i] = ''
    end
    items[3] = dumplua(value, ident or 0, "t")
    if closure_cnt > 0 then
        items[1], items[6] = dumplua_closure:match("(.*\n)\n(.*)")
        out[#out+1] = ""
    end
    if #out > 0 then
        items[2], items[4] = "local t = ", "\n"
        items[5] = table.concat(out)
        items[7] = varname .. "t"
    else
        items[2] = varname
    end
    return table.concat(items)
end

function DD.restore(s)
    return loadstring(s)()
end

return DD
