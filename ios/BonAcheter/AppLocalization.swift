//
//  AppLocalization.swift
//  BonAcheter
//

import Foundation

// MARK: - Preference (stored)

enum AppLanguagePreference: String, CaseIterable, Codable {
    case system
    case english
    case french
    case portugueseBrazil
    case spanish
}

// MARK: - Map system locale to app language

enum AppLanguageResolver {
    static func resolvedLanguageCode(for preference: AppLanguagePreference) -> String {
        switch preference {
        case .system:
            return systemLanguageCode()
        case .english:
            return "en"
        case .french:
            return "fr"
        case .portugueseBrazil:
            return "pt-BR"
        case .spanish:
            return "es"
        }
    }
    
    /// Picks a supported app language from iOS preferred languages.
    static func systemLanguageCode() -> String {
        for id in Locale.preferredLanguages {
            let lower = id.lowercased().replacingOccurrences(of: "_", with: "-")
            if lower.hasPrefix("fr") { return "fr" }
            if lower.hasPrefix("pt-br") { return "pt-BR" }
            if lower.hasPrefix("pt") { return "pt-BR" }
            if lower.hasPrefix("es") { return "es" }
            if lower.hasPrefix("en") { return "en" }
        }
        return "en"
    }
}

// MARK: - UI strings

struct AppStrings {
    private let code: String
    
    init(langCode: String) {
        self.code = langCode.lowercased()
    }
    
    private func t(en: String, fr: String, pt: String, es: String) -> String {
        if code.hasPrefix("fr") { return fr }
        if code.hasPrefix("pt") { return pt }
        if code.hasPrefix("es") { return es }
        return en
    }
    
    // Language picker (option names)
    func languagePickerLabel(_ pref: AppLanguagePreference) -> String {
        switch pref {
        case .system:
            return t(
                en: "System language",
                fr: "Langue du système",
                pt: "Idioma do sistema",
                es: "Idioma del sistema"
            )
        case .english:
            return "English"
        case .french:
            return "Français"
        case .portugueseBrazil:
            return "Português (Brasil)"
        case .spanish:
            return "Español"
        }
    }
    
    var tabHome: String { t(en: "Home", fr: "Accueil", pt: "Início", es: "Inicio") }
    var tabList: String { t(en: "List", fr: "Liste", pt: "Lista", es: "Lista") }
    
    var landingTitle: String { "BonAcheter" }
    var landingSubtitle: String {
        t(
            en: "Shared list, budget and Québec taxes.\nMontérégie, CMM.",
            fr: "Liste partagée, budget et taxes Québec.\nMontérégie, CMM.",
            pt: "Lista compartilhada, orçamento e impostos do Québec.\nMontérégie, CMM.",
            es: "Lista compartida, presupuesto e impuestos de Québec.\nMontérégie, CMM."
        )
    }
    var landingStart: String { t(en: "Get started", fr: "Commencer", pt: "Começar", es: "Empezar") }
    var landingHaveAccount: String {
        t(en: "I already have an account", fr: "J'ai déjà un compte", pt: "Já tenho uma conta", es: "Ya tengo una cuenta")
    }
    var landingCreateAccount: String {
        t(en: "Create account with email", fr: "Créer un compte avec courriel", pt: "Criar conta com e-mail", es: "Crear cuenta con correo")
    }
    
    var dashboardTitle: String { t(en: "Dashboard", fr: "Tableau de bord", pt: "Painel", es: "Panel") }
    var dashboardBudgetPeriod: String { t(en: "Period budget", fr: "Budget période", pt: "Orçamento do período", es: "Presupuesto del período") }
    func dashboardRemaining(_ remaining: Double, _ total: Double) -> String {
        let fmt = t(
            en: "%.0f $ left / %.0f $",
            fr: "%.0f $ restants / %.0f $",
            pt: "%.0f $ restantes / %.0f $",
            es: "%.0f $ restantes / %.0f $"
        )
        return String(format: fmt, remaining, total)
    }
    var dashboardQuickAccess: String { t(en: "Quick access", fr: "Accès rapide", pt: "Acesso rápido", es: "Acceso rápido") }
    var dashboardMyList: String { t(en: "My list", fr: "Ma liste", pt: "Minha lista", es: "Mi lista") }
    var dashboardBudget: String { t(en: "Budget", fr: "Budget", pt: "Orçamento", es: "Presupuesto") }
    var dashboardLastTrip: String { t(en: "Last grocery run", fr: "Dernière course", pt: "Última compra", es: "Última compra") }
    var dashboardLastTripMock: String { "IGA — 45,20 $" }
    var dashboardSettings: String { t(en: "Settings", fr: "Paramètres", pt: "Ajustes", es: "Ajustes") }
    
    func budgetPeriod(_ p: BudgetPeriod) -> String {
        switch p {
        case .biweekly:
            return t(en: "Biweekly", fr: "Bi-hebdo", pt: "Quinzenal", es: "Quincenal")
        case .monthly:
            return t(en: "Monthly", fr: "Mensuel", pt: "Mensal", es: "Mensual")
        }
    }
    
    var listTitle: String { t(en: "My list", fr: "Ma liste", pt: "Minha lista", es: "Mi lista") }
    var listBudget: String { t(en: "Budget", fr: "Budget", pt: "Orçamento", es: "Presupuesto") }
    var listArticles: String { t(en: "Items", fr: "Articles", pt: "Itens", es: "Artículos") }
    var listAddItem: String { t(en: "Add item", fr: "Ajouter un article", pt: "Adicionar item", es: "Añadir artículo") }
    var listRecordPurchase: String {
        t(en: "I went shopping", fr: "J'ai fait les courses", pt: "Fiz as compras", es: "Hice la compra")
    }
    func listTaxLine(isTaxable: Bool) -> String {
        if isTaxable {
            return t(en: "14.98% tax", fr: "14,98% tax", pt: "14,98% imposto", es: "14,98% impuesto")
        }
        return t(en: "0% tax", fr: "0% tax", pt: "0% imposto", es: "0% impuesto")
    }
    func listBarcodeLine(_ code: String) -> String {
        let fmt = t(en: "Barcode %@", fr: "Code-barres %@", pt: "Código %@", es: "Código %@")
        return String(format: fmt, code)
    }
    
