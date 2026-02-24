-- ===========================================
-- AUTO HOP - COMPLETO E FUNCIONAL
-- ===========================================
return function(UI)
    if not UI or not UI.Window then return end
    
    -- CRIAR ABA AUTO HOP
    UI.Tabs.AutoHop = UI.Window:AddTab({ 
        Title = "AUTO HOP", 
        Icon = "rotate-cw" 
    })
    
    -- VARIÁVEIS DE CONTROLE
    local tempo = 120
    local autoHopAtivo = false
    local threadAutoHop = nil
    
    -- ===========================================
    -- FUNÇÃO DE SERVER HOP
    -- ===========================================
    local function pularServidor()
        local PlaceID = game.PlaceId
        local sucesso, resultado = pcall(function()
            local response = game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100')
            local data = game:GetService('HttpService'):JSONDecode(response)
            
            for _, servidor in pairs(data.data) do
                if servidor.playing < servidor.maxPlayers then
                    return servidor.id
                end
            end
            return nil
        end)
        
        if sucesso and resultado then
            UI.Fluent:Notify({
                Title = "🚀 Auto Hop",
                Content = "Servidor encontrado! Teleportando...",
                Duration = 3
            })
            wait(1)
            game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, resultado, game.Players.LocalPlayer)
            return true
        else
            UI.Fluent:Notify({
                Title = "❌ Auto Hop",
                Content = "Nenhum servidor disponível",
                Duration = 3
            })
            return false
        end
    end
    
    -- ===========================================
    -- FUNÇÃO DO LOOP AUTOMÁTICO
    -- ===========================================
    local function iniciarLoopAutoHop()
        while autoHopAtivo do
            UI.Fluent:Notify({
                Title = "⏳ Auto Hop",
                Content = "Procurando servidor em " .. tempo .. " segundos...",
                Duration = 3
            })
            
            -- Contagem regressiva
            for i = tempo, 1, -1 do
                if not autoHopAtivo then break end
                if i <= 5 then -- Notifica nos últimos 5 segundos
                    UI.Fluent:Notify({
                        Title = "⏰ Auto Hop",
                        Content = "Trocando servidor em " .. i .. " segundos...",
                        Duration = 1
                    })
                end
                wait(1)
            end
            
            if autoHopAtivo then
                pularServidor()
            end
        end
    end
    
    -- ===========================================
    -- ELEMENTOS DA UI
    -- ===========================================
    UI.Tabs.AutoHop:AddParagraph({
        Title = "🌐 Auto Hop - Pular Servidores",
        Content = "Configure o tempo e ative para começar"
    })
    
    -- INPUT DE TEMPO
    UI.Tabs.AutoHop:AddInput("tempo_input", {
        Title = "⏱️ Intervalo (segundos)",
        Description = "Digite o tempo entre cada pulo",
        Default = tostring(tempo),
        Numeric = true,
        Callback = function(valor)
            local novo = tonumber(valor)
            if novo and novo > 0 then
                tempo = novo
                UI.Fluent:Notify({
                    Title = "⏱️ Tempo Atualizado",
                    Content = "Auto Hop mudará a cada " .. tempo .. " segundos",
                    Duration = 3
                })
                print("✅ Tempo alterado para:", tempo)
            end
        end
    })
    
    -- TOGGLE PARA ATIVAR/DESATIVAR
    UI.Tabs.AutoHop:AddToggle("auto_toggle", {
        Title = "⚡ Ativar Auto Hop",
        Description = "Começa a pular servidores automaticamente",
        Default = false
    }):OnChanged(function(v)
        autoHopAtivo = v
        
        if v then
            UI.Fluent:Notify({
                Title = "✅ Auto Hop Ativado",
                Content = "Trocando servidor a cada " .. tempo .. " segundos",
                Duration = 4
            })
            
            -- Inicia o loop em uma thread separada
            task.spawn(iniciarLoopAutoHop)
            
        else
            UI.Fluent:Notify({
                Title = "❌ Auto Hop Desativado",
                Content = "Processo interrompido",
                Duration = 3
            })
        end
    end)
    
    -- BOTÃO PARA PULAR AGORA
    UI.Tabs.AutoHop:AddButton({
        Title = "🚀 Pular Servidor Agora",
        Description = "Executa uma única vez",
        Callback = function()
            pularServidor()
        end
    })
    
    -- BOTÃO PARA VER TEMPO ATUAL
    UI.Tabs.AutoHop:AddButton({
        Title = "⏱️ Ver Tempo Configurado",
        Callback = function()
            UI.Fluent:Notify({
                Title = "⏱️ Tempo Atual",
                Content = "Intervalo: " .. tempo .. " segundos",
                Duration = 3
            })
        end
    })
    
    print("✅ Aba AUTO HOP criada com temporizador!")
end
