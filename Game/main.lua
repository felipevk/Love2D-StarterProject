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
DebugTools = require 'core.DebugTools'
AssetManager = require 'editors.asset_manager'
require 'libraries/utf8/utf8'
require "core.utils"
require 'core.assets'
require 'core.memory'

default_color = {222/255, 222/255, 222/255}
background_color = {16/255, 16/255, 16/255}

function love.load()
    input = Input()
    timer = Timer()
    camera = Camera()
    draft = Draft()
    debugTools = DebugTools()
    assetManager = AssetManager()

    --resize(1.5)

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

    AddTestShortcuts()

    gotoRoom("Room")
end

function love.update(dt)
    timer:update(dt*slow_amount)
    camera:update(dt*slow_amount)
    if current_room then current_room:update(dt*slow_amount) end
    if debugMode then debugTools:update(dt) end
    assetManager:update(dt)
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

    if debugMode then debugTools:draw() end

    assetManager:draw()
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

function AddTestShortcuts()
    input:bind('f1', checkGC )
    input:bind('f3', function() debugMode = not debugMode end )
end