    func listPriceStats(avg: Double, min: Double, max: Double) -> String {
        let fmt = t(
            en: "Avg %.2f $ · min %.2f $ · max %.2f $",
            fr: "Moy. %.2f $ · min %.2f $ · max %.2f $",
            pt: "Méd. %.2f $ · mín %.2f $ · máx %.2f $",
            es: "Med. %.2f $ · mín %.2f $ · máx %.2f $"
        )
        return String(format: fmt, avg, min, max)
    }
    
    var addItemTitle: String { t(en: "New item", fr: "Nouvel article", pt: "Novo item", es: "Artículo nuevo") }
    var addItemName: String { t(en: "Name", fr: "Nom", pt: "Nome", es: "Nombre") }
    var addItemNamePlaceholder: String { t(en: "e.g. 2% milk", fr: "ex. Lait 2%", pt: "ex. Leite 2%", es: "ej. Leche 2%") }
    var addItemQtyUnit: String { t(en: "Quantity / Unit", fr: "Quantité / Unité", pt: "Quantidade / Unidade", es: "Cantidad / Unidad") }
    var addItemUnitPicker: String { t(en: "Unit", fr: "Unité", pt: "Unidade", es: "Unidad") }
    var addItemTax: String { t(en: "Tax", fr: "Taxe", pt: "Imposto", es: "Impuesto") }
    var addItemTaxCategory: String { t(en: "Category", fr: "Catégorie", pt: "Categoria", es: "Categoría") }
    var addItemTaxZero: String { t(en: "0% (grocery)", fr: "0% (alimentaire)", pt: "0% (alimentação)", es: "0% (alimentación)") }
    var addItemTaxable: String { t(en: "14.98% (taxable)", fr: "14,98% (taxable)", pt: "14,98% (tributado)", es: "14,98% (gravable)") }
    var addItemScan: String { t(en: "Scan barcode", fr: "Scanner code-barres", pt: "Ler código de barras", es: "Escanear código de barras") }
    var addItemBarcodeSection: String {
        t(en: "Barcode (Open Food Facts)", fr: "Code-barres (Open Food Facts)", pt: "Código de barras (Open Food Facts)", es: "Código de barras (Open Food Facts)")
    }
    var addItemBarcodePlaceholder: String {
        t(en: "8+ digits (EAN/UPC)", fr: "8+ chiffres (EAN/UPC)", pt: "8+ dígitos (EAN/UPC)", es: "8+ dígitos (EAN/UPC)")
    }
    var addItemLookupOFF: String {
        t(en: "Look up product", fr: "Rechercher le produit", pt: "Buscar produto", es: "Buscar producto")
    }
    var addItemSave: String { t(en: "Save", fr: "Enregistrer", pt: "Salvar", es: "Guardar") }
    var addItemNewDefaultName: String { t(en: "New item", fr: "Nouvel article", pt: "Novo item", es: "Artículo nuevo") }
    
    var addItemTaxOriginTitle: String {
        t(en: "Category origin", fr: "Origine de la catégorie", pt: "Origem da categoria", es: "Origen de la categoría")
    }
    func addItemTaxOriginBody(source: TaxCategorySource, isTaxable: Bool) -> String {
        switch source {
        case .manual:
            if isTaxable {
                return t(
                    en: "Manual choice — taxable line: GST+QST simplified to 14.98% in the app (see Tax sources).",
                    fr: "Choix manuel — ligne taxable : TPS + TVQ simplifiées à 14,98 % dans l’app (voir Sources fiscales).",
                    pt: "Escolha manual — linha tributável: GST+QST simplificados a 14,98% no app (veja Fontes fiscais).",
                    es: "Elección manual: línea gravable; GST+QST simplificados al 14,98% en la app (ver Fuentes fiscales)."
                )
            }
            return t(
                en: "Manual choice — basic grocery at 0%; check exceptions (beverages, format, etc.) on Revenu Québec.",
                fr: "Choix manuel — aliment de base à 0 % ; vérifiez les exceptions (boissons, format, etc.) sur Revenu Québec.",
                pt: "Escolha manual — alimento básico a 0%; confira exceções (bebidas, formato etc.) no Revenu Québec.",
                es: "Elección manual: alimento básico al 0%; revise excepciones en Revenu Québec."
            )
        case .openFoodFacts:
            return t(
                en: "Open Food Facts estimate — product categories (Québec heuristic, not legal advice).",
                fr: "Estimation Open Food Facts — catégories produit (heuristique Québec, pas un avis fiscal).",
                pt: "Estimativa Open Food Facts — categorias do produto (heurística Québec; não é assessoria fiscal).",
                es: "Estimación Open Food Facts — categorías (heurística; no es asesoramiento fiscal)."
            )
        case .appDefault:
            return t(
                en: "App default when no other source is available.",
                fr: "Valeur par défaut de l’app lorsque aucune autre source n’est disponible.",
                pt: "Valor padrão do app quando não há outra fonte.",
                es: "Valor por defecto de la app cuando no hay otra fuente."
            )
        }
    }
    var addItemTaxDisclaimer: String {
        t(
            en: "Indicative only — not tax advice. If in doubt, consult Revenu Québec or the CRA.",
            fr: "Indicatif seulement — pas un avis fiscal. En cas de doute, consultez Revenu Québec ou l’ARC.",
            pt: "Apenas indicativo — não substitui orientação fiscal. Em dúvida, consulte Revenu Québec ou a ARC.",
            es: "Solo orientativo; no es asesoramiento fiscal. Consulte Revenu Québec o la ARC."
        )
    }
    var addItemTaxHowTitle: String {
        t(en: "How this category is set", fr: "Comment cette catégorie est déterminée", pt: "Como essa categoria é definida", es: "Cómo se define esta categoría")
    }
    var addItemTaxHowBody: String {
        t(
            en: "Your picker choice, an Open Food Facts suggestion after scan or lookup, or an app default. The app stores isTaxable only — not full legal detail per item.",
            fr: "Votre choix dans le sélecteur, une suggestion Open Food Facts après scan ou recherche, ou une valeur par défaut. L’app enregistre seulement isTaxable.",
            pt: "Sua escolha no controle, sugestão do Open Food Facts após leitura ou busca, ou padrão do app. O app guarda só isTaxable — não o detalhe legal por item.",
            es: "Su elección, sugerencia de Open Food Facts o valor por defecto. La app solo guarda isTaxable."
        )
    }
    var addItemTaxSourcesLink: String {
        t(en: "GST/QST details & official links", fr: "TPS/TVQ et liens officiels", pt: "GST/QST e links oficiais", es: "GST/QST y enlaces oficiales")
    }
    
