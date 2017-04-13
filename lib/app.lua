local getTimer = system.getTimer
local pairs = _G.pairs

local _M = {} 

_M.deviceID = system.getInfo('deviceID')

if system.getInfo('environment') ~= 'simulator' then
    io.output():setvbuf('no')
else
    _M.isSimulator = true
end

local platform = system.getInfo('platformName')
if platform == 'Android' then
    _M.isAndroid = true
elseif platform == 'iPhone OS' then
    _M.isiOS = true
end

-- Disabled for now
--[[
if _M.isSimulator then
    -- Prevent global missuse
    local mt = getmetatable(_G)
    if mt == nil then
      mt = {}
      setmetatable(_G, mt)
    end

    mt.__declared = {}

    mt.__newindex = function (t, n, v)
      if not mt.__declared[n] then
        local w = debug.getinfo(2, 'S').what
        if w ~= 'main' and w ~= 'C' then
          error('assign to undeclared variable \'' .. n .. '\'', 2)
        end
        mt.__declared[n] = true
      end
      rawset(t, n, v)
    end

    mt.__index = function (t, n)
      if not mt.__declared[n] and debug.getinfo(2, 'S').what ~= 'C' then
        error('variable \'' .. n .. '\' is not declared', 2)
      end
      return rawget(t, n)
    end
end
--]]
local locals = {
    _W = display.contentWidth,
    _H = display.contentHeight,
    _T = display.screenOriginY,
    _B = display.viewableContentHeight - display.screenOriginY,
    _L = display.screenOriginX,
    _R = display.viewableContentWidth - display.screenOriginX,
    _CX = math.floor(display.contentWidth * 0.5),
    _CY = math.floor(display.contentHeight * 0.5),
    mMax = math.max,
    mMin = math.min,
    mFloor = math.floor,
    tInsert = table.insert,
    mCeil = math.ceil,
    mFloor = math.floor,
    mAbs = math.abs,
    mAtan2 = math.atan2,
    mSin = math.sin,
    mCos = math.cos,
    mPi = math.pi,
    mSqrt = math.sqrt,
    mExp = math.exp,
    mRandom = math.random,
    tInsert = table.insert,
    tRemove = table.remove,
    tForeach = table.foreach,
    tShuffle = table.shuffle,
    sSub = string.sub,
    sLower = string.lower}
locals._SW = locals._R - locals._L
locals._SH = locals._B - locals._T

function _M.setLocals()
    local i = 1
    repeat
        local k, v = debug.getlocal(2, i)
        if k and v == nil then
            if locals[k] ~= nil then
                debug.setlocal(2, i, locals[k])
            else
                --error('No value for a local variable: ' .. k, 2)
            end
        end
        i = i + 1
    until not k
end

local colors = {}
colors['white'] = {1, 1, 1}
colors['grey'] = {0.6, 0.6, 0.6}
colors['black'] = {0, 0, 0}
colors['red'] = {1, 0, 0}
colors['green'] = {0, 1, 0}
colors['blue'] = {0, 0, 1}
colors['yellow'] = {1, 1, 0}
colors['cyan'] = {0, 1, 1}
colors['magenta'] = {1, 0, 1}

colors['orange'] = {1, 0.75, 0}
colors['dark_green'] = {0, 0.5, 0}
colors['res_green'] = {0, 0.3, 0}
colors['res_red'] = {0.7, 0, 0}

local ext = (_M.isAndroid or _M.isSimulator) and '.ogg' or '.m4a'

local sounds = {
    button = 'sounds/button.wav',
    swipe = 'sounds/swipe.wav',
    wrong = 'sounds/wrong.wav',
    correct = 'sounds/correct.wav',
    pop = 'sounds/pop.wav',
    music = 'sounds/music' .. ext
}

_M.duration = 200

local referencePoints = {
    TopLeft      = {0, 0},
    TopRight     = {1, 0},
    TopCenter    = {0.5, 0},
    BottomLeft   = {0, 1},
    BottomRight  = {1, 1},
    BottomCenter = {0.5, 1},
    CenterLeft   = {0, 0.5},
    CenterRight  = {1, 0.5},
    Center       = {0.5, 0.5}
}
function _M.setRP(object, rp)
    local anchor = referencePoints[rp]
    if anchor then
        object.anchorX, object.anchorY = anchor[1], anchor[2]
    else
        error('No such reference point: ' .. tostring(rp), 2)
    end
