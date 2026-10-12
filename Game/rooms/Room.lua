local Room = Object:extend()

function Room:new()
    self.area = Area(self)
    self.area:addPhysicsWorld()
    self.room_canvas = love.graphics.newCanvas(GameConfig.gw, GameConfig.gh)

    self.demoFont = love.graphics.newFont(40)

    input:bind('escape', 'exit')
    AddTestShortcuts()
end

function Room:update(dt)
    -- this keeps the camera centered after shake
    camera.smoother = Camera.smooth.damped(5)
    camera:lockPosition(dt, GameConfig.gw / 2, GameConfig.gh / 2)
    
    self.area:update(dt)

    if input:pressed('exit') then
        love.event.quit()
    end
end

--[[
    Creates a canvas with the game resolution and resizes it to fit the scale
]]
function Room:draw()
    love.graphics.setCanvas(self.room_canvas)
    love.graphics.clear()
    camera:attach(0, 0, GameConfig.gw, GameConfig.gh)
        self.area:draw()
        love.graphics.setFont(self.demoFont)
        printInsideRect("Hello Love2D!", self.demoFont, "center")
  	camera:detach()
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.room_canvas, 0, 0, 0, GameConfig.sx, GameConfig.sy)
    love.graphics.setBlendMode('alpha')
end

return Room