    func listTaxSourceBadge(_ source: TaxCategorySource?) -> String? {
        guard let source else { return nil }
        switch source {
        case .manual:
            return t(en: "Manual choice", fr: "Choix manuel", pt: "Escolha manual", es: "Elección manual")
        case .openFoodFacts:
            return t(en: "Estim. Open Food Facts", fr: "Estim. Open Food Facts", pt: "Estim. Open Food Facts", es: "Estim. Open Food Facts")
        case .appDefault:
            return t(en: "App default", fr: "Défaut app", pt: "Padrão do app", es: "Predeterminado")
        }
    }
    
    var taxSourcesTitle: String {
        t(en: "Tax sources (Québec)", fr: "Sources fiscales (Québec)", pt: "Fontes fiscais (Québec)", es: "Fuentes fiscales (Québec)")
    }
    var taxSourcesIntro1: String {
        t(
            en: "Taxable lines use one rounded factor (0.1498) in the app for budgeting. Official GST and QST follow Revenu Québec point-of-sale rules.",
            fr: "Les lignes taxables utilisent un facteur arrondi (0,1498) dans l’app. La TPS et la TVQ officielles suivent Revenu Québec.",
            pt: "Linhas tributáveis usam um fator arredondado (0,1498) no app. GST e QST oficiais seguem o Revenu Québec.",
            es: "Las líneas gravables usan 0,1498 en la app. La GST y QST oficiales siguen a Revenu Québec."
        )
    }
    var taxSourcesIntro2: String {
        t(
            en: "The taxable flag may come from your choice, Open Food Facts categories, or an app default — not a barcode certification.",
            fr: "La catégorie peut venir de votre choix, des catégories Open Food Facts ou d’un défaut — pas une certification par code-barres.",
            pt: "A categoria pode vir da sua escolha, das categorias Open Food Facts ou do padrão — não é certificação por código de barras.",
            es: "La categoría puede venir de su elección, Open Food Facts o un predeterminado."
        )
    }
    var taxSourcesDocFooter: String {
        t(
            en: "See also the repo doc consumption-taxes-quebec.md",
            fr: "Voir aussi consumption-taxes-quebec.md dans le dépôt",
            pt: "Veja também consumption-taxes-quebec.md no repositório",
            es: "Vea también consumption-taxes-quebec.md en el repositorio"
        )
    }
    
    var recordTaxDetailTitle: String {
        t(en: "Tax detail (illustrative)", fr: "Détail des taxes (indicatif)", pt: "Detalhe dos impostos (ilustrativo)", es: "Detalle de impuestos (ilustrativo)")
    }
    var recordTaxGstLine: String { t(en: "GST 5% (taxable base)", fr: "TPS 5 % (base taxable)", pt: "GST 5% (base tributável)", es: "GST 5% (base gravable)") }
    var recordTaxQstLine: String { t(en: "QST 9.975% (same base, illustrative)", fr: "TVQ 9,975 % (même base, indicatif)", pt: "QST 9,975% (mesma base, ilustrativo)", es: "QST 9,975% (misma base, ilustrativo)") }
    var recordTaxDetailFootnote: String {
        t(
            en: "The app totals tax with 0.1498 per line; GST+QST shown here split the same base for reference. Cash register rules may differ.",
            fr: "L’app totalise avec 0,1498 ; le détail TPS/TVQ est indicatif. Le caisse peut différer.",
            pt: "O app totaliza com 0,1498; GST+QST aqui dividem a mesma base só como referência. O caixa pode diferir.",
            es: "La app usa 0,1498; el desglose es orientativo."
        )
    }
    
    var settingsTaxReferences: String {
        t(en: "Tax references (Québec)", fr: "Références fiscales (Québec)", pt: "Referências fiscais (Québec)", es: "Referencias fiscales (Québec)")
    }
    var settingsTaxReferencesFootnote: String {
        t(
            en: "Official pages to verify tax-exempt vs taxable foods — not applied live in the app.",
            fr: "Pages officielles — le prototype n’applique pas ces règles en temps réel.",
            pt: "Páginas oficiais — o app não aplica essas regras em tempo real.",
            es: "Páginas oficiales; la app no aplica estas reglas en vivo."
        )
    }
    var linkRevenuQuebecHome: String { t(en: "Revenu Québec — home", fr: "Revenu Québec — accueil", pt: "Revenu Québec — início", es: "Revenu Québec — inicio") }
    var linkRqCalculatingTaxes: String {
        t(en: "Calculating GST and QST (RQ)", fr: "Calcul des taxes (RQ)", pt: "Cálculo de impostos (RQ)", es: "Cálculo de impuestos (RQ)")
    }
    var linkRevenuQuebecGroceryStores: String {
        t(
            en: "Groceries & convenience stores (RQ)",
            fr: "Épiceries et dépanneurs (RQ)",
            pt: "Mercearias (RQ)",
            es: "Tiendas de comestibles (RQ)"
        )
    }
    var linkRevenuQuebecFood: String {
        t(
            en: "Food — taxable or zero-rated",
            fr: "Alimentation — produits taxables ou détaxés",
            pt: "Alimentação — tributados ou isentos",
            es: "Alimentación — gravados o exentos"
        )
    }
    var linkCraHome: String { t(en: "Canada Revenue Agency", fr: "Agence du revenu du Canada", pt: "Agência da Receita do Canadá", es: "Agencia de ingresos de Canadá") }
    
