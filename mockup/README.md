# Protótipo BonAcheter (mockup)

Protótipo HTML/CSS clicável. **Idioma da interface: português (Brasil).**

Documentação sobre limites fiscais (GST/QST, modelo do app vs. varejo): [`docs/architecture/consumption-taxes-quebec.md`](../docs/architecture/consumption-taxes-quebec.md).

## Como abrir

1. Abrir `index.html` no navegador (duplo clique ou `open mockup/index.html` a partir da pasta do projeto).
2. Para visualização tipo telefone, reduzir a largura da janela ou usar DevTools em modo mobile (~390px).

## Navegação

- **Abertura:** « Começar » → onboarding; « Já tenho uma conta » → painel (com abas **Início** / **Lista**).
- **Abas:** visíveis só em `#screen-dashboard` e `#screen-list`.
- **Painel:** orçamento, acesso rápido (lista, orçamento, última compra, ajustes).
- **Onboarding:** idioma → lar → região → painel.
- **Lista:** faixa de orçamento (clique) → orçamento; itens → histórico de preços; adicionar / registrar compra.
- **Novo item:** código de barras Open Food Facts, imposto, **origem da categoria**, detalhe expansível, link **Fontes dos impostos (Québec)**.
- **Fontes dos impostos** (`#screen-tax-info`): GST/QST, `isTaxable`, links Revenu Québec / ARC e link para o doc de arquitetura.
- **Registrar compra:** detalhe expansível GST/QST (estimativa).
- **Ajustes:** conta (wireframe), idioma, unidades, lar, comunidade, **referências fiscais** + doc do repositório.

## Ficheiros

- `index.html` — ecrãs e navegação por hash (`#screen-*`).
- `styles.css` — mobile-first, bleu Québec (#003da5).

## Especificações

Ver `docs/design/personas-flows.md` e `docs/design/screens.md`.
