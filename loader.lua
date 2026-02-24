print("🚀 CARREGANDO CACHOS SCRIPT...")

-- Carregar UI base
local uiUrl = "https://raw.githubusercontent.com/CachosDEV/Cachos-Script/refs/heads/main/ui-base.lua"
local UI = loadstring(game:HttpGet(uiUrl))()

if not UI then
    warn("❌ ERRO: UI não carregou")
    return
end

print("✅ UI base carregada!")

-- ===========================================
-- CONTEÚDO DA ABA MAIN
-- ===========================================
UI.Tabs.Main:AddParagraph({
    Title = "👋 Bem-vindo ao Cachos Script!",
    Content = "Este é seu hub de scripts personalizado.\n\n📌 Use as abas acima para acessar as funções:\n• TESTE - Funções de teste\n• AUTO HOP - Pular servidores automaticamente"
})

UI.Tabs.Main:AddButton({
    Title = "📊 Informações do Script",
    Description = "Clique para ver detalhes",
    Callback = function()
        UI.Fluent:Notify({
            Title = "ℹ️ Cachos Script",
            Content = "Versão 1.0\nBy CachosDEV",
            Duration = 4
        })
    end
})

-- ===========================================
-- CONFIGURAÇÕES DA UI (SETTINGS ORIGINAL)
-- ===========================================
-- Carregar os addons da Fluent para a Settings original
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

SaveManager:SetLibrary(UI.Fluent)
InterfaceManager:SetLibrary(UI.Fluent)

SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("CachosScript")
SaveManager:SetFolder("CachosScript/config")

InterfaceManager:BuildInterfaceSection(UI.Tabs.Settings)
SaveManager:BuildConfigSection(UI.Tabs.Settings)

-- ===========================================
-- CARREGAR SCRIPTS (CADA UM CRIA SUA ABA)
-- ===========================================
local scripts = {
    "teste",
    "auto"
}

for _, nome in ipairs(scripts) do
    local url = "https://raw.githubusercontent.com/CachosDEV/Cachos-Script/refs/heads/main/" .. nome .. ".lua"
    local func = loadstring(game:HttpGet(url))()
    if func then
        func(UI)
        print("✅ Script: " .. nome)
    else
        warn("❌ Erro: " .. nome)
    end
end

-- ===========================================
-- FINALIZAR
-- ===========================================
UI.Window:SelectTab(1) -- Abre na Main

UI.Fluent:Notify({
    Title = "✅ CACHOS SCRIPT",
    Content = "Todas as abas carregadas!",
    Duration = 4
})

print("🎉 Tudo pronto! Abas: Main, Settings, TESTE, AUTO HOP")
