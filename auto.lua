return function(UI)
    -- Adiciona funções na aba TESTE
    UI.Tabs.Teste:AddToggle("auto_toggle", {
        Title = "🌐 Auto Hop",
        Default = false
    }):OnChanged(function(v)
        print(v and "Auto Hop ON" or "Auto Hop OFF")
    end)
    
    UI.Tabs.Teste:AddInput("tempo", {
        Title = "⏱️ Intervalo (segundos)",
        Default = "120",
        Numeric = true
    })
    
    UI.Tabs.Teste:AddButton({
        Title = "🚀 Pular Agora",
        Callback = function()
            print("Pulando servidor...")
        end
    })
end
