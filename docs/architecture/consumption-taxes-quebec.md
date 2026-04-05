# Impostos sobre consumo no Québec (contexto BonAcheter)

**Última revisão:** 2026-04-04  
**Objetivo deste documento:** explicar a diferença entre o **modelo simplificado do app** e as **regras reais** de TPS (GST) e TVQ (QST), com **ligações oficiais** para atualização. Não é assessoria fiscal.

---

## O que o BonAcheter faz hoje (MVP)

| Aspecto | Implementação | Ficheiros |
|--------|----------------|-----------|
| Classificação por artigo | Booleano `isTaxable` (tributável ou não) | [`BonAcheterApp.swift`](../../ios/BonAcheter/BonAcheterApp.swift) (`ListItem`) |
| Sugestão automática | Heurística sobre categorias do **Open Food Facts** | [`OpenFoodFactsClient.swift`](../../ios/BonAcheter/Services/OpenFoodFactsClient.swift) |
| Imposto na compra registrada | Para linhas tributáveis: `preço × 0.1498` (aproximação ~14,98 %) | [`RecordPurchaseView.swift`](../../ios/BonAcheter/Views/RecordPurchaseView.swift) |

O escopo do produto é **estimativa de orçamento familiar**, não conformidade fiscal de retalhistas nem declarações do utilizador.

---

## O que a legislação e o varejo fazem (resumo)

- **Alimentos básicos** vendidos em mercearias, em muitos casos, estão **sem TPS e sem TVQ** (fornecimentos com taxa zero / regras específicas de “produits alimentaires de base”). **Exceções** incluem bebidas (exceto leite natural simples), alguns formatos de padaria, comidas preparadas/quentes, doces, gelados, etc. — ver páginas oficiais abaixo.
- **Bens tributáveis** no Québec: TPS **5 %** e TVQ **9,975 %**. Na prática o cálculo ao caixa segue as **fórmulas publicadas pelo Revenu Québec** (incluindo a base sobre a qual incide a TVQ, frequentemente o valor que **já inclui a TPS**). Por isso um único multiplicador **0,1498 sobre o pré-imposto** é uma **aproximação** para o orçamento, não uma réplica do PDV.
- **“Taxas diferenciadas”** no contexto de mercearia são sobretudo **0 % vs taxa normal**, mais **nichos** (ex.: regras para certos estabelecimentos de restauração). Não é o mesmo padrão que múltiplas alíquotas estaduais por NCM como no Brasil.
- **Como retalhistas tratam o assunto:** cadastro de produtos (SKU/categoria) ligado a **códigos de imposto no ERP/PDV**, parametrização conforme orientação de contabilistas e documentação RQ/ARC, e **responsabilidade do comerciante** pela cobrança correta. Não há API pública canónica “EAN → tributável?” para aplicações de consumidor.

---

## Fontes oficiais (priorizar estes domínios)

Ao atualizar este documento ou o produto, **verificar sempre** o texto vigente nas páginas oficiais (URLs podem ser redireccionadas).

1. **Revenu Québec — Cálculo dos impostos (inglês)**  
   https://www.revenuquebec.ca/en/businesses/consumption-taxes/gsthst-and-qst/collecting-gst-and-qst/calculating-the-taxes/

2. **Revenu Québec — Mercearias e “dépanneurs”**  
   https://www.revenuquebec.ca/en/businesses/consumption-taxes/gsthst-and-qst/special-cases-gsthst-and-qst/food-services-sector-applying-the-gst-and-qst/grocery-and-convenience-stores/

3. **Revenu Québec — Alimentação: produtos tributáveis ou isentos (francês)**  
   https://www.revenuquebec.ca/fr/citoyens/taxes/biens-et-services-taxables-detaxes-ou-exoneres/tps-et-tvq/alimentation-produits-taxables-detaxes-ou-exoneres/

4. **ARC — TPS/TVH para empresas**  
   https://www.canada.ca/en/revenue-agency/services/tax/businesses/topics/gst-hst-businesses.html  

Versão francesa da ARC: https://www.canada.ca/fr/agence-revenu.html  

---

## MCP e “informação sempre atual”

Não existe (até à data desta revisão) um **MCP oficial** do governo que devolva classificação fiscal por código de barras. O fluxo recomendado para o equipa é:

- Manter **este ficheiro** e o mockup com **URLs canónicas** e **data de última revisão**.
- Para conferir alterações legislativas ou novas páginas: **navegador** ou **fetch** restrito a **`revenuquebec.ca`** e **`canada.ca`**.
- Opcionalmente, usar uma **regra do Cursor** no repositório para lembrar: citações sobre impostos QC só com fontes nestes domínios.

---

## Processo de revisão sugerido

1. Abrir os quatro links acima (ou equivalentes atualizados no sítio).
2. Ajustar **apenas o resumo** neste doc se algo mudar (não copiar texto legal integral).
3. Atualizar o campo **Última revisão** no topo.
4. Se o modelo do app mudar (ex.: novo cálculo), actualizar a tabela “O que o BonAcheter faz” e os comentários nos ficheiros Swift apontados para este documento.
