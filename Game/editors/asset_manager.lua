local AssetManager = Object:extend()
local Slab = require 'libraries.Slab.Slab'

require 'core.assets'
require 'core.utils'

local columns = {
    filename = 0,
    type     = 200,
    handle   = 400,
    actions  = 600,
    warning  = 800
}

local colors = {
    Background = {0.09, 0.10, 0.12},
    Panel = {0.12, 0.13, 0.16},
    Border = {0.20, 0.22, 0.26},

    Text = {0.94, 0.95, 0.97},
    TextMuted = {0.65, 0.68, 0.72},

    Accent = {0.16, 0.47, 0.94},
    Error = {1.00, 0.27, 0.31},
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

function AssetManager:new()
    Slab.Initialize()

    assets = deserializeAssetTable(assetTablePath)

    icons = {}

    loadImages()

    resize(1.5)

    self.showFileDialog = false
    self.notification = nil

    icons.font = love.graphics.newImage("editors/font.png")
    icons.image = love.graphics.newImage("editors/image.png")
    icons.sound = love.graphics.newImage("editors/sound.png")
    icons.shader = love.graphics.newImage("editors/shader.png")

    fonts.editorMain = love.graphics.newFont("editors/Inter_18pt-Medium.ttf", 18)
    fonts.editorBold = love.graphics.newFont("editors/Inter_18pt-Bold.ttf", 18)

    local style = Slab.GetStyle()

    -- Window / panel background
    style.WindowBackgroundColor = colors.Background
    style.WindowTitleFocusedColor = colors.border

    -- General text
    style.TextColor = colors.Text

    -- Buttons
    style.ButtonColor = colors.Panel
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
        Title = "Asset Editor",
        X = 100,
        Y = 21,
        W = 900,
        H = 300,
        AutoSizeWindow = false
    })

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
    
    Slab.PushFont(fonts.editorBold)
    Slab.Text("Properties")
    Slab.PopFont()
    
    Slab.BeginLayout("PropertiesPanel", {
        Columns = 2,
        W = 300
    })

    Slab.SetLayoutColumn(1)
    Slab.Text("File:")
    Slab.SetLayoutColumn(2)
    Slab.Text(assets[self.selectedAsset].name)

    Slab.SetLayoutColumn(1)
    Slab.Text("Asset Type:")
    Slab.SetLayoutColumn(2)
    Slab.Text(assets[self.selectedAsset].type)

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
    Slab.BeginListBox("Assets",{StretchW = true, H = 400})
    
    --header
    Slab.BeginListBoxItem("AssetHeader")

    local x, y = Slab.GetCursorPos()
    
    Cell(x, y, columns.filename)
    Slab.Text("File Name")
    
    Cell(x, y, columns.type)
    Slab.Text("Preview / Type")
    
    Cell(x, y, columns.handle)
    Slab.Text("Asset Handle")
    
    Cell(x, y, columns.actions)
    Slab.Text("Actions")
    Slab.EndListBoxItem()

    for i, asset in ipairs(assets) do

        Slab.BeginListBoxItem("Asset" .. i, {
            Selected = self.selectedAsset == i
        })
        local x, y = Slab.GetCursorPos()
        
        Cell(x, y, columns.filename)
        Slab.Text(asset.name)
        
        Cell(x, y, columns.type)
        if asset.type == "image" then
            Slab.Image("AssetIcon" .. i, {
                Image = icons[asset.uuid],
                W = 32,
                H = 32
            })
        else
            Slab.Image("AssetIcon" .. i, {
                Image = icons[asset.type]
            })
        end
        

        Cell(x, y, columns.type + 40)
        Slab.Text(asset.type)
        
        Cell(x, y, columns.handle)
        Slab.Text(asset.handle)
        
        Cell(x, y, columns.actions)
        if Slab.Button("Remove", {H = 20}) then
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