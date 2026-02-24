print("🚀 CARREGANDO...")

-- Verificar se conseguiu carregar a UI
local sucesso, UI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Dede7zinho777/minha-ui/main/ui-base.lua"))()
end)

if not sucesso or not UI then
    warn("❌ ERRO: Não conseguiu carregar a UI")
    return
end

print("✅ UI carregada!")

-- Lista de scripts
local scripts = {
    "teste",
    "auto"
}

-- Carregar cada script
for _, nome in ipairs(scripts) do
    local url = "https://raw.githubusercontent.com/Dede7zinho777/meus-scripts/main/" .. nome .. ".lua"
    
    local funcSucesso, func = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if funcSucesso and func then
        local execSucesso = pcall(function()
            func(UI)
        end)
        
        if execSucesso then
            print("✅ Script: " .. nome)
        else
            warn("❌ Erro ao executar: " .. nome)
        end
    else
        warn("❌ Erro ao carregar: " .. nome)
    end
end

-- Abrir na aba correta
if UI.Window and UI.Tabs then
    UI.Window:SelectTab(3)
    
    if UI.Fluent then
        UI.Fluent:Notify({
            Title = "✅ PRONTO!",
            Content = "Scripts carregados",
            Duration = 4
        })
    end
end

print("🎉 Processo finalizado!")
