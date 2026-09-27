local AssetManager = Object:extend()
local Slab = require 'libraries.Slab.Slab'

require 'core.assets'
require 'core.utils'

local columns = {
    filename = 0,
    type     = 350,
    handle   = 550,
    actions  = 750,
    warning  = 950
}

local colors = {
    Background = {0.09, 0.10, 0.12},
    Panel = {0.12, 0.13, 0.16},
    Border = {0.20, 0.22, 0.26},

    Text = {0.94, 0.95, 0.97},
    TextMuted = {0.65, 0.68, 0.72},

    Accent = {0.16, 0.47, 0.94},
    Error = {1.00, 0.27, 0.31},

    Button = { 0.26, 0.32, 0.40 }
}

local assetTablePath = "resources/asset_table.lua"

local function Cell(rowX, rowY, offset)
    Slab.SetCursorPos(rowX + offset, rowY)
end

local function serializeAssets(tbl)
    local lines = {"return {"}

    for _, asset in ipairs(tbl) do
        local line

        if asset.type == "sound" then
            line = string.format(
                '    { name = %q, type = %q, uuid = %q, handle = %q, audioMode = %q },',
                asset.name,
                asset.type,
                asset.uuid,
                asset.handle,
                asset.audioMode
            )
        elseif asset.type == "font" then
            line = string.format(
                '    { name = %q, type = %q, uuid = %q, handle = %q, fontSize = %d },',
                asset.name,
                asset.type,
                asset.uuid,
                asset.handle,
                asset.fontSize
            )
        else
            line = string.format(
                '    { name = %q, type = %q, uuid = %q, handle = %q },',
                asset.name,
                asset.type,
                asset.uuid,
                asset.handle
            )
        end

        table.insert(lines, line)
    end

    table.insert(lines, "}")

    return table.concat(lines, "\n")
end

local function saveAssets()
    local file, err = io.open(assetTablePath, "w")

    if not file then
        return false, err
    end

    local data = serializeAssets(assets)

    local success, writeErr = file:write(data)
    file:close()

    if not success then
        return false, writeErr
    end

    return true
end

-- for image thumbnails
local function loadImage(asset)
    icons[asset.uuid] = love.graphics.newImage("resources/sprites/" .. asset.name)
end

local function loadImages()
    for _, asset in ipairs(assets) do
        if asset.type == "image" then
            loadImage(asset)
        end
    end
end

local function loadSound(asset)
    sounds[asset.uuid] = love.audio.newSource("resources/audio/" .. asset.name, asset.audioMode)
end

local function loadSounds()
    for _, asset in ipairs(assets) do
        if asset.type == "sound" then
            loadSound(asset)
        end
    end
end

function AssetManager:new()
    Slab.Initialize()

    assets = deserializeAssetTable(assetTablePath)

    icons = {
        font = {},
        image = {},
        sound = {},
        shader = {}
    }

    loadImages()
    loadSounds()

    resize(1.5)

    self.showFileDialog = false
    self.notification = nil
    
    icons.font.icon = love.graphics.newImage("editors/font_icon_32x32.png")
    icons.font.label = love.graphics.newImage("editors/font_label_96x32.png")

    icons.image.icon = love.graphics.newImage("editors/image_icon_32x32.png")
    icons.image.label = love.graphics.newImage("editors/image_label_96x32.png")

    icons.sound.icon = love.graphics.newImage("editors/sound_icon_32x32.png")
    icons.sound.label = love.graphics.newImage("editors/sound_label_96x32.png")

    icons.shader.icon = love.graphics.newImage("editors/shader_icon_32x32.png")
    icons.shader.label = love.graphics.newImage("editors/shader_label_96x32.png")

    fonts.editorMain = love.graphics.newFont("editors/Inter_18pt-Medium.ttf", 19)
    fonts.editorHeader = love.graphics.newFont("editors/Inter_18pt-Bold.ttf", 50)
    fonts.editorMainBold = love.graphics.newFont("editors/Inter_18pt-Bold.ttf", 20)

    local style = Slab.GetStyle()

    -- Window / panel background
    style.WindowBackgroundColor = colors.Background
    style.WindowTitleFocusedColor = colors.border

    -- General text
    style.TextColor = colors.Text

    -- Buttons
    style.ButtonColor = colors.Button
    style.ButtonHoveredColor = colors.Accent
    style.ButtonPressedColor = colors.Accent

    -- List item selection
    style.ListBoxItemSelectedColor = colors.Accent

    style.Font = fonts.editorMain

    love.graphics.setBackgroundColor(colors.Background)