end

function _M.setFillColor(object, color)
    local rgb = colors[color]
    if rgb then
        object:setFillColor(unpack(rgb))
    else
        error('No such color: ' .. tostring(color), 2)
    end
end

function _M.setStrokeColor(object, color)
    local rgb = colors[color]
    if rgb then
        object:setStrokeColor(unpack(rgb))
    else
        error('No such color: ' .. tostring(color), 2)
    end
end

function _M.enableRemoteConsole(hostname, port)
    if not hostname then
        error('Hostname is required', 2)
    end
    port = port or 22000
    local udp = require('socket').udp()
    udp:setsockname('*', port + 1)
    udp:settimeout(1)
    _G.print = function(...)
        local t = {...}
        local s = ''
        for i = 1, #t do
            local v = t[i]
            if v == nil then v = 'nil' end
            s = s .. tostring(v) .. '\t'
        end
        udp:sendto(s .. '\n', hostname, port)
    end
    Runtime:addEventListener('unhandledError', function(event)
        local message = 'Runtime error\n' .. event.errorMessage .. event.stackTrace .. '\n'
        udp:sendto(message, hostname, port)
    end)
end

function _M.newImage(filename, params)
    params = params or {}
    local w, h = params.w or _W, params.h or _H
    local image = display.newImageRect(filename, params.dir or system.ResourceDirectory, w, h)
    if not image then return end
    if params.rp then
        _M.setRP(image, params.rp)
    end
    image.x = params.x or 0
    image.y = params.y or 0
    if params.g then
        params.g:insert(image)
    end
    return image
end

function _M.newText(params)
    params = params or {}
    local text
    if params.align then
        text = display.newText{text = params.text or '',
            x = params.x or 0, y = params.y or 0,
            width = params.w, height = params.h or (params.w and 0),
            font = params.font or _M.font,
            fontSize = params.size or 16,
            align = params.align or 'center'}
    elseif params.w then
        text = display.newEmbossedText(params.text or '', 0, 0, params.w, params.h or 0, params.font or _M.font, params.size or 16)
    else
        text = display.newEmbossedText(params.text or '', 0, 0, params.font or _M.font, params.size or 16)
    end
    if params.rp then
        _M.setRP(text, params.rp)
    end
    text.x = params.x or 0
    text.y = params.y or 0
    if params.g then
        params.g:insert(text)
    end
    if params.color then
        _M.setColor(text, params.color)
    end
    return text
end

function _M.newButton(params)
    local button = widget.newButton {
        width = params.w or 32, height = params.h or 32,
        defaultFile = params.image or 'images/button.png',
        overFile = params.imageOver or 'images/button-over.png',
        label = params.text,
        labelColor = params.fontColor or {default = {1, 1, 1}, over = {0.8, 0.8, 0.8}},
        fontSize = params.fontSize or 14,
        onPress = params.onPress,
        onRelease = params.onRelease,
        onEvent = params.onEvent}
    button.x, button.y = params.x or 0, params.y or 0
    if params.rp then
        _M.setRP(button, params.rp)
    end
    params.g:insert(button)
    return button
end

function _M.transition(object, params)
    params = params or {}
    params.delay = params.delay or 0
    object.alpha = 0
    local transParams = {time = 800, alpha = 1, transition = function (a,b,c,d) local v = easing.outExpo(a,b,c,d); if v > 1 then return 1 else return v end end}
    if params.delay > 0 then
        object.isVisible = false
        transParams.onStart = function (obj) obj.isVisible = true end
        transParams.delay = params.delay * 30
    end
    transition.to(object, transParams)
end

function _M.alert(txt)
    if type(txt) == 'string' then
        native.showAlert(_M.name, txt, {'OK'})
    end
end

function _M.returnTrue(obj)
    if obj then
        local function rt() return true end
        obj:addEventListener('touch', rt)
        obj:addEventListener('tap', rt)
        obj.isHitTestable = true
    else
        return true
    end
end

