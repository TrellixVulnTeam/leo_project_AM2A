-- 
--  This is file `luamplib.lua',
--  generated with the docstrip utility.
-- 
--  The original source files were:
-- 
--  luamplib.dtx  (with options: `lua')
--  
--  See source file 'luamplib.dtx' for licencing and contact information.
--  

luamplib          = luamplib or { }


local luamplib    = luamplib
luamplib.showlog  = luamplib.showlog or false
luamplib.lastlog  = ""

local err, warn, info, log = luatexbase.provides_module({
    name          = "luamplib",
    version       =  2.11,
    date          = "2013/12/23",
    description   = "Lua package to typeset Metapost with LuaTeX's MPLib.",
})


local format, abs = string.format, math.abs

local stringgsub    = string.gsub
local stringfind    = string.find
local stringmatch   = string.match
local stringgmatch  = string.gmatch
local tableconcat   = table.concat
local texsprint     = tex.sprint

local mplib = require ('mplib')
local kpse  = require ('kpse')

local file = file
if not file then


  file = { }

  function file.replacesuffix(filename, suffix)
      return (stringgsub(filename,"%.[%a%d]+$","")) .. "." .. suffix
  end

  function file.stripsuffix(filename)
      return (stringgsub(filename,"%.[%a%d]+$",""))
  end
end

local mpkpse = kpse.new("luatex", "mpost")

local function finder(name, mode, ftype)
    if mode == "w" then
        return name
    else
        return mpkpse:find_file(name,ftype)
    end
end
luamplib.finder = finder


function luamplib.resetlastlog()
    luamplib.lastlog = ""
end

local mplibone = tonumber(mplib.version()) <= 1.50

if mplibone then

    luamplib.make = luamplib.make or function(name,mem_name,dump)
        local t = os.clock()
        local mpx = mplib.new {
            ini_version = true,
            find_file = luamplib.finder,
            job_name = file.stripsuffix(name)
        }
        mpx:execute(format("input %s ;",name))
        if dump then
            mpx:execute("dump ;")
            info("format %s made and dumped for %s in %0.3f seconds",mem_name,name,os.clock()-t)
        else
            info("%s read in %0.3f seconds",name,os.clock()-t)
        end
        return mpx
    end

    function luamplib.load(name)
        local mem_name = file.replacesuffix(name,"mem")
        local mpx = mplib.new {
            ini_version = false,
            mem_name = mem_name,
            find_file = luamplib.finder
        }
        if not mpx and type(luamplib.make) == "function" then
            -- when i have time i'll locate the format and dump
            mpx = luamplib.make(name,mem_name)
        end
        if mpx then
            info("using format %s",mem_name,false)
            return mpx, nil
        else
            return nil, { status = 99, error = "out of memory or invalid format" }
        end
    end

else


    local preamble = [[
        boolean mplib ; mplib := true ;
        let dump = endinput ;
        let normalfontsize = fontsize;
        input %s ;
    ]]

    luamplib.make = luamplib.make or function()
    end

    function luamplib.load(name)
        local mpx = mplib.new {
            ini_version = true,
            find_file = luamplib.finder,
        }
        local result
        if not mpx then
            result = { status = 99, error = "out of memory"}
        else
            result = mpx:execute(format(preamble, file.replacesuffix(name,"mp")))
        end
        luamplib.reporterror(result)
        return mpx, result
    end

end

local currentformat = "plain"

local function setformat (name) --- used in .sty
    currentformat = name
end
luamplib.setformat = setformat

luamplib.reporterror = function (result)
    if not result then
        err("no result object returned")
    elseif result.status > 0 then
        local t, e, l = result.term, result.error, result.log
        if t then
            info(t)
        end
        if e then
            err(e)
        end
        if not t and not e and l then
            luamplib.lastlog = luamplib.lastlog .. "\n " .. l
            log(l)
        else
            err("unknown, no error, terminal or log messages")
        end
    else
        return false
    end
    return true
end