    func measurementSystemLabel(_ system: GroceryMeasurementSystem) -> String {
        switch system {
        case .metricBrazilCanada:
            return t(
                en: "Brazil & Canada (metric)",
                fr: "Brésil et Canada (métrique)",
                pt: "Brasil e Canadá (métrico)",
                es: "Brasil y Canadá (métrico)"
            )
        case .usCustomary:
            return t(
                en: "United States (US customary)",
                fr: "États-Unis (mesures US)",
                pt: "Estados Unidos (medidas US)",
                es: "Estados Unidos (medidas US)"
            )
        }
    }
    
    var settingsMeasurementSection: String {
        t(en: "Measurement units", fr: "Unités de mesure", pt: "Unidades de medida", es: "Unidades de medida")
    }
    var settingsMeasurementFooter: String {
        t(
            en: "Metric (L, kg, g, ml) matches typical labels in Brazil and Canada. Choose US customary for lb, oz, fl oz, cups, pints, quarts, and gallons.",
            fr: "Le métrique (L, kg, g, ml) correspond aux étiquettes courantes au Brésil et au Canada. Choisissez les mesures US pour lb, oz, fl oz, tasses, chopines, pintes et gallons.",
            pt: "O métrico (L, kg, g, ml) coincide com rótulos comuns no Brasil e no Canadá. Use medidas americanas para lb, oz, fl oz, xícaras, pt, qt e gal.",
            es: "El métrico (L, kg, g, ml) coincide con etiquetas típicas en Brasil y Canadá. Elija medidas de EE. UU. para lb, oz, fl oz, tazas, pt, qt y gal."
        )
    }
    
    func unitLabel(_ stored: String) -> String {
        switch stored {
        case "piece", "pièce":
            return t(en: "ea", fr: "pce", pt: "un.", es: "pza.")
        case "L":
            return "L"
        case "ml":
            return "ml"
        case "kg":
            return "kg"
        case "g":
            return "g"
        case "lb":
            return "lb"
        case "oz":
            return t(en: "oz", fr: "oz", pt: "oz", es: "oz")
        case "fl_oz":
            return t(en: "fl oz", fr: "oz liq.", pt: "fl oz", es: "fl oz")
        case "cup":
            return t(en: "cup", fr: "tasse", pt: "xíc.", es: "taza")
        case "pt":
            return "pt"
        case "qt":
            return t(en: "qt", fr: "qt", pt: "qt", es: "qt")
        case "gal":
            return t(en: "gal", fr: "gal", pt: "gal", es: "gal")
        default:
            return stored
        }
    }
    
    var recordStore: String { t(en: "Store", fr: "Magasin", pt: "Loja", es: "Tienda") }
    var recordStorePlaceholder: String { t(en: "e.g. IGA, Maxi", fr: "ex. IGA, Maxi", pt: "ex. IGA, Maxi", es: "ej. IGA, Maxi") }
    var recordItemsBought: String { t(en: "Items purchased", fr: "Articles achetés", pt: "Itens comprados", es: "Artículos comprados") }
    var recordPricePlaceholder: String { t(en: "Price $", fr: "Prix $", pt: "Preço $", es: "Precio $") }
    var recordRecap: String { t(en: "Summary", fr: "Récap", pt: "Resumo", es: "Resumen") }
    var recordSubtotal: String { t(en: "Subtotal", fr: "Sous-total", pt: "Subtotal", es: "Subtotal") }
    var recordTaxes: String { t(en: "Taxes", fr: "Taxes", pt: "Impostos", es: "Impuestos") }
    var recordTotal: String { t(en: "Total", fr: "Total", pt: "Total", es: "Total") }
    var recordSave: String { t(en: "Save grocery run", fr: "Enregistrer la course", pt: "Salvar compra", es: "Guardar compra") }
    var recordTitle: String { recordSave }
    
    var shareDialogTitle: String {
        t(
            en: "Share prices with the community?",
            fr: "Partager les prix avec la communauté ?",
            pt: "Compartilhar preços com a comunidade?",
            es: "¿Compartir precios con la comunidad?"
        )
    }
    var shareDialogYes: String {
        t(en: "Yes, help the community", fr: "Oui, aider la communauté", pt: "Sim, ajudar a comunidade", es: "Sí, ayudar a la comunidad")
    }
    var shareDialogNo: String { t(en: "No thanks", fr: "Non merci", pt: "Não, obrigado", es: "No, gracias") }
    var shareDialogMessage: String {
        t(
            en: "Amounts may be used for anonymous averages. No network connection yet.",
            fr: "Les montants peuvent être utilisés pour des moyennes anonymes. Aucune connexion réseau pour l’instant.",
            pt: "Os valores podem ser usados em médias anônimas. Ainda sem conexão de rede.",
            es: "Los importes pueden usarse para promedios anónimos. Aún sin conexión de red."
        )
    }
    
