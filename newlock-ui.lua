--[[
	NEWLOC UI  -  biblioteca de UI estilo menu FiveM (Roblox / Luau)

	Janela:   Library:CreateWindow({ Name, Subtitle, ToggleKey, Nickname, Logo, Banner, Avatar, Width, Height, Settings })
	Aba:      Window:CreateTab({ Name, Icon })
	Secao:    Tab:CreateSection("Nome")  ou  { Name = "Nome", Side = "Left"/"Right" }
	Elementos (Section:):
		CreateButton, CreateToggle, CreateSlider, CreateDropdown, CreateSelector,
		CreateInput, CreateKeybind, CreateColorPicker, CreateLabel
	Janela:   Notify, Toggle, Minimize, SaveConfig, LoadConfig, ExportConfig, ImportConfig, Destroy
	Todo elemento com Flag (ou nome) entra na config exportada/salva.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Library = {}
local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab
local Section = {}
Section.__index = Section

local FONT, FONTB, FONTX = Enum.Font.Gotham, Enum.Font.GothamBold, Enum.Font.GothamBlack
local LEFT, RIGHT, CENTER = Enum.TextXAlignment.Left, Enum.TextXAlignment.Right, Enum.TextXAlignment.Center
local AUTOY, AUTOX = Enum.AutomaticSize.Y, Enum.AutomaticSize.X

------------------------------------------------------------------ tema

local DefaultTheme = {
	Accent = Color3.fromRGB(124, 58, 237),
	Background = Color3.fromRGB(13, 12, 20),
	Sidebar = Color3.fromRGB(16, 14, 25),
	Card = Color3.fromRGB(20, 18, 31),
	Element = Color3.fromRGB(30, 27, 44),
	Text = Color3.fromRGB(245, 245, 250),
	SubText = Color3.fromRGB(160, 155, 182),
	Stroke = Color3.fromRGB(48, 43, 70),
}

local ThemeOrder = {
	{ "Accent", "Cor principal (destaque)" },
	{ "Background", "Fundo do menu" },
	{ "Sidebar", "Barra lateral" },
	{ "Card", "Cartões (seções)" },
	{ "Element", "Elementos" },
	{ "Text", "Texto" },
	{ "SubText", "Texto secundário" },
	{ "Stroke", "Bordas / desligado" },
}

local Presets = {
	Roxo = Color3.fromRGB(124, 58, 237),
	Azul = Color3.fromRGB(59, 130, 246),
	Ciano = Color3.fromRGB(6, 182, 212),
	Verde = Color3.fromRGB(34, 197, 94),
	Laranja = Color3.fromRGB(249, 115, 22),
	Vermelho = Color3.fromRGB(239, 68, 68),
	Rosa = Color3.fromRGB(236, 72, 153),
}
local PresetOrder = { "Roxo", "Azul", "Ciano", "Verde", "Laranja", "Vermelho", "Rosa" }

local Swatches = {
	Color3.fromRGB(124, 58, 237), Color3.fromRGB(59, 130, 246), Color3.fromRGB(6, 182, 212),
	Color3.fromRGB(34, 197, 94), Color3.fromRGB(234, 179, 8), Color3.fromRGB(249, 115, 22),
	Color3.fromRGB(239, 68, 68), Color3.fromRGB(236, 72, 153), Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(150, 150, 165), Color3.fromRGB(30, 27, 44), Color3.fromRGB(0, 0, 0),
}

------------------------------------------------------------------ helpers

local function New(class, props, children)
	local inst = Instance.new(class)
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then parent = v else inst[k] = v end
	end
	for _, c in ipairs(children or {}) do c.Parent = inst end
	if parent then inst.Parent = parent end
	return inst
end

local function Tween(obj, props, t)
	local tw = TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function Round(inst, r)
	return New("UICorner", { CornerRadius = UDim.new(0, r or 6), Parent = inst })
end

local function Stroke(inst, color, th)
	return New("UIStroke", { Color = color, Thickness = th or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = inst })
end

local function Pad(inst, l, t, r, b)
	t = t or l
	return New("UIPadding", {
		PaddingLeft = UDim.new(0, l), PaddingTop = UDim.new(0, t),
		PaddingRight = UDim.new(0, r or l), PaddingBottom = UDim.new(0, b or t), Parent = inst,
	})
end

local function List(inst, pad, dir)
	return New("UIListLayout", {
		Padding = UDim.new(0, pad or 0), SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = dir or Enum.FillDirection.Vertical, Parent = inst,
	})
end

local function ToHex(c)
	return string.format("#%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

local function FromHex(s)
	s = (tostring(s):gsub("#", ""):gsub("%s", ""))
	if #s == 3 then s = s:sub(1, 1):rep(2) .. s:sub(2, 2):rep(2) .. s:sub(3, 3):rep(2) end
	if #s ~= 6 or not tonumber(s, 16) then return nil end
	return Color3.fromRGB(tonumber(s:sub(1, 2), 16), tonumber(s:sub(3, 4), 16), tonumber(s:sub(5, 6), 16))
end

local function Escape(s)
	return (tostring(s):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function Mouse()
	return UserInputService:GetMouseLocation()
end

local function IsPress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end

local function IsMove(i)
	return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

-- aceita ID numerico, rbxassetid:// ou link (precisa de writefile + getcustomasset no executor)
local function ResolveImage(src)
	src = tostring(src or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if src == "" then return "" end
	if tonumber(src) then return "rbxassetid://" .. src end
	if src:find("^rbxasset") then return src end
	if src:find("^https?://") then
		if writefile and getcustomasset and isfile and makefolder and isfolder then
			local ok, res = pcall(function()
				if not isfolder("NewlocUI") then makefolder("NewlocUI") end
				if not isfolder("NewlocUI/img") then makefolder("NewlocUI/img") end
				local sum = 0
				for i = 1, #src do sum = (sum * 31 + src:byte(i)) % 4294967291 end
				local path = "NewlocUI/img/" .. sum .. ".png"
				if not isfile(path) then writefile(path, game:HttpGet(src)) end
				return getcustomasset(path)
			end)
			if ok then return res end
		end
	end
	return ""
end

local function Label(w, parent, props, key)
	local p = {
		BackgroundTransparency = 1, Font = FONT, TextSize = 13, TextXAlignment = LEFT,
		Text = "", Parent = parent,
	}
	for k, v in pairs(props or {}) do p[k] = v end
	local l = New("TextLabel", p)
	w:Bind(l, "TextColor3", key or "Text")
	return l
end

local function MakeDraggable(w, handle, target, onClick)
	local dragging, moved, startM, startPos = false, false, nil, nil
	w:Connect(handle.InputBegan, function(i)
		if IsPress(i) then
			dragging, moved = true, false
			startM, startPos = Mouse(), target.Position
		end
	end)
	w:Connect(UserInputService.InputChanged, function(i)
		if dragging and IsMove(i) then
			local d = Mouse() - startM
			if d.Magnitude > 4 then moved = true end
			if moved then
				target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end
	end)
	w:Connect(UserInputService.InputEnded, function(i)
		if dragging and IsPress(i) then
			dragging = false
			if not moved and onClick then onClick() end
		end
	end)
end

------------------------------------------------------------------ janela: base

function Window:Connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(self.Conns, c)
	return c
end

function Window:Bind(inst, prop, key)
	table.insert(self.Binds, { inst, prop, key })
	inst[prop] = self.Theme[key]
end

function Window:SetColor(key, color)
	if not self.Theme[key] then return end
	self.Theme[key] = color
	for _, b in ipairs(self.Binds) do
		if b[3] == key and b[1].Parent then b[1][b[2]] = color end
	end
	for _, fn in ipairs(self.Refreshers) do pcall(fn) end
end

function Window:AddOpaque(inst)
	table.insert(self.Opaque, inst)
	inst.BackgroundTransparency = 1 - self.Opacity
end

function Window:SetOpacity(v)
	self.Opacity = math.clamp(v, 0.3, 1)
	for _, inst in ipairs(self.Opaque) do
		if inst.Parent then inst.BackgroundTransparency = 1 - self.Opacity end
	end
end

function Window:SetState(s)
	self.State = s
	self.Main.Visible = (s == "open")
	self.Pill.Visible = (s == "minimized")
end

function Window:Toggle()
	if self.State == "hidden" then
		self:SetState(self.LastState or "open")
	else
		self.LastState = self.State
		self:SetState("hidden")
	end
end

function Window:Minimize()
	self:SetState(self.State == "minimized" and "open" or "minimized")
end

function Window:Destroy()
	for _, c in ipairs(self.Conns) do pcall(function() c:Disconnect() end) end
	self.Gui:Destroy()
end

function Window:Copy(text)
	local f = setclipboard or toclipboard
	if f then
		pcall(f, tostring(text))
		self:Notify({ Title = "NEWLOC", Content = "Copiado para a área de transferência.", Duration = 2 })
	else
		self:Notify({ Title = "NEWLOC", Content = "Seu executor não suporta copiar.", Duration = 2 })
	end
end

function Window:Notify(o)
	o = o or {}
	self.NotifyCount = (self.NotifyCount or 0) + 1
	local f = New("CanvasGroup", {
		Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = self.Theme.Card, GroupTransparency = 1,
		LayoutOrder = self.NotifyCount, Parent = self.NotifyHolder,
	})
	Round(f, 10)
	Stroke(f, self.Theme.Accent, 1)
	local ic = New("TextLabel", {
		Size = UDim2.fromOffset(28, 28), Position = UDim2.fromOffset(12, 15), BackgroundColor3 = self.Theme.Accent,
		Text = "✓", Font = FONTB, TextSize = 15, TextColor3 = Color3.new(1, 1, 1), Parent = f,
	})
	Round(ic, 14)
	New("TextLabel", {
		Size = UDim2.new(1, -60, 0, 18), Position = UDim2.fromOffset(52, 10), BackgroundTransparency = 1, Font = FONTB,
		TextSize = 13, TextXAlignment = LEFT, TextColor3 = self.Theme.Text, Text = tostring(o.Title or "NEWLOC"),
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = f,
	})
	New("TextLabel", {
		Size = UDim2.new(1, -60, 0, 18), Position = UDim2.fromOffset(52, 29), BackgroundTransparency = 1, Font = FONT,
		TextSize = 12, TextXAlignment = LEFT, TextColor3 = self.Theme.SubText, Text = tostring(o.Content or ""),
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = f,
	})
	Tween(f, { GroupTransparency = 0 }, 0.25)
	task.delay(o.Duration or 3, function()
		if f.Parent then
			Tween(f, { GroupTransparency = 1 }, 0.3).Completed:Wait()
			f:Destroy()
		end
	end)
end

------------------------------------------------------------------ janela: personalizacao

function Window:_refreshBanner()
	local hex = ToHex(self.Theme.Accent)
	local nick = string.format('<font color="%s">%s</font>', hex, Escape(self.Nick))
	local title = Escape(self.Title)
	local function fill(t)
		t = Escape(t)
		t = t:gsub("{nick}", function() return nick end)
		t = t:gsub("{title}", function() return title end)
		return t
	end
	self.WelcomeLabel.Text = fill(self.WelcomeText)
	self.WelcomeSubLabel.Text = fill(self.WelcomeSub)
end

function Window:SetTitle(t)
	self.Title = t ~= "" and t or "NEWLOC MENU"
	self.TitleLabel.Text = self.Title
	self.PillLabel.Text = string.upper(self.Title)
	self:_refreshBanner()
end

function Window:SetSubtitle(t)
	self.Subtitle = t
	self.SubLabel.Text = t
end

function Window:SetNickname(t)
	self.Nick = (t and t ~= "") and t or LocalPlayer.DisplayName
	self.NameLabel.Text = self.Nick
	self:_refreshBanner()
end

function Window:SetWelcome(t, sub)
	if t then self.WelcomeText = t end
	if sub then self.WelcomeSub = sub end
	self:_refreshBanner()
end

function Window:_layoutLogo()
	local has = self.LogoImage.Image ~= ""
	self.LogoImage.Visible = has
	if has then
		self.TitleLabel.Position, self.SubLabel.Position = UDim2.fromOffset(10, 76), UDim2.fromOffset(10, 104)
	else
		self.TitleLabel.Position, self.SubLabel.Position = UDim2.fromOffset(10, 40), UDim2.fromOffset(10, 72)
	end
end

function Window:SetLogo(src)
	task.spawn(function()
		self.LogoImage.Image = ResolveImage(src)
		self:_layoutLogo()
	end)
end

function Window:SetBanner(src)
	task.spawn(function() self.BannerImage.Image = ResolveImage(src) end)
end

function Window:SetAvatar(src)
	task.spawn(function()
		local img = ResolveImage(src)
		if img ~= "" then
			self.Avatar.Image = img
		else
			local ok, res = pcall(Players.GetUserThumbnailAsync, Players, LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
			if ok then self.Avatar.Image = res end
		end
	end)
end

------------------------------------------------------------------ janela: config

local FOLDER = "NewlocUI/configs"

local function HasFS()
	return (writefile and readfile and isfile and listfiles and makefolder and isfolder and delfile) and true or false
end

local function EnsureFolders()
	if not isfolder("NewlocUI") then makefolder("NewlocUI") end
	if not isfolder(FOLDER) then makefolder(FOLDER) end
end

local function CleanName(n)
	n = tostring(n or ""):gsub("[^%w_%-]", "")
	return n ~= "" and n or "default"
end

function Window:ExportConfig()
	local data = {}
	for flag, obj in pairs(self.Elements) do
		local ok, v = pcall(obj.Get, obj)
		if ok then data[flag] = v end
	end
	return HttpService:JSONEncode({ version = 1, data = data })
end

function Window:ImportConfig(str)
	local ok, decoded = pcall(HttpService.JSONDecode, HttpService, tostring(str))
	if not ok or type(decoded) ~= "table" or type(decoded.data) ~= "table" then return false end
	for flag, v in pairs(decoded.data) do
		local obj = self.Elements[flag]
		if obj then pcall(obj.Set, obj, v) end
	end
	return true
end

function Window:SaveConfig(name)
	if not HasFS() then return false, "Seu executor não suporta arquivos." end
	local ok, err = pcall(function()
		EnsureFolders()
		writefile(FOLDER .. "/" .. CleanName(name) .. ".json", self:ExportConfig())
	end)
	return ok, err
end

function Window:LoadConfig(name)
	if not HasFS() then return false, "Seu executor não suporta arquivos." end
	local path = FOLDER .. "/" .. CleanName(name) .. ".json"
	local ok, content = pcall(function() return isfile(path) and readfile(path) or nil end)
	if not ok or not content then return false, "Config não encontrada." end
	return self:ImportConfig(content)
end

function Window:DeleteConfig(name)
	if not HasFS() then return false end
	local path = FOLDER .. "/" .. CleanName(name) .. ".json"
	return pcall(function() if isfile(path) then delfile(path) end end)
end

function Window:ListConfigs()
	local out = {}
	if not HasFS() then return out end
	pcall(function()
		EnsureFolders()
		for _, p in ipairs(listfiles(FOLDER)) do
			local n = p:match("([^/\\]+)%.json$")
			if n then table.insert(out, n) end
		end
	end)
	table.sort(out)
	return out
end

function Window:ResetAll()
	for _, obj in pairs(self.Elements) do
		if obj.Default ~= nil then pcall(obj.Set, obj, obj.Default) end
	end
end

------------------------------------------------------------------ abas e secoes

function Window:SelectTab(tab)
	if self.Current then self.Current.Page.Visible = false end
	local prev = self.Current
	self.Current = tab
	tab.Page.Visible = true
	if prev then prev:_style() end
	tab:_style()
	if self.SearchBox.Text ~= "" then self.SearchBox.Text = "" end
	self:Search("")
end

function Window:Search(q)
	q = string.lower(q or "")
	local tab = self.Current
	if not tab then return end
	for _, sec in ipairs(tab.Sections) do
		local secMatch = q == "" or string.find(string.lower(sec.Name), q, 1, true) ~= nil
		local any = secMatch
		for _, it in ipairs(sec.Items) do
			local vis = secMatch or string.find(it.name, q, 1, true) ~= nil
			it.frame.Visible = vis
			any = any or vis
		end
		sec.Card.Visible = any
	end
end

function Window:CreateTab(o)
	if type(o) == "string" then o = { Name = o } end
	local w = self
	local tab = setmetatable({ Window = w, Name = o.Name or "Aba", Sections = {}, IsSettings = o.IsSettings }, Tab)
	table.insert(w.Tabs, tab)

	local btn = New("TextButton", {
		Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1,
		LayoutOrder = o.Order or #w.Tabs, Parent = w.TabList,
	})
	w:Bind(btn, "BackgroundColor3", "Accent")
	Round(btn, 8)
	tab.Btn = btn
	tab.Bar = New("Frame", { Size = UDim2.fromOffset(3, 20), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), BackgroundTransparency = 1, Parent = btn })
	w:Bind(tab.Bar, "BackgroundColor3", "Accent")
	Round(tab.Bar, 2)

	local icon = tostring(o.Icon or "◆")
	if icon:match("^%d+$") or icon:find("^rbxasset") then
		tab.IconObj = New("ImageLabel", {
			Size = UDim2.fromOffset(20, 20), Position = UDim2.fromOffset(16, 10), BackgroundTransparency = 1,
			Image = ResolveImage(icon), Parent = btn,
		})
		tab.IconProp = "ImageColor3"
	else
		tab.IconObj = New("TextLabel", {
			Size = UDim2.fromOffset(24, 40), Position = UDim2.fromOffset(14, 0), BackgroundTransparency = 1,
			Text = icon, Font = FONTB, TextSize = 16, Parent = btn,
		})
		tab.IconProp = "TextColor3"
	end
	tab.NameLabel = New("TextLabel", {
		Size = UDim2.new(1, -52, 1, 0), Position = UDim2.fromOffset(48, 0), BackgroundTransparency = 1, Text = tab.Name,
		Font = FONTB, TextSize = 13, TextXAlignment = LEFT, TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn,
	})

	local page = New("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = AUTOY, Visible = false, Parent = w.Pages,
	})
	w:Bind(page, "ScrollBarImageColor3", "Accent")
	tab.Page = page
	tab.Left = New("Frame", { Size = UDim2.new(0.5, -6, 0, 0), AutomaticSize = AUTOY, BackgroundTransparency = 1, Parent = page })
	tab.Right = New("Frame", { Size = UDim2.new(0.5, -6, 0, 0), AutomaticSize = AUTOY, Position = UDim2.new(0.5, 6, 0, 0), BackgroundTransparency = 1, Parent = page })
	List(tab.Left, 12)
	List(tab.Right, 12)
	Pad(page, 0, 0, 6, 8)

	btn.MouseButton1Click:Connect(function() w:SelectTab(tab) end)
	btn.MouseEnter:Connect(function() if w.Current ~= tab then Tween(btn, { BackgroundTransparency = 0.9 }, 0.12) end end)
	btn.MouseLeave:Connect(function() if w.Current ~= tab then Tween(btn, { BackgroundTransparency = 1 }, 0.12) end end)
	table.insert(w.Refreshers, function() tab:_style() end)
	tab:_style()

	if not w.Current or w.Current.IsSettings then w:SelectTab(tab) end
	return tab
end

function Tab:_style()
	local w = self.Window
	local on = (w.Current == self)
	self.Btn.BackgroundTransparency = on and 0.78 or 1
	self.Bar.BackgroundTransparency = on and 0 or 1
	local c = on and w.Theme.Text or w.Theme.SubText
	self.NameLabel.TextColor3 = c
	self.IconObj[self.IconProp] = on and w.Theme.Accent or c
end

function Tab:CreateSection(o)
	if type(o) == "string" then o = { Name = o } end
	local w = self.Window
	local col
	if o.Side == "Left" then col = self.Left
	elseif o.Side == "Right" then col = self.Right
	else
		self.Flip = not self.Flip
		col = self.Flip and self.Left or self.Right
	end
	local card = New("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = AUTOY, LayoutOrder = #self.Sections + 1, Parent = col })
	w:Bind(card, "BackgroundColor3", "Card")
	w:AddOpaque(card)
	Round(card, 10)
	local st = Stroke(card, w.Theme.Stroke, 1)
	w:Bind(st, "Color", "Stroke")
	Pad(card, 12, 10, 12, 12)
	List(card, 6)
	local sec = setmetatable({ Window = w, Tab = self, Card = card, Items = {}, Order = 0, Name = o.Name or "" }, Section)
	Label(w, card, { Size = UDim2.new(1, 0, 0, 24), Text = sec.Name, Font = FONTB, TextSize = 15, LayoutOrder = 0 })
	table.insert(self.Sections, sec)
	return sec
end

------------------------------------------------------------------ secao: base dos elementos

function Section:_next()
	self.Order += 1
	return self.Order
end

function Section:_reg(frame, name)
	table.insert(self.Items, { frame = frame, name = string.lower(tostring(name or "")) })
end

function Section:_row(name, height, parent)
	local w = self.Window
	local row = New("Frame", {
		Size = UDim2.new(1, 0, 0, height or 34), BackgroundTransparency = 0.6,
		LayoutOrder = parent and 1 or self:_next(),
	})
	w:Bind(row, "BackgroundColor3", "Element")
	Round(row, 6)
	row.Parent = parent or self.Card
	local label = Label(w, row, {
		Size = UDim2.new(0.5, -8, 1, 0), Position = UDim2.fromOffset(10, 0), Text = tostring(name or ""),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	if not parent then self:_reg(row, name) end
	return row, label
end

function Section:_register(obj, o, default)
	local flag = o.Flag or (self.Tab.Name .. "/" .. tostring(o.Name or default))
	obj.Flag = flag
	obj.Default = obj:Get()
	if o.Save ~= false then self.Window.Elements[flag] = obj end
	self.Window.Flags[flag] = obj:Get()
	return obj
end

local function fire(cb, ...)
	if cb then task.spawn(cb, ...) end
end

------------------------------------------------------------------ elementos

function Section:CreateLabel(text)
	local w = self.Window
	local l = Label(w, self.Card, { Size = UDim2.new(1, 0, 0, 20), Text = tostring(text), TextWrapped = true, LayoutOrder = self:_next() }, "SubText")
	self:_reg(l, text)
	return { Set = function(_, t) l.Text = tostring(t) end }
end

function Section:CreateButton(o)
	local w = self.Window
	local row = self:_row(o.Name)
	local b = New("TextButton", {
		Text = o.NameButton or "Executar", Font = FONTB, TextSize = 12, AutoButtonColor = false,
		Size = UDim2.fromOffset(92, 24), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
		TextColor3 = Color3.new(1, 1, 1), Parent = row,
	})
	w:Bind(b, "BackgroundColor3", "Accent")
	Round(b, 6)
	b.MouseEnter:Connect(function() Tween(b, { BackgroundTransparency = 0.2 }, 0.1) end)
	b.MouseLeave:Connect(function() Tween(b, { BackgroundTransparency = 0 }, 0.1) end)
	b.MouseButton1Click:Connect(function() fire(o.Callback) end)
	return { Button = b, SetText = function(_, t) b.Text = t end }
end

function Section:CreateToggle(o)
	local w = self.Window
	local row = self:_row(o.Name)
	local sw = New("TextButton", {
		Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(40, 20), AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0), BackgroundColor3 = w.Theme.Stroke, Parent = row,
	})
	Round(sw, 10)
	local knob = New("Frame", {
		Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(240, 240, 245), Parent = sw,
	})
	Round(knob, 7)
	local obj = { Value = o.CurrentValue and true or false }
	local function render(anim)
		local t = anim and 0.15 or 0
		Tween(sw, { BackgroundColor3 = obj.Value and w.Theme.Accent or w.Theme.Stroke }, t)
		Tween(knob, { Position = obj.Value and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }, t)
	end
	function obj:Get() return self.Value end
	function obj:Set(v, silent)
		self.Value = v and true or false
		w.Flags[self.Flag] = self.Value
		render(true)
		if not silent then fire(o.Callback, self.Value) end
	end
	sw.MouseButton1Click:Connect(function() obj:Set(not obj.Value) end)
	table.insert(w.Refreshers, function() render(false) end)
	self:_register(obj, o, "toggle")
	render(false)
	return obj
end

function Section:CreateSlider(o)
	local w = self.Window
	local min, max = o.Range[1], o.Range[2]
	local inc = o.Increment or 1
	local row, label = self:_row(o.Name)
	label.Size = UDim2.new(0.38, -8, 1, 0)
	local val = Label(w, row, {
		Size = UDim2.fromOffset(48, 34), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 0), TextXAlignment = RIGHT,
	})
	local track = New("Frame", {
		Size = UDim2.new(0.62, -72, 0, 6), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0.38, 0.5), Parent = row,
	})
	w:Bind(track, "BackgroundColor3", "Stroke")
	Round(track, 3)
	local fill = New("Frame", { Size = UDim2.fromScale(0, 1), Parent = track })
	w:Bind(fill, "BackgroundColor3", "Accent")
	Round(fill, 3)
	local knob = New("Frame", {
		Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(1, 0.5), BackgroundColor3 = Color3.fromRGB(245, 245, 250), Parent = fill,
	})
	Round(knob, 7)
	local hit = New("TextButton", {
		Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5), Parent = track,
	})

	local function snap(v)
		v = math.clamp(v, min, max)
		v = math.floor((v - min) / inc + 0.5) * inc + min
		return math.clamp(tonumber(string.format("%.6g", v)), min, max)
	end
	local obj = { Value = snap(o.CurrentValue or min) }
	local function render()
		fill.Size = UDim2.fromScale((obj.Value - min) / (max - min), 1)
		val.Text = tostring(obj.Value) .. (o.Suffix or "")
	end
	function obj:Get() return self.Value end
	function obj:Set(v, silent)
		self.Value = snap(tonumber(v) or min)
		w.Flags[self.Flag] = self.Value
		render()
		if not silent then fire(o.Callback, self.Value) end
	end
	local dragging = false
	local function update()
		local a = math.clamp((Mouse().X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		local v = snap(min + (max - min) * a)
		if v ~= obj.Value then obj:Set(v) end
	end
	w:Connect(hit.InputBegan, function(i) if IsPress(i) then dragging = true update() end end)
	w:Connect(UserInputService.InputChanged, function(i) if dragging and IsMove(i) then update() end end)
	w:Connect(UserInputService.InputEnded, function(i) if IsPress(i) then dragging = false end end)
	self:_register(obj, o, "slider")
	render()
	return obj
end

local function BuildChoice(self, o, kind)
	local w = self.Window
	local obj = { Options = o.Options or {}, Value = o.CurrentValue }
	if obj.Value == nil then obj.Value = obj.Options[1] end
	return obj, w
end

function Section:CreateDropdown(o)
	local obj, w = BuildChoice(self, o)
	local box = New("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = AUTOY, BackgroundTransparency = 1, LayoutOrder = self:_next(), Parent = self.Card })
	List(box, 4)
	local row = self:_row(o.Name, 34, box)
	self:_reg(box, o.Name)
	local btn = New("TextButton", {
		Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(140, 24), AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0), Parent = row,
	})
	w:Bind(btn, "BackgroundColor3", "Background")
	Round(btn, 6)
	local txt = Label(w, btn, { Size = UDim2.new(1, -26, 1, 0), Position = UDim2.fromOffset(8, 0), TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd })
	Label(w, btn, { Size = UDim2.fromOffset(16, 24), Position = UDim2.new(1, -20, 0, 0), Text = "▾", TextSize = 12, TextXAlignment = CENTER }, "SubText")
	local list = New("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = AUTOY, Visible = false, LayoutOrder = 2, Parent = box })
	w:Bind(list, "BackgroundColor3", "Background")
	Round(list, 6)
	Pad(list, 4)
	List(list, 2)

	local function render()
		txt.Text = obj.Value ~= nil and tostring(obj.Value) or "Nenhum"
		for _, c in ipairs(list:GetChildren()) do
			if c:IsA("TextButton") then
				c.TextColor3 = (c.Text == tostring(obj.Value)) and w.Theme.Accent or w.Theme.Text
			end
		end
	end
	local function build()
		for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
		for i, opt in ipairs(obj.Options) do
			local b = New("TextButton", {
				Text = tostring(opt), Font = FONT, TextSize = 12, BackgroundTransparency = 1, AutoButtonColor = false,
				Size = UDim2.new(1, 0, 0, 24), LayoutOrder = i, Parent = list,
			})
			b.MouseEnter:Connect(function() b.BackgroundTransparency = 0.85 b.BackgroundColor3 = w.Theme.Accent end)
			b.MouseLeave:Connect(function() b.BackgroundTransparency = 1 end)
			b.MouseButton1Click:Connect(function()
				obj:Set(opt)
				list.Visible = false
			end)
		end
		render()
	end
	function obj:Get() return self.Value end
	function obj:Set(v, silent)
		self.Value = v
		w.Flags[self.Flag] = v
		render()
		if not silent then fire(o.Callback, v) end
	end
	function obj:SetOptions(opts)
		self.Options = opts
		build()
	end
	btn.MouseButton1Click:Connect(function()
		list.Visible = not list.Visible
	end)
	table.insert(w.Refreshers, render)
	self:_register(obj, o, "dropdown")
	build()
	return obj
end

function Section:CreateSelector(o)
	local obj, w = BuildChoice(self, o)
	local row = self:_row(o.Name)
	local box = New("Frame", {
		Size = UDim2.fromOffset(160, 24), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Parent = row,
	})
	w:Bind(box, "BackgroundColor3", "Background")
	Round(box, 6)
	local function arrow(txt, pos)
		local b = New("TextButton", {
			Text = txt, Font = FONTB, TextSize = 14, BackgroundTransparency = 1, Size = UDim2.fromOffset(24, 24),
			Position = pos, Parent = box,
		})
		w:Bind(b, "TextColor3", "SubText")
		return b
	end
	local prev, nxt = arrow("<", UDim2.fromOffset(0, 0)), arrow(">", UDim2.new(1, -24, 0, 0))
	local txt = Label(w, box, { Size = UDim2.new(1, -48, 1, 0), Position = UDim2.fromOffset(24, 0), TextXAlignment = CENTER, TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd })
	local function index()
		for i, v in ipairs(obj.Options) do if v == obj.Value then return i end end
		return 1
	end
	function obj:Get() return self.Value end
	function obj:Set(v, silent)
		self.Value = v
		txt.Text = tostring(v)
		w.Flags[self.Flag] = v
		if not silent then fire(o.Callback, v) end
	end
	local function step(d)
		local n = #obj.Options
		if n == 0 then return end
		obj:Set(obj.Options[(index() - 1 + d) % n + 1])
	end
	prev.MouseButton1Click:Connect(function() step(-1) end)
	nxt.MouseButton1Click:Connect(function() step(1) end)
	self:_register(obj, o, "selector")
	txt.Text = tostring(obj.Value)
	return obj
end

function Section:CreateInput(o)
	local w = self.Window
	local row = self:_row(o.Name)
	local box = New("TextBox", {
		Size = UDim2.fromOffset(160, 24), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
		Font = FONT, TextSize = 12, PlaceholderText = o.Placeholder or "Digite...", Text = tostring(o.CurrentValue or ""),
		ClearTextOnFocus = false, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
	})
	w:Bind(box, "BackgroundColor3", "Background")
	w:Bind(box, "TextColor3", "Text")
	box.PlaceholderColor3 = w.Theme.SubText
	Round(box, 6)
	Pad(box, 8, 0, 8, 0)
	local obj = { Value = box.Text, Box = box }
	function obj:Get() return self.Value end
	function obj:Set(v, silent)
		self.Value = tostring(v or "")
		box.Text = self.Value
		w.Flags[self.Flag] = self.Value
		if not silent then fire(o.Callback, self.Value) end
	end
	box.FocusLost:Connect(function() obj:Set(box.Text) end)
	self:_register(obj, o, "input")
	return obj
end

function Section:CreateKeybind(o)
	local w = self.Window
	local row = self:_row(o.Name)
	local btn = New("TextButton", {
		Size = UDim2.fromOffset(92, 24), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
		Font = FONTB, TextSize = 12, AutoButtonColor = false, Text = "", Parent = row,
	})
	w:Bind(btn, "BackgroundColor3", "Background")
	w:Bind(btn, "TextColor3", "Accent")
	Round(btn, 6)
	local obj = { Key = nil }
	local function toKey(v)
		if typeof(v) == "EnumItem" then return v end
		if type(v) == "string" and v ~= "None" then return Enum.KeyCode[v] end
		return nil
	end
	obj.Key = toKey(o.CurrentValue)
	obj.Callback = o.Callback
	function obj:Get() return self.Key and self.Key.Name or "None" end
	function obj:Set(v, silent)
		local ok, k = pcall(toKey, v)
		self.Key = ok and k or nil
		btn.Text = self.Key and self.Key.Name or "Nenhuma"
		w.Flags[self.Flag] = self:Get()
		if not silent then fire(o.OnChanged, self.Key) end
	end
	btn.MouseButton1Click:Connect(function()
		if w.Listening then return end
		w.Listening = true
		btn.Text = "..."
		local c
		c = UserInputService.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.Keyboard then
				c:Disconnect()
				if i.KeyCode == Enum.KeyCode.Backspace then obj:Set(nil) elseif i.KeyCode ~= Enum.KeyCode.Escape then obj:Set(i.KeyCode) else obj:Set(obj.Key, true) end
				task.delay(0.15, function() w.Listening = false end)
			end
		end)
	end)
	if o.Callback then table.insert(w.Keybinds, obj) end
	self:_register(obj, o, "keybind")
	btn.Text = obj.Key and obj.Key.Name or "Nenhuma"
	return obj
end

function Section:CreateColorPicker(o)
	local w = self.Window
	local box = New("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = AUTOY, BackgroundTransparency = 1, LayoutOrder = self:_next(), Parent = self.Card })
	List(box, 4)
	local row = self:_row(o.Name, 34, box)
	self:_reg(box, o.Name)
	local preview = New("TextButton", {
		Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(46, 20), AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1), Parent = row,
	})
	Round(preview, 5)
	local pst = Stroke(preview, w.Theme.Stroke, 1)
	w:Bind(pst, "Color", "Stroke")

	local panel = New("Frame", { Size = UDim2.new(1, 0, 0, 192), Visible = false, LayoutOrder = 2, Parent = box })
	w:Bind(panel, "BackgroundColor3", "Background")
	Round(panel, 8)

	-- quadrado saturacao / brilho
	local sv = New("Frame", { Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 0, 100), BackgroundColor3 = Color3.new(1, 0, 0), ClipsDescendants = true, Parent = panel })
	Round(sv, 4)
	local white = New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = sv })
	New("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = white })
	local black = New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Parent = sv })
	New("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0), Parent = black })
	local svCursor = New("Frame", { Size = UDim2.fromOffset(10, 10), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, ZIndex = 5, Parent = sv })
	Round(svCursor, 5)
	Stroke(svCursor, Color3.new(1, 1, 1), 2)
	local svHit = New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 6, Parent = sv })

	-- barra de matiz
	local hue = New("Frame", { Position = UDim2.fromOffset(8, 116), Size = UDim2.new(1, -16, 0, 12), BackgroundColor3 = Color3.new(1, 1, 1), Parent = panel })
	Round(hue, 6)
	New("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(1 / 6, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(2 / 6, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(3 / 6, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(4 / 6, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(5 / 6, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		}),
		Parent = hue,
	})
	local hueCursor = New("Frame", { Size = UDim2.new(0, 4, 1, 6), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), Parent = hue })
	Round(hueCursor, 2)
	Stroke(hueCursor, Color3.new(0, 0, 0), 1)
	local hueHit = New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 8), Position = UDim2.fromOffset(0, -4), Parent = hue })

	-- hex
	local hex = New("TextBox", {
		Position = UDim2.fromOffset(8, 136), Size = UDim2.new(1, -16, 0, 22), Font = FONT, TextSize = 12,
		ClearTextOnFocus = false, Text = "#FFFFFF", Parent = panel,
	})
	w:Bind(hex, "BackgroundColor3", "Element")
	w:Bind(hex, "TextColor3", "Text")
	Round(hex, 5)

	-- paleta rapida (estilo paint)
	local sw = New("Frame", { Position = UDim2.fromOffset(8, 166), Size = UDim2.new(1, -16, 0, 18), BackgroundTransparency = 1, Parent = panel })
	List(sw, 3, Enum.FillDirection.Horizontal)

	local obj = { Value = Color3.new(1, 1, 1) }
	local h, s, v = 0, 0, 1
	local function apply(silent)
		local c = Color3.fromHSV(h, s, v)
		obj.Value = c
		preview.BackgroundColor3 = c
		sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		svCursor.Position = UDim2.fromScale(s, 1 - v)
		hueCursor.Position = UDim2.fromScale(h, 0.5)
		if not hex:IsFocused() then hex.Text = ToHex(c) end
		if obj.Flag then w.Flags[obj.Flag] = ToHex(c) end
		if not silent then fire(o.Callback, c) end
	end
	function obj:Get() return ToHex(self.Value) end
	function obj:Set(c, silent)
		if typeof(c) == "string" then c = FromHex(c) end
		if typeof(c) ~= "Color3" then return end
		local nh, ns, nv = c:ToHSV()
		if ns > 0 and nv > 0 then h = nh end
		s, v = ns, nv
		apply(silent)
	end

	for _, col in ipairs(Swatches) do
		local b = New("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(16, 16), BackgroundColor3 = col, Parent = sw })
		Round(b, 4)
		Stroke(b, w.Theme.Stroke, 1)
		b.MouseButton1Click:Connect(function() obj:Set(col) end)
	end

	local drag
	local function upd()
		local m = Mouse()
		if drag == "sv" then
			s = math.clamp((m.X - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1), 0, 1)
			v = 1 - math.clamp((m.Y - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1), 0, 1)
			apply()
		elseif drag == "hue" then
			h = math.clamp((m.X - hue.AbsolutePosition.X) / math.max(hue.AbsoluteSize.X, 1), 0, 0.999)
			apply()
		end
	end
	w:Connect(svHit.InputBegan, function(i) if IsPress(i) then drag = "sv" upd() end end)
	w:Connect(hueHit.InputBegan, function(i) if IsPress(i) then drag = "hue" upd() end end)
	w:Connect(UserInputService.InputChanged, function(i) if drag and IsMove(i) then upd() end end)
	w:Connect(UserInputService.InputEnded, function(i) if IsPress(i) then drag = nil end end)
	hex.FocusLost:Connect(function()
		local c = FromHex(hex.Text)
		if c then obj:Set(c) else hex.Text = ToHex(obj.Value) end
	end)
	preview.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)

	local start = o.CurrentValue or o.Default or Color3.new(1, 1, 1)
	if typeof(start) == "string" then start = FromHex(start) or Color3.new(1, 1, 1) end
	local nh, ns, nv = start:ToHSV()
	h, s, v = nh, ns, nv
	self:_register(obj, o, "color")
	apply(true)
	return obj
