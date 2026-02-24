print("🚀 CARREGANDO...")

-- Carrega a UI base
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Dede7zinho777/scripts/main/ui-base.lua"))()

-- Lista de funções para carregar
local funcoes = {
    "teste",
    "auto"
}

-- Carrega cada função
for _, nome in ipairs(funcoes) do
    local url = "https://raw.githubusercontent.com/Dede7zinho777/scripts/main/" .. nome .. ".lua"
    local func = loadstring(game:HttpGet(url))()
    func(UI)
    print("✅ Carregou: " .. nome)
end

-- Abre na aba TESTE
UI.Window:SelectTab(3)

UI.Fluent:Notify({
    Title = "✅ PRONTO!",
    Content = "Funções carregadas na aba TESTE",
    Duration = 4
})

print("🎉 Tudo carregado! Clique na aba TESTE")
