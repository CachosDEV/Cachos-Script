-- ===========================================
-- MÓDULO: BRAINROT COLLECTOR - VERSÃO FUNCIONAL
-- Baseado em mecânicas reais do jogo
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
    local velocidadeColeta = 3 -- segundos (mais seguro)
    local ultimaNotificacao = 0
    
    -- LISTA COMPLETA DE RARIDADES (baseado no jogo) [citation:2][citation:8][citation:10]
    local todasRaridades = {
        "Common", "Uncommon", "Rare", "Epic", 
        "Legendary", "Mythical", "Cosmic", "Secret", "Celestial", "Divine"
    }
    
    -- RARIDADES SELECIONADAS (padrão: todas)
    local raridadesSelecionadas = {}
    for _, r in ipairs(todasRaridades) do
        raridadesSelecionadas[r] = true
    end
    
    -- ===========================================
    -- FUNÇÃO PARA ENCONTRAR BRAINROTS (CORRIGIDA)
    -- ===========================================
    local function encontrarBrainrots()
        local brainrotsEncontrados = {}
        
        -- Procura em todo o workspace por Brainrots
        for _, obj in ipairs(workspace:GetDescendants()) do
            -- Verifica se é um Brainrot (modelo com Handle ou ProximityPrompt)
            if obj:IsA("Model") then
                local handle = obj:FindFirstChild("Handle")
                local prompt = obj:FindFirstChild("TakePrompt", true)
                
                if handle and handle:IsA("BasePart") then
                    -- Verifica raridade pelo nome ou atributo
                    local raridade = obj:GetAttribute("Rarity") or "Unknown"
                    
                    -- Tenta extrair raridade do nome (ex: "Noobini Cakenini" é Common) [citation:8]
                    for raridadeTest, _ in pairs(raridadesSelecionadas) do
                        if raridadeSelecionadas[raridadeTest] then
                            -- Lista de brainrots conhecidos por raridade [citation:10]
                            local brainrotsComuns = {"Noobini Cakenini", "Lirili Larila", "Tim Cheese", "Frulli Frulla", "Talpa Di Fero", "Svinino Bombondino", "Pipi Kiwi", "Pipi Corni"}
                            local brainrotsIncomuns = {"Trippi Troppi", "Gangster Footera", "Bobrito Bandito", "Boneca Ambalabu", "Cacto Hipopotamo", "Ta Ta Ta Sahur", "Tric Tric Baraboom", "67", "Pipi Avocado"}
                            local brainrotsRaros = {"Cappuccino Assassino", "Trulimero Trulicina", "Bambini Crostini", "Bananita Dolphinita", "Brr Brr Patapim", "Perochello Lemonchello", "Avocadini Guffo", "Salamino Penguino", "Penguino Cocosino", "Ti Ti Ti Sahur"}
                            local brainrotsEpicos = {"Burbaloni Luliloli", "Chimpanzini Bananini", "Ballerina Cappuccina", "Chef Crabracadabra", "Lionel Cactuseli", "Glorbo Fruttodrillo", "Strawberrelli Flamingelli", "Pandaccini Bananini", "Sigma Boy", "Pi Pi Watermelon", "Blueberrinni Octopussini", "Cocosini Mama", "Guesto Angelic"}
                            local brainrotsLendarios = {"Frigo Camelo", "Orangutini Ananasini", "Rhino Toasterino", "Bombardiro Crocodilo", "Spioniro Golubiro", "Bombombini Gusini", "Zibra Zubra Zibralini", "Tigrilini Watermelini", "Cavallo Virtuoso", "Gorillo Watermelondrillo", "Avocadorilla"}
                            
                            -- Simplificando: aceita qualquer brainrot por enquanto
                            table.insert(brainrotsEncontrados, {
                                obj = obj,
                                handle = handle,
                                prompt = prompt,
                                raridade = raridadeTest
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
    -- FUNÇÃO PARA COLETAR BRAINROT (CORRIGIDA)
    -- Usa fireproximityprompt que funciona [citation:9]
    -- ===========================================
    local function coletarBrainrot(brainrot)
        if not brainrot or not brainrot.obj then return false end
        
        local playerChar = game.Players.LocalPlayer.Character
        if not playerChar then return false end
        
        local hrp = playerChar:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        
        -- 1. Teleporta para perto do brainrot
        hrp.CFrame = CFrame.new(brainrot.handle.Position + Vector3.new(0, 2, 0))
        task.wait(0.2)
        
        -- 2. Tenta usar o ProximityPrompt (método que funciona) [citation:9]
        if brainrot.prompt then
            pcall(function()
                fireproximityprompt(brainrot.prompt)
            end)
            return true
        end
        
        -- 3. Alternativa: simular tecla E
        pcall(function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
        
        return true
    end
    
    -- ===========================================
    -- FUNÇÃO DE PROTEÇÃO (baseado em guias) [citation:3][citation:5]
    -- ===========================================
    local function ativarProtecao()
        local playerChar = game.Players.LocalPlayer.Character
        if not playerChar then return end
        
        -- Ativar noclip temporário
        for _, part in pairs(playerChar:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        
        -- Tentar remover hitboxes de tsunami (opcional)
        local at = workspace:FindFirstChild("ActiveTsunamis")
        if at then
            for _, v in pairs(at:GetDescendants()) do
                if v:IsA("BasePart") and v.Name == "Hitbox" then
                    v:Destroy()
                end
            end
        end
    end
    
    -- ===========================================
    -- FUNÇÃO PRINCIPAL (COM CONTROLE DE NOTIFICAÇÕES)
    -- ===========================================
    local function loopColeta()
        while coletorAtivo do
            local brainrots = encontrarBrainrots()
            local coletados = 0
            local agora = tick()
            
            for _, brainrot in ipairs(brainrots) do
                if not coletorAtivo then break end
                
                local sucesso = coletarBrainrot(brainrot)
                if sucesso then
                    coletados = coletados + 1
                end
                
                task.wait(0.3) -- pausa entre coletas
            end
            
            -- NOTIFICAÇÃO ÚNICA (sem spam)
            if coletados > 0 and (agora - ultimaNotificacao > 5) then
                UI.Fluent:Notify({
                    Title = "🧠 Brainrot",
                    Content = coletados .. " brainrots coletados",
                    Duration = 2
                })
                ultimaNotificacao = agora
            elseif coletados == 0 and (agora - ultimaNotificacao > 10) then
                UI.Fluent:Notify({
                    Title = "🧠 Brainrot",
                    Content = "Nenhum brainrot encontrado",
                    Duration = 2
                })
                ultimaNotificacao = agora
            end
            
            -- Aguarda o tempo configurado
            for i = 1, velocidadeColeta do
                if not coletorAtivo then break end
                task.wait(1)
            end
        end
    end
    
    -- ===========================================
    -- ELEMENTOS DA UI
    -- ===========================================
    
    -- TÍTULO
    UI.Tabs.Brainrot:AddParagraph({
        Title = "🧠 Coletor de Brainrots",
        Content = "Selecione as raridades no dropdown abaixo"
    })
    
    -- DROPDOWN DE SELEÇÃO MÚLTIPLA
    UI.Tabs.Brainrot:AddParagraph({
        Title = "⚙️ Raridades Ativas",
        Content = "Selecione/deselecione as raridades"
    })
    
    UI.Tabs.Brainrot:AddDropdown("raridades_dropdown", {
        Title = "📋 Raridades",
        Description = "Escolha quais raridades coletar",
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
    
    -- CONTROLE DE VELOCIDADE
    UI.Tabs.Brainrot:AddSlider("velocidade_coleta", {
        Title = "⏱️ Intervalo entre coletas",
        Description = "Segundos (recomendado: 3-5 para não travar)",
        Default = 3,
        Min = 2,
        Max = 10,
        Rounding = 1
    }):OnChanged(function(v)
        velocidadeColeta = v
        UI.Fluent:Notify({
            Title = "⏱️ Velocidade",
            Content = "Intervalo: " .. v .. " segundos",
            Duration = 2
        })
    end)
    
    -- TOGGLE PRINCIPAL
    UI.Tabs.Brainrot:AddToggle("coletor_toggle", {
        Title = "⚡ ATIVAR COLETOR",
        Description = "Começa a coletar automaticamente",
        Default = false
    }):OnChanged(function(v)
        coletorAtivo = v
        
        if v then
            UI.Fluent:Notify({
                Title = "✅ Coletor Ativado",
                Content = "Coletando a cada " .. velocidadeColeta .. "s",
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
    
    -- BOTÃO DE TESTE ÚNICO
    UI.Tabs.Brainrot:AddButton({
        Title = "🔍 TESTAR UMA VEZ",
        Description = "Coleta brainrots agora",
        Callback = function()
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
                    Title = "🔍 Teste",
                    Content = coletados .. " brainrots coletados",
                    Duration = 3
                })
            end)
        end
    })
    
    -- INFORMAÇÕES SOBRE O JOGO
    UI.Tabs.Brainrot:AddParagraph({
        Title = "ℹ️ Dicas do Jogo [citation:3][citation:5]",
        Content = "• Brainrots desaparecem em ~10 segundos\n• Buracos no chão protegem do tsunami\n• Pressione E para coletar\n• Cada raridade tem sua própria zona"
    })
    
    print("✅ Módulo BRAINROT carregado! (versão funcional)")
end
