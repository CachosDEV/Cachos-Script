return function(UI)
    if not UI or not UI.Window then return end
    
    UI.Tabs.Teste = UI.Window:AddTab({ Title = "TESTE", Icon = "test-tube" })
    
    UI.Tabs.Teste:AddToggle("teste_msg", {
        Title = "📢 teste-msg",
        Default = false
    }):OnChanged(function(v)
        if v then
            print("🟢 TESTE ATIVADO!")
            if UI.Fluent then
                UI.Fluent:Notify({
                    Title = "✅ Teste",
                    Content = "Ativado!",
                    Duration = 3
                })
            end
        else
            print("🔴 TESTE DESATIVADO!")
        end
    end)
end
