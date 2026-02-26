-- ===========================================
-- MÓDULO: AUTO FARM - COM SELEÇÃO DE MONSTROS
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
    local modoAtual = "Monstros" -- Monstros, Itens
    local monstroSelecionado = nil -- Nome do monstro selecionado
    local raioBusca = 150
    local autoAtacar = true
    local autoColetar = true
    local autoReviver = true
    local autoTeleport = true
    
    -- Lista de monstros disponíveis
    local listaMonstros = {} -- { "Nome1", "Nome2", ... }
    local listaMonstrosCompleta = {} -- Para referência
    
    -- Alvo atual
    local alvoAtual = nil
    
    -- Sistema de Pathfinding
    local PFS = game:GetService("PathfindingService")
    local path = PFS:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = false,
        AgentCanClimb = true,
        AgentMaxSlope = 45
    })
    
    -- Coordenadas de farm
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
    -- FUNÇÃO PARA DETECTAR MONSTROS (CORRIGIDA)
    -- ===========================================
    local function detectarMonstros()
        local lista = {}
        local hrp = getHRP()
        if not hrp then return lista end
        
        -- Limpar lista de nomes para o dropdown
        listaMonstros = {}
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local humanoid = obj:FindFirstChildOfClass("Humanoid")
                local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildWhichIsA("BasePart")
                
                if humanoid and rootPart and humanoid.Health > 0 then
                    if obj ~= game.Players.LocalPlayer.Character then
                        -- CONVERSÃO CORRETA: tostring e tonumber
                        local distancia = (rootPart.Position - hrp.Position).Magnitude
                        local distanciaNum = tonumber(distancia) or 999999
                        
                        if distanciaNum <= tonumber(raioBusca) then
                            -- Adiciona à lista de monstros
                            local nomeMonstro = obj.Name
                            
                            -- Adiciona à lista de nomes (para o dropdown)
                            if not listaMonstros[nomeMonstro] then
                                table.insert(listaMonstros, nomeMonstro)
                                listaMonstrosCompleta[nomeMonstro] = true
                            end
                            
                            -- Adiciona à lista de instâncias
                            table.insert(lista, {
                                obj = obj,
                                rootPart = rootPart,
                                humanoid = humanoid,
                                nome = nomeMonstro,
                                distancia = distanciaNum,
                                health = humanoid.Health,
                                maxHealth = humanoid.MaxHealth
                            })
                        end
                    end
                end
            end
        end
        
        -- Ordenar por distância
        table.sort(lista, function(a, b)
            return a.distancia < b.distancia
        end)
        
        return lista
    end
    
    -- ===========================================
    -- FUNÇÃO PARA DETECTAR ITENS
    -- ===========================================
    local function detectarItens()
        local itens = {}
        local hrp = getHRP()
        if not hrp then return itens end
        
        local palavrasChave = {"orb", "gem", "coin", "crystal", "essence", "drop", "loot", "chest", "box"}
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local nomeLower = obj.Name:lower()
                for _, palavra in ipairs(palavrasChave) do
                    if nomeLower:find(palavra) then
                        local distancia = (obj.Position - hrp.Position).Magnitude
                        local distanciaNum = tonumber(distancia) or 999999
                        
                        if distanciaNum <= tonumber(raioBusca) then
                            table.insert(itens, {
                                obj = obj,
                                position = obj.Position,
                                nome = obj.Name,
                                distancia = distanciaNum
                            })
                            break
                        end
                    end
                end
            end
        end
        
        table.sort(itens, function(a, b)
            return a.distancia < b.distancia
        end)
        
        return itens
    end
    
    -- ===========================================
    -- FUNÇÃO PARA MOVER ATÉ O ALVO
    -- ===========================================
    local function moverPara(posicao)
        local hrp = getHRP()
        local humanoid = getHumanoid()
        if not hrp or not humanoid then return false end
        
        -- Tenta pathfinding
        local success = pcall(function()
            path:ComputeAsync(hrp.Position, posicao)
        end)
        
        if success and path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            
            for i, waypoint in ipairs(waypoints) do
                if not farmAtivo then return false end
                
                humanoid:MoveTo(waypoint.Position)
                
                local timeout = 0
                local reached = false
                
                local conn = humanoid.MoveToFinished:Connect(function()
                    reached = true
                end)
                
                while not reached and timeout < 30 and farmAtivo do
                    task.wait(0.1)
                    timeout = timeout + 0.1
                end
                
                conn:Disconnect()
            end
        else
            -- Fallback: teleporte direto
            hrp.CFrame = CFrame.new(posicao)
        end
        
        return true
    end
    
    -- ===========================================
    -- FUNÇÃO DE ATAQUE
    -- ===========================================
    local function atacarAlvo(alvo)
        if not alvo then return false end
        
        -- Tenta encontrar remote de ataque
        local remotes = {
            game:GetService("ReplicatedStorage"):FindFirstChild("rEvents"),
            game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
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
        
        return true
    end
    
    -- ===========================================
    -- FUNÇÃO DE COLETA
    -- ===========================================
    local function coletarItem(item)
        if not item then return false end
        
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
        end
        return true
    end
    
    -- ===========================================
    -- FUNÇÃO DE PROTEÇÃO
    -- ===========================================
    local function verificarPerigo()
        local humanoid = getHumanoid()
        if not humanoid then return false end
        
        if humanoid.Health < 20 and autoReviver and #farmLocations > 0 then
            local hrp = getHRP()
            if hrp then
                hrp.CFrame = CFrame.new(farmLocations[1].pos)
                return true
            end
        end
        return false
    end
    
    -- ===========================================
    -- FUNÇÃO PRINCIPAL DE FARM
    -- ===========================================
    local function loopFarm()
        while farmAtivo do
            verificarPerigo()
            
            if modoAtual == "Monstros" then
                local monstros = detectarMonstros()
                
                if #monstros > 0 then
                    for _, monstro in ipairs(monstros) do
                        if not farmAtivo then break end
                        
                        -- Verifica se o monstro é o selecionado (ou qualquer se não houver seleção)
                        if not monstroSelecionado or monstro.nome == monstroSelecionado then
                            -- Move para o monstro
                            moverPara(monstro.rootPart.Position + Vector3.new(0, 3, 0))
                            
                            -- Ataca
                            if autoAtacar then
                                atacarAlvo(monstro)
                            end
                            
                            task.wait(0.3)
                        end
                    end
                elseif autoTeleport and #farmLocations > 0 then
                    -- Se não encontrou monstros, teleporta para próxima área
                    local loc = farmLocations[math.random(1, #farmLocations)]
                    moverPara(loc.pos)
                    task.wait(2)
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
                        
                        task.wait(0.2)
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
        Values = {"Monstros", "Itens"},
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
    
    -- ===========================================
    -- NOVA SEÇÃO: SELEÇÃO DE MONSTROS
    -- ===========================================
    UI.Tabs.Farm:AddParagraph({
        Title = "👾 SELEÇÃO DE MONSTROS",
        Content = "Escolha qual monstro farmar (opcional)"
    })
    
    -- BOTÃO PARA ATUALIZAR LISTA DE MONSTROS
    UI.Tabs.Farm:AddButton({
        Title = "🔄 ATUALIZAR LISTA",
        Description = "Detecta monstros na área",
        Callback = function()
            -- Executa detecção para preencher a lista
            detectarMonstros()
            
            -- Ordena a lista alfabeticamente
            table.sort(listaMonstros)
            
            UI.Fluent:Notify({
                Title = "🔍 Detecção",
                Content = #listaMonstros .. " tipos de monstros encontrados",
                Duration = 3
            })
            
            -- Mostra no console
            print("📋 Monstros encontrados:")
            for i, nome in ipairs(listaMonstros) do
                print(i .. ". " .. nome)
            end
        end
    })
    
    -- DROPDOWN PARA SELECIONAR MONSTRO
    UI.Tabs.Farm:AddDropdown("monstro_dropdown", {
        Title = "🎯 SELECIONAR MONSTRO",
        Description = "Deixe em branco para farmar qualquer um",
        Values = listaMonstros,
        Multi = false,
        Default = nil
    }):OnChanged(function(valor)
        monstroSelecionado = valor
        if valor then
            UI.Fluent:Notify({
                Title = "✅ Monstro selecionado",
                Content = valor,
                Duration = 2
            })
        else
            UI.Fluent:Notify({
                Title = "ℹ️ Modo alterado",
                Content = "Farmando qualquer monstro",
                Duration = 2
            })
        end
    end)
    
    -- BOTÃO PARA LIMPAR SELEÇÃO
    UI.Tabs.Farm:AddButton({
        Title = "❌ LIMPAR SELEÇÃO",
        Description = "Farmar qualquer monstro",
        Callback = function()
            monstroSelecionado = nil
            UI.Fluent:Notify({
                Title = "✅ Seleção limpa",
                Content = "Farmando qualquer monstro",
                Duration = 2
            })
        end
    })
    
    -- ===========================================
    -- CONFIGURAÇÕES ADICIONAIS
    -- ===========================================
    UI.Tabs.Farm:AddParagraph({
        Title = "⚡ CONFIGURAÇÕES",
        Content = "Ajuste as opções de farm"
    })
    
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
    
    -- TOGGLES
    UI.Tabs.Farm:AddToggle("auto_atacar", {
        Title = "⚔️ AUTO ATACAR",
        Default = true
    }):OnChanged(function(v) autoAtacar = v end)
    
    UI.Tabs.Farm:AddToggle("auto_coletar", {
        Title = "💎 AUTO COLETAR",
        Default = true
    }):OnChanged(function(v) autoColetar = v end)
    
    UI.Tabs.Farm:AddToggle("auto_reviver", {
        Title = "❤️ AUTO REVIVER",
        Default = true
    }):OnChanged(function(v) autoReviver = v end)
    
    UI.Tabs.Farm:AddToggle("auto_teleport", {
        Title = "🚀 AUTO TELEPORT",
        Default = true
    }):OnChanged(function(v) autoTeleport = v end)
    
    -- ===========================================
    -- TELEPORTS MANUAIS
    -- ===========================================
    UI.Tabs.Farm:AddParagraph({
        Title = "📍 TELEPORTS RÁPIDOS",
        Content = "Clique para teleportar"
    })
    
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
    
    -- ===========================================
    -- CONTROLE PRINCIPAL
    -- ===========================================
    UI.Tabs.Farm:AddParagraph({
        Title = "⚡ CONTROLE PRINCIPAL",
        Content = "Ative para iniciar o farm"
    })
    
    UI.Tabs.Farm:AddToggle("farm_principal", {
        Title = "🎮 ATIVAR AUTO FARM",
        Default = false
    }):OnChanged(function(v)
        farmAtivo = v
        
        if v then
            UI.Fluent:Notify({
                Title = "✅ FARM ATIVADO",
                Content = "Modo: " .. modoAtual .. (monstroSelecionado and " - " .. monstroSelecionado or ""),
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
    
    print("✅ Módulo AUTO FARM carregado!")
end
