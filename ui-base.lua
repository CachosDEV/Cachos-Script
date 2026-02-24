local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

if not Fluent then
    warn("❌ Erro ao carregar Fluent")
    return
end

local Window = Fluent:CreateWindow({
    Title = "CACHOS SCRIPT",
    SubTitle = "by CachosDEV",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark"
})

-- APENAS Main e Settings (as abas nativas da Fluent)
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- A Settings já vem com todas as configs da UI (fechar, temas, etc)

return {
    Fluent = Fluent,
    Window = Window,
    Tabs = Tabs
}
