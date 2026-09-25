local InputLib = require 'libraries/boipushy/Input'

local Input = Object:extend()

function Input:new()
    self.handler = InputLib()
end

function Input:bind(key, action)
    self.handler:bind(key, action)
end

function Input:pressed(action)
    return self.handler:pressed(action)
end

function Input:released(action)
    return self.handler:released(action)
end

function Input:down(action)
    return self.handler:down(action)
end

function Input:axis(actionAxis)
    return self.handler:axis(actionAxis)
end

function Input:bindCommon()
    self:bind('left', 'left')
    self:bind('right', 'right')
    self:bind('a', 'left')
    self:bind('d', 'right')
    self:bind('up', 'up')
    self:bind('down', 'down')
    self:bind('w', 'up')
    self:bind('s', 'down')
end

return Input