end

function AssetManager:canSave()
    for _, asset in ipairs(assets) do
        if not asset.handle or asset.handle == "" then
            return false
        end
    end
    return true
end

local function parseAssetPath(path)
    local fileName = path:match("([^/\\]+)$")
    local extension = fileName:match("%.([^%.]+)$")

    if not extension then
        return nil
    end

    extension = extension:lower()

    local assetType = nil

    if extension == "png"
        or extension == "jpg"
        or extension == "jpeg" then

        assetType = "image"

    elseif extension == "wav"
        or extension == "ogg"
        or extension == "mp3" then

        assetType = "sound"

    elseif extension == "ttf"
        or extension == "otf" then

        assetType = "font"

    elseif extension == "glsl"
        or extension == "frag"
        or extension == "vert" then

        assetType = "shader"
    end

    if not assetType then
        return nil
    end

    result = {
        name = fileName,
        type = assetType,
        uuid = UUID(),
        handle = ""
    }

    if assetType == "sound" then
        result.audioMode = "static"
    end

    return result
end

function AssetManager:update(dt)
    Slab.Update(dt)

    Slab.BeginWindow("AssetEditor", {
        Title = "",
        X = 100,
        Y = 21,
        W = 900,
        H = 300,
        AutoSizeWindow = false
    })

    Slab.PushFont(fonts.editorHeader)
    Slab.Text("Asset Manager")
    Slab.PopFont()

    Slab.Separator()

    Slab.PushFont(fonts.editorMain)

    if Slab.Button("Add") then
        self.showFileDialog = true
    end

    Slab.SameLine()
    if Slab.Button("Save",{
        Disabled = not self:canSave()
    }) then
        local success, err = saveAssets()

        if success then
            self.notification = "Assets saved successfully."
        else
            self.notification = "Failed to save assets:\n" .. tostring(err)
        end
    end
    self:updateAssetList()
    self:updatePropertiesPanel()

	Slab.EndWindow()

    self:updateNotification()
    self:handeFileDialog()

    Slab.PopFont()
end

function AssetManager:handeFileDialog()
    if self.showFileDialog then
        local result = Slab.FileDialog({
            Type = "openfile",
            AllowMultiSelect = true,
            Directory = "resources"
        })

        if result.Button == "OK" then
            for _, filePath in ipairs(result.Files) do
                newAsset = parseAssetPath(filePath)
                if newAsset then
                    table.insert(assets,newAsset)
                    if newAsset.type == "image" then
                        loadImage(newAsset)
                    elseif newAsset.type == "sound" then
                        loadSound(newAsset)
                    end
                end
            end
            self.showFileDialog = false
        elseif result.Button == "Cancel" then
            self.showFileDialog = false
        end
    end
end

function AssetManager:updateNotification()
    if self.notification then
        Slab.OpenDialog("Notification")
    end

    if Slab.BeginDialog("Notification") then
        Slab.Text(self.notification)

        local dialogW = Slab.GetWindowActiveSize()
        local buttonW = 80

        local x, y = Slab.GetCursorPos()

        Slab.SetCursorPos(
            x + (dialogW - buttonW) / 2,
            y
        )

        if Slab.Button("OK", {
            W = buttonW
        }) then
            self.notification = nil
            Slab.CloseDialog()
        end

        Slab.EndDialog()
    end
end

