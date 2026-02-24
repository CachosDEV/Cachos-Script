return function(UI)
    -- CRIA a aba TESTE
    UI.Tabs.Teste = UI.Window:AddTab({ Title = "TESTE", Icon = "test-tube" })
    
    -- Adiciona o toggle teste-msg
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
end