    var settingsTitle: String { t(en: "Settings", fr: "Paramètres", pt: "Ajustes", es: "Ajustes") }
    var settingsRegion: String { t(en: "Shopping region(s)", fr: "Région(s) d'achat", pt: "Região(ões) de compra", es: "Región(es) de compra") }
    var settingsLanguage: String { t(en: "Language", fr: "Langue", pt: "Idioma", es: "Idioma") }
    /// Shared label for household / foyer (settings section and onboarding).
    var household: String { t(en: "Household", fr: "Foyer", pt: "Lar", es: "Hogar") }
    var settingsInvite: String { t(en: "Invite members", fr: "Inviter des membres", pt: "Convidar membros", es: "Invitar miembros") }
    var settingsInviteCodeLabel: String {
        t(en: "Invite code", fr: "Code d'invitation", pt: "Código de convite", es: "Código de invitación")
    }
    var settingsCopyInvite: String { t(en: "Copy code", fr: "Copier le code", pt: "Copiar código", es: "Copiar código") }
    var settingsInviteShare: String { t(en: "Share invite", fr: "Partager l'invitation", pt: "Compartilhar convite", es: "Compartir invitación") }
    var settingsInviteShareSubject: String { "BonAcheter" }
    var settingsInviteShareMessage: String {
        t(
            en: "Join our BonAcheter household with this code:",
            fr: "Rejoignez notre foyer BonAcheter avec ce code :",
            pt: "Entre no lar BonAcheter com este código:",
            es: "Únete a nuestro hogar BonAcheter con este código:"
        )
    }
    var settingsNoHouseholdCode: String {
        t(
            en: "Complete onboarding with “Create a household” or “Join” to get a code.",
            fr: "Terminez l’accueil avec « Créer un foyer » ou « Rejoindre » pour obtenir un code.",
            pt: "Conclua o onboarding com “Criar lar” ou “Entrar” para obter um código.",
            es: "Completa el onboarding con “Crear hogar” o “Unirse” para obtener un código."
        )
    }
    var settingsHouseholdFooter: String {
        t(
            en: "Same code on every device will sync when the backend is enabled (see docs).",
            fr: "Le même code sur chaque appareil synchronisera lorsque le serveur sera activé (voir la doc).",
            pt: "O mesmo código em cada dispositivo sincronizará quando o backend estiver ativo (veja a doc).",
            es: "El mismo código en cada dispositivo se sincronizará cuando el backend esté activo (ver docs)."
        )
    }
    var settingsCommunity: String { t(en: "Community", fr: "Communauté", pt: "Comunidade", es: "Comunidad") }
    var settingsSharePricesTitle: String {
        t(en: "Share prices (community)", fr: "Partager les prix (communauté)", pt: "Compartilhar preços (comunidade)", es: "Compartir precios (comunidad)")
    }
    var settingsSharePricesFootnote: String {
        t(
            en: "Contribute to anonymous averages when the API is available.",
            fr: "Contribuer à des moyennes anonymes lorsque l’API sera disponible.",
            pt: "Contribuir com médias anônimas quando a API estiver disponível.",
            es: "Contribuir a promedios anónimos cuando la API esté disponible."
        )
    }
    var settingsSignOut: String { t(en: "Sign out", fr: "Déconnexion", pt: "Sair", es: "Cerrar sesión") }
    
    var budgetTitle: String { dashboardBudget }
    var budgetPeriodSection: String { t(en: "Period", fr: "Période", pt: "Período", es: "Período") }
    var budgetAmountSection: String { t(en: "Amount (CAD)", fr: "Montant (CAD)", pt: "Valor (CAD)", es: "Importe (CAD)") }
    func budgetRemainingLine(_ amount: Double) -> String {
        let fmt = t(
            en: "Current balance: %.0f $ left",
            fr: "Solde actuel : %.0f $ restants",
            pt: "Saldo atual: %.0f $ restantes",
            es: "Saldo actual: %.0f $ restantes"
        )
        return String(format: fmt, amount)
    }
    var budgetSave: String { t(en: "Save", fr: "Enregistrer", pt: "Salvar", es: "Guardar") }
    
    var regionTitle: String { t(en: "Shopping region", fr: "Région d'achat", pt: "Região de compra", es: "Región de compra") }
    var regionCountry: String { t(en: "Country / Province", fr: "Pays / Province", pt: "País / Província", es: "País / Provincia") }
    var regionCanadaQC: String { t(en: "Canada — Québec", fr: "Canada — Québec", pt: "Canadá — Québec", es: "Canadá — Québec") }
    var regionRegions: String { t(en: "Region(s)", fr: "Région(s)", pt: "Região(ões)", es: "Región(es)") }
    var regionMonteregieDisplayName: String { "Montérégie" }
    var regionCMMDisplayName: String { "CMM" }
    var regionCity: String { t(en: "City", fr: "Ville", pt: "Cidade", es: "Ciudad") }
    var regionContinue: String { t(en: "Continue", fr: "Continuer", pt: "Continuar", es: "Continuar") }
    
    var languageOnboardingTitle: String { t(en: "Language", fr: "Langue", pt: "Idioma", es: "Idioma") }
    var onboardingBack: String { t(en: "Back", fr: "Retour", pt: "Voltar", es: "Volver") }
    var languageOnboardingHeadline: String { "BonAcheter" }
    var languageOnboardingSubtitle: String {
        t(en: "Choose your language", fr: "Choisissez votre langue", pt: "Escolha seu idioma", es: "Elige tu idioma")
    }
    var languageOnboardingHint: String {
        t(
            en: "You can pick a fixed language or follow the system.",
            fr: "Vous pouvez choisir une langue fixe ou suivre le système.",
            pt: "Você pode escolher um idioma fixo ou seguir o sistema.",
            es: "Puedes elegir un idioma fijo o seguir el sistema."
        )
    }
    
    var householdCreate: String { t(en: "Create a household", fr: "Créer un foyer", pt: "Criar um lar", es: "Crear un hogar") }
    var householdOr: String { t(en: "or", fr: "ou", pt: "ou", es: "o") }
    var householdInvitePlaceholder: String {
        t(en: "Invitation code", fr: "Code d'invitation", pt: "Código de convite", es: "Código de invitación")
    }
    var householdJoin: String { t(en: "Join", fr: "Rejoindre", pt: "Entrar", es: "Unirse") }
    
