-- ===========================================
-- MÓDULO: AUTO FARM (VERSÃO TESTE)
-- ===========================================
return function(UI)
    if not UI or not UI.Window then return end
    
    -- CRIAR ABA FARM
    UI.Tabs.Farm = UI.Window:AddTab({ 
        Title = "⚔️ AUTO FARM", 
        Icon = "sword" 
    })
    
    -- CONTEÚDO SIMPLES
    UI.Tabs.Farm:AddParagraph({
        Title = "✅ MÓDULO CARREGADO",
        Content = "Auto Farm funcionando corretamente!"
    })
    
    UI.Tabs.Farm:AddButton({
        Title = "🔍 TESTAR",
        Callback = function()
            UI.Fluent:Notify({
                Title = "✅ Teste",
                Content = "Auto Farm está funcionando!",
                Duration = 3
            })
        end
    })
    
    print("✅ Módulo AUTO FARM carregado com sucesso!")
end