local function process_indeed (mpx, data)
    local converted, result = false, {}
    local mpx = luamplib.load(mpx)
    if mpx and data then
        local result = mpx:execute(data)
        if not result then
            err("no result object returned")
        elseif result.status > 0 then
            err("%s",(result.term or "no-term") .. "\n" .. (result.error or "no-error"))
        elseif luamplib.showlog then
            luamplib.lastlog = luamplib.lastlog .. "\n" .. result.term
            info("%s",result.term or "no-term")
        elseif result.fig then
            converted = luamplib.convert(result)
        else
            err("unknown error, maybe no beginfig/endfig")
        end
    else
        err("Mem file unloadable. Maybe generated with a different version of mplib?")
    end
    return converted, result
end
local process = function (data)
    return process_indeed(currentformat, data)
end
luamplib.process = process

local function getobjects(result,figure,f)
    return figure:objects()
end

local function convert(result, flusher)
    luamplib.flush(result, flusher)
    return true -- done
end
luamplib.convert = convert

local function pdf_startfigure(n,llx,lly,urx,ury)
    texsprint(format("\\mplibstarttoPDF{%f}{%f}{%f}{%f}",llx,lly,urx,ury))
end

local function pdf_stopfigure()
    texsprint("\\mplibstoptoPDF")
end

local function pdf_literalcode(fmt,...) -- table
    texsprint(format("\\mplibtoPDF{%s}",format(fmt,...)))
end
luamplib.pdf_literalcode = pdf_literalcode

local function pdf_textfigure(font,size,text,width,height,depth)
    -- if text == "" then text = "\0" end -- char(0) has gone
    text = text:gsub(".",function(c)
        return format("\\hbox{\\char%i}",string.byte(c)) -- kerning happens in metapost
    end)
    texsprint(format("\\mplibtextext{%s}{%f}{%s}{%s}{%f}",font,size,text,0,-( 7200/ 7227)/65536*depth))
end
luamplib.pdf_textfigure = pdf_textfigure

local bend_tolerance = 131/65536

local rx, sx, sy, ry, tx, ty, divider = 1, 0, 0, 1, 0, 0, 1

local function pen_characteristics(object)
    local t = mplib.pen_info(object)
    rx, ry, sx, sy, tx, ty = t.rx, t.ry, t.sx, t.sy, t.tx, t.ty
    divider = sx*sy - rx*ry
    return not (sx==1 and rx==0 and ry==0 and sy==1 and tx==0 and ty==0), t.width
end

local function concat(px, py) -- no tx, ty here
    return (sy*px-ry*py)/divider,(sx*py-rx*px)/divider
end

local function curved(ith,pth)
    local d = pth.left_x - ith.right_x
    if abs(ith.right_x - ith.x_coord - d) <= bend_tolerance and abs(pth.x_coord - pth.left_x - d) <= bend_tolerance then
        d = pth.left_y - ith.right_y
        if abs(ith.right_y - ith.y_coord - d) <= bend_tolerance and abs(pth.y_coord - pth.left_y - d) <= bend_tolerance then
            return false
        end
    end
    return true
end

local function flushnormalpath(path,open)
    local pth, ith
    for i=1,#path do
        pth = path[i]
        if not ith then
            pdf_literalcode("%f %f m",pth.x_coord,pth.y_coord)
        elseif curved(ith,pth) then
            pdf_literalcode("%f %f %f %f %f %f c",ith.right_x,ith.right_y,pth.left_x,pth.left_y,pth.x_coord,pth.y_coord)
        else
            pdf_literalcode("%f %f l",pth.x_coord,pth.y_coord)
        end
        ith = pth
    end
    if not open then
        local one = path[1]
        if curved(pth,one) then
            pdf_literalcode("%f %f %f %f %f %f c",pth.right_x,pth.right_y,one.left_x,one.left_y,one.x_coord,one.y_coord )
        else
            pdf_literalcode("%f %f l",one.x_coord,one.y_coord)
        end
    elseif #path == 1 then
        -- special case .. draw point
        local one = path[1]
        pdf_literalcode("%f %f l",one.x_coord,one.y_coord)
    end
    return t
end