function AssetManager:updatePropertiesPanel()
    if not self.selectedAsset then
        return
    end

    local thumbW, thumbH = 64, 64
    
    Slab.PushFont(fonts.editorMainBold)
    Slab.Text("Properties")
    Slab.PopFont()
    
    Slab.BeginLayout("PropertiesHeader", {
        Columns = 4
    })
    Slab.SetLayoutColumn(1)
    if assets[self.selectedAsset].type == "image" then
        Slab.Image("PropertiesIcon", {
            Image = icons[assets[self.selectedAsset].uuid],
            W = thumbW,
            H = thumbH
        })
    else
        Slab.Image("PropertiesIcon", {
            Image = icons[assets[self.selectedAsset].type].icon,
            W = thumbW,
            H = thumbH
        })
    end
    Slab.SameLine()
    Slab.PushFont(fonts.editorMainBold)
    Slab.Text(assets[self.selectedAsset].name)
    Slab.PopFont()
    Slab.SetLayoutColumn(2)
    if assets[self.selectedAsset].type == "sound" then
        if Slab.Button("Preview") then
            sounds[assets[self.selectedAsset].uuid]:play()
        end
    end
    Slab.SetLayoutColumn(5)
    Slab.Button("###RowHeight", {
        Invisible = true,
        W = 1,
        H = 74
    })
    Slab.EndLayout()
    Slab.BeginLayout("PropertiesPanel", {
        Columns = 4
    })
    Slab.SetLayoutColumn(1)
    Slab.Text("Asset Type:")
    Slab.SameLine()
    Slab.Button("###RowHeight", {
        Invisible = true,
        W = 1,
        H = 32
    })
    Slab.SetLayoutColumn(2)
    Slab.Image("PropertiesIcon", {
        Image = icons[assets[self.selectedAsset].type].label
    })

    Slab.SetLayoutColumn(1)
    Slab.Text("UUID:")
    Slab.SetLayoutColumn(2)
    Slab.Text(assets[self.selectedAsset].uuid)

    Slab.SetLayoutColumn(1)
    Slab.Text("Handle:")
    Slab.SetLayoutColumn(2)
    if Slab.Input("SelectedAssetHandle", {
        Text = assets[self.selectedAsset].handle
    }) then
        assets[self.selectedAsset].handle = Slab.GetInputText()
    end

    if assets[self.selectedAsset].type == "font" then
        Slab.SetLayoutColumn(1)
        Slab.Text("Font Size:")
        Slab.SetLayoutColumn(2)
        if Slab.Input("fontSize", {
                Text = assets[self.selectedAsset].fontSize
            }) then
            assets[self.selectedAsset].fontSize = Slab.GetInputText()
        end
    end


    if assets[self.selectedAsset].type == "sound" then
        Slab.SetLayoutColumn(1)
        Slab.Text("Mode")
        Slab.SetLayoutColumn(2)
        if Slab.BeginComboBox("audioMode", {
            Selected = assets[self.selectedAsset].audioMode
        }) then

            if Slab.TextSelectable("Static") then
                assets[self.selectedAsset].audioMode = "static"
            end

            if Slab.TextSelectable("Stream") then
                assets[self.selectedAsset].audioMode = "stream"
            end

            Slab.EndComboBox()
        end
    end

    Slab.EndLayout()
end

function AssetManager:updateAssetList()
    Slab.BeginListBox("Assets",{StretchW = true, H = 350})
    
    --header
    Slab.BeginListBoxItem("AssetHeader")

    local x, y = Slab.GetCursorPos()
    
    Cell(x, y, columns.filename)
    Slab.Text("File Name")
    
    Cell(x, y, columns.type)
    Slab.Text("Type")
    
    Cell(x, y, columns.handle)
    Slab.Text("Asset Handle")
    
    Cell(x, y, columns.actions)
    Slab.Text("Actions")
    Slab.EndListBoxItem()

    for i, asset in ipairs(assets) do

        local labelYOffset = 12

        Slab.BeginListBoxItem("Asset" .. i, {
            Selected = self.selectedAsset == i
        })
        local x, y = Slab.GetCursorPos()
        Cell(x, y, columns.filename)
        if asset.type == "image" then
            Slab.Image("AssetIcon" .. i, {
                Image = icons[asset.uuid],
                W = 32,
                H = 32
            })
        else
            Slab.Image("AssetIcon" .. i, {
                Image = icons[asset.type].icon
            })
        end

        y = y + labelYOffset
        
        Cell(x + 40, y, columns.filename)
        Slab.Text(asset.name)
        
        y = y - labelYOffset
        Cell(x, y, columns.type)
        Slab.Image("AssetIcon" .. i, {
            Image = icons[asset.type].label
        })
        y = y + labelYOffset

        
        Cell(x, y, columns.handle)
        y = y - labelYOffset + 5
        Slab.Text(asset.handle)
        
        Cell(x, y, columns.actions)
        if Slab.Button("Remove") then
            table.remove(assets,i)
            if i == self.selectedAsset then
                self.selectedAsset = nil
            end
        end

        if asset.handle == "" then
            Cell(x, y, columns.warning)
            Slab.Text("Handle required", {Color = {1, 0, 0, 1}})
        end
        
        -- Adding this to force the row height to this size
        -- For some reason only the last item influences it
        Slab.Button("##RowHeight" .. i, {
            Invisible = true,
            W = 1,
            H = 40
        })

        if Slab.IsListBoxItemClicked() then
            self.selectedAsset = i
        end
        Slab.EndListBoxItem()

    end

    Slab.EndListBox()
end

function AssetManager:draw()
    Slab.Draw()
end

return AssetManager