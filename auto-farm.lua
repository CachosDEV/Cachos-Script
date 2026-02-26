-- ===========================================
-- MÓDULO: AUTO FARM COMPLETO - ANIME CLASH
-- Baseado em 7 scripts open source
-- Combina: Pathfinding, Coleta, Combate, Anti-Death
-- ===========================================
return function(UI)
    if not UI or not UI.Window then return end
    
    -- CRIAR ABA FARM
    UI.Tabs.Farm = UI.Window:AddTab({ 
        Title = "⚔️ AUTO FARM", 
        Icon = "sword" 
    })
    
    -- ===========================================
    -- VARIÁVEIS DE CONTROLE
    -- ===========================================
    local farmAtivo = false
    local farmThread = nil
    local modoAtual = "Monstros" -- Monstros, Itens, Boss
    local raioBusca = 150
    autoAtacar = true
    autoColetar = true
    autoReviver = true
    autoTeleport = true
    
    -- Lista de monstros detectados
    local monstrosDetectados = {}
    local alvoAtual = nil
    
    -- Sistema de Pathfinding (baseado em autofarm6.txt)
    local PFS = game:GetService("PathfindingService")
    local path = PFS:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = false,
        AgentCanClimb = true,
        AgentMaxSlope = 45
    })
    
    -- Coordenadas de farm (baseado em autofarm3.txt)
    local farmLocations = {
        { nome = "Área 1", pos = Vector3.new(-60.43, 879.67, -244.91) },
        { nome = "Área 2", pos = Vector3.new(-12.35, 881.81, -263.19) },
        { nome = "Área 3", pos = Vector3.new(37.95, 878.07, -334.69) },
        { nome = "Área 4", pos = Vector3.new(87.55, 881.15, -416.87) },
        { nome = "Área 5", pos = Vector3.new(135.91, 942.15, -338.13) },
        { nome = "Área 6", pos = Vector3.new(320.53, 884.72, -42.79) },
        { nome = "Área 7", pos = Vector3.new(227.03, 991.95, 63.93) }
    }
    
    -- ===========================================
    -- FUNÇÕES DE UTILITÁRIO
    -- ===========================================
    local function getCharacter()
        return game.Players.LocalPlayer.Character
    end
    
    local function getHRP()
        local char = getCharacter()
        return char and char:FindFirstChild("HumanoidRootPart")
    end
    
    local function getHumanoid()
        local char = getCharacter()
        return char and char:FindFirstChildOfClass("Humanoid")
    end
    
    -- ===========================================
    -- FUNÇÃO PARA DETECTAR MONSTROS (autofarm5.txt + autofarm6.txt)
    -- ===========================================
    local function detectarMonstros()
        local lista = {}
        local hrp = getHRP()
        if not hrp then return lista end
        
        -- Procura em todo o workspace
        for _, obj in ipairs(workspace:GetDescendants()) do
            -- Verifica se é um modelo com Humanoid
            if obj:IsA("Model") then
                local humanoid = obj:FindFirstChildOfClass("Humanoid")
                local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildWhichIsA("BasePart")
                
                if humanoid and rootPart and humanoid.Health > 0 then
                    -- Ignora o próprio jogador
                    if obj ~= game.Players.LocalPlayer.Character then
                        local distancia = (rootPart.Position - hrp.Position).Magnitude
                        
                        -- Filtra por distância
                        if distancia <= raioBusca then
                            table.insert(lista, {
                                obj = obj,
                                rootPart = rootPart,
                                humanoid = humanoid,
                                nome = obj.Name,
                                distancia = distancia,
                                health = humanoid.Health,
                                maxHealth = humanoid.MaxHealth
                            })
                        end
                    end
                end
            end
            
            -- Procura por pastas de inimigos (padrão em jogos)
            if obj.Name:lower():find("enemy") or obj.Name:lower():find("mob") or obj.Name:lower():find("monster") then
                if obj:IsA("Folder") or obj:IsA("Model") then
                    for _, enemy in ipairs(obj:GetChildren()) do
                        if enemy:IsA("Model") then
                            local humanoid = enemy:FindFirstChildOfClass("Humanoid")
                            local rootPart = enemy:FindFirstChild("HumanoidRootPart")
                            if humanoid and rootPart and humanoid.Health > 0 then
                                local distancia = (rootPart.Position - hrp.Position).Magnitude
                                if distancia <= raioBusca then
                                    table.insert(lista, {
                                        obj = enemy,
                                        rootPart = rootPart,
                                        humanoid = humanoid,
                                        nome = enemy.Name,
                                        distancia = distancia,
                                        health = humanoid.Health,
                                        maxHealth = humanoid.MaxHealth
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- Ordena por distância
        table.sort(lista, function(a, b)
            return a.distancia < b.distancia
        end)
        
        return lista
    end
    
    -- ===========================================
    -- FUNÇÃO PARA DETECTAR ITENS COLETÁVEIS (autofarm5.txt)
    -- ===========================================
    local function detectarItens()
        local itens = {}
        local hrp = getHRP()
        if not hrp then return itens end
        
        -- Padrões comuns de itens coletáveis
        local palavrasChave = {"orb", "gem", "coin", "crystal", "essence", "drop", "loot", "chest", "box"}
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Part") then
                local nomeLower = obj.Name:lower()
                
                -- Verifica se é um item coletável
                for _, palavra in ipairs(palavrasChave) do
                    if nomeLower:find(palavra) then
                        local distancia = (obj.Position - hrp.Position).Magnitude
                        if distancia <= raioBusca then
                            table.insert(itens, {
                                obj = obj,
                                position = obj.Position,
                                nome = obj.Name,
                                distancia = distancia
                            })
                            break
                        end
                    end
                end
            end
        end
        
        -- Ordena por distância
        table.sort(itens, function(a, b)
            return a.distancia < b.distancia
        end)
        
        return itens
    end
    
    -- ===========================================
    -- FUNÇÃO DE MOVIMENTAÇÃO COM PATHFINDING (autofarm6.txt)
    -- ===========================================
    local function moverPara(posicao)
        local hrp = getHRP()
        local humanoid = getHumanoid()
        if not hrp or not humanoid then return false end
        
        -- Calcula caminho
        local success = pcall(function()
            path:ComputeAsync(hrp.Position, posicao)
        end)
        
        if not success or path.Status ~= Enum.PathStatus.Success then
            -- Fallback: teleporte direto
            hrp.CFrame = CFrame.new(posicao)
            return true
        end
        
        local waypoints = path:GetWaypoints()
        
        for i, waypoint in ipairs(waypoints) do
            if not farmAtivo then return false end
            
            humanoid:MoveTo(waypoint.Position)
            
            -- Aguarda chegar no waypoint
            local timeout = 0
            local reached = false
            
            local conn
            conn = humanoid.MoveToFinished:Connect(function()
                reached = true
                conn:Disconnect()
            end)
            
            while not reached and timeout < 30 and farmAtivo do
                task.wait(0.1)
                timeout = timeout + 0.1
            end
            
            conn:Disconnect()
            
            if not reached then
                -- Se não conseguiu, tenta teleporte direto
                hrp.CFrame = CFrame.new(posicao)
                return true
            end
        end
        
        return true
    end
    
    -- ===========================================
    -- FUNÇÃO DE ATAQUE (autofarm5.txt + autofarm2.txt)
    -- ===========================================
    local function atacarAlvo(alvo)
        if not alvo or not alvo.obj then return false end
        
        local hrp = getHRP()
        if not hrp then return false end
        
        -- Tenta encontrar Remote de ataque
        local remotes = {
            game:GetService("ReplicatedStorage"):FindFirstChild("rEvents"),
            game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"),
            game:GetService("ReplicatedStorage"):FindFirstChild("Events")
        }
        
        for _, remoteFolder in ipairs(remotes) do
            if remoteFolder then
                local attackRemote = remoteFolder:FindFirstChild("attackEvent") or 
                                    remoteFolder:FindFirstChild("damageEvent") or
                                    remoteFolder:FindFirstChild("combatEvent")
                
                if attackRemote then
                    pcall(function()
                        attackRemote:FireServer(alvo.obj)
                    end)
                    return true
                end
            end
        end
        
        -- Fallback: simulador de clique
        pcall(function()
            local vim = game:GetService("VirtualInputManager")
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(0.1)
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end)
        
        return true
    end
    
    -- ===========================================
    -- FUNÇÃO DE COLETA (autofarm5.txt)
    -- ===========================================
    local function coletarItem(item)
        if not item or not item.obj then return false end
        
        -- Tenta remote de coleta
        local orbEvent = game:GetService("ReplicatedStorage"):FindFirstChild("rEvents") and
                        game.ReplicatedStorage.rEvents:FindFirstChild("orbEvent")
        
        if orbEvent then
            pcall(function()
                orbEvent:FireServer("collectOrb", item.nome, "City")
            end)
            return true
        end
        
        -- Fallback: teleporta para o item
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = CFrame.new(item.position + Vector3.new(0, 2, 0))
            return true
        end
        
        return false
    end
    
    -- ===========================================
    -- FUNÇÃO DE PROTEÇÃO/ANTI-DEATH (autofarm6.txt + autofarm7.txt)
    -- ===========================================
    local function verificarPerigo()
        local hrp = getHRP()
        local humanoid = getHumanoid()
        if not hrp or not humanoid then return false end
        
        -- Verifica vida baixa
        if humanoid.Health < 20 and autoReviver then
            -- Tenta teleportar para área segura
            if #farmLocations > 0 then
                hrp.CFrame = CFrame.new(farmLocations[1].pos)
                return true
            end
        end
        
        return false
    end
    
    -- ===========================================
    -- FUNÇÃO PRINCIPAL DE FARM (loop)
    -- ===========================================
    local function loopFarm()
        while farmAtivo do
            -- Verifica perigo primeiro
            if verificarPerigo() then
                task.wait(2)
            end
            
            if modoAtual == "Monstros" then
                local monstros = detectarMonstros()
                
                if #monstros > 0 then
                    alvoAtual = monstros[1]
                    
                    -- Move para o monstro
                    moverPara(alvoAtual.rootPart.Position + Vector3.new(0, 3, 0))
                    
                    -- Ataca
                    if autoAtacar then
                        atacarAlvo(alvoAtual)
                    end
                    
                    task.wait(0.5)
                else
                    -- Se não encontrou monstros, teleporta para próxima área
                    if autoTeleport and #farmLocations > 0 then
                        local loc = farmLocations[math.random(1, #farmLocations)]
                        moverPara(loc.pos)
                        task.wait(2)
                    end
                end
                
            elseif modoAtual == "Itens" then
                local itens = detectarItens()
                
                if #itens > 0 then
                    for _, item in ipairs(itens) do
                        if not farmAtivo then break end
                        
                        if autoColetar then
                            coletarItem(item)
                        else
                            moverPara(item.position + Vector3.new(0, 2, 0))
                        end
                        
                        task.wait(0.3)
                    end
                else
                    task.wait(1)
                end
            end
            
            task.wait(0.1)
        end
    end
    
    -- ===========================================
    -- ELEMENTOS DA UI
    -- ===========================================
    
    -- SEÇÃO: CONFIGURAÇÕES GERAIS
    UI.Tabs.Farm:AddParagraph({
        Title = "⚙️ CONFIGURAÇÕES GERAIS",
        Content = "Ajuste as opções de farm abaixo"
    })
    
    -- DROPDOWN: MODO DE FARM
    UI.Tabs.Farm:AddDropdown("modo_farm", {
        Title = "🎯 MODO DE FARM",
        Values = {"Monstros", "Itens", "Boss (em breve)"},
        Default = "Monstros",
        Multi = false
    }):OnChanged(function(valor)
        modoAtual = valor
        UI.Fluent:Notify({
            Title = "✅ Modo alterado",
            Content = "Farm: " .. valor,
            Duration = 2
        })
    end)
    
    -- SLIDER: RAIO DE BUSCA
    UI.Tabs.Farm:AddSlider("raio_busca", {
        Title = "📏 RAIO DE BUSCA",
        Description = "Distância máxima para procurar alvos",
        Default = 150,
        Min = 30,
        Max = 500,
        Rounding = 10
    }):OnChanged(function(v)
        raioBusca = v
    end)
    
    -- SEÇÃO: TOGGLES
    UI.Tabs.Farm:AddParagraph({
        Title = "⚡ OPÇÕES DE AÇÃO",
        Content = "Ative/desative funcionalidades"
    })
    
    UI.Tabs.Farm:AddToggle("auto_atacar", {
        Title = "⚔️ AUTO ATACAR",
        Description = "Ataca automaticamente os monstros",
        Default = true
    }):OnChanged(function(v) autoAtacar = v end)
    
    UI.Tabs.Farm:AddToggle("auto_coletar", {
        Title = "💎 AUTO COLETAR",
        Description = "Coleta itens automaticamente",
        Default = true
    }):OnChanged(function(v) autoColetar = v end)
    
    UI.Tabs.Farm:AddToggle("auto_reviver", {
        Title = "❤️ AUTO REVIVER",
        Description = "Teleporta para área segura quando com vida baixa",
        Default = true
    }):OnChanged(function(v) autoReviver = v end)
    
    UI.Tabs.Farm:AddToggle("auto_teleport", {
        Title = "🚀 AUTO TELEPORT",
        Description = "Teleporta entre áreas quando não encontra alvos",
        Default = true
    }):OnChanged(function(v) autoTeleport = v end)
    
    -- SEÇÃO: TELEPORTS MANUAIS
    UI.Tabs.Farm:AddParagraph({
        Title = "📍 TELEPORTS RÁPIDOS",
        Content = "Clique para teleportar para uma área"
    })
    
    -- Botões de teleport para cada área
    for i, loc in ipairs(farmLocations) do
        UI.Tabs.Farm:AddButton({
            Title = "🚀 " .. loc.nome,
            Callback = function()
                local hrp = getHRP()
                if hrp then
                    hrp.CFrame = CFrame.new(loc.pos)
                    UI.Fluent:Notify({
                        Title = "✅ Teleportado",
                        Content = loc.nome,
                        Duration = 2
                    })
                end
            end
        })
    end
    
    -- SEÇÃO: MONSTROS DETECTADOS
    UI.Tabs.Farm:AddParagraph({
        Title = "👾 MONSTROS PRÓXIMOS",
        Content = "Clique em 'Atualizar' para ver a lista"
    })
    
    UI.Tabs.Farm:AddButton({
        Title = "🔄 ATUALIZAR LISTA",
        Description = "Detecta monstros na área",
        Callback = function()
            local lista = detectarMonstros()
            UI.Fluent:Notify({
                Title = "🔍 Detecção",
                Content = #lista .. " monstros encontrados",
                Duration = 3
            })
            
            -- Mostra nomes no console
            print("📋 Monstros encontrados:")
            for i, m in ipairs(lista) do
                print(i .. ". " .. m.nome .. " - " .. math.floor(m.distancia) .. "m")
            end
        end
    end)
    
    -- TOGGLE PRINCIPAL
    UI.Tabs.Farm:AddParagraph({
        Title = "⚡ CONTROLE PRINCIPAL",
        Content = "Ative para iniciar o farm automático"
    })
    
    UI.Tabs.Farm:AddToggle("farm_principal", {
        Title = "🎮 ATIVAR AUTO FARM",
        Description = "Começa o loop de farm",
        Default = false
    }):OnChanged(function(v)
        farmAtivo = v
        
        if v then
            UI.Fluent:Notify({
                Title = "✅ FARM ATIVADO",
                Content = "Modo: " .. modoAtual,
                Duration = 3
            })
            task.spawn(loopFarm)
        else
            UI.Fluent:Notify({
                Title = "❌ FARM DESATIVADO",
                Duration = 2
            })
        end
    end)
    
    -- SEÇÃO: STATUS
    UI.Tabs.Farm:AddParagraph({
        Title = "📊 STATUS",
        Content = "Informações em tempo real"
    })
    
    -- Loop de atualização de status
    task.spawn(function()
        while true do
            if farmAtivo and UI and UI.Tabs and UI.Tabs.Farm then
                local hrp = getHRP()
                local humanoid = getHumanoid()
                if hrp and humanoid then
                    -- Tenta atualizar algum elemento de status se existir
                end
            end
            task.wait(1)
        end
    end)
    
    print("✅ Módulo AUTO FARM COMPLETO carregado!")
end
