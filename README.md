# Soulseek Bombado 🚀🎵

Uma aplicação autossuficiente (Portátil e Nativa) projetada para orquestrar downloads potentes buscando músicas em FLAC e MP3-320 de provedores premium!

O aplicativo junta os poderes do **SpotDL** (Python) com o incrível mecanismo do **Soulseek** (slskd) oferecendo uma GUI moderna imitando **Fibra de Carbono e detalhes Neon**.

---

## 💻 Funcionalidades Principais
*   **SpotDL Puro:** Download rápido extraindo a rota de áudio via YouTube Music enquanto aplica as capas e os metadados oficias extraídos do Spotify de forma imaculada.
*   **Soulseek Puro:** Mapeamento 1 por 1. Passa o título direto para uma busca aprofundada na rede P2P Soulseek visando encontrar usuários online hospedando os arquivos exatos, em extrema qualidade.
*   **Modo Hybrid ⭐:** O melhor dos dois mundos. Primeiro uma varredura rigorosa P2P pelo Soulseek visando arquivos Lossless/320kb. Quando encontra "buracos" (músicas que faltaram), o app silenciosamente ativa um *fallback* via SpotDL para completar a playlist, garantindo **100% de aproveitamento** do download!
*   **Frontend Modular (UI Local):** Uma experiência visual em Web App (Web-Engine nativa embutida) eliminando ferramentas de TUI limitadas ou telas pretas de console.
*   **100% Portátil:** Pode ser transportado para Pendrives, levado em pastas zips para computadores "virgens" e até clonado por desenvolvedores da nuvem. O aplicativo gerencia seus caminhos internamente usando `$PSScriptRoot`.

---

## 📦 Como Usar a Versão Compilada (`.exe`)

Recomendamos usar nossa versão embarcada se você só quer "dar os cliques" e realizar os downloads sem se preocupar em abrir o editor de código.

1. Vá para a seção [**Releases**](https://github.com/Oliver-Rubem/Soulseek-Bombado/releases) deste repositório.
2. Baixe o arquivo `.zip` da versão mais recente (ex: `SoulseekBombado-v1.0.zip`).
3. Extraia o conteúdo para uma pasta no seu computador.
4. Dê dois cliques em **`SoulseekBombado.exe`**.
5. O aplicativo deve abrir uma bela interface de Webview.

> **Note:** Sendo um wrap local baseado em PyWebView, se for no Windows ele usará o Edge WebView2 interno que já vem no Windows 10/11 por padrão.

---

## 🛠️ Como Contribuir ou Modificar o Código (Modo `.bat` Fork)

Pensamos nos *forks* e nos curiosos. Deixamos as fontes totalmente expostas.

1. Descompacte os arquivos localmente.
2. Certifique-se de que tenha **Python >3.8** instalado localmente (`pip install pywebview`).
3. Para ativar a modificação transparente do código Frontend, basta abrir **`Iniciar-Soulseek.bat`** (ele roda a API crua de desenvolvimento via Terminal exibindo possiveis prints/logs no ar).
4. O frontend é manipulado em `interface/index.html` e estilizado via CSS Vanilla simples. Tudo conversando com os `.ps1` da pasta `scripts/`.

---

## 🔑 Sobre a API do Spotify e do Soulseek

O app é gentil o suficiente para não salvar nenhuma credencial externa no Github oficial (sua segurança e a nossa privacidade imperam). Mas para baixar usando nosso script, o ecossistema requer chaves.

### Spotify
É necessário um *Client ID* e um *Client Secret* gerado livremente por você para bater no ponto oficial das rotas (puxar número e nomes exatos das tracks em playlists grandiosas).
1. Vá até o [Dashboard de Desenvolvedores do Spotify](https://developer.spotify.com/dashboard).
2. Faça o login com a sua conta gratuita.
3. Crie um app fantasma e capture o `Client ID` e o `Client Secret`.
4. Transfira as duas chaves para as caixinhas na interface final deste App. Ele vai guardá-las para sempre no `config.json` e você não vai precisar abrir esse Dashboard nunca mais!

### Soulseek (Login Opcional)
Você notará que existe um campo de usuário e senha na GUI:
- **Já sou usuário avançado**: Se você já usa ativamente programas do Soulseek (`SoulseekQt`, `Nicotine+`) de forma rotineira no seu PC, é altamente provável que o sistema "vaze" a configuração pelo registro do %AppData% do Windows permitindo a inicialização automática, dispensando usuário e senha aqui.
- **Sou Novo / Computador Limpo**: Preencha o login! Faça uma conta rápida no portal do Soulseek e insira o *Username* e a *Password* nestes campos.

---

🌟 **Bom Download! E ajude semeando na rede P2P!**