end

------------------------------------------------------------------ aba de configuracoes (automatica)

function Window:_buildSettings()
	local w = self
	local tab = w:CreateTab({ Name = "Configurações", Icon = "⚙", Order = 1000, IsSettings = true })

	-- personalizacao
	local p = tab:CreateSection("Personalização")
	p:CreateInput({ Name = "Título do menu", Flag = "cfg/title", CurrentValue = w.Title, Callback = function(t) w:SetTitle(t) end })
	p:CreateInput({ Name = "Subtítulo", Flag = "cfg/subtitle", CurrentValue = w.Subtitle, Callback = function(t) w:SetSubtitle(t) end })
	p:CreateInput({ Name = "Logo (ID ou link)", Flag = "cfg/logo", Placeholder = "ID / link da imagem", Callback = function(t) w:SetLogo(t) end })
	p:CreateInput({ Name = "Nickname", Flag = "cfg/nick", CurrentValue = w.Nick, Callback = function(t) w:SetNickname(t) end })
	p:CreateInput({ Name = "Foto de perfil", Flag = "cfg/avatar", Placeholder = "ID / link (vazio = padrão)", Callback = function(t) w:SetAvatar(t) end })
	p:CreateInput({ Name = "Imagem do banner", Flag = "cfg/banner", Placeholder = "ID / link da imagem", Callback = function(t) w:SetBanner(t) end })
	p:CreateInput({ Name = "Texto do banner", Flag = "cfg/welcome", CurrentValue = w.WelcomeText, Callback = function(t) w:SetWelcome(t) end })
	p:CreateInput({ Name = "Subtexto do banner", Flag = "cfg/welcomesub", CurrentValue = w.WelcomeSub, Callback = function(t) w:SetWelcome(nil, t) end })
	p:CreateLabel("Dica: use {nick} e {title} nos textos do banner.")
	p:CreateSlider({ Name = "Opacidade do menu", Flag = "cfg/opacity", Range = { 30, 100 }, CurrentValue = 100, Suffix = "%", Callback = function(v) w:SetOpacity(v / 100) end })
	p:CreateToggle({ Name = "Mostrar FPS / Ping", Flag = "cfg/stats", CurrentValue = false, Callback = function(v) w.StatsFrame.Visible = v end })

	-- cores
	local c = tab:CreateSection("Cores")
	c:CreateSelector({
		Name = "Tema rápido", Options = PresetOrder, CurrentValue = "Roxo", Save = false,
		Callback = function(n)
			local el = w.Elements["cfg/color/Accent"]
			if el and Presets[n] then el:Set(Presets[n]) end
		end,
	})
	for _, item in ipairs(ThemeOrder) do
		local key = item[1]
		c:CreateColorPicker({
			Name = item[2], Flag = "cfg/color/" .. key, CurrentValue = DefaultTheme[key],
			Callback = function(col) w:SetColor(key, col) end,
		})
	end
	c:CreateButton({
		Name = "Restaurar cores padrão", NameButton = "Restaurar",
		Callback = function()
			for key, col in pairs(DefaultTheme) do
				local el = w.Elements["cfg/color/" .. key]
				if el then el:Set(col) end
			end
		end,
	})

	-- teclas / janela
	local k = tab:CreateSection("Teclas e janela")
	k:CreateKeybind({
		Name = "Ocultar / mostrar menu", Flag = "cfg/togglekey", CurrentValue = w.ToggleKey,
		OnChanged = function(key)
			if key then w.ToggleKey = key else w.Elements["cfg/togglekey"]:Set(w.ToggleKey, true) end
		end,
	})
	k:CreateButton({ Name = "Ocultar menu agora", NameButton = "Ocultar", Callback = function() w:SetState("hidden") w.LastState = "open" end })
	k:CreateButton({ Name = "Minimizar", NameButton = "Minimizar", Callback = function() w:SetState("minimized") end })

	-- config
	local f = tab:CreateSection("Configuração")
	local nameIn = f:CreateInput({ Name = "Nome da config", CurrentValue = "default", Save = false })
	local drop
	local function refreshList() if drop then drop:SetOptions(w:ListConfigs()) end end
	drop = f:CreateDropdown({
		Name = "Configs salvas", Options = w:ListConfigs(), CurrentValue = nil, Save = false,
		Callback = function(v) if v then nameIn:Set(v, true) end end,
	})
	f:CreateButton({ Name = "Atualizar lista", NameButton = "Atualizar", Callback = refreshList })
	f:CreateButton({
		Name = "Salvar config", NameButton = "Salvar",
		Callback = function()
			local ok, err = w:SaveConfig(nameIn:Get())
			w:Notify({ Title = ok and "Config salva" or "Erro", Content = ok and CleanName(nameIn:Get()) or tostring(err), Duration = 3 })
			refreshList()
		end,
	})
	f:CreateButton({
		Name = "Carregar config", NameButton = "Carregar",
		Callback = function()
			local ok, err = w:LoadConfig(nameIn:Get())
			w:Notify({ Title = ok and "Config carregada" or "Erro", Content = ok and CleanName(nameIn:Get()) or tostring(err), Duration = 3 })
		end,
	})
	f:CreateButton({
		Name = "Deletar config", NameButton = "Deletar",
		Callback = function()
			w:DeleteConfig(nameIn:Get())
			w:Notify({ Title = "Config deletada", Content = CleanName(nameIn:Get()), Duration = 3 })
			refreshList()
		end,
	})
	local txt = f:CreateInput({ Name = "Texto da config", Placeholder = "Exporte ou cole aqui", Save = false })
	f:CreateButton({
		Name = "Exportar (copiar)", NameButton = "Exportar",
		Callback = function()
			local s = w:ExportConfig()
			txt:Set(s, true)
			w:Copy(s)
		end,
	})
	f:CreateButton({
		Name = "Importar (colar acima)", NameButton = "Importar",
		Callback = function()
			local ok = w:ImportConfig(txt:Get())
			w:Notify({ Title = ok and "Config importada" or "Erro", Content = ok and "Tudo aplicado." or "Texto inválido.", Duration = 3 })
		end,
	})
	f:CreateButton({ Name = "Resetar tudo", NameButton = "Resetar", Callback = function() w:ResetAll() end })
