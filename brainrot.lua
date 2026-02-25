-- ===========================================
-- MÓDULO: BRAINROT COLLECTOR PROFISSIONAL
-- CORRIGIDO: Com Dropdown e Anti-Travamento
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
    local velocidadeColeta = 2 -- segundos (aumentado para não travar)
    
    -- LISTA COMPLETA DE RARIDADES
    local todasRaridades = {
        "Comum", "Incomum", "Raro", "Épico", 
        "Lendário", "Mítico", "Divino", "Secreto"
    }
    
    -- RARIDADES SELECIONADAS (inicia com algumas padrão)
    local raridadesSelecionadas = {
        "Raro", "Épico", "Lendário", "Mítico", "Divino", "Secreto"
    }
    
    -- ===========================================
    -- FUNÇÃO GODMODE (adaptada do source2.txt)
    -- ===========================================
    local function ativarProtecao()
        -- Remove hitboxes do tsunami
        local at = workspace:FindFirstChild("ActiveTsunamis")
        if at then
            for _, v in pairs(at:GetDescendants()) do
                if v:IsA("BasePart") and v.Name == "Hitbox" then
                    v:Destroy()
                end
            end
        end
        
        -- Torna tsunami invisível
        if at then
            for _, v in pairs(at:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Transparency = 1
                end
            end
        end
    end
    
    -- ===========================================
    -- FUNÇÃO PARA ENCONTRAR BRAINROTS
    -- ===========================================
    local function encontrarBrainrots()
        local brainrotsEncontrados = {}
        local ab = workspace:FindFirstChild("ActiveBrainrots")
        if not ab then return brainrotsEncontrados end
        
        -- Para cada raridade selecionada
        for _, raridade in ipairs(raridadesSelecionadas) do
            local pasta = ab:FindFirstChild(raridade)
            if pasta then
                for _, brainrot in pairs(pasta:GetChildren()) do
                    if brainrot:IsA("Model") and not brainrot:GetAttribute("Coletado") then
                        -- Marca para não coletar repetido
                        brainrot:SetAttribute("Coletado", true)
                        table.insert(brainrotsEncontrados, brainrot)
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
        
        -- Ativar proteção
        ativarProtecao()
        
        -- Encontrar parte principal
        local primaryPart = brainrot.PrimaryPart or brainrot:FindFirstChild("Handle") or brainrot:FindFirstChildWhichIsA("BasePart")
        if not primaryPart then return false end
        
        -- Teleportar para o brainrot (posição segura)
        local playerChar = game.Players.LocalPlayer.Character
        if not playerChar then return false end
        
        local hrp = playerChar:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        
        -- POSIÇÃO SEGURA: teleporta levemente acima
        hrp.CFrame = CFrame.new(primaryPart.Position + Vector3.new(0, 5, 0))
        
        -- Aguarda um pouco
        task.wait(0.3)
        
        -- Tentar ativar o prompt de coleta (igual no source2.txt)
        local prompt = brainrot:FindFirstChild("TakePrompt", true)
        if prompt and prompt:IsA("ProximityPrompt") then
            pcall(function()
                fireproximityprompt(prompt)
            end)
            return true
        end
        
        return false
    end
    
    -- ===========================================
    -- FUNÇÃO PRINCIPAL (COM ANTI-TRAVAMENTO)
    -- ===========================================
    local function loopColeta()
        while coletorAtivo do
            -- Encontrar brainrots
            local brainrots = encontrarBrainrots()
            
            if #brainrots > 0 then
                -- Coleta apenas 1 por ciclo para não travar
                local coletado = coletarBrainrot(brainrots[1])
                
                if coletado then
                    UI.Fluent:Notify({
                        Title = "🧠 Brainrot",
                        Content = "Coletado: " .. brainrots[1].Name,
                        Duration = 2
                    })
                end
            end
            
            -- ESPERA OBRIGATÓRIA para não travar o jogo
            for i = 1, velocidadeColeta do
                if not coletorAtivo then break end
                task.wait(1) -- 1 segundo de cada vez
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
    
    -- ===========================================
    -- DROPDOWN DE SELEÇÃO MÚLTIPLA (CORRIGIDO)
    -- ===========================================
    
    -- Texto explicativo
    UI.Tabs.Brainrot:AddParagraph({
        Title = "⚙️ Raridades Ativas",
        Content = "Clique para selecionar/deselecionar"
    })
    
    -- Dropdown de múltipla escolha
    UI.Tabs.Brainrot:AddDropdown("raridades_dropdown", {
        Title = "📋 Raridades",
        Description = "Selecione as raridades que deseja coletar",
        Values = todasRaridades,
        Multi = true, -- Permite múltipla seleção
        Default = raridadesSelecionadas
    }):OnChanged(function(valores)
        -- Atualiza lista de raridades selecionadas
        raridadesSelecionadas = {}
        for raridade, selecionada in pairs(valores) do
            if selecionada then
                table.insert(raridadesSelecionadas, raridade)
            end
        end
        
        UI.Fluent:Notify({
            Title = "⚙️ Raridades",
            Content = #raridadesSelecionadas .. " raridades selecionadas",
            Duration = 2
        })
    end)
    
    -- ===========================================
    -- CONTROLES DE VELOCIDADE
    -- ===========================================
    UI.Tabs.Brainrot:AddSlider("velocidade_coleta", {
        Title = "⏱️ Velocidade de Coleta",
        Description = "Segundos entre coletas (maior = mais seguro)",
        Default = 2,
        Min = 1,
        Max = 5,
        Rounding = 1
    }):OnChanged(function(v)
        velocidadeColeta = v
        print("⏱️ Velocidade:", v)
    end)
    
    -- ===========================================
    -- TOGGLE PRINCIPAL (COM ANTI-TRAVAMENTO)
    -- ===========================================
    UI.Tabs.Brainrot:AddToggle("coletor_toggle", {
        Title = "⚡ ATIVAR COLETOR",
        Description = "ATENÇÃO: Use velocidade 2 ou mais para não travar",
        Default = false
    }):OnChanged(function(v)
        coletorAtivo = v
        
        if v then
            UI.Fluent:Notify({
                Title = "✅ Coletor Ativado",
                Content = "Coletando a cada " .. velocidadeColeta .. "s",
                Duration = 3
            })
            
            -- Iniciar loop em thread separada
            task.spawn(loopColeta)
            
        else
            UI.Fluent:Notify({
                Title = "❌ Coletor Desativado",
                Duration = 2
            })
        end
    end)
    
    -- ===========================================
    -- BOTÃO DE TESTE ÚNICO
    -- ===========================================
    UI.Tabs.Brainrot:AddButton({
        Title = "🔍 TESTAR UMA VEZ",
        Description = "Coleta 1 brainrot para testar",
        Callback = function()
            task.spawn(function()
                local brainrots = encontrarBrainrots()
                if #brainrots > 0 then
                    coletarBrainrot(brainrots[1])
                    UI.Fluent:Notify({
                        Title = "✅ Teste",
                        Content = "Coletou: " .. brainrots[1].Name,
                        Duration = 2
                    })
                else
                    UI.Fluent:Notify({
                        Title = "❌ Teste",
                        Content = "Nenhum brainrot encontrado",
                        Duration = 2
                    })
                end
            end)
        end
    })
    
    -- ===========================================
    -- AVISO IMPORTANTE
    -- ===========================================
    UI.Tabs.Brainrot:AddParagraph({
        Title = "⚠️ IMPORTANTE",
        Content = "• Use velocidade 2 ou mais\n• Não deixe o coletor ligado sem necessidade\n• O jogo pode travar se a velocidade for muito baixa"
    })
    
    print("✅ Módulo BRAINROT carregado! (com dropdown e anti-travamento)")
end
