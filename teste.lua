return function(UI)
    if not UI or not UI.Window then return end
    
    UI.Tabs.Teste = UI.Window:AddTab({ 
        Title = "TESTE", 
        Icon = "test-tube" 
    })
    
    UI.Tabs.Teste:AddParagraph({
        Title = "Área de Testes",
        Content = "Bem-vindo à aba TESTE!"
    })
    
    UI.Tabs.Teste:AddToggle("teste_msg", {
        Title = "📢 teste-msg",
        Default = false
    }):OnChanged(function(v)
        if v then
            print("🟢 TESTE ATIVADO!")
            UI.Fluent:Notify({
                Title = "✅ Teste",
                Content = "Ativado!",
                Duration = 3
            })
        else
            print("🔴 TESTE DESATIVADO!")
        end
    end)
    
    UI.Tabs.Teste:AddButton({
        Title = "🔔 Botão de Teste",
        Callback = function()
            UI.Fluent:Notify({
                Title = "📨 Teste",
                Content = "Botão funcionou!",
                Duration = 3
            })
        end
    })
    
    print("✅ Aba TESTE criada!")
end
