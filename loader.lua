-- ===========================================
-- LOADER PRINCIPAL - CACHOS SCRIPT
-- TODOS OS MÓDULOS CARREGADOS
-- ===========================================

print("🚀 CARREGANDO CACHOS SCRIPT...")
print("📦 Versão 2.0 - Multi-módulos")

-- ===========================================
-- FUNÇÃO PARA VERIFICAR SE ARQUIVO CARREGOU
-- ===========================================
local function carregarArquivo(url, nome)
    local sucesso, resultado = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if sucesso and resultado then
        print("✅ " .. nome .. " carregado!")
        return resultado
    else
        warn("❌ Erro ao carregar " .. nome)
        return nil
    end
end

-- ===========================================
-- 1. CARREGAR UI BASE
-- ===========================================
local UI = carregarArquivo(
    "https://raw.githubusercontent.com/CachosDEV/Cachos-Script/refs/heads/main/ui-base.lua",
    "UI Base"
)

if not UI then
    warn("❌ ERRO FATAL: UI não carregou")
    return
end

-- ===========================================
-- 2. CONFIGURAR ABA MAIN (BEM-VINDO)
-- ===========================================
UI.Tabs.Main:AddParagraph({
    Title = "👋 Bem-vindo ao Cachos Script!",
    Content = "Este é seu hub de scripts personalizado.\n\n📌 Módulos disponíveis:\n• TESTE - Funções de teste\n• AUTO HOP - Pular servidores\n• BRAINROT - Coletor de brainrots"
})

UI.Tabs.Main:AddButton({
    Title = "📊 Informações do Script",
    Description = "Clique para ver detalhes",
    Callback = function()
        UI.Fluent:Notify({
            Title = "ℹ️ Cachos Script",
            Content = "Versão 2.0\nBy CachosDEV\n3 módulos ativos",
            Duration = 5
        })
    end
})

-- ===========================================
-- 3. CONFIGURAR ABA SETTINGS (ORIGINAL)
-- ===========================================
local SaveManager = carregarArquivo(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua",
    "SaveManager"
)

local InterfaceManager = carregarArquivo(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua",
    "InterfaceManager"
)

if SaveManager and InterfaceManager then
    SaveManager:SetLibrary(UI.Fluent)
    InterfaceManager:SetLibrary(UI.Fluent)
    
    SaveManager:IgnoreThemeSettings()
    InterfaceManager:SetFolder("CachosScript")
    SaveManager:SetFolder("CachosScript/config")
    
    InterfaceManager:BuildInterfaceSection(UI.Tabs.Settings)
    SaveManager:BuildConfigSection(UI.Tabs.Settings)
    
    print("✅ Configurações da UI carregadas")
end

-- ===========================================
-- 4. LISTA DE MÓDULOS (SCRIPTS)
-- ===========================================
local modulos = {
    { nome = "teste",     arquivo = "teste.lua"     },
    { nome = "auto",      arquivo = "auto.lua"      },
    { nome = "brainrot",  arquivo = "brainrot.lua"  }
}

-- ===========================================
-- 5. CARREGAR CADA MÓDULO
-- ===========================================
local modulosCarregados = 0

for _, modulo in ipairs(modulos) do
    local url = "https://raw.githubusercontent.com/CachosDEV/Cachos-Script/refs/heads/main/" .. modulo.arquivo
    local func = carregarArquivo(url, modulo.nome)
    
    if func then
        local execSucesso = pcall(function()
            func(UI)
        end)
        
        if execSucesso then
            print("   ✅ Função executada: " .. modulo.nome)
            modulosCarregados = modulosCarregados + 1
        else
            warn("   ❌ Erro ao executar: " .. modulo.nome)
        end
    end
end

-- ===========================================
-- 6. FINALIZAR
-- ===========================================
UI.Window:SelectTab(1) -- Abre na Main

UI.Fluent:Notify({
    Title = "✅ CACHOS SCRIPT",
    Content = modulosCarregados .. " módulos carregados!",
    Duration = 5
})

print("🎉 SISTEMA COMPLETO CARREGADO!")
print("📌 Abas disponíveis: Main, Settings, TESTE, AUTO HOP, BRAINROT")
print("🚀 Link do loader: https://raw.githubusercontent.com/CachosDEV/Cachos-Script/refs/heads/main/loader.lua")
