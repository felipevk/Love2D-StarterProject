sprites = {}
sounds = {}
fonts = {}
shaders = {}

--[[
    Stores all possible object files into a table
]]
function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
        if love.filesystem.getInfo(file) then
            table.insert(file_list, file)
        elseif love.filesystem.isDirectory(file) then
            recursiveEnumerate(file, file_list)
        end
    end
end

--[[
    Imports files from a table
]]
function requireFiles(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        local className = file:match("([^/]+)$")
        if not _G[className] then
            _G[className] = require(file)
        end
    end
end

function loadAssetsFromTable()
    local load_func = {
        image =
            function(asset)
                sprites[asset.handle] = love.graphics.newImage("resources/sprites/" .. asset.name)
            end,
        font = 
            function(asset)
                fonts[asset.handle] = love.graphics.newFont("resources/fonts/" .. asset.name, asset.fontSize)
            end,
        sound =
            function(asset)
                sounds[asset.handle] = love.audio.newSource("resources/audio/" .. asset.name, asset.audioMode)
            end,
        shader =
            function(asset)
                shaders[asset.handle] = love.graphics.newShader("resources/shaders/" .. asset.name)
            end
    }

    local tableData = require("resources.asset_table")

    for _, asset in ipairs (tableData) do
        load_func[asset.type](asset)
    end

end