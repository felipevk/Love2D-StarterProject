local AssetManager = Object:extend()
local Slab = require 'libraries.Slab.Slab'

local columns = {
    filename = 0,
    type     = 200,
    handle   = 400,
    actions  = 600,
    warning  = 800
}

local assetTablePath = "resources/asset_table.lua"

local function Cell(rowX, rowY, offset)
    Slab.SetCursorPos(rowX + offset, rowY)
end

local function loadAssets()
    local file = assert(io.open(assetTablePath, "r"))

    local content = file:read("*a")
    file:close()

    local chunk = assert(load(content))

    return chunk()
end

local function serializeAssets(tbl)
    local lines = {"return {"}

    for _, asset in ipairs(tbl) do
        table.insert(lines, string.format(
            '    { name = %q, type = %q, handle = %q },',
            asset.name,
            asset.type,
            asset.handle
        ))
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

function AssetManager:new()
    Slab.Initialize()

    local style = Slab.GetStyle()
    style.WindowTitleFocusedColor = {0.95, 0.30, 0.55, 1.0}

    assets = loadAssets()

    resize(1.5)

    self.showFileDialog = false
    self.notification = nil
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

    return {
        name = fileName,
        type = assetType,
        handle = ""
    }
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

    self:handeFileDialog()

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
    Slab.Text("Handle:")
    Slab.SetLayoutColumn(2)
    if Slab.Input("SelectedAssetHandle", {
        Text = assets[self.selectedAsset].handle
    }) then
        assets[self.selectedAsset].handle = Slab.GetInputText()
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
        Slab.Text(asset.type)
        
        Cell(x, y, columns.handle)
        Slab.Text(asset.handle)
        
        Cell(x, y, columns.actions)
        if Slab.Button("Remove") then
            table.remove(assets,i)
        end

        if asset.handle == "" then
            Cell(x, y, columns.warning)
            Slab.Text("Handle required", {Color = {1, 0, 0, 1}})
        end

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