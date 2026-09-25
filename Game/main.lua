Object = require 'libraries/classic/classic'
Timer = require 'libraries/EnhancedTimer/EnhancedTimer'
M = require "libraries/Moses/moses"
Camera = require 'libraries/hump/camera'
Vector = require 'libraries/hump/vector'
Physics = require 'libraries/windfield/windfield'
Draft = require 'libraries/draft/draft'
Anim8 = require 'libraries/anim8/anim8'
sti = require 'libraries/Simple-Tiled-Implementation/sti'

Input = require 'core.input_handler'
require 'libraries/utf8/utf8'
require "core.utils"
require 'core.assets'

default_color = {222/255, 222/255, 222/255}
background_color = {16/255, 16/255, 16/255}

function love.load()
    input = Input()
    timer = Timer()
    camera = Camera()
    draft = Draft()

    --resize(2)

    GameObject = require("objects/GameObject")

    local object_files = {}
    recursiveEnumerate('objects', object_files)
    requireFiles(object_files)

    local room_files = {}
    recursiveEnumerate('rooms', room_files)
    requireFiles(room_files)
    current_room = nil

    slow_amount = 1

    flash_frames = nil
    flashColor = {1,1,1,1}

    if automaticAssetLoad then
        autoloadAssets()
    end
    input:bindCommon()
    input:bind('escape', 'exit')

    gotoRoom("Room")

    if debug then debugTools = DebugTools() end
end

function love.update(dt)
    timer:update(dt*slow_amount)
    camera:update(dt*slow_amount)
    if current_room then current_room:update(dt*slow_amount) end
    if debug then debugTools:update(dt) end
end

function love.draw()
    if current_room then current_room:draw() end

    if flash_frames then 
        flash_frames = flash_frames - 1
        if flash_frames == -1 then flash_frames = nil end
    end
    if flash_frames then
        love.graphics.setColor(flashColor)
        love.graphics.rectangle('fill', 0, 0, sx*gw, sy*gh)
        love.graphics.setColor(1, 1, 1)
    end

    if debug then debugTools:draw() end
end

function love.keypressed(key)
end

function gotoRoom(room_type, ...)
    if current_room and current_room.destroy then current_room:destroy() end
    current_room = _G[room_type](...)
end

function resize(s)
    love.window.setMode(s*gw, s*gh) 
    sx, sy = s, s
end

function slow(amount, duration)
    slow_amount = amount
    timer:tween('slow', duration, _G, {slow_amount = 1}, 'in-out-cubic')
end

function flash(frames, color)
    flash_frames = frames
    flashColor = color or {1,1,1,0.5}
end

function checkGC()
    -- Counts how many of each object type exist in memory after garbage collection
    print("Before collection: " .. collectgarbage("count")/1024)
    collectgarbage()
    print("After collection: " .. collectgarbage("count")/1024)
    print("Object count: ")
    local counts = type_count()
    for k, v in pairs(counts) do print(k, v) end
    print("-------------------------------------")
end

function count_all(f)
    local seen = {}
    local count_table
    count_table = function(t)
        if seen[t] then return end
            f(t)
	    seen[t] = true
	    for k,v in pairs(t) do
	        if type(v) == "table" then
		    count_table(v)
	        elseif type(v) == "userdata" then
		    f(v)
	        end
	end
    end
    count_table(_G)
end

function type_count()
    local counts = {}
    local enumerate = function (o)
        local t = type_name(o)
        counts[t] = (counts[t] or 0) + 1
    end
    count_all(enumerate)
    return counts
end

global_type_table = nil
function type_name(o)
    if global_type_table == nil then
        global_type_table = {}
            for k,v in pairs(_G) do
	        global_type_table[v] = k
	    end
	global_type_table[0] = "table"
    end
    return global_type_table[getmetatable(o) or 0] or "Unknown"
end

function AddTestShortcuts()
    input:bind('f1', checkGC )
    input:bind('f3', function() debug = not debug end )
end