local audioChannel, otherAudioChannel, currentMusicPath = 1, 2
audio.crossFadeBackground = function(path, force)
    if not _M.music_on then return end
    path = sounds[path]
    if currentMusicPath == path and audio.getVolume{channel = audioChannel} > 0.1 and not force then return false end
    audio.fadeOut{channel = audioChannel, time = 1000}
    audioChannel, otherAudioChannel = otherAudioChannel, audioChannel
    audio.setVolume(0.5, {channel = audioChannel})
    audio.play(audio.loadStream(path), {channel = audioChannel, loops = -1, fadein = 1000})
    currentMusicPath = path
end
audio.reserveChannels(2)

local loadedSounds = {}
local function loadSound(snd)
    if not loadedSounds[snd] then
        loadedSounds[snd] = audio.loadSound(sounds[snd])
    end
    return loadedSounds[snd]
end
audio.playSFX = function(snd, params)
    if not _M.sound_on then return end
    local channel = (type(snd) == 'string') and audio.play(loadSound(snd), params) or audio.play(snd, params)
    audio.setVolume(1, {channel = channel})
    return channel
end

function _M.initUser(t)
    _M.user = json.decode(_M.readFile('user.txt'))
    if not _M.user then
        _M.user = t
        _M.saveUser()
    end
end

function _M.saveUser()
    _M.saveFile('user.txt', json.encode(_M.user))
end

function _M.nextFrame(f)
    timer.performWithDelay(1, f)
end

function _M.enterFrame()
    for i = 1, #_M.enterFrameFunctions do
        _M.enterFrameFunctions[i]()
    end
end
function _M.eachFrame(f)
    if not _M.enterFrameFunctions then
        _M.enterFrameFunctions = {}
        Runtime:addEventListener('enterFrame', _M.enterFrame)
    end
    table.insert(_M.enterFrameFunctions, f)
    return f
end
function _M.eachFrameRemove(f)
    if not f or not _M.enterFrameFunctions then return end
    local ind = table.indexOf(_M.enterFrameFunctions, f)
    if ind then
        table.remove(_M.enterFrameFunctions, ind)
        if #_M.enterFrameFunctions == 0 then
            Runtime:removeEventListener('enterFrame', _M.enterFrame)
            _M.enterFrameFunctions = nil
        end
    end
end

function _M.extend(target, source)
    for k, v in pairs(source) do
        target[k] = v
    end
end

-- Stop everything
function _M.eachFrameRemoveAll()  
    Runtime:removeEventListener('enterFrame', _M.enterFrame)
    _M.enterFrameFunctions = nil
end

function _M.addRtEvents( events )
     if not _M.RtEventTable then
        _M.RtEventTable = { listeners={}, names={} }
    end

    for i=1, #events * 0.5 do
        local name = events[ 2 * i - 1 ]
        local listener = events[ 2 * i ]
         
        Runtime:addEventListener( name, listener )
        table.insert( _M.RtEventTable.listeners, listener )
        table.insert( _M.RtEventTable.names, name )
    end    
end

function _M.removeRtEvents( events )
    for i=1, #events * 0.5 do
        local name = events[ 2 * i - 1 ]
        local listener = events[ 2 * i ]

        if not listener or not _M.RtEventTable then break end
        local ind = table.indexOf( _M.RtEventTable.listeners, listener )
    
        if ind then
            table.remove( _M.RtEventTable.listeners, ind )
            table.remove( _M.RtEventTable.names, ind )
            Runtime:removeEventListener( name, listener )
        end
    end    
end

-- Stop everything
function _M.removeAllRtEvents() 
    if ( _M.RtEventTable and _M.RtEventTable.listeners ) then
        for i=1, #_M.RtEventTable.listeners do
            local name = _M.RtEventTable.names[ i ]
            local listener = _M.RtEventTable.listeners[ i ]

            Runtime:removeEventListener( name, listener )
        end  
        _M.RtEventTable.listeners = nil
        _M.RtEventTable.names     = nil
        _M.RtEventTable           = nil
    end    
end

-- Funkcję do obsługi zdarzeń generowanych przez programistę
function _M.listen( name, listener ) 
    M.addRtEvents( { name, listener } )
end  

function _M.ignore( name, listener ) 
    M.removeRtEvents( { name, listener } )
end   

function _M.post( name, params ) 
   local params = params or {}
   local event = { name = name }
   for k,v in pairs( params ) do
      event[k] = v
   end
   if ( not event.time ) then event.time = getTimer() end
   Runtime:dispatchEvent( event )
end 
-----------------------------------------------------------

return _M