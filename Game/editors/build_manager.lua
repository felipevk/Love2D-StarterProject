local BuildManager = Object:extend()
local Slab = require 'libraries.Slab.Slab'

local colors = {
    Background = { 0.09, 0.10, 0.12 },
    Panel = { 0.12, 0.13, 0.16 },
    Border = { 0.20, 0.22, 0.26 },

    Text = { 0.94, 0.95, 0.97 },
    TextMuted = { 0.65, 0.68, 0.72 },

    Accent = { 0.16, 0.47, 0.94 },
    Error = { 1.00, 0.27, 0.31 },

    Button = { 0.26, 0.32, 0.40 }
}

local function Cell(rowX, rowY, offset)
    Slab.SetCursorPos(rowX + offset, rowY)
end

function BuildManager:new()
    Slab.Initialize()

    icons = {
        font = {},
        image = {},
        sound = {},
        shader = {}
    }

    resize(1.5)

    self.notification = nil

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

    self.gameName = GameConfig.window.title

    self.running = false

    self.buildTypes = {
        { 
            name = "Windows (standalone)", 
            enabled = false, 
            buildFunc = function (gameName)
                local sourceDir = love.filesystem.getSource()
                local buildDir = sourceDir .. "/.."
                local scriptPath = "./build-standalone-win64.bat"

                return string.format(
                    'cmd /c "cd /d "%s" && call "%s" "%s" "%s""',
                    buildDir,
                    scriptPath,
                    sourceDir,
                    self.gameName
                )
        end 
        },
        {
            name = "Windows (.exe + .love)",
            enabled = false,
            buildFunc = function(gameName)
                local sourceDir = love.filesystem.getSource()
                local buildDir = sourceDir .. "/.."
                local scriptPath = sourceDir .. "/../build-love-win64.bat"

                return string.format(
                    'cmd /c "cd /d "%s" && call "%s" "%s" "%s""',
                    buildDir,
                    scriptPath,
                    sourceDir,
                    self.gameName
                )
            end
        },
        {
            name = "Web",
            enabled = false,
            buildFunc = function(gameName)
                local sourceDir = love.filesystem.getSource()
                local buildDir = sourceDir .. "/.."
                local scriptPath = sourceDir .. "/../build-web.bat"

                return string.format(
                    'cmd /c "cd /d "%s" && call "%s" "%s" "%s""',
                    buildDir,
                    scriptPath,
                    sourceDir,
                    self.gameName
                )
            end
        },
        {
            name = ".love",
            enabled = false,
            buildFunc = function(gameName)
                local sourceDir = love.filesystem.getSource()
                local buildDir = sourceDir .. "/.."
                local scriptPath = sourceDir .. "/../build-love.bat"

                return string.format(
                    'cmd /c "cd /d "%s" && call "%s" "%s" "%s""',
                    buildDir,
                    scriptPath,
                    sourceDir,
                    self.gameName
                )
            end
        }
    }
end

function BuildManager:canBuild()
    if self.running then
        return false
    end

    for _, buildType in ipairs(self.buildTypes) do
        if buildType.enabled then
            return true
        end
    end

    return false
end

function BuildManager:build(gameName)
    self.running = true
    local success = true
    local err = ''
    for i, buildType in ipairs(self.buildTypes) do
        if buildType.enabled then
            local command = buildType.buildFunc(gameName)
            print(command)

            commandSuccess, commandErr, _ = os.execute(command)
            if not commandSuccess then
                success = false
                err = err .. commandErr
            end
        end
    end

    self.running = false
    return success, err
end

function BuildManager:update(dt)
    Slab.Update(dt)

    Slab.BeginWindow("BuildManager", {
        Title = "",
        X = 100,
        Y = 21,
        W = 900,
        H = 190,
        AutoSizeWindow = false
    })

    local windowW, _ = Slab.GetWindowSize()

    Slab.PushFont(fonts.editorHeader)
    Slab.Text("Build Manager")
    Slab.PopFont()

    Slab.Separator()

    Slab.PushFont(fonts.editorMain)

    

    Slab.Text("Game Name")
    if Slab.Input("gameName", {
            Text = self.gameName
        }) then
        self.gameName = Slab.GetInputText()
    end

    Slab.Separator()

    Slab.Text("Build Types")

    local x, y = Slab.GetCursorPos()
    local innerPadding = 6
    local lineH = 30
    local rectW, rectH = windowW -  10, (innerPadding * 2) + (#self.buildTypes * lineH)

    Slab.Rectangle({
        W = rectW,
        H = rectH,
        Color = colors.Panel,
        Outline = true,
        OutlineColor = colors.Border,
        Rounding = 4
    })

    Slab.SetCursorPos(x + innerPadding, y + innerPadding)

    for i, buildType in ipairs(self.buildTypes) do
        if Slab.CheckBox(buildType.enabled, buildType.name) then
            buildType.enabled = not buildType.enabled
        end
        Slab.SetCursorPos(x + innerPadding, y + innerPadding +(lineH * (i)))
    end

    Slab.SetCursorPos(x, y + rectH + 8)

    if Slab.Button("Build", {
            W = rectW,
            Disabled = not self:canBuild()
        }) then
        
        local success, err = self:build(self.gameName)

        if success then
            self.notification = "Build(s) executed successfully."
        else
            self.notification = "Failed to run builds:\n" .. tostring(err)
        end
    end

    Slab.EndWindow()

    self:updateNotification()

    Slab.PopFont()
end

function BuildManager:updateNotification()
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

function BuildManager:draw()
    Slab.Draw()
end

return BuildManager
