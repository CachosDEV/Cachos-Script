-- ===========================================
-- MÓDULO: BRAINROT COLLECTOR - VERSÃO VOADORA
-- Com detecção de tsunami e voo seguro
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
    local loopAtivo = false
    local brainrotThread = nil
    local velocidadeVoo = 50
    
    -- LISTA DE RARIDADES (baseado no jogo)
    local todasRaridades = {
        "Common", "Uncommon", "Rare", "Epic", 
        "Legendary", "Mythical", "Cosmic", "Secret", "Celestial", "Divine"
    }
    
    -- RARIDADES SELECIONADAS (todas por padrão)
    local raridadesSelecionadas = {}
    for _, r in ipairs(todasRaridades) do
        raridadesSelecionadas[r] = true
    end
    
    -- ===========================================
    -- FUNÇÕES DE UTILITÁRIO
    -- ===========================================
    local function getCharacter()
        local char = game.Players.LocalPlayer.Character
        if not char then return nil end
        return char
    end
    
    local function getHRP()
        local char = getCharacter()
        if not char then return nil end
        return char:FindFirstChild("HumanoidRootPart")
    end
    
    -- ===========================================
    -- FUNÇÃO PARA DETECTAR TSUNAMI (NOVA!)
    -- ===========================================
    local function tsunamiEstaChegando()
        -- Verifica por mensagens de aviso no jogo
        local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, obj in pairs(playerGui:GetDescendants()) do
                if obj:IsA("TextLabel") then
                    local texto = obj.Text:lower()
                    if texto:find("tsunami") or texto:find("wave") or texto:find("incoming") then
                        return true
                    end
                end
            end
        end
        
        -- Verifica por partículas ou efeitos de tsunami
        local at = workspace:FindFirstChild("ActiveTsunamis")
        if at then
            for _, v in pairs(at:GetDescendants()) do
                if v:IsA("BasePart") and v.Transparency < 1 then
                    return true
                end
            end
        end
        
        return false
    end
    
    -- ===========================================
    -- FUNÇÃO PARA VOAR PARA O ALTO (NOVA!)
    -- ===========================================
    local function voarParaAlto()
        local hrp = getHRP()
        if not hrp then return false end
        
        -- Altura segura (acima do tsunami)
        local alturaSegura = 200
        local posAtual = hrp.Position
        local posAlvo = Vector3.new(posAtual.X, alturaSegura, posAtual.Z)
        
        -- Animação de voo
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
        bodyVelocity.Velocity = Vector3.new(0, velocidadeVoo, 0)
        bodyVelocity.Parent = hrp
        
        -- Espera até chegar na altura
        while hrp.Position.Y < alturaSegura - 10 do
            task.wait(0.1)
            if not coletorAtivo then
                bodyVelocity:Destroy()
                return false
            end
        end
        
        bodyVelocity:Destroy()
        return true
    end
    
    -- ===========================================
    -- FUNÇÃO PARA DESCER RAPIDAMENTE (NOVA!)
    -- ===========================================
    local function descerRapido(alvo)
        local hrp = getHRP()
        if not hrp then return false end
        
        -- Desce rápido
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
        bodyVelocity.Velocity = Vector3.new(0, -velocidadeVoo * 2, 0)
        bodyVelocity.Parent = hrp
        
        -- Espera até chegar perto do alvo
        while (hrp.Position - alvo).Magnitude > 5 do
            task.wait(0.1)
            if not coletorAtivo then
                bodyVelocity:Destroy()
                return false
            end
        end
        
        bodyVelocity:Destroy()
        return true
    end
    
    -- ===========================================
    -- FUNÇÃO PARA ENCONTRAR BRAINROTS (CORRIGIDA)
    -- ===========================================
    local function encontrarBrainrots()
        local brainrotsEncontrados = {}
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local handle = obj:FindFirstChild("Handle")
                local prompt = obj:FindFirstChild("TakePrompt", true)
                
                if handle and handle:IsA("BasePart") then
                    -- Verifica raridade (simplificado para evitar erros)
                    local raridade = "Unknown"
                    for r, selecionada in pairs(raridadesSelecionadas) do
                        if selecionada then
                            -- Aceita qualquer brainrot por enquanto
                            table.insert(brainrotsEncontrados, {
                                obj = obj,
                                handle = handle,
                                prompt = prompt,
                                posicao = handle.Position,
                                raridade = r
                            })
                            break
                        end
                    end
                end
            end
        end
        
        return brainrotsEncontrados
    end
    
    -- ===========================================
    -- FUNÇÃO PARA COLETAR BRAINROT (COM VOO)
    -- ===========================================
    local function coletarBrainrot(brainrot)
        if not brainrot then return false end
        
        -- Verifica se tem tsunami vindo
        if tsunamiEstaChegando() then
            -- Sobe para segurança
            voarParaAlto()
            task.wait(2) -- Espera tsunami passar
        end
        
        local hrp = getHRP()
        if not hrp then return false end
        
        -- SOBE para posição segura primeiro
        voarParaAlto()
        
        -- Verifica novamente se tsunami passou
        local tentativas = 0
        while tsunamiEstaChegando() and tentativas < 5 do
            task.wait(1)
            tentativas = tentativas + 1
        end
        
        if tsunamiEstaChegando() then
            return false -- Tsunami ainda ativo
        end
        
        -- DESCE rapidamente até o brainrot
        local sucessoDescida = descerRapido(brainrot.posicao)
        if not sucessoDescida then return false end
        
        -- Teleporta exato
        hrp.CFrame = CFrame.new(brainrot.posicao + Vector3.new(0, 2, 0))
        task.wait(0.2)
        
        -- Tenta coletar
        if brainrot.prompt then
            pcall(function()
                fireproximityprompt(brainrot.prompt)
            end)
            return true
        end
        
        -- Alternativa: tecla E
        pcall(function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
        
        return true
    end
    
    -- ===========================================
    -- FUNÇÃO PARA VOLTAR PARA BASE (NOVA!)
    -- ===========================================
    local function voltarParaBase()
        -- Encontra a base do jogador
        local bases = workspace:FindFirstChild("Bases")
        if not bases then return false end
        
        for _, base in pairs(bases:GetChildren()) do
            if base:IsA("Model") and base:GetAttribute("Holder") == game.Players.LocalPlayer.UserId then
                local home = base:FindFirstChild("Home")
                if home then
                    local hrp = getHRP()
                    if hrp then
                        hrp.CFrame = home.CFrame
                        return true
                    end
                end
            end
        end
        return false
    end
    
    -- ===========================================
    -- FUNÇÃO PRINCIPAL (COM LÓGICA COMPLETA)
    -- ===========================================
    local function loopColeta()
        local ultimaNotificacao = 0
        local notificacaoCooldown = 5
        
        while coletorAtivo do
            -- Encontra brainrots
            local brainrots = encontrarBrainrots()
            local coletados = 0
            local agora = tick()
            
            if #brainrots > 0 then
                for _, brainrot in ipairs(brainrots) do
                    if not coletorAtivo then break end
                    
                    -- Coleta cada brainrot
                    local sucesso = coletarBrainrot(brainrot)
                    if sucesso then
                        coletados = coletados + 1
                    end
                    
                    task.wait(0.5)
                end
                
                -- Se coletou algo, volta pra base
                if coletados > 0 then
                    voltarParaBase()
                end
            end
            
            -- NOTIFICAÇÃO CONTROLADA (sem spam)
            if coletados > 0 and (agora - ultimaNotificacao > notificacaoCooldown) then
                UI.Fluent:Notify({
                    Title = "🧠 Brainrot",
                    Content = coletados .. " brainrots coletados e guardados!",
                    Duration = 3
                })
                ultimaNotificacao = agora
            elseif coletados == 0 and (agora - ultimaNotificacao > notificacaoCooldown * 2) then
                UI.Fluent:Notify({
                    Title = "🧠 Brainrot",
                    Content = "Nenhum brainrot encontrado",
                    Duration = 2
                })
                ultimaNotificacao = agora
            end
            
            -- Aguarda um pouco
            task.wait(2)
        end
    end
    
    -- ===========================================
    -- ELEMENTOS DA UI
    -- ===========================================
    
    -- TÍTULO
    UI.Tabs.Brainrot:AddParagraph({
        Title = "🧠 Coletor Inteligente Voador",
        Content = "• Sobe para área segura\n• Detecta tsunamis\n• Desce rapidamente para coletar\n• Volta para base automaticamente"
    })
    
    -- DROPDOWN DE RARIDADES
    UI.Tabs.Brainrot:AddParagraph({
        Title = "⚙️ Raridades Alvo",
        Content = "Selecione quais coletar"
    })
    
    UI.Tabs.Brainrot:AddDropdown("raridades_dropdown", {
        Title = "📋 Raridades",
        Values = todasRaridades,
        Multi = true,
        Default = raridadesSelecionadas
    }):OnChanged(function(valores)
        raridadesSelecionadas = valores
        local count = 0
        for _, v in pairs(valores) do if v then count = count + 1 end end
        UI.Fluent:Notify({
            Title = "⚙️ Raridades",
            Content = count .. " raridades selecionadas",
            Duration = 2
        })
    end)
    
    -- CONTROLE DE VELOCIDADE DE VOO
    UI.Tabs.Brainrot:AddSlider("velocidade_voo", {
        Title = "🚀 Velocidade de Voo",
        Description = "Quão rápido sobe/desce",
        Default = 50,
        Min = 30,
        Max = 100,
        Rounding = 5
    }):OnChanged(function(v)
        velocidadeVoo = v
    end)
    
    -- TOGGLE PRINCIPAL
    UI.Tabs.Brainrot:AddToggle("coletor_toggle", {
        Title = "⚡ ATIVAR COLETOR INTELIGENTE",
        Description = "Voa, coleta e volta para base",
        Default = false
    }):OnChanged(function(v)
        coletorAtivo = v
        
        if v then
            UI.Fluent:Notify({
                Title = "✅ Coletor Ativado",
                Content = "Modo voador inteligente",
                Duration = 3
            })
            task.spawn(loopColeta)
        else
            UI.Fluent:Notify({
                Title = "❌ Coletor Desativado",
                Duration = 2
            })
        end
    end)
    
    -- BOTÃO DE TESTE
    UI.Tabs.Brainrot:AddButton({
        Title = "🔍 TESTAR UMA VEZ",
        Description = "Executa ciclo completo",
        Callback = function()
            task.spawn(function()
                local brainrots = encontrarBrainrots()
                local coletados = 0
                
                for _, brainrot in ipairs(brainrots) do
                    if coletarBrainrot(brainrot) then
                        coletados = coletados + 1
                    end
                    task.wait(0.5)
                end
                
                if coletados > 0 then
                    voltarParaBase()
                end
                
                UI.Fluent:Notify({
                    Title = "🔍 Teste",
                    Content = coletados .. " brainrots coletados",
                    Duration = 3
                })
            end)
        end
    })
    
    print("✅ MÓDULO BRAINROT VOADOR carregado!")
end
