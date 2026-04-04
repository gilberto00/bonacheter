# Configuração Cursor — BonAcheter

## MCP: Browser (browsermcp)

O servidor **Browser MCP** está configurado em `mcp.json`. Ele permite que o Agent use ferramentas de browser (navegar, clicar, capturar tela, etc.).

**Para ativar:**
1. **Reinicie o Cursor** por completo (feche e abra de novo) para carregar o MCP.
2. Opcional: em **Cursor Settings** (Cmd+Shift+J) > **Tools & MCP**, confira se o servidor `browsermcp` aparece e está ligado (toggle verde).
3. O Agent passará a poder usar o browser quando você pedir (por exemplo: "abra o wireframe no browser").

**Requisitos:** Node.js e `npx` instalados (já verificados no projeto).

Se o Cursor tiver também a opção **"Browser Automation"** > **"Browser Tab"** em Settings, você pode ativar para o Agent usar a aba Browser interna do Cursor em vez de um browser externo.
