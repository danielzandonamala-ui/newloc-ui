# NEWLOC UI

Biblioteca de interface em **Luau (Roblox)** no estilo de menu FiveM: tema roxo, sidebar com abas, seções em cartões, banner de boas-vindas, painel de informações do jogador, aba de configurações com editor de cores, sistema de config (salvar, carregar, exportar e importar) e tela de abertura.

---

## Sumário

- [Instalação](#instalação)
- [Exemplo rápido](#exemplo-rápido)
- [Configuração do código-fonte (`SOURCE`)](#configuração-do-código-fonte-source)
- [Janela](#janela)
- [Abas e seções](#abas-e-seções)
- [Elementos](#elementos)
- [Métodos da janela](#métodos-da-janela)
- [Aba Configurações (automática)](#aba-configurações-automática)
- [Sistema de config](#sistema-de-config)
- [Cores do tema](#cores-do-tema)
- [Imagens](#imagens)
- [Arquivos do repositório](#arquivos-do-repositório)
- [Solução de problemas](#solução-de-problemas)

---

## Instalação

```lua
local NewlocUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/danielzandonamala-ui/newloc-ui/refs/heads/main/newloc.lua"))()
```

---

## Exemplo rápido

```lua
local Window = NewlocUI:CreateWindow({
    ToggleKey = Enum.KeyCode.RightControl,
})

local Tab = Window:CreateTab({ Name = "Principal", Icon = "◆" })
local Section = Tab:CreateSection("Geral")

Section:CreateButton({
    Name = "Teste",
    Callback = function()
        Window:Notify({ Title = "NEWLOC", Content = "Funcionando!", Duration = 3 })
    end,
})

Section:CreateToggle({
    Name = "Ativar algo",
    CurrentValue = false,
    Callback = function(v) print("Toggle:", v) end,
})

Section:CreateSlider({
    Name = "Valor",
    Range = { 0, 100 },
    CurrentValue = 50,
    Callback = function(v) print("Slider:", v) end,
})
```

Um exemplo com todas as funções está no arquivo `exemplo.lua`.

---

## Configuração do código-fonte (`SOURCE`)

No topo do `newloc.lua` existe a tabela `SOURCE`. **Só quem tem o código-fonte edita isso**; essas opções não aparecem na aba Configurações do menu.

```lua
local SOURCE = {
    Title = "NEWLOC MENU",                       -- título grande da sidebar
    Subtitle = "UI Library",                     -- subtítulo da sidebar
    Logo = "",                                   -- ID ou link de imagem (aparece acima do título)
    Banner = "",                                 -- ID ou link da imagem do banner
    WelcomeText = "Bem-vindo de volta, {nick}!", -- texto do banner ({nick} e {title})
    WelcomeSub = "Aproveite sua experiência com o {title}.",

    ButtonIcon = "https://raw.githubusercontent.com/.../fingerprint.png", -- ícone dos botões

    Splash = {                                   -- tela de abertura
        Enabled = true,
        Title = "NEWLOC MENU",
        Subtitle = "Carregando...",
        Image = "",                              -- opcional
        Duration = 2.5,                          -- segundos
    },
}
```

| Campo | O que faz |
|---|---|
| `Title` / `Subtitle` | Texto da sidebar e do botão minimizado |
| `Logo` | Imagem exibida acima do título |
| `Banner` | Imagem de fundo do banner de boas-vindas |
| `WelcomeText` / `WelcomeSub` | Textos do banner. `{nick}` vira o nickname (na cor de destaque) e `{title}` vira o título |
| `ButtonIcon` | PNG usado nos botões (impressão digital). Se vazio ou falhar, usa um desenho padrão |
| `Splash` | Tela de abertura com título, subtítulo, imagem opcional e barra de carregamento. `Enabled = false` desliga |

---

## Janela

```lua
local Window = NewlocUI:CreateWindow({
    ToggleKey = Enum.KeyCode.RightControl,
    Nickname = nil,
    Avatar = nil,
    Width = 800,
    Height = 500,
    Settings = true,
})
```

| Opção | Padrão | Descrição |
|---|---|---|
| `ToggleKey` | `RightControl` | Tecla que oculta/mostra o menu por completo. Dá para trocar na aba Configurações |
| `Nickname` | `DisplayName` do jogador | Nome exibido no menu |
| `Avatar` | headshot do jogador | ID ou link de uma foto de perfil |
| `Width` / `Height` | `800` / `500` | Tamanho da janela (limitado ao tamanho da tela) |
| `Settings` | `true` | `false` não cria a aba Configurações |

### Controles da janela

- **Tecla (`ToggleKey`)**: oculta tudo, sem mostrar nada na tela. Apertar de novo traz o menu de volta.
- **Botão X**: oculta o menu da mesma forma. Use a tecla para reabrir.
- **Botão de minimizar**: fica só uma pílula com o título do menu. Clique nela para restaurar. Ela pode ser arrastada.
- **Card do jogador (canto inferior esquerdo)**: abre um painel com informações do **jogador**, do **jogo** e do **servidor**. Clicar em uma linha copia o valor.
- **Busca**: filtra as opções da aba atual.
- A janela é arrastável pela barra superior.

---

## Abas e seções

```lua
local Tab = Window:CreateTab({ Name = "Principal", Icon = "◆" })
```

- `Name`: nome da aba.
- `Icon`: texto curto (um símbolo simples) **ou** ID/link de imagem. Dê preferência a ID de imagem, porque alguns símbolos e emojis podem não aparecer na fonte do Roblox.

```lua
local Section = Tab:CreateSection("Nome")
-- ou escolhendo a coluna:
local Section = Tab:CreateSection({ Name = "Nome", Side = "Right" }) -- "Left" ou "Right"
```

Sem `Side`, as seções se alternam entre a coluna esquerda e a direita.

---

## Elementos

Todos são criados a partir de uma seção (`Section:CreateXxx`).

Elementos com valor aceitam estas opções comuns:

| Opção | Descrição |
|---|---|
| `Flag` | Nome do elemento na config. Padrão: `"NomeDaAba/NomeDoElemento"` |
| `Save = false` | O elemento **não** entra na config |
| `Callback` | Função chamada quando o valor muda |

E têm estes métodos:

```lua
elemento:Get()              -- valor atual
elemento:Set(valor, silent) -- define o valor (silent = true não dispara o Callback)
```

### Button

```lua
Section:CreateButton({
    Name = "Nome da opção",
    Callback = function() end,
})
```

O botão é um quadradinho com o ícone de impressão digital (`SOURCE.ButtonIcon`).

### Toggle

```lua
Section:CreateToggle({ Name = "God Mode", CurrentValue = false, Callback = function(v) end })
```

### Slider

```lua
Section:CreateSlider({
    Name = "Velocidade",
    Range = { 16, 200 },
    Increment = 1,       -- passo
    CurrentValue = 16,
    Suffix = "%",        -- opcional
    Callback = function(v) end,
})
```

### Dropdown

```lua
local dd = Section:CreateDropdown({
    Name = "Veículo",
    Options = { "Sultan", "Adder" },
    CurrentValue = "Sultan",
    Callback = function(v) end,
})
dd:SetOptions({ "Outro", "Lista" })  -- troca as opções
```

### Selector (`<  >`)

```lua
Section:CreateSelector({
    Name = "Tamanho",
    Options = { "Pequeno", "Normal", "Grande" },
    CurrentValue = "Normal",
    Callback = function(v) end,
})
```

### Input (caixa de texto)

```lua
Section:CreateInput({
    Name = "Quantia",
    Placeholder = "Digite...",
    CurrentValue = "",
    Callback = function(texto) end,  -- chamado ao confirmar (Enter / sair da caixa)
})
```

### Keybind

```lua
Section:CreateKeybind({
    Name = "Atalho",
    CurrentValue = Enum.KeyCode.G,
    Callback = function(key) end,    -- chamado ao APERTAR a tecla
    OnChanged = function(key) end,   -- chamado ao TROCAR a tecla
})
```

Clique no botão e aperte uma tecla. `Backspace` remove a tecla e `Esc` cancela.

### ColorPicker

```lua
Section:CreateColorPicker({
    Name = "Cor",
    CurrentValue = Color3.fromRGB(124, 58, 237), -- ou "#7C3AED"
    Callback = function(cor) end,                -- recebe Color3
})
```

Seletor estilo paint: quadrado de saturação/brilho, barra de matiz, campo hex e paleta rápida. `Get()` devolve o valor em hexadecimal (`"#7C3AED"`).

### Label

```lua
local l = Section:CreateLabel("Texto")
l:Set("Novo texto")
```

---

## Métodos da janela

| Método | Descrição |
|---|---|
| `Window:Notify({ Title, Content, Duration })` | Notificação no canto da tela (`Duration` em segundos, padrão 3) |
| `Window:Toggle()` | Oculta/mostra o menu por completo |
| `Window:Minimize()` | Minimiza/restaura |
| `Window:SetState("open" / "minimized" / "hidden")` | Define o estado da janela |
| `Window:SetColor(chave, Color3)` | Muda uma cor do tema ([chaves](#cores-do-tema)) |
| `Window:SetOpacity(0.3 a 1)` | Opacidade do menu |
| `Window:SetNickname(texto)` | Nickname exibido |
| `Window:SetAvatar(idOuLink)` | Foto de perfil (vazio volta ao padrão) |
| `Window:SetTitle(texto)` / `SetSubtitle(texto)` | Título e subtítulo |
| `Window:SetLogo(idOuLink)` / `SetBanner(idOuLink)` | Logo e imagem do banner |
| `Window:SetWelcome(texto, subtexto)` | Textos do banner |
| `Window:SaveConfig(nome)` | Salva em arquivo |
| `Window:LoadConfig(nome)` | Carrega de arquivo |
| `Window:DeleteConfig(nome)` | Apaga um arquivo de config |
| `Window:ListConfigs()` | Lista os nomes das configs salvas |
| `Window:ExportConfig()` | Devolve a config como texto (JSON) |
| `Window:ImportConfig(texto)` | Aplica uma config a partir do texto |
| `Window:ResetAll()` | Volta todos os elementos ao valor inicial |
| `Window:Destroy()` | Remove o menu |
| `Window.Flags` | Tabela com o valor atual de cada elemento |

`SaveConfig` e `LoadConfig` devolvem `true` ou `false, "motivo"`.

---

## Aba Configurações (automática)

Criada sempre por último na sidebar:

- **Personalização**: nickname, foto de perfil, opacidade do menu, mostrar FPS/Ping na tela.
- **Cores**: tema rápido (Roxo, Azul, Ciano, Verde, Laranja, Vermelho, Rosa) e um seletor de cor para cada parte do menu, com botão de restaurar.
- **Teclas e janela**: tecla de ocultar/mostrar, ocultar agora e minimizar.
- **Configuração**: salvar, carregar, deletar, lista de configs salvas, exportar (copia para a área de transferência), importar (cole o texto e importe) e resetar tudo.

---

## Sistema de config

Cada elemento com valor entra na config pelo seu `Flag` (ou `"Aba/Nome"` por padrão). A config guarda:

- funções ativas (toggles, sliders, dropdowns, inputs, teclas);
- cores do tema;
- personalização (nickname, foto de perfil, opacidade, tecla de ocultar).

**Arquivos** (precisam de `writefile`, `readfile`, `listfiles`, `makefolder`, `isfolder` e `delfile` no executor): ficam na pasta `workspace/NewlocUI/configs/NOME.json`.

**Exportar / importar** funcionam por texto e não dependem de arquivos.

```lua
Window:SaveConfig("minha")
Window:LoadConfig("minha")

local texto = Window:ExportConfig()
Window:ImportConfig(texto)

-- carregar automaticamente ao iniciar (depois de criar todas as abas):
Window:LoadConfig("default")
```

> Carregue a config **depois** de criar todos os elementos, senão os que ainda não existem não são afetados.

---

## Cores do tema

Chaves aceitas em `Window:SetColor`:

| Chave | Parte do menu |
|---|---|
| `Accent` | Cor principal (destaques, botões, toggles ligados) |
| `Background` | Fundo do menu |
| `Sidebar` | Barra lateral |
| `Card` | Cartões das seções |
| `Element` | Fundo dos elementos |
| `Text` | Texto principal |
| `SubText` | Texto secundário |
| `Stroke` | Bordas e toggles desligados |

```lua
Window:SetColor("Accent", Color3.fromRGB(239, 68, 68))
```

---

## Imagens

Onde há campo de imagem (`Logo`, `Banner`, `Avatar`, `ButtonIcon`, `Splash.Image`, ícone de aba), aceita:

| Formato | Exemplo | Requisito |
|---|---|---|
| ID numérico | `"123456789"` | nenhum |
| `rbxassetid://` | `"rbxassetid://123456789"` | nenhum |
| Link direto | `"https://.../imagem.png"` | executor com `writefile` + `getcustomasset` |

Links: o conteúdo baixado é validado (PNG, JPG, GIF ou WEBP) e fica em cache em `workspace/NewlocUI/img/`. O link precisa apontar **direto para o arquivo** (no GitHub, use o link `raw.githubusercontent.com`).

---

## Arquivos do repositório

| Arquivo | Função |
|---|---|
| `newloc.lua` | A biblioteca (é o que o `loadstring` carrega) |
| `fingerprint.png` | Ícone de impressão digital dos botões. Deve ficar na mesma pasta do `newloc.lua`, no mesmo branch do link em `SOURCE.ButtonIcon` |
| `exemplo.lua` | Script de exemplo usando todas as funções |
| `README.md` | Este arquivo |

---

## Solução de problemas

**A impressão digital não aparece nos botões (só círculos).**
1. Confira se o `fingerprint.png` está no repositório e se o link em `SOURCE.ButtonIcon` abre a imagem no navegador.
2. Se você testou antes de subir o arquivo, pode haver um cache antigo. Apague a pasta `workspace/NewlocUI/img/` e execute de novo.
3. O executor precisa suportar `writefile` e `getcustomasset`. Sem isso, a imagem por link não carrega (o desenho padrão aparece no lugar).
4. Veja o console (F9): a biblioteca avisa com `[NewlocUI]` o motivo de uma imagem não ter carregado.

**Salvar config não funciona.** Seu executor não tem as funções de arquivo. Use exportar e importar por texto.

**O menu sumiu.** Ele está oculto: aperte a tecla de ocultar/mostrar (padrão `RightControl`).

**Algum símbolo da aba aparece quebrado.** A fonte do Roblox não tem todos os símbolos. Use um ID de imagem em `Icon` ou um caractere simples.
