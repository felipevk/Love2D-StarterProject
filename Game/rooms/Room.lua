local Room = Object:extend()

function Room:new()
    self.area = Area(self)
    self.area:addPhysicsWorld()
    self.room_canvas = love.graphics.newCanvas(gw, gh)

    self.demoFont = love.graphics.newFont(40)
end

function Room:update(dt)
    -- this keeps the camera centered after shake
    camera.smoother = Camera.smooth.damped(5)
    camera:lockPosition(dt, gw/2, gh/2)
    
    self.area:update(dt)
end

--[[
    Creates a canvas with the game resolution and resizes it to fit the scale
]]
function Room:draw()
    love.graphics.setCanvas(self.room_canvas)
    love.graphics.clear()
    camera:attach(0, 0, gw, gh)
        self.area:draw()
        love.graphics.setFont(self.demoFont)
        printInsideRect("Hello Love2D!", self.demoFont, "center")
  	camera:detach()
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.room_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

return Room