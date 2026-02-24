print("🚀 CARREGANDO CACHOS SCRIPT...")

-- Carregar UI base (só Main e Settings)
local uiUrl = "https://raw.githubusercontent.com/CachosDEV/Cachos-Script/refs/heads/main/ui-base.lua"
local UI = loadstring(game:HttpGet(uiUrl))()

if not UI then
    warn("❌ ERRO: UI não carregou")
    return
end

print("✅ UI base carregada! (Main + Settings)")

-- Lista de scripts (cada um cria sua própria aba)
local scripts = {
    "teste",  -- Cria aba TESTE
    "auto"    -- Cria aba AUTO HOP
}

-- Carregar cada script
for _, nome in ipairs(scripts) do
    local url = "https://raw.githubusercontent.com/CachosDEV/Cachos-Script/refs/heads/main/" .. nome .. ".lua"
    
    local func = loadstring(game:HttpGet(url))()
    if func then
        func(UI)
        print("✅ Script carregado: " .. nome)
    else
        warn("❌ Erro no script: " .. nome)
    end
end

-- Abrir na primeira aba (Main)
UI.Window:SelectTab(1)

UI.Fluent:Notify({
    Title = "✅ CACHOS SCRIPT",
    Content = "Abas: Main, Settings, TESTE, AUTO HOP",
    Duration = 5
})

print("🎉 TODAS AS ABAS CRIADAS!")
print("📌 Main + Settings (nativas)")
print("📌 TESTE (criada por teste.lua)")
print("📌 AUTO HOP (criada por auto.lua)")