end

------------------------------------------------------------------ criar janela

function Library:CreateWindow(o)
	o = o or {}
	local w = setmetatable({
		Theme = table.clone(DefaultTheme), Flags = {}, Elements = {}, Binds = {}, Refreshers = {}, Opaque = {},
		Tabs = {}, Conns = {}, Keybinds = {},
		ToggleKey = o.ToggleKey or Enum.KeyCode.RightControl,
		State = "open", Opacity = 1,
		Title = o.Name or "NEWLOC MENU", Subtitle = o.Subtitle or "UI Library",
		Nick = o.Nickname or LocalPlayer.DisplayName,
		WelcomeText = o.WelcomeText or "Bem-vindo de volta, {nick}!",
		WelcomeSub = o.WelcomeSub or "Aproveite sua experiência com o {title}.",
		FPS = 0, Ping = 0,
	}, Window)

	-- gui
	local gui = New("ScreenGui", { Name = "NewlocUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, DisplayOrder = 999 })
	local ok = false
	if gethui then ok = pcall(function() gui.Parent = gethui() end) end
	if not ok then ok = pcall(function() gui.Parent = CoreGui end) end
	if not ok then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
	for _, g in ipairs(gui.Parent:GetChildren()) do
		if g ~= gui and g.Name == "NewlocUI" then g:Destroy() end
	end
	w.Gui = gui

	local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	local W = math.min(o.Width or 800, vp.X - 24)
	local H = math.min(o.Height or 500, vp.Y - 24)

	local main = New("Frame", { Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(W, H), Parent = gui })
	w.Main = main
	w:Bind(main, "BackgroundColor3", "Background")
	w:AddOpaque(main)
	Round(main, 12)
	local mst = Stroke(main, w.Theme.Stroke, 1)
	w:Bind(mst, "Color", "Stroke")

	-- sidebar
	local side = New("Frame", { Size = UDim2.new(0, 190, 1, 0), Parent = main })
	w:Bind(side, "BackgroundColor3", "Sidebar")
	w:AddOpaque(side)
	Round(side, 12)
	local filler = New("Frame", { Size = UDim2.new(0, 14, 1, 0), AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), BorderSizePixel = 0, Parent = side })
	w:Bind(filler, "BackgroundColor3", "Sidebar")
	w:AddOpaque(filler)
	local sep = New("Frame", { Size = UDim2.new(0, 1, 1, 0), AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), BorderSizePixel = 0, Parent = side })
	w:Bind(sep, "BackgroundColor3", "Stroke")

	w.LogoImage = New("ImageLabel", {
		Size = UDim2.fromOffset(60, 60), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 12), BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit, Image = "", Visible = false, Parent = side,
	})
	w.TitleLabel = Label(w, side, {
		Size = UDim2.new(1, -20, 0, 30), Position = UDim2.fromOffset(10, 40), Text = w.Title, Font = FONTX, TextSize = 24,
		TextXAlignment = CENTER, TextScaled = true,
	})
	New("UITextSizeConstraint", { MaxTextSize = 26, MinTextSize = 10, Parent = w.TitleLabel })
	w.SubLabel = Label(w, side, { Size = UDim2.new(1, -20, 0, 16), Position = UDim2.fromOffset(10, 72), Text = w.Subtitle, TextSize = 11, TextXAlignment = CENTER }, "SubText")

	w.TabList = New("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -216), Position = UDim2.fromOffset(0, 138), BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = AUTOY, Parent = side,
	})
	List(w.TabList, 4)
	Pad(w.TabList, 10, 4, 10, 4)

	-- card do jogador (clicavel)
	local card = New("TextButton", {
		Text = "", AutoButtonColor = false, Size = UDim2.new(1, -20, 0, 58), AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 10, 1, -10), BackgroundTransparency = 0.4, Parent = side,
	})
	w:Bind(card, "BackgroundColor3", "Element")
	Round(card, 10)
	w.Avatar = New("ImageLabel", { Size = UDim2.fromOffset(40, 40), Position = UDim2.fromOffset(9, 9), BackgroundColor3 = w.Theme.Stroke, Parent = card })
	Round(w.Avatar, 20)
	w.NameLabel = Label(w, card, { Size = UDim2.new(1, -90, 0, 18), Position = UDim2.fromOffset(56, 10), Text = w.Nick, Font = FONTB, TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd })
	Label(w, card, { Size = UDim2.new(1, -90, 0, 16), Position = UDim2.fromOffset(56, 30), Text = "ID: " .. LocalPlayer.UserId, TextSize = 11 }, "SubText")
	Label(w, card, { Size = UDim2.fromOffset(20, 58), Position = UDim2.new(1, -24, 0, 0), Text = "ⓘ", TextSize = 14, TextXAlignment = CENTER }, "Accent")
	card.MouseEnter:Connect(function() Tween(card, { BackgroundTransparency = 0.15 }, 0.12) end)
	card.MouseLeave:Connect(function() Tween(card, { BackgroundTransparency = 0.4 }, 0.12) end)

	-- conteudo
	local content = New("Frame", { Size = UDim2.new(1, -190, 1, 0), Position = UDim2.fromOffset(190, 0), BackgroundTransparency = 1, Parent = main })
	local top = New("Frame", { Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1, Active = true, Parent = content })
	MakeDraggable(w, top, main)

	local function topBtn(txt, x)
		local b = New("TextButton", {
			Text = txt, Font = FONTB, TextSize = 14, AutoButtonColor = false, Size = UDim2.fromOffset(28, 28),
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, x, 0, 24), Parent = top,
		})
		w:Bind(b, "BackgroundColor3", "Element")
		w:Bind(b, "TextColor3", "Text")
		Round(b, 7)
		b.MouseEnter:Connect(function() Tween(b, { BackgroundColor3 = w.Theme.Accent }, 0.1) end)
		b.MouseLeave:Connect(function() Tween(b, { BackgroundColor3 = w.Theme.Element }, 0.1) end)
		return b
	end
	topBtn("✕", -12).MouseButton1Click:Connect(function() w.LastState = "open" w:SetState("hidden") end)
	topBtn("—", -46).MouseButton1Click:Connect(function() w:SetState("minimized") end)

	local sbox = New("Frame", { Size = UDim2.fromOffset(210, 30), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -82, 0, 24), Parent = top })
	w:Bind(sbox, "BackgroundColor3", "Element")
	Round(sbox, 8)
	Label(w, sbox, { Size = UDim2.fromOffset(26, 30), Text = "⌕", TextSize = 18, TextXAlignment = CENTER }, "SubText")
	w.SearchBox = New("TextBox", {
		Size = UDim2.new(1, -32, 1, 0), Position = UDim2.fromOffset(28, 0), BackgroundTransparency = 1, Font = FONT, TextSize = 12,
		TextXAlignment = LEFT, PlaceholderText = "Buscar opção...", Text = "", ClearTextOnFocus = false, Parent = sbox,
	})
	w:Bind(w.SearchBox, "TextColor3", "Text")
	w.SearchBox.PlaceholderColor3 = w.Theme.SubText
	w.SearchBox:GetPropertyChangedSignal("Text"):Connect(function() w:Search(w.SearchBox.Text) end)

	-- banner
	local banner = New("Frame", { Size = UDim2.new(1, -24, 0, 66), Position = UDim2.fromOffset(12, 52), ClipsDescendants = true, Parent = content })
	w:Bind(banner, "BackgroundColor3", "Card")
	Round(banner, 8)
	w.BannerImage = New("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Crop, Image = "", Parent = banner })
	local ov = New("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, Parent = banner })
	w:Bind(ov, "BackgroundColor3", "Card")
	New("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.55, 0.15), NumberSequenceKeypoint.new(1, 0.85) }), Parent = ov })
	local bar = New("Frame", { Size = UDim2.new(0, 4, 1, 0), BorderSizePixel = 0, Parent = banner })
	w:Bind(bar, "BackgroundColor3", "Accent")
	w.WelcomeLabel = Label(w, banner, { Size = UDim2.new(1, -30, 0, 28), Position = UDim2.fromOffset(18, 8), Font = FONTB, TextSize = 20, RichText = true, TextTruncate = Enum.TextTruncate.AtEnd })
	w.WelcomeSubLabel = Label(w, banner, { Size = UDim2.new(1, -30, 0, 18), Position = UDim2.fromOffset(18, 38), TextSize = 12, RichText = true, TextTruncate = Enum.TextTruncate.AtEnd }, "SubText")
	table.insert(w.Refreshers, function() w:_refreshBanner() end)

	w.Pages = New("Frame", { Size = UDim2.new(1, -24, 1, -130), Position = UDim2.fromOffset(12, 124), BackgroundTransparency = 1, ClipsDescendants = true, Parent = content })

	-- notificacoes
	w.NotifyHolder = New("Frame", { Size = UDim2.fromOffset(300, 0), AutomaticSize = AUTOY, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16), BackgroundTransparency = 1, Parent = gui })
	List(w.NotifyHolder, 8)

	-- fps / ping
	w.StatsFrame = New("Frame", { Size = UDim2.fromOffset(0, 24), AutomaticSize = AUTOX, Position = UDim2.fromOffset(8, 8), Visible = false, Parent = gui })
	w:Bind(w.StatsFrame, "BackgroundColor3", "Background")
	Round(w.StatsFrame, 5)
	local sst = Stroke(w.StatsFrame, w.Theme.Accent, 1)
	w:Bind(sst, "Color", "Accent")
	local statsLabel = Label(w, w.StatsFrame, { Size = UDim2.fromOffset(0, 24), AutomaticSize = AUTOX, Text = "FPS: --", Font = FONTB, TextSize = 12 })
	Pad(statsLabel, 8, 0, 8, 0)
	local acc, frames = 0, 0
	w:Connect(RunService.RenderStepped, function(dt)
		acc += dt
		frames += 1
		if acc >= 0.5 then
			w.FPS = math.floor(frames / acc + 0.5)
			acc, frames = 0, 0
			pcall(function() w.Ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
			if w.StatsFrame.Visible then
				statsLabel.Text = string.format("FPS: %d  |  Ping: %dms  |  Jogadores: %d", w.FPS, w.Ping, #Players:GetPlayers())
			end
		end
	end)

	-- pill (minimizado)
	w.Pill = New("Frame", { Size = UDim2.fromOffset(0, 36), AutomaticSize = AUTOX, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 20), Visible = false, Active = true, Parent = gui })
	w:Bind(w.Pill, "BackgroundColor3", "Background")
	Round(w.Pill, 18)
	local pst = Stroke(w.Pill, w.Theme.Accent, 1.5)
	w:Bind(pst, "Color", "Accent")
	w.PillLabel = Label(w, w.Pill, { Size = UDim2.fromOffset(0, 36), AutomaticSize = AUTOX, Text = string.upper(w.Title), Font = FONTX, TextSize = 14 })
	Pad(w.PillLabel, 18, 0, 18, 0)
	MakeDraggable(w, w.Pill, w.Pill, function() w:SetState("open") end)

	-- modal de informacoes
	local modal = New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, Visible = false, ZIndex = 50, Active = true, Parent = main })
	Round(modal, 12)
	local panel = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(430, math.min(340, H - 30)), Parent = modal })
	w:Bind(panel, "BackgroundColor3", "Card")
	Round(panel, 12)
	local pnst = Stroke(panel, w.Theme.Accent, 1)
	w:Bind(pnst, "Color", "Accent")
	Label(w, panel, { Size = UDim2.new(1, -60, 0, 36), Position = UDim2.fromOffset(16, 4), Text = "Informações", Font = FONTB, TextSize = 16 })
	local xb = New("TextButton", { Text = "✕", Font = FONTB, TextSize = 14, AutoButtonColor = false, Size = UDim2.fromOffset(26, 26), Position = UDim2.new(1, -36, 0, 9), Parent = panel })
	w:Bind(xb, "BackgroundColor3", "Element")
	w:Bind(xb, "TextColor3", "Text")
	Round(xb, 7)
	xb.MouseButton1Click:Connect(function() modal.Visible = false end)

	local infoTabsBar = New("Frame", { Size = UDim2.new(1, -32, 0, 28), Position = UDim2.fromOffset(16, 44), BackgroundTransparency = 1, Parent = panel })
	List(infoTabsBar, 6, Enum.FillDirection.Horizontal)
	local infoList = New("ScrollingFrame", {
		Size = UDim2.new(1, -32, 1, -88), Position = UDim2.fromOffset(16, 80), BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = AUTOY, Parent = panel,
	})
	w:Bind(infoList, "ScrollBarImageColor3", "Accent")
	List(infoList, 4)

	task.spawn(function()
		local okk, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, game.PlaceId)
		if okk and info then w.GameName = info.Name end
	end)

	local function fmtTime(sec)
		sec = math.floor(sec)
		return string.format("%02d:%02d:%02d", sec // 3600, sec % 3600 // 60, sec % 60)
	end
	local infoTabs = {
		Jogador = function()
			local ch = LocalPlayer.Character
			local hum = ch and ch:FindFirstChildOfClass("Humanoid")
			local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
			return {
				{ "Nickname (menu)", w.Nick }, { "Usuário", LocalPlayer.Name }, { "Display name", LocalPlayer.DisplayName },
				{ "User ID", LocalPlayer.UserId }, { "Idade da conta", LocalPlayer.AccountAge .. " dias" },
				{ "Premium", LocalPlayer.MembershipType == Enum.MembershipType.Premium and "Sim" or "Não" },
				{ "Vida", hum and string.format("%d / %d", math.floor(hum.Health), math.floor(hum.MaxHealth)) or "-" },
				{ "Velocidade", hum and math.floor(hum.WalkSpeed) or "-" },
				{ "Posição", hrp and string.format("%d, %d, %d", math.floor(hrp.Position.X), math.floor(hrp.Position.Y), math.floor(hrp.Position.Z)) or "-" },
			}
		end,
		Jogo = function()
			return {
				{ "Nome", w.GameName or "carregando..." }, { "Place ID", game.PlaceId }, { "Game ID", game.GameId },
				{ "Versão do place", game.PlaceVersion },
			}
		end,
		Servidor = function()
			return {
				{ "Job ID", game.JobId ~= "" and game.JobId or "(Studio)" },
				{ "Jogadores", #Players:GetPlayers() .. " / " .. Players.MaxPlayers },
				{ "Ping", w.Ping .. " ms" }, { "FPS", w.FPS },
				{ "Tempo do servidor", fmtTime(workspace.DistributedGameTime) },
				{ "Servidor privado", game.PrivateServerId ~= "" and "Sim" or "Não" },
			}
		end,
	}
	local infoOrder = { "Jogador", "Jogo", "Servidor" }
	local curInfo = "Jogador"
	local rowsCache, infoBtns = {}, {}

	local function renderInfo()
		local data = infoTabs[curInfo]()
		for i, item in ipairs(data) do
			local r = rowsCache[i]
			if not r then
				local f = New("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 0.6, LayoutOrder = i, Parent = infoList })
				w:Bind(f, "BackgroundColor3", "Element")
				Round(f, 6)
				local l = Label(w, f, { Size = UDim2.new(0.38, 0, 1, 0), Position = UDim2.fromOffset(10, 0) }, "SubText")
				local v = Label(w, f, { Size = UDim2.new(0.62, -20, 1, 0), Position = UDim2.new(0.38, 10, 0, 0), TextXAlignment = RIGHT, TextTruncate = Enum.TextTruncate.AtEnd })
				f.MouseButton1Click:Connect(function() w:Copy(v.Text) end)
				r = { f = f, l = l, v = v }
				rowsCache[i] = r
			end
			r.f.Visible = true
			r.l.Text = item[1]
			r.v.Text = tostring(item[2])
		end
		for i = #data + 1, #rowsCache do rowsCache[i].f.Visible = false end
	end
	local function styleInfoTabs()
		for name, b in pairs(infoBtns) do
			b.BackgroundColor3 = (name == curInfo) and w.Theme.Accent or w.Theme.Element
			b.TextColor3 = (name == curInfo) and Color3.new(1, 1, 1) or w.Theme.SubText
		end
	end
	for _, name in ipairs(infoOrder) do
		local b = New("TextButton", { Text = name, Font = FONTB, TextSize = 12, AutoButtonColor = false, Size = UDim2.fromOffset(92, 28), Parent = infoTabsBar })
		Round(b, 7)
		infoBtns[name] = b
		b.MouseButton1Click:Connect(function() curInfo = name styleInfoTabs() renderInfo() end)
	end
	table.insert(w.Refreshers, styleInfoTabs)
	styleInfoTabs()

	card.MouseButton1Click:Connect(function()
		modal.Visible = not modal.Visible
		if modal.Visible then
			task.spawn(function()
				while modal.Visible and gui.Parent do
					renderInfo()
					task.wait(1)
				end
			end)
		end
	end)

	-- tecla global
	w:Connect(UserInputService.InputBegan, function(input, gpe)
		if gpe or input.UserInputType ~= Enum.UserInputType.Keyboard or w.Listening then return end
		if input.KeyCode == w.ToggleKey then
			w:Toggle()
			return
		end
		for _, kb in ipairs(w.Keybinds) do
			if kb.Key == input.KeyCode and kb.Callback then task.spawn(kb.Callback, kb.Key) end
		end
	end)

	-- inicial
	w:SetLogo(o.Logo)
	w:SetBanner(o.Banner)
	w:SetAvatar(o.Avatar)
	w:_layoutLogo()
	w:_refreshBanner()
	if o.Settings ~= false then w:_buildSettings() end
	return w
end

return Library
