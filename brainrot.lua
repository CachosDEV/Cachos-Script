-- ===========================================
-- MÓDULO: BRAINROT COLLECTOR PROFISSIONAL
-- ===========================================
return function(UI)
    if not UI or not UI.Window then return end
    
    -- CRIAR ABA BRAINROT
    UI.Tabs.Brainrot = UI.Window:AddTab({ 
        Title = "BRAINROT", 
        Icon = "brain" 
    })
    
    -- ===========================================
    -- VARIÁVEIS DE CONTROLE
    -- ===========================================
    local coletorAtivo = false
    local brainrotThread = nil
    local velocidadeColeta = 1 -- segundos entre tentativas
    
    -- LISTA COMPLETA DE RARIDADES DO JOGO
    local raridadesDisponiveis = {
        "Comum",
        "Incomum",
        "Raro",
        "Épico",
        "Lendário",
        "Mítico",
        "Divino",
        "Secreto"
    }
    
    -- RARIDADES SELECIONADAS (inicia com todas)
    local raridadesSelecionadas = {}
    for _, r in ipairs(raridadesDisponiveis) do
        raridadesSelecionadas[r] = true
    end
    
    -- ===========================================
    -- FUNÇÃO GODMODE (PREVINE MORTE)
    -- ===========================================
    local function ativarProtecao()
        -- Remove hitboxes do tsunami (código do source2.txt)
        local at = workspace:FindFirstChild("ActiveTsunamis")
        if at then
            for _, v in pairs(at:GetDescendants()) do
                if v:IsA("BasePart") and v.Name == "Hitbox" then
                    v:Destroy()
                end
            end
        end
        
        -- Torna tsunami invisível (não afeta colisão)
        for _, v in pairs(at:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Transparency = 1
            end
        end
        
        -- Proteção extra: noclip temporário
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
    
    -- ===========================================
    -- FUNÇÃO PARA ENCONTRAR BRAINROTS POR RARIDADE
    -- ===========================================
    local function encontrarBrainrots()
        local brainrotsEncontrados = {}
        local ab = workspace:FindFirstChild("ActiveBrainrots")
        if not ab then return brainrotsEncontrados end
        
        -- Para cada raridade selecionada
        for raridade, selecionada in pairs(raridadesSelecionadas) do
            if selecionada then
                local pasta = ab:FindFirstChild(raridade)
                if pasta then
                    for _, brainrot in pairs(pasta:GetChildren()) do
                        if brainrot:IsA("Model") then
                            table.insert(brainrotsEncontrados, brainrot)
                        end
                    end
                end
            end
        end
        
        return brainrotsEncontrados
    end
    
    -- ===========================================
    -- FUNÇÃO PARA COLETAR BRAINROT COM SEGURANÇA
    -- ===========================================
    local function coletarBrainrot(brainrot)
        if not brainrot then return false end
        
        -- Ativar proteção antes da coleta
        ativarProtecao()
        
        -- Encontrar parte principal
        local primaryPart = brainrot.PrimaryPart or brainrot:FindFirstChild("Handle") or brainrot:FindFirstChildWhichIsA("BasePart")
        if not primaryPart then return false end
        
        -- Teleportar para o brainrot
        local playerChar = game.Players.LocalPlayer.Character
        if not playerChar then return false end
        
        local hrp = playerChar:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        
        -- POSIÇÃO SEGURA: teleporta levemente acima
        local posAlvo = primaryPart.Position + Vector3.new(0, 3, 0)
        hrp.CFrame = CFrame.new(posAlvo)
        
        -- Pequena pausa para o jogo processar
        task.wait(0.3)
        
        -- Tentar ativar o prompt de coleta
        local prompt = brainrot:FindFirstChild("TakePrompt", true)
        if prompt and prompt:IsA("ProximityPrompt") then
            pcall(function()
                fireproximityprompt(prompt)
            end)
            return true
        end
        
        -- Se não achou prompt, tenta por toque
        if primaryPart then
            pcall(function()
                firetouchinterest(hrp, primaryPart, 0)
                task.wait(0.1)
                firetouchinterest(hrp, primaryPart, 1)
            end)
            return true
        end
        
        return false
    end
    
    -- ===========================================
    -- FUNÇÃO PRINCIPAL DO LOOP DE COLETA
    -- ===========================================
    local function loopColeta()
        while coletorAtivo do
            -- Encontrar brainrots disponíveis
            local brainrots = encontrarBrainrots()
            
            if #brainrots > 0 then
                UI.Fluent:Notify({
                    Title = "🧠 Brainrot",
                    Content = #brainrots .. " brainrots encontrados!",
                    Duration = 2
                })
                
                -- Coletar cada brainrot
                for _, brainrot in ipairs(brainrots) do
                    if not coletorAtivo then break end
                    
                    local sucesso = coletarBrainrot(brainrot)
                    if sucesso then
                        print("✅ Coletou:", brainrot.Name)
                    end
                    
                    task.wait(0.5) -- pausa entre coletas
                end
            else
                -- Se não achou nada, espera e tenta de novo
                UI.Fluent:Notify({
                    Title = "🧠 Brainrot",
                    Content = "Nenhum brainrot encontrado...",
                    Duration = 2
                })
            end
            
            -- Aguardar intervalo configurado
            for i = velocidadeColeta, 1, -1 do
                if not coletorAtivo then break end
                task.wait(1)
            end
        end
    end
    
    -- ===========================================
    -- ELEMENTOS DA UI
    -- ===========================================
    
    -- PARÁGRAFO INFORMATIVO
    UI.Tabs.Brainrot:AddParagraph({
        Title = "🧠 Coletor de Brainrots",
        Content = "Selecione as raridades e ative a coleta automática.\nO sistema protege contra mortes por tsunami."
    })
    
    -- ===========================================
    -- SELETOR MÚLTIPLO DE RARIDADES
    -- ===========================================
    UI.Tabs.Brainrot:AddParagraph({
        Title = "⚙️ Raridades Ativas",
        Content = "Clique nos botões abaixo para ativar/desativar"
    })
    
    -- Criar botões para cada raridade
    for _, raridade in ipairs(raridadesDisponiveis) do
        -- Frame para cada raridade
        UI.Tabs.Brainrot:AddToggle("raridade_" .. raridade, {
            Title = "🎯 " .. raridade,
            Description = "Ativar coleta de brainrots " .. raridade,
            Default = true
        }):OnChanged(function(v)
            raridadesSelecionadas[raridade] = v
            local status = v and "ativada" or "desativada"
            print("✅ Raridade " .. raridade .. " " .. status)
            
            UI.Fluent:Notify({
                Title = "⚙️ Raridade",
                Content = raridade .. " " .. status,
                Duration = 2
            })
        end)
    end
    
    -- ===========================================
    -- CONTROLES DE VELOCIDADE
    -- ===========================================
    UI.Tabs.Brainrot:AddParagraph({
        Title = "⏱️ Configurações de Coleta",
        Content = "Ajuste o intervalo entre verificações"
    })
    
    UI.Tabs.Brainrot:AddSlider("velocidade_coleta", {
        Title = "⚡ Velocidade de Coleta",
        Description = "Tempo entre verificações (segundos)",
        Default = 1,
        Min = 0.5,
        Max = 5,
        Rounding = 0.5
    }):OnChanged(function(v)
        velocidadeColeta = v
        print("⏱️ Velocidade:", v)
    end)
    
    -- ===========================================
    -- TOGGLE PRINCIPAL DO COLETOR
    -- ===========================================
    UI.Tabs.Brainrot:AddToggle("coletor_toggle", {
        Title = "⚡ ATIVAR COLETOR AUTOMÁTICO",
        Description = "Começa a coletar brainrots automaticamente",
        Default = false
    }):OnChanged(function(v)
        coletorAtivo = v
        
        if v then
            -- Contar quantas raridades estão ativas
            local count = 0
            for _, ativa in pairs(raridadesSelecionadas) do
                if ativa then count = count + 1 end
            end
            
            UI.Fluent:Notify({
                Title = "✅ Coletor Ativado",
                Content = count .. " raridades selecionadas",
                Duration = 4
            })
            
            -- Iniciar loop
            task.spawn(loopColeta)
            
        else
            UI.Fluent:Notify({
                Title = "❌ Coletor Desativado",
                Content = "Processo interrompido",
                Duration = 3
            })
        end
    end)
    
    -- ===========================================
    -- BOTÃO DE COLETA ÚNICA (TESTE)
    -- ===========================================
    UI.Tabs.Brainrot:AddButton({
        Title = "🔍 COLETAR AGORA (UMA VEZ)",
        Description = "Executa uma única busca e coleta",
        Callback = function()
            UI.Fluent:Notify({
                Title = "🔍 Coletando...",
                Content = "Procurando brainrots",
                Duration = 2
            })
            
            task.spawn(function()
                local brainrots = encontrarBrainrots()
                local coletados = 0
                
                for _, brainrot in ipairs(brainrots) do
                    if coletarBrainrot(brainrot) then
                        coletados = coletados + 1
                    end
                    task.wait(0.3)
                end
                
                UI.Fluent:Notify({
                    Title = "✅ Coleta Manual",
                    Content = coletados .. " brainrots coletados",
                    Duration = 3
                })
            end)
        end
    })
    
    -- ===========================================
    -- BOTÕES DE ATALHO (SELECIONAR/DESELECIONAR TODOS)
    -- ===========================================
    UI.Tabs.Brainrot:AddButton({
        Title = "✅ Selecionar Todas Raridades",
        Callback = function()
            for raridade, _ in pairs(raridadesSelecionadas) do
                raridadesSelecionadas[raridade] = true
            end
            UI.Fluent:Notify({
                Title = "✅ Todas selecionadas",
                Content = "Todas as raridades ativadas",
                Duration = 2
            })
        end
    })
    
    UI.Tabs.Brainrot:AddButton({
        Title = "❌ Deselecionar Todas",
        Callback = function()
            for raridade, _ in pairs(raridadesSelecionadas) do
                raridadesSelecionadas[raridade] = false
            end
            UI.Fluent:Notify({
                Title = "❌ Todas deselecionadas",
                Content = "Nenhuma raridade ativa",
                Duration = 2
            })
        end
    })
    
    -- ===========================================
    -- SEÇÃO INFORMATIVA SOBRE SEGURANÇA
    -- ===========================================
    UI.Tabs.Brainrot:AddParagraph({
        Title = "🛡️ Sistema de Segurança",
        Content = "• Remove hitboxes do tsunami\n• Torna tsunami invisível\n• Ativa noclip temporário\n• Teleporta para posição segura"
    })
    
    print("✅ Módulo BRAINROT carregado! (Coletor profissional com " .. #raridadesDisponiveis .. " raridades)")
end
