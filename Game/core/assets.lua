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

function autoloadAssets()
    local asset_types = {
        {
            "resources/sprites",
            function(filename, file)
                sprites[filename] = love.graphics.newImage(file)
            end
        },
        {
            "resources/fonts",
            function(filename, file)
                fonts[filename] = love.graphics.newFont(file)
            end
        },
        {
            "resources/audio/stream",
            function(filename, file)
                sounds[filename] = love.audio.newSource(file, "stream")
            end
        },
        {
            "resources/audio/static",
            function(filename, file)
                sounds[filename] = love.audio.newSource(file, "static")
            end
        },
        {
            "resources/shaders",
            function(filename, file)
                shaders[filename] = love.graphics.newShader(file)
            end
        }
    }

    for _, type in ipairs (asset_types) do
        local folder = type[1]
        local files = {}

        local object_files = {}
        recursiveEnumerate(folder, files)

        for _, file in ipairs(files) do
            local filename, extension = file:match("^.+/(.+)%.(.+)$")
            type[2](filename, file)
        end
    end

end