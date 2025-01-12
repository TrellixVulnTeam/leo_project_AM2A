if not modules then modules = { } end modules ['util-tpl'] = {
    version   = 1.001,
    comment   = "companion to luat-lib.mkiv",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

-- This is experimental code. Coming from dos and windows, I've always used %whatever%
-- as template variables so let's stick to it. After all, it's easy to parse and stands
-- out well. A double %% is turned into a regular %.

utilities.templates = utilities.templates or { }
local templates     = utilities.templates

local trace_template  = false  trackers.register("templates.trace",function(v) trace_template = v end)
local report_template = logs.reporter("template")

local tostring = tostring
local format, sub = string.format, string.sub
local P, C, Cs, Carg, lpegmatch, lpegpatterns = lpeg.P, lpeg.C, lpeg.Cs, lpeg.Carg, lpeg.match, lpeg.patterns

-- todo: make installable template.new

local replacer

local function replacekey(k,t,how,recursive)
    local v = t[k]
    if not v then
        if trace_template then
            report_template("unknown key %a",k)
        end
        return ""
    else
        v = tostring(v)
        if trace_template then
            report_template("setting key %a to value %a",k,v)
        end
        if recursive then
            return lpegmatch(replacer,v,1,t,how,recursive)
        else
            return v
        end
    end
end

local sqlescape = lpeg.replacer {
    { "'",    "''"   },
    { "\\",   "\\\\" },
    { "\r\n", "\\n"  },
    { "\r",   "\\n"  },
 -- { "\t",   "\\t"  },
}

local sqlquoted = lpeg.Cs(lpeg.Cc("'") * sqlescape * lpeg.Cc("'"))

lpegpatterns.sqlescape = sqlescape
lpegpatterns.sqlquoted = sqlquoted

-- escapeset  : \0\1\2\3\4\5\6\7\8\9\10\11\12\13\14\15\16\17\18\19\20\21\22\23\24\25\26\27\28\29\30\31\"\\\127
-- test string: [[1\0\31test23"\\]] .. string.char(19) .. "23"
--
-- slow:
--
-- local luaescape = lpeg.replacer {
--     { '"',  [[\"]]   },
--     { '\\', [[\\]]   },
--     { R("\0\9")   * #R("09"), function(s) return "\\00" .. byte(s) end },
--     { R("\10\31") * #R("09"), function(s) return "\\0"  .. byte(s) end },
--     { R("\0\31")            , function(s) return "\\"   .. byte(s) end },
--     }
--
-- slightly faster:
--
-- local luaescape = Cs ((
--     P('"' ) / [[\"]] +
--     P('\\') / [[\\]] +
--     Cc("\\00") * (R("\0\9")   / byte) * #R("09") +
--     Cc("\\0")  * (R("\10\31") / byte) * #R("09") +
--     Cc("\\")   * (R("\0\31")  / byte)                 +
--     P(1)
-- )^0)

-- local xmlescape = lpegpatterns.xmlescape
-- local texescape = lpegpatterns.texescape
-- local luaescape = lpegpatterns.luaescape
-- local sqlquoted = lpegpatterns.sqlquoted
-- local luaquoted = lpegpatterns.luaquoted

local escapers = {
    lua = function(s)
     -- return sub(format("%q",s),2,-2)
        return lpegmatch(luaescape,s)
    end,
    sql = function(s)
        return lpegmatch(sqlescape,s)
    end,
}

local quotedescapers = {
    lua = function(s)
     -- return lpegmatch(luaquoted,s)
        return format("%q",s)
    end,
    sql = function(s)
        return lpegmatch(sqlquoted,s)
    end,
}

local luaescaper       = escapers.lua
local quotedluaescaper = quotedescapers.lua

local function replacekeyunquoted(s,t,how,recurse) -- ".. \" "
    local escaper = how and escapers[how] or luaescaper
    return escaper(replacekey(s,t,how,recurse))
end

local function replacekeyquoted(s,t,how,recurse) -- ".. \" "
    local escaper = how and quotedescapers[how] or quotedluaescaper
    return escaper(replacekey(s,t,how,recurse))
end

local single      = P("%")  -- test %test% test     : resolves test
local double      = P("%%") -- test 10%% test       : %% becomes %
local lquoted     = P("%[") -- test '%[test]%' test : resolves to test with escaped "'s
local rquoted     = P("]%") --
local lquotedq    = P("%(") -- test %(test)% test   : resolves to 'test' with escaped "'s
local rquotedq    = P(")%") --

local escape      = double   / '%%'
local nosingle    = single   / ''
local nodouble    = double   / ''
local nolquoted   = lquoted  / ''
local norquoted   = rquoted  / ''
local nolquotedq  = lquotedq / ''
local norquotedq  = rquotedq / ''

local key         = nosingle   * ((C((1-nosingle  )^1) * Carg(1) * Carg(2) * Carg(3)) / replacekey        ) * nosingle
local quoted      = nolquotedq * ((C((1-norquotedq)^1) * Carg(1) * Carg(2) * Carg(3)) / replacekeyquoted  ) * norquotedq
local unquoted    = nolquoted  * ((C((1-norquoted )^1) * Carg(1) * Carg(2) * Carg(3)) / replacekeyunquoted) * norquoted
local any         = P(1)

      replacer    = Cs((unquoted + quoted + escape + key + any)^0)

local function replace(str,mapping,how,recurse)
    if mapping and str then
        return lpegmatch(replacer,str,1,mapping,how or "lua",recurse or false) or str
    else
        return str
    end
end

-- print(replace("test '%[x]%' test",{ x = [[a 'x'  a]] }))
-- print(replace("test '%[x]%' test",{ x = true }))
-- print(replace("test '%[x]%' test",{ x = [[a 'x'  a]], y = "oeps" },'sql'))
-- print(replace("test '%[x]%' test",{ x = [[a '%y%'  a]], y = "oeps" },'sql',true))
-- print(replace([[test %[x]% test]],{ x = [[a "x"  a]]}))
-- print(replace([[test %(x)% test]],{ x = [[a "x"  a]]}))

templates.replace = replace

function templates.replacer(str,how,recurse) -- reads nicer
    return function(mapping)
        return lpegmatch(replacer,str,1,mapping,how or "lua",recurse or false) or str
    end
end

-- local cmd = templates.replacer([[foo %bar%]]) print(cmd { bar = "foo" })

function templates.load(filename,mapping,how,recurse)
    local data = io.loaddata(filename) or ""
    if mapping and next(mapping) then
        return replace(data,mapping,how,recurse)
    else
        return data
    end
end

function templates.resolve(t,mapping,how,recurse)
    if not mapping then
        mapping = t
    end
    for k, v in next, t do
        t[k] = replace(v,mapping,how,recurse)
    end
    return t
end

-- inspect(utilities.templates.replace("test %one% test", { one = "%two%", two = "two" }))
-- inspect(utilities.templates.resolve({ one = "%two%", two = "two", three = "%three%" }))
