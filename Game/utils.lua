function UUID()
    local fn = function(x)
        local r = love.math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789abcdef"):sub(r, r)
    end
    return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

 
-- math.random(min, max) only gives a integer range. This gives a float range
function random(min, max)
    local min, max = min or 0, max or 1
    return (min > max and (love.math.random()*(min - max) + max)) or (love.math.random()*(max - min) + min)
end

function printAll(...)
    for _,v in ipairs({...}) do
        print(v)
    end
end

function printText(...)
    local function concat(a,b) return a..b end
    print(M.reduce({...}, concat))
end

function distanceBetweenPoints(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 +(y2 - y1)^2)
end

function isInsideCircle(x, y, xC, yC, radius)
    return distanceBetweenPoints(x, y, xC, yC) <= radius
end

--[[
    Rotates r degrees centered at x,y. Rotation will be applied to all draw functions until love.graphics.pop is called
]]
function pushRotate(x, y, r)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    love.graphics.translate(-x, -y)
end

--[[
    Rotates r degrees centered at x,y. Rotation and scale will be applied to all draw functions until love.graphics.pop is called
]]
function pushRotateScale(x, y, r, sx, sy)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    love.graphics.scale(sx or 1, sy or sx or 1)
    love.graphics.translate(-x, -y)
end

--[[
    Returns a position equivalent the original position moved at a certain distance and angle
]]
function movePointDistanceAngle(x, y, d, r)
    return { x = x + (d * math.cos(r)), y = y + (d * math.sin(r))}
end

-- Picks a random valid index from a table
function table.random(t)
    return t[love.math.random(1, #t)]
end

function createIrregularPolygon(size, point_amount)
    local point_amount = point_amount or 8
    local points = {}
    for i = 1, point_amount do
        local distance = size + random(-size/4, size/4)
        local angle_interval = 2*math.pi/point_amount
        local angle = (i-1)*angle_interval + random(-angle_interval/4, angle_interval/4)
        table.insert(points, distance*math.cos(angle))
        table.insert(points, distance*math.sin(angle))
    end
    return points
end

--[[
    Receives a list of values and odds.
    Returns a table with a function to get a random value. 
    Internally it contains a list with each value copied N times, where N are its odds.
    Every time a value is returned, it is removed from the list.
    This ensures that something with X% odds will always appear X times if next is called 100 times.
]]
function chanceList(...)
    return {
        chance_list = {},
        chance_definitions = {...},
        next = function(self)
            if #self.chance_list == 0 then
                for _, chance_definition in ipairs(self.chance_definitions) do
                      for i = 1, chance_definition[2] do 
                        table.insert(self.chance_list, chance_definition[1]) 
                      end
                end
            end
            return table.remove(self.chance_list, love.math.random(1, #self.chance_list))
        end
    }
end

--[[
    Renders text inside a corner of a rect.
    If no rect is given, screen will be used as rect.
]]
function printInsideRect(text, font, side, offset, rect)

    x = 0
    y = 0
    ox = 0
    oy = 0 
    offset = offset or 0

    screenRect = {
        x = 0,
        y = 0,
        w = gw,
        h = gh,
    }

    rect = rect or screenRect

    if side == 'center' then
        x = rect.x + rect.w / 2
        y = rect.y + rect.h / 2
        ox = font:getWidth(text) / 2
        oy = font:getHeight() / 2
    elseif side == 'top' then
        x = rect.x + rect.w / 2
        y = rect.y + offset
        ox = font:getWidth(text) / 2
        oy = 0
    elseif side == 'bottom' then
        x = rect.x + rect.w / 2
        y = rect.y + rect.h - offset
        ox = font:getWidth(text) / 2
        oy = font:getHeight()
    elseif side == 'left' then
        x = rect.x + offset
        y = rect.y + rect.h / 2
        ox = 0
        oy = font:getHeight() / 2
    elseif side == 'right' then
        x = rect.x + rect.w - offset
        y = rect.y + rect.h / 2
        ox = font:getWidth(text)
        oy = font:getHeight() / 2
    elseif side == 'topLeft' then
        x = rect.x +  offset
        y = rect.y + offset
        ox = 0
        oy = 0
    elseif side == 'topRight' then
        x = rect.x + rect.w - offset
        y = rect.y + offset
        ox = font:getWidth(text)
        oy = 0
    elseif side == 'bottomLeft' then
        x = rect.x + offset
        y = rect.y + rect.h - offset
        ox = 0
        oy = font:getHeight()
    elseif side == 'bottomRight' then
        x = rect.x + rect.w - offset
        y = rect.y + rect.h - offset
        ox = font:getWidth(text)
        oy = font:getHeight()
    end

    love.graphics.print(text, x, y, 0, 1, 1, ox, oy)
end