local DebugTools = Object:extend()

function DebugTools:new()
    self.drawRect = {
        visible = false,
        x = 0,
        y = 0,
        w = 0,
        h = 0,
        topLeft = {
            x = 0,
            y = 0
        },
        message = nil,
        color = { 0, 1, 0, 1},
        font = love.graphics.newFont('resources/fonts/PixelTandysoft-0rJG.ttf', 20)
    }
    input:bind('mouse2', 'rMouse')
end

function DebugTools:update(dt)
    if input:pressed('rMouse') then
        self.drawRect.visible = true
        self.drawRect.x = love.mouse.getX()
        self.drawRect.y = love.mouse.getY()
    end
    if input:released('rMouse') then
        self.drawRect.visible = false
        print( self.drawRect.message )
    end

    if self.drawRect.visible then
        self.drawRect.w = love.mouse.getX() - self.drawRect.x
        self.drawRect.h = love.mouse.getY() - self.drawRect.y

        self.drawRect.topLeft.x = self.drawRect.w >= 0 and self.drawRect.x or self.drawRect.x + self.drawRect.w
        self.drawRect.topLeft.y = self.drawRect.h >= 0 and self.drawRect.y or self.drawRect.y + self.drawRect.h

        self.drawRect.message = 'Debug Rect: X = '..self.drawRect.topLeft.x / sx..
            ' Y = '..self.drawRect.topLeft.y / sy..
            ' | W = '..math.abs( self.drawRect.w / sx )..
            ' H = '..math.abs( self.drawRect.h / sy)
    end
end

function DebugTools:draw()
    if self.drawRect.visible then
        love.graphics.setFont(self.drawRect.font)
        love.graphics.setColor(self.drawRect.color)
        love.graphics.rectangle("line", self.drawRect.x, self.drawRect.y, self.drawRect.w, self.drawRect.h)

            printInsideRect(self.drawRect.message, self.drawRect.font, 'topLeft', 5)
            
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return DebugTools