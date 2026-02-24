-- ===========================================
-- SCRIPT: AUTO HOP
-- CRIA SUA PRÓPRIA ABA
-- ===========================================
return function(UI)
    if not UI or not UI.Window then return end
    
    -- CRIA a aba AUTO HOP
    UI.Tabs.AutoHop = UI.Window:AddTab({ 
        Title = "AUTO HOP", 
        Icon = "rotate-cw" 
    })
    
    -- Conteúdo da aba AUTO HOP
    UI.Tabs.AutoHop:AddParagraph({
        Title = "Auto Hop - Pular Servidores",
        Content = "Configure o Auto Hop aqui"
    })
    
    local tempo = 120
    local ativo = false
    
    UI.Tabs.AutoHop:AddToggle("auto_toggle", {
        Title = "🌐 Auto Hop",
        Description = "Ative para pular servidores automaticamente",
        Default = false
    }):OnChanged(function(v)
        ativo = v
        if v then
            print("🟢 AUTO HOP ATIVADO!")
            UI.Fluent:Notify({
                Title = "🌐 Auto Hop",
                Content = "Ativado!",
                Duration = 3
            })
        else
            print("🔴 AUTO HOP DESATIVADO!")
        end
    end)
    
    UI.Tabs.AutoHop:AddInput("tempo_input", {
        Title = "⏱️ Intervalo (segundos)",
        Description = "Tempo entre pulos",
        Default = "120",
        Numeric = true,
        Callback = function(valor)
            tempo = tonumber(valor) or 120
            print("⏱️ Intervalo:", tempo)
        end
    })
    
    UI.Tabs.AutoHop:AddButton({
        Title = "🚀 Pular Agora",
        Description = "Executa uma vez",
        Callback = function()
            print("🔄 Pulando servidor...")
            UI.Fluent:Notify({
                Title = "🚀 Auto Hop",
                Content = "Procurando servidor...",
                Duration = 3
            })
            
            -- Função de server hop
            local function pularServidor()
                local PlaceID = game.PlaceId
                local response = game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100')
                local data = game:GetService('HttpService'):JSONDecode(response)
                
                for _, servidor in pairs(data.data) do
                    if servidor.playing < servidor.maxPlayers then
                        game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, servidor.id, game.Players.LocalPlayer)
                        return
                    end
                end
                
                UI.Fluent:Notify({
                    Title = "❌ Erro",
                    Content = "Nenhum servidor disponível",
                    Duration = 3
                })
            end
            
            pularServidor()
        end
    })
    
    print("✅ Aba AUTO HOP criada!")
end
