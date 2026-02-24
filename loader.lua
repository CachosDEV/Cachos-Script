print("🚀 CARREGANDO CACHOS SCRIPT...")

-- Carregar UI do repositório CachosDEV
local uiUrl = "https://raw.githubusercontent.com/CachosDEV/Cachos-Script/refs/heads/main/ui-base.lua"
local UI = loadstring(game:HttpGet(uiUrl))()

if not UI then
    warn("❌ ERRO: UI não carregou")
    return
end

print("✅ UI carregada!")

-- Lista de scripts (no MESMO repositório)
local scripts = {
    "teste",
    "auto"
}

-- Carregar cada script
for _, nome in ipairs(scripts) do
    local url = "https://raw.githubusercontent.com/CachosDEV/Cachos-Script/refs/heads/main/" .. nome .. ".lua"
    
    local func = loadstring(game:HttpGet(url))()
    if func then
        func(UI)
        print("✅ Script: " .. nome)
    else
        warn("❌ Erro ao carregar: " .. nome)
    end
end

-- Abrir na aba TESTE
if UI.Window and UI.Tabs then
    UI.Window:SelectTab(3)
    if UI.Fluent then
        UI.Fluent:Notify({
            Title = "✅ CACHOS SCRIPT",
            Content = "Scripts carregados!",
            Duration = 4
        })
    end
end

print("🎉 Tudo pronto! Clique na aba TESTE")