local function flushconcatpath(path,open)
    pdf_literalcode("%f %f %f %f %f %f cm", sx, rx, ry, sy, tx ,ty)
    local pth, ith
    for i=1,#path do
        pth = path[i]
        if not ith then
           pdf_literalcode("%f %f m",concat(pth.x_coord,pth.y_coord))
        elseif curved(ith,pth) then
            local a, b = concat(ith.right_x,ith.right_y)
            local c, d = concat(pth.left_x,pth.left_y)
            pdf_literalcode("%f %f %f %f %f %f c",a,b,c,d,concat(pth.x_coord, pth.y_coord))
        else
           pdf_literalcode("%f %f l",concat(pth.x_coord, pth.y_coord))
        end
        ith = pth
    end
    if not open then
        local one = path[1]
        if curved(pth,one) then
            local a, b = concat(pth.right_x,pth.right_y)
            local c, d = concat(one.left_x,one.left_y)
            pdf_literalcode("%f %f %f %f %f %f c",a,b,c,d,concat(one.x_coord, one.y_coord))
        else
            pdf_literalcode("%f %f l",concat(one.x_coord,one.y_coord))
        end
    elseif #path == 1 then
        -- special case .. draw point
        local one = path[1]
        pdf_literalcode("%f %f l",concat(one.x_coord,one.y_coord))
    end
    return t
end