    var historyEmpty: String {
        t(
            en: "No recorded purchases for this item.",
            fr: "Aucun achat enregistré pour cet article.",
            pt: "Nenhuma compra registrada para este item.",
            es: "No hay compras registradas para este artículo."
        )
    }
    var historyAverage: String { t(en: "Average", fr: "Moyenne", pt: "Média", es: "Media") }
    var historyLowest: String { t(en: "Lowest", fr: "Moins cher", pt: "Mais barato", es: "Más barato") }
    var historyHighest: String { t(en: "Highest", fr: "Plus cher", pt: "Mais caro", es: "Más caro") }
    var historyPurchases: String { t(en: "Purchases", fr: "Achats", pt: "Compras", es: "Compras") }
    var historySummary: String { t(en: "Summary", fr: "Résumé", pt: "Resumo", es: "Resumen") }
    var historySection: String { t(en: "History", fr: "Historique", pt: "Histórico", es: "Historial") }
    
    var scannerTitle: String { t(en: "Scanner", fr: "Scanner", pt: "Leitor", es: "Escáner") }
    var scannerCameraHint: String {
        t(
            en: "Camera view — Barcode / QR",
            fr: "Vue caméra — Code-barres / QR",
            pt: "Câmera — Código de barras / QR",
            es: "Cámara — Código de barras / QR"
        )
    }
    var scannerSimulate: String { t(en: "Simulate successful scan", fr: "Simuler un scan réussi", pt: "Simular leitura bem-sucedida", es: "Simular escaneo correcto") }
    var scannerMockProduct: String { t(en: "Scanned product", fr: "Produit scanné", pt: "Produto lido", es: "Producto escaneado") }
    var scannerClose: String { t(en: "Close", fr: "Fermer", pt: "Fechar", es: "Cerrar") }
    var scannerManualSection: String {
        t(en: "Enter barcode", fr: "Saisir le code-barres", pt: "Digite o código", es: "Introducir código")
    }
    var scannerManualPlaceholder: String { addItemBarcodePlaceholder }
    var scannerLookupButton: String { addItemLookupOFF }
    var scannerLookupInProgress: String {
        t(en: "Looking up…", fr: "Recherche…", pt: "Buscando…", es: "Buscando…")
    }
    var scannerLookupFailed: String {
        t(en: "Lookup failed", fr: "Échec de la recherche", pt: "Falha na busca", es: "Error al buscar")
    }
    var scannerSimulateFooter: String {
        t(
            en: "Uses a sample EAN; replace with a real camera scan later.",
            fr: "Utilise un EAN d’exemple ; la caméra viendra plus tard.",
            pt: "Usa um EAN de exemplo; a câmera virá depois.",
            es: "Usa un EAN de ejemplo; la cámara llegará después."
        )
    }
    var scannerBarcodeTooShort: String {
        t(en: "Enter at least 8 digits.", fr: "Saisissez au moins 8 chiffres.", pt: "Digite pelo menos 8 dígitos.", es: "Introduce al menos 8 dígitos.")
    }
    
    var loginTitle: String { t(en: "Sign in", fr: "Connexion", pt: "Entrar", es: "Iniciar sesión") }
    var loginEmailPlaceholder: String { t(en: "Email", fr: "Courriel", pt: "E-mail", es: "Correo") }
    var loginPasswordPlaceholder: String { t(en: "Password", fr: "Mot de passe", pt: "Senha", es: "Contraseña") }
    var loginFooter: String {
        t(
            en: "Password and Passkeys stay on this device (Keychain). New accounts must verify email via a link. For production, use a backend (e.g. Supabase Auth).",
            fr: "Mot de passe et clés Passkey restent sur cet appareil (Trousseau). Les nouveaux comptes doivent valider le courriel par un lien. En production, utilisez un serveur (p. ex. Supabase Auth).",
            pt: "Senha e Passkeys ficam neste dispositivo (Keychain). Contas novas precisam validar o e-mail por um link. Em produção, use um backend (ex.: Supabase Auth).",
            es: "La contraseña y las Passkeys quedan en este dispositivo (Llavero). Las cuentas nuevas deben verificar el correo con un enlace. En producción, usa un backend (p. ej. Supabase Auth)."
        )
    }
    var loginSignIn: String { loginTitle }
    var loginCancel: String { t(en: "Cancel", fr: "Annuler", pt: "Cancelar", es: "Cancelar") }
    var loginCreateAccountInstead: String {
        t(en: "Create an account", fr: "Créer un compte", pt: "Criar uma conta", es: "Crear una cuenta")
    }
    var loginErrorWrongCredentials: String {
        t(
            en: "Incorrect email or password. Create an account if you have not registered yet.",
            fr: "Courriel ou mot de passe incorrect. Créez un compte si vous n’êtes pas encore inscrit.",
            pt: "E-mail ou senha incorretos. Crie uma conta se ainda não se registou.",
            es: "Correo o contraseña incorrectos. Crea una cuenta si aún no te has registrado."
        )
    }
    var loginErrorMissingFields: String {
        t(en: "Enter your email and password.", fr: "Saisissez votre courriel et mot de passe.", pt: "Introduza e-mail e senha.", es: "Introduce correo y contraseña.")
    }
    var loginErrorEmailNotVerified: String {
        t(
            en: "This email is not verified yet. Open the link we sent you, or resend the verification email.",
            fr: "Ce courriel n’est pas encore validé. Ouvrez le lien reçu ou renvoyez le courriel de validation.",
            pt: "Este e-mail ainda não foi validado. Abra a ligação que enviámos ou reenvie o e-mail de verificação.",
            es: "Este correo aún no está verificado. Abre el enlace que te enviamos o reenvía el correo de verificación."
        )
    }
    var loginWithPasskey: String {
        t(en: "Sign in with Passkey", fr: "Se connecter avec une clé Passkey", pt: "Entrar com Passkey", es: "Iniciar sesión con Passkey")
    }
    var loginPasskeyFailed: String {
        t(en: "Passkey sign-in failed.", fr: "Échec de la connexion Passkey.", pt: "Falha ao entrar com Passkey.", es: "Error al iniciar sesión con Passkey.")
    }
    var emailVerificationResendMail: String {
        t(en: "Resend verification email", fr: "Renvoyer le courriel de validation", pt: "Reenviar e-mail de verificação", es: "Reenviar correo de verificación")
    }
    
