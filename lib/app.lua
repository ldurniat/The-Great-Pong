local getTimer = system.getTimer
local pairs = _G.pairs

local M = {} 

M.sound = true
M.music = true
M.deviceID = system.getInfo('deviceID')

if system.getInfo('environment') ~= 'simulator' then
    io.output():setvbuf('no')
else
    M.isSimulator = true
end

local platform = system.getInfo('platformName')
if platform == 'Android' then
    M.isAndroid = true
elseif platform == 'iPhone OS' then
    M.isiOS = true
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

local dir = 'scene/game/sfx/'
local sounds = {
    button = dir .. 'select.wav',
    wall = dir .. 'wall.wav',
    hit  = dir .. 'hit.wav',
    lost = dir .. 'lost.wav', 
}
local loadedSounds = {}

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

-- ustawianie punktu anchor
function M.setRP(object, rp)
    local anchor = referencePoints[rp]
    if anchor then
        object.anchorX, object.anchorY = anchor[1], anchor[2]
    else
        error('No such reference point: ' .. tostring(rp), 2)
    end
end
-- ustawianie koloru wypełnienia
function M.setFillColor(object, color)
    local rgb = colors[color]
    if rgb then
        object:setFillColor(unpack(rgb))
    else
        error('No such color: ' .. tostring(color), 2)
    end
end
-- ustawianie koloru konturu
function M.setStrokeColor(object, color)
    local rgb = colors[color]
    if rgb then
        object:setStrokeColor(unpack(rgb))
    else
        error('No such color: ' .. tostring(color), 2)
    end
end
-- Funkcje od ładowania i odtwarzania dzwieków
local function loadSound( name )
    if ( not loadedSounds[name] ) then
        loadedSounds[name] = audio.loadSound( sounds[name] )
    end
    return loadedSounds[name]
end

function M.loadSounds()
    for name in pairs(sounds) do loadSound( name ) end
    loadedSounds.music = audio.loadStream( 'scene/menu/music/automation.mp3' )
end

function M.playSound( name )
    if M.sound then audio.play( loadedSounds[name] or name ) end    
end 

function M.stopMusic( name )
    audio.stop( 2 )   
end 

function M.playMusic( name )
    if M.music then audio.play( loadedSounds[name] or name, { loops = -1, channel = 2 } ) end    
end

function M.disposeSounds()
    audio.stop()
    for sound in pairs(loadedSounds) do 
        audio.dispose( sound )
        loadedSounds[sound] = nil
    end    
end   
-- Funkcję do manipulacji lokalnymi zdarzeniami typu enterFrame 
function M.nextFrame(f)
    timer.performWithDelay(1, f)
end

function M.enterFrame()
    for i = 1, #M.enterFrameFunctions do
        M.enterFrameFunctions[i]()
    end
end
function M.eachFrame(f)
    if not M.enterFrameFunctions then
        M.enterFrameFunctions = {}
        Runtime:addEventListener('enterFrame', M.enterFrame)
    end
    table.insert(M.enterFrameFunctions, f)
    return f
end
function M.eachFrameRemove(f)
    if not f or not M.enterFrameFunctions then return end
    local ind = table.indexOf(M.enterFrameFunctions, f)
    if ind then
        table.remove(M.enterFrameFunctions, ind)
        if #M.enterFrameFunctions == 0 then
            Runtime:removeEventListener('enterFrame', M.enterFrame)
            M.enterFrameFunctions = nil
        end
    end
end

function M.extend(target, source)
    for k, v in pairs(source) do
        target[k] = v
    end
end

function M.eachFrameRemoveAll()  
    Runtime:removeEventListener('enterFrame', M.enterFrame)
    M.enterFrameFunctions = nil
end

-- Funkcję do manipulacji globalnymi zdarzeniami różnego typu 
function M.addRuntimeEvents( events )
     if not M.RtEventTable then
        M.RtEventTable = { listeners={}, names={} }
    end

    for i=1, #events * 0.5 do
        local name = events[ 2 * i - 1 ]
        local listener = events[ 2 * i ]
         
        Runtime:addEventListener( name, listener )
        table.insert( M.RtEventTable.listeners, listener )
        table.insert( M.RtEventTable.names, name )
    end    
end

-- usunięcie wybranych zdarzeń
function M.removeRuntimeEvents( events )
    for i=1, #events * 0.5 do
        local name = events[ 2 * i - 1 ]
        local listener = events[ 2 * i ]

        if not listener or not M.RtEventTable then break end
        local ind = table.indexOf( M.RtEventTable.listeners, listener )
    
        if ind then
            table.remove( M.RtEventTable.listeners, ind )
            table.remove( M.RtEventTable.names, ind )
            Runtime:removeEventListener( name, listener )
        end
    end    
end

-- usunięcie wszystkich zdarzeń
function M.removeAllRuntimeEvents() 
    if ( M.RtEventTable and M.RtEventTable.listeners ) then
        for i=1, #M.RtEventTable.listeners do
            local name = M.RtEventTable.names[ i ]
            local listener = M.RtEventTable.listeners[ i ]

            Runtime:removeEventListener( name, listener )
        end  
        M.RtEventTable.listeners = nil
        M.RtEventTable.names     = nil
        M.RtEventTable           = nil
    end    
end

-- Generowanie dowolnych zdarzeń
--
-- dodanie zdarzenia
function M.listen( name, listener ) 
    M.addRtEvents( { name, listener } )
end

-- usunięcie zdarzenia
function M.ignore( name, listener ) 
    M.removeRtEvents( { name, listener } )
end   

-- wygenerowanie zdarzenia
function M.post( name, params ) 
   local params = params or {}
   local event = { name = name }
   for k,v in pairs( params ) do
      event[k] = v
   end
   if ( not event.time ) then event.time = getTimer() end
   Runtime:dispatchEvent( event )
end 

return M