local mplibcodepreamble = [[
vardef rawtextext (expr t) =
    if unknown TEXBOX_:
        image( special "%%mkTEXbox:"&t; )
    else:
        TEXBOX_ := TEXBOX_ + 1;
        image (
            addto currentpicture doublepath unitsquare
            xscaled TEXBOX_wd[TEXBOX_]
            yscaled (TEXBOX_ht[TEXBOX_] + TEXBOX_dp[TEXBOX_])
            shifted (0, -TEXBOX_dp[TEXBOX_])
            withprescript "%%TEXtxtbox:" &
                          decimal TEXBOX_ & ":" &
                          decimal TEXBOX_wd[TEXBOX_] & ":" &
                          decimal(TEXBOX_ht[TEXBOX_]+TEXBOX_dp[TEXBOX_]);
        )
    fi
enddef;
if known context_mlib:
    defaultfont := "cmtt10";
    let infont = normalinfont;
    let fontsize = normalfontsize;
    vardef thelabel@#(expr p,z) =
        if string p :
            thelabel@#(p infont defaultfont scaled defaultscale,z)
        else :
            p shifted (z + labeloffset*mfun_laboff@# -
                (mfun_labxf@#*lrcorner p + mfun_labyf@#*ulcorner p +
                (1-mfun_labxf@#-mfun_labyf@#)*llcorner p))
        fi
    enddef;
else:
    vardef textext@# (text t) = rawtextext (t) enddef;
fi
def externalfigure primary filename =
    draw rawtextext("\includegraphics{"& filename &"}")
enddef;
def TEX = textext enddef;
def VerbatimTeX (text t) =
    if known TEXBOX_: message "verbatimtex '"& t &"' is ignored"; fi
enddef;
def fontmapfile primary filename = enddef;
]]

local factor = 65536*(7227/7200)

local function putTEXboxes (object)
    local n,tw,th = stringmatch(object.prescript,
                                "%%%%TEXtxtbox:(%d+):([%d%.%+%-]+):([%d%.%+%-]+)")
    if n and tw and th then
        local op = object.path
        local first, second, fourth = op[1], op[2], op[4]
        local tx, ty = first.x_coord, first.y_coord
        local sx, sy = (second.x_coord - tx)/tw, (fourth.y_coord - ty)/th
        local rx, ry = (second.y_coord - ty)/tw, (fourth.x_coord - tx)/th
        if sx == 0 then sx = 0.00001 end
        if sy == 0 then sy = 0.00001 end
        local cs = object.color
        if cs and #cs > 0 then
            pdf_literalcode(luamplib.colorconverter(cs))
        end
        pdf_literalcode("q %f %f %f %f %f %f cm",sx,rx,ry,sy,tx,ty)
        texsprint(format("\\mplibputtextbox{%i}",n))
        pdf_literalcode("Q")
    end
end

local function domakeTEXboxes (data)
    local num = tex.count[14] -- newbox register
    if data and data.fig then
        local figures = data.fig
        for f=1, #figures do
            local figure = figures[f]
            local objects = getobjects(data,figure,f)
            if objects then
                for o=1,#objects do
                    local object    = objects[o]
                    local prescript = object.prescript
                    local str = prescript and stringmatch(prescript, "%%%%mkTEXbox:(.*)")
                    if str then
                        num = num + 1
                        texsprint(format("\\setbox%i\\hbox{%s}",num,str))
                    end
                end
            end
        end
    end
end

local function makeTEXboxes (data)
    data = stringgsub(data, "([^A-Z_a-z])btex([^A-Z_a-z])",
    function(pre,post)
        post = stringgsub(post,"%s","")
        return pre .. 'textext("' .. post
    end)
    data = stringgsub(data, "([^A-Z_a-z])verbatimtex([^A-Z_a-z])",
    function(pre,post)
        post = stringgsub(post,"%s","")
        return pre .. 'VerbatimTeX("' .. post
    end)
    data = stringgsub(data, "([^A-Z_a-z])etex([^A-Z_a-z])",
    function(pre,post)
        pre = stringgsub(pre,"%s","")
        return pre .. '")' .. post
    end)
    local mpx = luamplib.load(currentformat)
    if mpx and data then
        local result = mpx:execute(mplibcodepreamble .. data)
        domakeTEXboxes(result)
    end
    return data
end

luamplib.makeTEXboxes = makeTEXboxes

local function processwithTEXboxes (data)
    local num = tex.count[14] -- the same newbox register
    local prepreamble = "TEXBOX_ := "..num..";\n"
    while true do
        num = num + 1
        local box = tex.box[num]
        if not box then break end
        prepreamble = prepreamble ..
        "TEXBOX_wd["..num.."] := "..box.width /factor..";\n"..
        "TEXBOX_ht["..num.."] := "..box.height/factor..";\n"..
        "TEXBOX_dp["..num.."] := "..box.depth /factor..";\n"
    end
    process(prepreamble .. mplibcodepreamble .. data)
end

luamplib.processwithTEXboxes = processwithTEXboxes


local function flush(result,flusher)
    if result then
        local figures = result.fig
        if figures then
            for f=1, #figures do
                info("flushing figure %s",f)
                local figure = figures[f]
                local objects = getobjects(result,figure,f)
                local fignum = tonumber(stringmatch(figure:filename(),"([%d]+)$") or figure:charcode() or 0)
                local miterlimit, linecap, linejoin, dashed = -1, -1, -1, false
                local bbox = figure:boundingbox()
                local llx, lly, urx, ury = bbox[1], bbox[2], bbox[3], bbox[4] -- faster than unpack
                if urx < llx then
                    -- invalid
                    pdf_startfigure(fignum,0,0,0,0)
                    pdf_stopfigure()
                else
                    pdf_startfigure(fignum,llx,lly,urx,ury)
                    pdf_literalcode("q")
                    if objects then
                        for o=1,#objects do
                            local object        = objects[o]
                            local objecttype    = object.type
                            local prescript     = object.prescript --- [be]tex patch
                            if prescript and stringfind(prescript,"%%%%TEXtxtbox:") then
                                putTEXboxes(object)
                            elseif objecttype == "start_bounds" or objecttype == "stop_bounds" then
                                -- skip
                            elseif objecttype == "start_clip" then
                                pdf_literalcode("q")
                                flushnormalpath(object.path,t,false)
                                pdf_literalcode("W n")
                            elseif objecttype == "stop_clip" then
                                pdf_literalcode("Q")
                                miterlimit, linecap, linejoin, dashed = -1, -1, -1, false
                            elseif objecttype == "special" then
                                -- not supported
                            elseif objecttype == "text" then
                                local ot = object.transform -- 3,4,5,6,1,2
                                local cs = object.color
                                if cs and #cs > 0 then
                                    pdf_literalcode(luamplib.colorconverter(cs))
                                end
                                pdf_literalcode("q %f %f %f %f %f %f cm",ot[3],ot[4],ot[5],ot[6],ot[1],ot[2])
                                pdf_textfigure(object.font,object.dsize,object.text,object.width,object.height,object.depth)
                                pdf_literalcode("Q")
                            else
                                local cs = object.color
                                if cs and #cs > 0 then
                                    pdf_literalcode(luamplib.colorconverter(cs))
                                end
                                local ml = object.miterlimit
                                if ml and ml ~= miterlimit then
                                    miterlimit = ml
                                    pdf_literalcode("%f M",ml)
                                end
                                local lj = object.linejoin
                                if lj and lj ~= linejoin then
                                    linejoin = lj
                                    pdf_literalcode("%i j",lj)
                                end
                                local lc = object.linecap
                                if lc and lc ~= linecap then
                                    linecap = lc
                                    pdf_literalcode("%i J",lc)
                                end
                                local dl = object.dash
                                if dl then
                                    local d = format("[%s] %i d",tableconcat(dl.dashes or {}," "),dl.offset)
                                    if d ~= dashed then
                                        dashed = d
                                        pdf_literalcode(dashed)
                                    end
                                elseif dashed then
                                   pdf_literalcode("[] 0 d")
                                   dashed = false
                                end
                                local path = object.path
                                local transformed, penwidth = false, 1
                                local open = path and path[1].left_type and path[#path].right_type
                                local pen = object.pen
                                if pen then
                                   if pen.type == 'elliptical' then
                                        transformed, penwidth = pen_characteristics(object) -- boolean, value
                                        pdf_literalcode("%f w",penwidth)
                                        if objecttype == 'fill' then
                                            objecttype = 'both'
                                        end
                                   else -- calculated by mplib itself
                                        objecttype = 'fill'
                                   end
                                end
                                if transformed then
                                    pdf_literalcode("q")
                                end
                                if path then
                                    if transformed then
                                        flushconcatpath(path,open)
                                    else
                                        flushnormalpath(path,open)
                                    end
                                    if objecttype == "fill" then
                                        pdf_literalcode("h f")
                                    elseif objecttype == "outline" then
                                        pdf_literalcode((open and "S") or "h S")
                                    elseif objecttype == "both" then
                                        pdf_literalcode("h B")
                                    end
                                end
                                if transformed then
                                    pdf_literalcode("Q")
                                end
                                local path = object.htap
                                if path then
                                    if transformed then
                                        pdf_literalcode("q")
                                    end
                                    if transformed then
                                        flushconcatpath(path,open)
                                    else
                                        flushnormalpath(path,open)
                                    end
                                    if objecttype == "fill" then
                                        pdf_literalcode("h f")
                                    elseif objecttype == "outline" then
                                        pdf_literalcode((open and "S") or "h S")
                                    elseif objecttype == "both" then
                                        pdf_literalcode("h B")
                                    end
                                    if transformed then
                                        pdf_literalcode("Q")
                                    end
                                end
--                              if cr then
--                                  pdf_literalcode(cr)
--                              end
                            end
                       end
                    end
                    pdf_literalcode("Q")
                    pdf_stopfigure()
                end
            end
        end
    end
end
luamplib.flush = flush

local function colorconverter(cr)
    local n = #cr
    if n == 4 then
        local c, m, y, k = cr[1], cr[2], cr[3], cr[4]
        return format("%.3f %.3f %.3f %.3f k %.3f %.3f %.3f %.3f K",c,m,y,k,c,m,y,k), "0 g 0 G"
    elseif n == 3 then
        local r, g, b = cr[1], cr[2], cr[3]
        return format("%.3f %.3f %.3f rg %.3f %.3f %.3f RG",r,g,b,r,g,b), "0 g 0 G"
    else
        local s = cr[1]
        return format("%.3f g %.3f G",s,s), "0 g 0 G"
    end
end
luamplib.colorconverter = colorconverter
-- 
--  End of File `luamplib.lua'.
