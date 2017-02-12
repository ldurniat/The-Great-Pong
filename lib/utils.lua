local mRandom = math.random
local tInsert = table.insert
local app = require('lib.app')
-------------------------------------------
-- Shuffle a table
-------------------------------------------
table.shuffle = function (t)
  local n = #t
  while n > 2 do
    -- n is now the last pertinent index
    local k = mRandom(1, n) -- 1 <= k <= n
    -- Quick swap
    t[n], t[k] = t[k], t[n]
    n = n - 1
  end
end

function table.deepcopy(t)
    if type(t) ~= 'table' then return t end
    local mt = getmetatable(t)
    local res = {}
    for k,v in pairs(t) do
        if type(v) == 'table' then
            v = table.deepcopy(v)
        end
        res[k] = v
    end
    setmetatable(res,mt)
    return res
end

function string.trim(s)
    local from = s:match"^%s*()"
    return from > #s and "" or s:match(".*%S", from)
end

function string.startswith(s, piece)
    return string.sub(s, 1, string.len(piece)) == piece
end

function string.endswith(s, send)
    return #s >= #send and s:find(send, #s-#send+1, true) and true or false
end

function string.split(p,d)
  local t, ll, l
  t={}
  ll=0
  if(#p == 1) then return {p} end
    while true do
      l=string.find(p,d,ll,true) -- find the next d in the string
      if l~=nil then -- if "not not" found then..
        tInsert(t, string.sub(p,ll,l-1)) -- Save it in our array.
        ll=l+1 -- save just after where we found it for searching next time.
      else
        tInsert(t, string.sub(p,ll)) -- Save what's left in our array.
        break -- Break at end, as it should be, according to the lua manual.
      end
    end
  return t
end

function math.clamp(value, low, high)
    if low and value <= low then
        return low
    elseif high and value >= high then
        return high
    end
    return value
end

function math.inBounds(value, low, high)
    if value >= low and value <= high then
        return true
    else
        return false
    end
end

function math.round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

function app.saveFile(strFilename, strValue, dir)
    local path = system.pathForFile(strFilename, dir or system.DocumentsDirectory)
    local file = io.open( path, "w+" )
    if file then
       file:write(strValue)
       io.close(file)
    end
end

function app.readFile(strFilename, dir)
    local theFile = strFilename
    local path = system.pathForFile( theFile, dir or system.DocumentsDirectory )
    -- io.open opens a file at path. returns nil if no file found
    local file = io.open( path, "r" )
    if file then
       -- read all contents of file into a string
       local contents = file:read( "*a" )
       io.close( file )
       return contents
    else
       return ''
    end
end

function app.readJsonFile(strFilename, dir)
    return json.decode(app.readFile(strFilename, dir))
end

function math.checkIn(value, ...)
    if type(arg[1]) == 'table' then
        for k, v in pairs(arg[1]) do
            if v == value then
                return true
            end
        end
    else
        for i, v in ipairs(arg) do
            if v == value  then
                return true
            end
        end
    end
    return false
end

function app.datetime()
    local t = os.date('*t')
    return t.year .. '-' .. t.month .. '-' .. t.day .. ' ' .. t.hour .. ':' .. t.min .. ':' .. t.sec
end

function app.parseDatetime(datetime)
    local pattern = '(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)'
    local year, month, day, hour, minute, seconds = datetime:match(pattern)
    year = tonumber(year)
    month = tonumber(month)
    day = tonumber(day)
    return {year = year, month = month, day = day, hour = hour, min = minute, sec = seconds}
end

function app.pprint(t, name, indent)
  local tableList = {}
  local function table_r (t, name, indent, full)
    local serial=string.len(full) == 0 and name
        or type(name)~="number" and '["'..tostring(name)..'"]' or '['..name..']'
    print(indent,serial,' = ')
    if type(t) == "table" then
      if tableList[t] ~= nil then print('{}; -- ',tableList[t],' (self reference)\n')
      else
        tableList[t]=full..serial
        if next(t) then -- Table not empty
          print('{\n')
          for key,value in pairs(t) do table_r(value,key,indent..'\t',full..serial) end
          print(indent,'};\n')
        else print('{};\n') end
      end
    else print(type(t)~="number" and type(t)~="boolean" and '"'..tostring(t)..'"'
                  or tostring(t),';\n') end
  end
  table_r(t,name or '__unnamed__',indent or '','')
end

function app.HSVtoRGB(h, s, v)
    local r,g,b
    local i
    local f,p,q,t

    if s == 0 then
        r = v
        g = v
        b = v
        return r, g, b
    end

    h =   h / 60;
    i  = math.floor(h);
    f = h - i;
    p = v *  (1 - s);
    q = v * (1 - s * f);
    t = v * (1 - s * (1 - f));
    if i == 0 then
        r = v
        g = t
        b = p
    elseif i == 1 then
        r = q
        g = v
        b = p
    elseif i == 2 then
        r = p
        g = v
        b = t
    elseif i == 3 then
        r = p
        g = q
        b = v
    elseif i == 4 then
        r = t
        g = p
        b = v
    elseif i == 5 then
        r = v
        g = p
        b = q
    end
    return r, g, b
end

function easing.loop(ease)
    return function(t, tMax, start, delta)
        if t / tMax < 0.5 then
            return ease(tMax - t, tMax * 0.5, start, delta * 0.5)
        else
            return ease(t, tMax * 0.5, start, delta * 0.5)
        end
    end
end

function table.removeByRef(t, obj)
    table.remove(t, table.indexOf(t, obj))
end