    var signUpTitle: String {
        t(en: "Create account", fr: "Créer un compte", pt: "Criar conta", es: "Crear cuenta")
    }
    var signUpEmailPlaceholder: String { loginEmailPlaceholder }
    var signUpPasswordPlaceholder: String { loginPasswordPlaceholder }
    var signUpConfirmPasswordPlaceholder: String {
        t(en: "Confirm password", fr: "Confirmer le mot de passe", pt: "Confirmar senha", es: "Confirmar contraseña")
    }
    var signUpPasswordRules: String {
        t(
            en: "At least 8 characters. Password is saved only on this iPhone/iPad (Keychain). You must verify your email before signing in.",
            fr: "Au moins 8 caractères. Le mot de passe est enregistré uniquement sur cet iPhone/iPad (Trousseau). Vous devez valider votre courriel avant de vous connecter.",
            pt: "Pelo menos 8 caracteres. A senha fica só neste iPhone/iPad (Keychain). Tem de verificar o e-mail antes de entrar.",
            es: "Al menos 8 caracteres. La contraseña se guarda solo en este iPhone/iPad (Llavero). Debes verificar el correo antes de iniciar sesión."
        )
    }
    var signUpCreateButton: String {
        t(en: "Create account", fr: "Créer le compte", pt: "Criar conta", es: "Crear cuenta")
    }
    var signUpErrorTitle: String { t(en: "Could not create account", fr: "Impossible de créer le compte", pt: "Não foi possível criar a conta", es: "No se pudo crear la cuenta") }
    var signUpErrorInvalidEmail: String {
        t(en: "Enter a valid email address.", fr: "Saisissez une adresse courriel valide.", pt: "Introduza um e-mail válido.", es: "Introduce un correo válido.")
    }
    var signUpErrorPasswordShort: String {
        t(en: "Password must be at least 8 characters.", fr: "Le mot de passe doit contenir au moins 8 caractères.", pt: "A senha deve ter pelo menos 8 caracteres.", es: "La contraseña debe tener al menos 8 caracteres.")
    }
    var signUpErrorPasswordMismatch: String {
        t(en: "Passwords do not match.", fr: "Les mots de passe ne correspondent pas.", pt: "As senhas não coincidem.", es: "Las contraseñas no coinciden.")
    }
    var signUpErrorAccountExists: String {
        t(
            en: "This email is already registered and verified. Sign in instead.",
            fr: "Ce courriel est déjà enregistré et validé. Connectez-vous plutôt.",
            pt: "Este e-mail já está registado e verificado. Entre em vez disso.",
            es: "Este correo ya está registrado y verificado. Inicia sesión."
        )
    }
    var signUpErrorWrongPasswordUnverified: String {
        t(
            en: "This email is registered but not verified yet. Enter the same password you used when you registered to get a new verification link.",
            fr: "Ce courriel est enregistré mais pas encore validé. Saisissez le même mot de passe qu’à l’inscription pour recevoir un nouveau lien de validation.",
            pt: "Este e-mail está registado mas ainda não foi verificado. Use a mesma palavra-passe de quando se registou para obter uma nova ligação de verificação.",
            es: "Este correo está registrado pero aún no verificado. Usa la misma contraseña que al registrarte para obtener un nuevo enlace de verificación."
        )
    }
    var signUpErrorKeychain: String {
        t(en: "Could not save credentials. Try again.", fr: "Impossible d’enregistrer les identifiants. Réessayez.", pt: "Não foi possível guardar as credenciais. Tente de novo.", es: "No se pudieron guardar las credenciales. Inténtalo de nuevo.")
    }
    
