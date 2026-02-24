local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

if not Fluent then
    warn("❌ Erro ao carregar Fluent")
    return
end

local Window = Fluent:CreateWindow({
    Title = "MEU SCRIPT",
    SubTitle = "by Dede7zinho777",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

return {
    Fluent = Fluent,
    Window = Window,
    Tabs = Tabs
}
