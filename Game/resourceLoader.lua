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

function LoadTextures(folder)
    local files = {}

    local object_files = {}
    recursiveEnumerate(folder, files)

    local textures = {}

    for _, file in ipairs(files) do
        local filename, extension = file:match("^.+/(.+)%.(.+)$")
        textures[filename] = love.graphics.newImage(file)
    end

    return textures
end

function LoadFonts(folder)
    local files = {}

    local object_files = {}
    recursiveEnumerate(folder, files)

    local fonts = {}

    for _, file in ipairs(files) do
        local filename, extension = file:match("^.+/(.+)%.(.+)$")
        fonts[filename] = love.graphics.newFont(file)
    end

    return fonts
end

function LoadSounds(folder, mode)
    local files = {}

    local object_files = {}
    recursiveEnumerate(folder, files)

    local sounds = {}

    for _, file in ipairs(files) do
        local filename, extension = file:match("^.+/(.+)%.(.+)$")
        sounds[filename] = love.audio.newSource(file, mode)
    end

    return sounds
end

function LoadShaders(folder)
    local files = {}

    local object_files = {}
    recursiveEnumerate(folder, files)

    local sounds = {}

    for _, file in ipairs(files) do
        local filename, extension = file:match("^.+/(.+)%.(.+)$")
        sounds[filename] = love.graphics.newShader(file)
    end

    return sounds
end