    var emailVerificationTitle: String {
        t(en: "Verify your email", fr: "Validez votre courriel", pt: "Verifique o seu e-mail", es: "Verifica tu correo")
    }
    /// When `canSendMail` is false (simulator, no Mail account), the “Send verification email” button is hidden—copy must match visible actions.
    func emailVerificationInstructions(email: String, canSendMail: Bool) -> String {
        if canSendMail {
            let fmt = t(
                en: "Your account is almost ready. Tap “Send verification email”, send the message to %@ from your Mail app, then open the link on this device.",
                fr: "Votre compte est presque prêt. Touchez « Envoyer le courriel », envoyez le message à %@ depuis Courrier, puis ouvrez le lien sur cet appareil.",
                pt: "A sua conta está quase pronta. Toque em “Enviar e-mail”, envie a mensagem para %@ no Mail e abra a ligação neste dispositivo.",
                es: "Tu cuenta casi está lista. Toca «Enviar correo», envía el mensaje a %@ desde Mail y abre el enlace en este dispositivo."
            )
            return String(format: fmt, email)
        }
        let fmt = t(
            en: "Your account is almost ready. This device can’t open a pre-filled Mail message (for example on the simulator without Mail). Use “Share verification link” below for %@, open the link on this iPhone or iPad, or paste a link in the field below if you copied it from another device.",
            fr: "Votre compte est presque prêt. Cet appareil ne peut pas ouvrir un courrier prérempli (par ex. simulateur sans Courrier). Utilisez « Partager le lien de validation » ci-dessous pour %@, ouvrez le lien sur cet iPhone ou iPad, ou collez un lien copié depuis un autre appareil.",
            pt: "A sua conta está quase pronta. Este dispositivo não abre o Mail pré-preenchido (ex.: simulador sem Mail). Use « Partilhar ligação de verificação » abaixo para %@, abra a ligação neste iPhone ou iPad, ou cole uma ligação no campo abaixo se a copiou doutro dispositivo.",
            es: "Tu cuenta casi está lista. Este dispositivo no puede abrir un correo rellenado (p. ej. simulador sin Mail). Usa «Compartir enlace de verificación» abajo para %@, abre el enlace en este iPhone o iPad, o pega un enlace abajo si lo copiaste de otro dispositivo."
        )
        return String(format: fmt, email)
    }
    var emailVerificationOpenMail: String {
        t(en: "Send verification email", fr: "Envoyer le courriel de validation", pt: "Enviar e-mail de verificação", es: "Enviar correo de verificación")
    }
    var emailVerificationShareSubject: String {
        t(en: "Verify your BonAcheter account", fr: "Valider votre compte BonAcheter", pt: "Verificar a sua conta BonAcheter", es: "Verificar tu cuenta BonAcheter")
    }
    var emailVerificationShareMessage: String {
        t(en: "Open this link on your iPhone/iPad to verify:", fr: "Ouvrez ce lien sur votre iPhone/iPad pour valider :", pt: "Abra esta ligação no iPhone/iPad para verificar:", es: "Abre este enlace en tu iPhone/iPad para verificar:")
    }
    var emailVerificationShareLink: String {
        t(en: "Share verification link", fr: "Partager le lien de validation", pt: "Partilhar ligação de verificação", es: "Compartir enlace de verificación")
    }
    var emailVerificationNewLink: String {
        t(en: "Generate a new link", fr: "Générer un nouveau lien", pt: "Gerar nova ligação", es: "Generar un enlace nuevo")
    }
    var emailVerificationPastePlaceholder: String {
        t(en: "Paste verification link", fr: "Coller le lien de validation", pt: "Colar ligação de verificação", es: "Pegar enlace de verificación")
    }
    var emailVerificationPasteButton: String {
        t(en: "Open pasted link", fr: "Ouvrir le lien collé", pt: "Abrir ligação colada", es: "Abrir enlace pegado")
    }
    var emailVerificationPasteFooter: String {
        t(
            en: "If you copied the link from another device, paste it here.",
            fr: "Si vous avez copié le lien depuis un autre appareil, collez-le ici.",
            pt: "Se copiou a ligação de outro dispositivo, cole-a aqui.",
            es: "Si copiaste el enlace desde otro dispositivo, pégalo aquí."
        )
    }
    var emailVerificationInvalidLink: String {
        t(en: "This link is invalid or expired. Generate a new link.", fr: "Lien invalide ou expiré. Générez un nouveau lien.", pt: "Ligação inválida ou expirada. Gere uma nova.", es: "Enlace no válido o caducado. Genera uno nuevo.")
    }
    var emailVerificationMailSubject: String {
        t(en: "Verify your BonAcheter email", fr: "Valider votre courriel BonAcheter", pt: "Verificar o seu e-mail BonAcheter", es: "Verificar tu correo BonAcheter")
    }
    var emailVerificationMailBodyIntro: String {
        t(
            en: "Tap the link below on this iPhone or iPad to verify your email:",
            fr: "Touchez le lien ci-dessous sur cet iPhone ou iPad pour valider votre courriel :",
            pt: "Toque na ligação abaixo neste iPhone ou iPad para verificar o seu e-mail:",
            es: "Toca el enlace siguiente en este iPhone o iPad para verificar tu correo:"
        )
    }
    var emailVerificationMailBodyOutro: String {
        t(
            en: "If you did not create a BonAcheter account, you can ignore this message.",
            fr: "Si vous n’avez pas créé de compte BonAcheter, ignorez ce message.",
            pt: "Se não criou uma conta BonAcheter, ignore esta mensagem.",
            es: "Si no creaste una cuenta BonAcheter, ignora este mensaje."
        )
    }
    
    var settingsAccount: String { t(en: "Account", fr: "Compte", pt: "Conta", es: "Cuenta") }
    var settingsSignedInAs: String { t(en: "Signed in as", fr: "Connecté en tant que", pt: "Sessão como", es: "Sesión como") }
    var settingsAddPasskey: String {
        t(en: "Add Passkey", fr: "Ajouter une clé Passkey", pt: "Adicionar Passkey", es: "Añadir Passkey")
    }
    var settingsPasskeyAdded: String {
        t(en: "Passkey saved on this device.", fr: "Clé Passkey enregistrée sur cet appareil.", pt: "Passkey guardada neste dispositivo.", es: "Passkey guardada en este dispositivo.")
    }
    var settingsPasskeyFooter: String {
        t(
            en: "Passkeys use iCloud Keychain and require Associated Domains (webcredentials) for your Relying Party ID in production.",
            fr: "Les Passkeys utilisent le Trousseau iCloud et exigent des domaines associés (webcredentials) pour votre identifiant de partie de confiance en production.",
            pt: "As Passkeys usam o Keychain do iCloud e exigem domínios associados (webcredentials) para o Relying Party ID em produção.",
            es: "Las Passkeys usan Llavero de iCloud y requieren dominios asociados (webcredentials) para tu Relying Party ID en producción."
        )
    }
    var settingsPasskeyNeedsVerifiedEmail: String {
        t(
            en: "Verify your email before adding a Passkey.",
            fr: "Validez votre courriel avant d’ajouter une Passkey.",
            pt: "Verifique o e-mail antes de adicionar uma Passkey.",
            es: "Verifica tu correo antes de añadir una Passkey."
        )
    }
    
    var alertDismissOK: String { t(en: "OK", fr: "OK", pt: "OK", es: "OK") }
}

extension AppState {
    var resolvedLanguageCode: String {
        AppLanguageResolver.resolvedLanguageCode(for: languagePreference)
    }
    
    var strings: AppStrings {
        AppStrings(langCode: resolvedLanguageCode)
    }
    
    var localeForFormatting: Locale {
        switch resolvedLanguageCode.prefix(2) {
        case "fr":
            return Locale(identifier: "fr_CA")
        case "pt":
            return Locale(identifier: "pt_BR")
        case "es":
            return Locale(identifier: "es_ES")
        default:
            return Locale(identifier: "en_CA")
        }
    }
}
