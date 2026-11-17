-- NEWLOC UI - exemplo com TODAS as funções
local NewlocUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/danielzandonamala-ui/newloc-ui/refs/heads/main/newloc.lua"))()

------------------------------------------------------------ JANELA
local Window = NewlocUI:CreateWindow({
	ToggleKey = Enum.KeyCode.RightControl,   -- tecla que oculta/mostra o menu por completo
	Nickname = nil,                          -- nome exibido (padrão: DisplayName)
	Avatar = nil,                            -- ID ou link da foto de perfil (padrão: headshot)
	Width = 800,
	Height = 500,
	Settings = true,                         -- false = não cria a aba Configurações
})
-- Título, subtítulo, logo, banner, textos do banner e a tela de abertura (splash)
-- ficam na tabela SOURCE no topo do newloc.lua (só quem tem a source edita).

------------------------------------------------------------ ABA 1: ELEMENTOS
local Main = Window:CreateTab({ Name = "Principal", Icon = "◆" })

local Player = Main:CreateSection("Jogador")      -- coluna esquerda/direita alterna sozinha

-- Toggle
local god = Player:CreateToggle({
	Name = "God Mode",
	CurrentValue = false,
	Flag = "godmode",                             -- nome usado na config (opcional)
	Callback = function(v) print("God Mode:", v) end,
})

-- Button
Player:CreateButton({
	Name = "Teste de notificação",
	NameButton = "Executar",
	Callback = function()
		Window:Notify({ Title = "NEWLOC", Content = "Funcionando!", Duration = 3 })
	end,
})

-- Slider
local speed = Player:CreateSlider({
	Name = "Velocidade",
	Range = { 16, 200 },
	Increment = 1,
	CurrentValue = 16,
	Suffix = "",
	Callback = function(v)
		local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = v end
	end,
})

-- Input (caixa de texto)
Player:CreateInput({
	Name = "Dar dinheiro",
	Placeholder = "Quantia...",
	CurrentValue = "",
	Callback = function(text) print("Quantia:", text) end,
})

-- Keybind (Callback roda ao apertar a tecla, OnChanged roda ao trocar a tecla)
Player:CreateKeybind({
	Name = "Atalho God Mode",
	CurrentValue = Enum.KeyCode.G,
	Callback = function() god:Set(not god:Get()) end,
	OnChanged = function(key) print("Nova tecla:", key and key.Name or "nenhuma") end,
})

-- Seção na coluna direita
local Veh = Main:CreateSection({ Name = "Veículo", Side = "Right" })

-- Dropdown
local drop = Veh:CreateDropdown({
	Name = "Veículo",
	Options = { "Sultan", "Adder", "Zentorno" },
	CurrentValue = "Sultan",
	Callback = function(v) print("Veículo:", v) end,
})

-- Selector (< >)
Veh:CreateSelector({
	Name = "Tamanho do menu",
	Options = { "Pequeno", "Normal", "Grande" },
	CurrentValue = "Normal",
	Callback = function(v) print("Tamanho:", v) end,
})

-- ColorPicker (estilo paint)
Veh:CreateColorPicker({
	Name = "Cor do veículo",
	CurrentValue = Color3.fromRGB(124, 58, 237),
	Callback = function(c) print("Cor:", c) end,
})

-- Label
local info = Veh:CreateLabel("Nenhuma ação ainda.")

-- Mudar valores por código (Set(valor, silent) - silent = não dispara Callback)
Veh:CreateButton({
	Name = "Mexer nos elementos por código",
	NameButton = "Aplicar",
	Callback = function()
		god:Set(true)
		speed:Set(100)
		drop:Set("Adder")
		info:Set("Valores alterados por código!")
	end,
})

------------------------------------------------------------ ABA 2: JANELA E CONFIG POR CÓDIGO
local Tools = Window:CreateTab({ Name = "Ferramentas", Icon = "★" })--tira isso nigger

local Win = Tools:CreateSection("Janela")

Win:CreateButton({ Name = "Minimizar / restaurar", NameButton = "Minimizar", Callback = function() Window:Minimize() end })
Win:CreateButton({ Name = "Ocultar (tecla reabre)", NameButton = "Ocultar", Callback = function() Window:Toggle() end })
Win:CreateButton({ Name = "Mudar título", NameButton = "Aplicar", Callback = function() Window:SetTitle("MEU MENU") Window:SetSubtitle("v2.0") end })
Win:CreateButton({ Name = "Mudar nickname", NameButton = "Aplicar", Callback = function() Window:SetNickname("Zazi") end })
Win:CreateButton({ Name = "Opacidade 70%", NameButton = "Aplicar", Callback = function() Window:SetOpacity(0.7) end })
Win:CreateButton({ Name = "Cor de destaque vermelha", NameButton = "Aplicar", Callback = function() Window:SetColor("Accent", Color3.fromRGB(239, 68, 68)) end })
-- Chaves de cor: Accent, Background, Sidebar, Card, Element, Text, SubText, Stroke

local Cfg = Tools:CreateSection("Config por código")

Cfg:CreateButton({
	Name = "Salvar config 'meu'",
	NameButton = "Salvar",
	Callback = function()
		local ok, err = Window:SaveConfig("meu")
		Window:Notify({ Title = ok and "Salvo" or "Erro", Content = ok and "meu.json" or tostring(err), Duration = 3 })
	end,
})

Cfg:CreateButton({
	Name = "Carregar config 'meu'",
	NameButton = "Carregar",
	Callback = function()
		local ok, err = Window:LoadConfig("meu")
		Window:Notify({ Title = ok and "Carregado" or "Erro", Content = ok and "meu.json" or tostring(err), Duration = 3 })
	end,
})

Cfg:CreateButton({
	Name = "Exportar config (console)",
	NameButton = "Exportar",
	Callback = function() print(Window:ExportConfig()) end,
})

Cfg:CreateButton({ Name = "Resetar tudo", NameButton = "Resetar", Callback = function() Window:ResetAll() end })

Cfg:CreateButton({
	Name = "Listar configs",
	NameButton = "Listar",
	Callback = function() print(table.concat(Window:ListConfigs(), ", ")) end,
})

-- Elemento que NÃO entra na config
Cfg:CreateToggle({ Name = "Não salvar este", CurrentValue = false, Save = false, Callback = print })

------------------------------------------------------------ LER FLAGS
-- Window.Flags guarda o valor atual de cada elemento
task.spawn(function()
	while task.wait(5) do
		if Window.Flags["godmode"] then print("God mode ligado") end
	end
end)

-- Carregar automaticamente uma config salva ao iniciar (descomente):
-- Window:LoadConfig("default")

Window:Notify({ Title = "NEWLOC", Content = "Menu carregado! Tecla: RightControl", Duration = 4 })
