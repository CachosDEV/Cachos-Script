-- ===========================================
-- LOADER PRINCIPAL - CACHOS SCRIPT
-- ===========================================
print("🚀 CARREGANDO CACHOS SCRIPT...")

-- Carregar UI base
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CachosDEV/Cachos-Script/refs/heads/main/ui-base.lua"))()

if not UI then
    warn("❌ ERRO: UI não carregou")
    return
end

print("✅ UI Base carregada!")

-- ===========================================
-- CONFIGURAR ABA MAIN
-- ===========================================
UI.Tabs.Main:AddParagraph({
    Title = "👋 BEM-VINDO AO CACHOS SCRIPT",
    Content = "Módulos disponíveis:\n\n📢 TESTE - Funções de teste\n🌐 AUTO HOP - Pular servidores\n🧠 BRAINROT - Coletor de brainrots\n⚔️ AUTO FARM - Farm automático"
})

-- ===========================================
-- CONFIGURAR ABA SETTINGS
-- ===========================================
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

if SaveManager and InterfaceManager then
    SaveManager:SetLibrary(UI.Fluent)
    InterfaceManager:SetLibrary(UI.Fluent)
    SaveManager:IgnoreThemeSettings()
    InterfaceManager:SetFolder("CachosScript")
    SaveManager:SetFolder("CachosScript/config")
    InterfaceManager:BuildInterfaceSection(UI.Tabs.Settings)
    SaveManager:BuildConfigSection(UI.Tabs.Settings)
end

-- ===========================================
-- LISTA DE MÓDULOS
-- ===========================================
local modulos = {
    { nome = "teste", arquivo = "teste.lua" },
    { nome = "auto", arquivo = "auto.lua" },
    { nome = "brainrot", arquivo = "brainrot.lua" },
    { nome = "auto-farm", arquivo = "auto-farm.lua" }  -- NOVO MÓDULO
}

-- ===========================================
-- CARREGAR MÓDULOS
-- ===========================================
for _, modulo in ipairs(modulos) do
    local url = "https://raw.githubusercontent.com/CachosDEV/Cachos-Script/refs/heads/main/" .. modulo.arquivo
    local func = loadstring(game:HttpGet(url))()
    
    if func then
        pcall(function() func(UI) end)
        print("✅ Módulo: " .. modulo.nome)
    else
        warn("❌ Erro: " .. modulo.nome)
    end
end

-- ===========================================
-- FINALIZAR
-- ===========================================
UI.Window:SelectTab(1)

UI.Fluent:Notify({
    Title = "✅ CACHOS SCRIPT",
    Content = #modulos .. " módulos carregados!",
    Duration = 4
})

print("🎉 SISTEMA COMPLETO CARREGADO!")
print("📌 Abas: Main, Settings, TESTE, AUTO HOP, BRAINROT, ⚔️ AUTO FARM")
