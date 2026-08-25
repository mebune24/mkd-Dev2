import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}

// AI response engine that handles all property/platform questions
class _SpaceRentalsAI {
  final bool isFr;
  _SpaceRentalsAI({required this.isFr});

  String respond(String input) {
    final q = input.toLowerCase().trim();

    // --- Greetings ---
    if (_matches(q, ['hello', 'hi', 'hey', 'bonjour', 'salut', 'bonsoir'])) {
      return isFr
          ? '👋 Bonjour ! Je suis **SpaceBot**, l\'assistant IA de SpaceRentals. Je peux vous aider avec :\n\n• Trouver des propriétés\n• Comprendre le processus de location\n• Informations sur les paiements\n• Procédure KYC pour propriétaires\n• Et bien plus encore!\n\nQue puis-je faire pour vous aujourd\'hui ?'
          : '👋 Hello! I\'m **SpaceBot**, the SpaceRentals AI assistant. I can help you with:\n\n• Finding properties\n• Understanding the rental process\n• Payment information\n• KYC process for landlords\n• And much more!\n\nWhat can I help you with today?';
    }

    // --- Properties ---
    if (_matches(q, ['property', 'properties', 'house', 'apartment', 'villa', 'studio', 'propriété', 'maison', 'appartement', 'find', 'search', 'chercher', 'trouver'])) {
      return isFr
          ? '🏠 **Trouver une Propriété**\n\nSpaceRentals propose des milliers de propriétés au Cameroun, notamment à :\n• **Yaoundé** – Bastos, Nlongkak, Melen, Omnisports\n• **Douala** – Bonanjo, Akwa, Bonapriso\n\n**Types disponibles :**\n✅ Appartements\n✅ Studios\n✅ Villas\n✅ Maisons individuelles\n✅ Logements étudiants\n✅ Bureaux commerciaux\n\nUtilisez la barre de recherche en haut ou le filtre de catégorie pour trouver exactement ce dont vous avez besoin !'
          : '🏠 **Finding a Property**\n\nSpaceRentals lists thousands of properties across Cameroon, including in:\n• **Yaoundé** – Bastos, Nlongkak, Melen, Omnisports\n• **Douala** – Bonanjo, Akwa, Bonapriso\n\n**Available types:**\n✅ Apartments\n✅ Studios\n✅ Villas\n✅ Houses\n✅ Student Housing\n✅ Commercial Offices\n\nUse the search bar at the top or the category filter to find exactly what you need!';
    }

    // --- Rent / Payment ---
    if (_matches(q, ['pay', 'payment', 'rent', 'payer', 'paiement', 'loyer', 'mtn', 'orange', 'momo', 'bank', 'visa', 'mastercard'])) {
      return isFr
          ? '💳 **Options de Paiement**\n\nSpaceRentals accepte plusieurs méthodes de paiement sécurisées :\n\n📱 **Mobile Money**\n• MTN Mobile Money\n• Orange Money\n\n🏦 **Carte Bancaire**\n• UBA Cameroun (Visa/Mastercard)\n• Afriland First Bank\n• Société Générale Cameroun\n• Ecobank\n• BICEC (Visa/GIMAC)\n\nPour payer votre loyer, allez dans **Mes Locations > Paiements** et choisissez votre méthode préférée. Les paiements sont sécurisés et confirmés en temps réel ✅'
          : '💳 **Payment Options**\n\nSpaceRentals supports multiple secure payment methods:\n\n📱 **Mobile Money**\n• MTN Mobile Money\n• Orange Money\n\n🏦 **Bank Card**\n• UBA Cameroon (Visa/Mastercard)\n• Afriland First Bank\n• Société Générale Cameroun\n• Ecobank\n• BICEC (Visa/GIMAC)\n\nTo pay your rent, go to **My Rentals > Payments** and choose your preferred method. Payments are secured and confirmed in real time ✅';
    }

    // --- KYC / Verification ---
    if (_matches(q, ['kyc', 'verify', 'verification', 'document', 'vérification', 'verified', 'landlord verify', 'id', 'titre', 'foncier', 'premium'])) {
      return isFr
          ? '📋 **Vérification KYC pour Propriétaires**\n\nPour publier des propriétés sur SpaceRentals, les propriétaires doivent se vérifier. Il existe **2 niveaux** :\n\n🔵 **Basique**\n• Carte Nationale d\'Identité (CNI)\n• Document de propriété foncière\n\n⭐ **Premium (Propriétaire Certifié)**\n• Titre Foncier officiel\n• Plan de Situation certifié\n• CNI valide\n• Quittance de taxe foncière *(optionnel)*\n\nAprès soumission, l\'équipe d\'administration de SpaceRentals examine vos documents sous **24 à 48 heures**. Une fois approuvé, vous pouvez lister vos propriétés immédiatement !'
          : '📋 **KYC Verification for Landlords**\n\nTo list properties on SpaceRentals, landlords must be verified. There are **2 tiers**:\n\n🔵 **Basic**\n• National ID Card (CNI)\n• Land property document\n\n⭐ **Premium (Certified Landlord)**\n• Official Land Title (Titre Foncier)\n• Certified Site Plan\n• Valid CNI\n• Property tax receipts *(optional)*\n\nAfter submission, the SpaceRentals admin team reviews your documents within **24-48 hours**. Once approved, you can list properties immediately!';
    }

    // --- Rental Application ---
    if (_matches(q, ['apply', 'application', 'how to rent', 'postuler', 'candidature', 'comment louer', 'how to apply'])) {
      return isFr
          ? '📝 **Comment Postuler à une Location**\n\n**Étapes simples :**\n1. 🔍 Parcourez les propriétés disponibles sur l\'écran d\'accueil\n2. 🏠 Appuyez sur une propriété qui vous intéresse\n3. 📋 Consultez les détails, les photos et la localisation sur la carte\n4. ✅ Appuyez sur **"Postuler / Louer maintenant"**\n5. 📄 Remplissez le formulaire de candidature\n6. ⏳ Attendez la confirmation du propriétaire\n7. 📜 Signez l\'accord de location numérique\n\n⚠️ **Important :** Vous devez avoir un compte locataire pour postuler.'
          : '📝 **How to Apply for a Rental**\n\n**Simple steps:**\n1. 🔍 Browse available properties on the home screen\n2. 🏠 Tap a property you\'re interested in\n3. 📋 Review details, photos and map location\n4. ✅ Tap **"Apply / Rent Now"**\n5. 📄 Fill out the rental application form\n6. ⏳ Await landlord confirmation\n7. 📜 Sign the digital rental agreement\n\n⚠️ **Important:** You need a tenant account to apply.';
    }

    // --- RNLP ---
    if (_matches(q, ['rnlp', 'deposit', 'financing', 'caution', 'financement', 'advance', 'avance'])) {
      return isFr
          ? '🏦 **RNLP – Financement de Caution**\n\nLe **Régime National de Location de Propriété (RNLP)** est un programme unique de SpaceRentals qui aide les locataires à financer leur caution locative.\n\n**Comment ça marche :**\n• SpaceRentals paie la caution en votre nom\n• Vous remboursez en **mensualités flexibles**\n• Aucun refus d\'appartement à cause d\'un manque de caution\n\nAccédez au RNLP depuis **Mes Locations > Financement RNLP** dans votre tableau de bord.'
          : '🏦 **RNLP – Deposit Financing**\n\nThe **Rental Neutral Loan Program (RNLP)** is a unique SpaceRentals program that helps tenants finance their rental deposit.\n\n**How it works:**\n• SpaceRentals pays the deposit on your behalf\n• You repay in **flexible monthly installments**\n• No more losing apartments due to lack of deposit funds\n\nAccess RNLP from **My Rentals > RNLP Financing** in your dashboard.';
    }

    // --- Maintenance ---
    if (_matches(q, ['maintenance', 'repair', 'fix', 'broken', 'réparation', 'service', 'plumbing', 'electric', 'electricité', 'panne'])) {
      return isFr
          ? '🔧 **Maintenance & Services**\n\nEn tant que locataire, vous pouvez soumettre des demandes de maintenance directement depuis l\'application !\n\n**Types de services :**\n• 🪛 Réparations générales\n• 🔌 Problèmes électriques\n• 🚿 Problèmes de plomberie\n• 🎨 Peinture et rénovation\n• ❄️ Climatisation\n• 🌿 Jardinage\n\n**Comment soumettre :**\nAllez dans **Mes Locations > Maintenance & Services**, décrivez le problème et soumettez. Le propriétaire sera notifié immédiatement.'
          : '🔧 **Maintenance & Services**\n\nAs a tenant, you can submit maintenance requests directly from the app!\n\n**Types of services:**\n• 🪛 General repairs\n• 🔌 Electrical issues\n• 🚿 Plumbing problems\n• 🎨 Painting & renovation\n• ❄️ Air conditioning\n• 🌿 Gardening\n\n**How to submit:**\nGo to **My Rentals > Maintenance & Services**, describe the problem and submit. The landlord will be notified immediately.';
    }

    // --- Account / Register ---
    if (_matches(q, ['account', 'register', 'sign up', 'create', 'compte', 'inscription', 'créer'])) {
      return isFr
          ? '👤 **Créer un Compte**\n\nSpaceRentals propose deux types de comptes :\n\n🏡 **Locataire**\n• Parcourir et postuler aux propriétés\n• Gérer vos locations\n• Effectuer des paiements\n• Accès RNLP\n\n🏗️ **Propriétaire**\n• Publier vos propriétés\n• Gérer vos locataires\n• Suivre les paiements\n• Vérification KYC obligatoire\n\n**Mot de passe requis :** 8 caractères minimum, une majuscule, un chiffre et un caractère spécial (!@#\$&*~).'
          : '👤 **Creating an Account**\n\nSpaceRentals offers two account types:\n\n🏡 **Tenant**\n• Browse and apply for properties\n• Manage your rentals\n• Make payments\n• RNLP access\n\n🏗️ **Landlord**\n• List your properties\n• Manage your tenants\n• Track payments\n• Mandatory KYC verification\n\n**Password requirement:** Minimum 8 characters, one uppercase letter, one number, and one special character (!@#\$&*~).';
    }

    // --- Price / Cost ---
    if (_matches(q, ['price', 'cost', 'how much', 'fcfa', 'cfa', 'prix', 'combien', 'tarif', 'cheap', 'affordable', 'budget'])) {
      return isFr
          ? '💰 **Gamme de Prix**\n\nLes propriétés sur SpaceRentals couvrent tous les budgets :\n\n| Type | Fourchette Mensuelle |\n|---|---|\n| Studio | 25 000 – 80 000 FCFA |\n| Appartement 2P | 80 000 – 200 000 FCFA |\n| Appartement 3P | 150 000 – 350 000 FCFA |\n| Villa | 300 000 – 1 000 000+ FCFA |\n| Logement Étudiant | 20 000 – 60 000 FCFA |\n\nUtilisez les filtres de prix sur la page de recherche pour affiner votre budget !'
          : '💰 **Price Range**\n\nProperties on SpaceRentals cover all budgets:\n\n| Type | Monthly Range |\n|---|---|\n| Studio | 25,000 – 80,000 FCFA |\n| 2-Bedroom Apt | 80,000 – 200,000 FCFA |\n| 3-Bedroom Apt | 150,000 – 350,000 FCFA |\n| Villa | 300,000 – 1,000,000+ FCFA |\n| Student Housing | 20,000 – 60,000 FCFA |\n\nUse the price filters on the search page to narrow down your budget!';
    }

    // --- Landlord listing properties ---
    if (_matches(q, ['add property', 'list property', 'post property', 'ajouter propriété', 'publier', 'listing', 'how to list'])) {
      return isFr
          ? '🏗️ **Comment Publier une Propriété**\n\n**Prérequis :**\n✅ Compte propriétaire créé\n✅ Vérification KYC approuvée par l\'admin\n\n**Étapes :**\n1. Connectez-vous à votre tableau de bord propriétaire\n2. Appuyez sur l\'icône **"+"** dans l\'onglet Propriétés\n3. Remplissez les détails : titre, description, prix, localisation\n4. Ajoutez des photos de haute qualité\n5. Définissez les commodités disponibles\n6. Publiez et attendez les candidatures !\n\n💡 **Conseil :** Les propriétés avec plus de 5 photos reçoivent 3× plus de candidatures !'
          : '🏗️ **How to List a Property**\n\n**Requirements:**\n✅ Landlord account created\n✅ KYC verification approved by admin\n\n**Steps:**\n1. Log in to your landlord dashboard\n2. Tap the **"+"** icon on the Properties tab\n3. Fill in details: title, description, price, location\n4. Add high-quality photos\n5. Set available amenities\n6. Publish and wait for applications!\n\n💡 **Tip:** Properties with 5+ photos get 3× more applications!';
    }

    // --- Admin ---
    if (_matches(q, ['admin', 'administrator', 'administrateur', 'approve', 'approuver'])) {
      return isFr
          ? '🛡️ **Rôle Administrateur**\n\nLes administrateurs de SpaceRentals gèrent la plateforme et peuvent :\n\n• ✅ Approuver / rejeter les demandes KYC des propriétaires\n• 👥 Gérer tous les utilisateurs (locataires et propriétaires)\n• 📊 Surveiller les transactions de la plateforme\n• ➕ Ajouter d\'autres administrateurs\n• 🗑️ Supprimer les comptes de test\n\nSeuls les administrateurs autorisés peuvent se connecter via le portail admin. Si vous pensez qu\'une propriété est frauduleuse, signalez-la depuis la page détaillée de la propriété.'
          : '🛡️ **Administrator Role**\n\nSpaceRentals admins manage the platform and can:\n\n• ✅ Approve / reject landlord KYC requests\n• 👥 Manage all users (tenants & landlords)\n• 📊 Monitor platform transactions\n• ➕ Add other administrators\n• 🗑️ Remove test accounts\n\nOnly authorized admins can log in via the admin portal. If you believe a property is fraudulent, report it from the property\'s detail page.';
    }

    // --- Favorites ---
    if (_matches(q, ['favorite', 'save', 'wishlist', 'favoris', 'sauvegarder', 'liked', 'bookmark'])) {
      return isFr
          ? '❤️ **Favoris**\n\nVous pouvez sauvegarder vos propriétés préférées en appuyant sur l\'icône **cœur** sur la page de détails de la propriété ou sur les cartes de propriété.\n\nAccédez à tous vos favoris dans l\'onglet **❤️ Favoris** de la barre de navigation inférieure.\n\nVos favoris sont sauvegardés localement sur votre appareil et ne seront pas perdus si vous fermez l\'application.'
          : '❤️ **Favorites**\n\nYou can save your favorite properties by tapping the **heart icon** on the property detail page or on property cards.\n\nAccess all your saved properties in the **❤️ Favorites** tab in the bottom navigation bar.\n\nYour favorites are saved locally on your device and won\'t be lost when you close the app.';
    }

    // --- Password ---
    if (_matches(q, ['password', 'mot de passe', 'forgot', 'oublié', 'reset', 'réinitialiser'])) {
      return isFr
          ? '🔐 **Mot de Passe**\n\n**Politique de sécurité :**\nVotre mot de passe doit contenir :\n• Au moins **8 caractères**\n• Une **lettre majuscule**\n• Un **chiffre**\n• Un **caractère spécial** (!@#\$&*~)\n\n**Mot de passe oublié ?**\nSur l\'écran de connexion, appuyez sur **"Mot de passe oublié?"** et suivez les instructions pour réinitialiser votre mot de passe via email.'
          : '🔐 **Password**\n\n**Security policy:**\nYour password must contain:\n• At least **8 characters**\n• One **uppercase letter**\n• One **number**\n• One **special character** (!@#\$&*~)\n\n**Forgot your password?**\nOn the login screen, tap **"Forgot password?"** and follow the instructions to reset your password via email.';
    }

    // --- Help / What can you do ---
    if (_matches(q, ['help', 'what can you do', 'aide', 'que peux-tu faire', 'capabilities', 'functions', 'features'])) {
      return isFr
          ? '🤖 **Ce que je peux faire**\n\nJe suis SpaceBot, votre assistant IA pour SpaceRentals. Posez-moi des questions sur :\n\n🏠 **Propriétés** — trouver, filtrer, catégories\n💳 **Paiements** — MTN MoMo, Orange, cartes bancaires\n📋 **KYC** — vérification propriétaire, documents requis\n📝 **Location** — comment postuler, conditions\n🏦 **RNLP** — financement de caution\n🔧 **Maintenance** — soumettre des demandes\n👤 **Comptes** — inscription, mot de passe, rôles\n🛡️ **Admin** — approbations, gestion\n❤️ **Favoris** — sauvegarder des propriétés\n\nTapez simplement votre question en français ou en anglais !'
          : '🤖 **What I can do**\n\nI\'m SpaceBot, your AI assistant for SpaceRentals. Ask me about:\n\n🏠 **Properties** — finding, filtering, categories\n💳 **Payments** — MTN MoMo, Orange, bank cards\n📋 **KYC** — landlord verification, required documents\n📝 **Renting** — how to apply, terms\n🏦 **RNLP** — deposit financing\n🔧 **Maintenance** — submitting requests\n👤 **Accounts** — registration, password, roles\n🛡️ **Admin** — approvals, management\n❤️ **Favorites** — saving properties\n\nJust type your question in English or French!';
    }

    // --- Default fallback ---
    return isFr
        ? '🤔 Je ne suis pas sûr de comprendre votre question. Essayez de demander :\n\n• "Comment trouver un appartement?"\n• "Comment payer mon loyer?"\n• "Quels documents KYC sont requis?"\n• "Comment ajouter une propriété?"\n• "Qu\'est-ce que le RNLP?"\n\nOu tapez **"aide"** pour voir toutes mes fonctionnalités !'
        : '🤔 I\'m not sure I understood your question. Try asking:\n\n• "How do I find an apartment?"\n• "How do I pay my rent?"\n• "What KYC documents are required?"\n• "How do I list a property?"\n• "What is RNLP?"\n\nOr type **"help"** to see all my capabilities!';
  }

  bool _matches(String input, List<String> keywords) {
    return keywords.any((k) => input.contains(k));
  }
}

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  final List<String> _quickPrompts = [
    'How to find a property?',
    'Payment options',
    'KYC for landlords',
    'What is RNLP?',
    'How to apply?',
    'Property prices',
  ];

  @override
  void initState() {
    super.initState();
    final isFr = ref.read(localeProvider).languageCode == 'fr';
    // Add welcome message
    _messages.add(ChatMessage(
      text: isFr
          ? '👋 Bonjour ! Je suis **SpaceBot**, votre assistant IA de SpaceRentals. Comment puis-je vous aider aujourd\'hui ?'
          : '👋 Hello! I\'m **SpaceBot**, your SpaceRentals AI assistant. How can I help you today?',
      isUser: false,
      time: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final isFr = ref.read(localeProvider).languageCode == 'fr';
    _inputController.clear();

    setState(() {
      _messages.add(ChatMessage(text: text.trim(), isUser: true, time: DateTime.now()));
      _isTyping = true;
    });
    _scrollToBottom();

    // Simulate AI thinking delay
    await Future.delayed(const Duration(milliseconds: 900));

    final ai = _SpaceRentalsAI(isFr: isFr);
    final response = ai.respond(text);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(text: response, isUser: false, time: DateTime.now()));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider);
    final isFr = ref.watch(localeProvider).languageCode == 'fr';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SpaceBot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isFr ? 'En ligne · Assistant IA' : 'Online · AI Assistant',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  // Typing indicator
                  return _TypingBubble();
                }
                final msg = _messages[index];
                return _MessageBubble(message: msg, theme: theme, userName: user.session?.fullName ?? 'You');
              },
            ),
          ),

          // Quick prompt chips
          if (_messages.length <= 2)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFr ? 'Suggestions rapides :' : 'Quick suggestions:',
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickPrompts.map((prompt) {
                      return GestureDetector(
                        onTap: () => _sendMessage(prompt),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            prompt,
                            style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Input bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _inputController,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      decoration: InputDecoration(
                        hintText: isFr ? 'Posez votre question...' : 'Ask a question...',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _sendMessage(_inputController.text),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final ThemeData theme;
  final String userName;

  const _MessageBubble({required this.message, required this.theme, required this.userName});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: isUser ? 60 : 0,
        right: isUser ? 0 : 60,
      ),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                  ),
                  const SizedBox(width: 6),
                  const Text('SpaceBot', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isUser
                  ? LinearGradient(colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)])
                  : null,
              color: isUser ? null : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
              border: isUser ? null : Border.all(color: Colors.grey.shade100),
            ),
            child: _ParsedText(text: message.text, isUser: isUser),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
            child: Text(
              '${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParsedText extends StatelessWidget {
  final String text;
  final bool isUser;

  const _ParsedText({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final baseColor = isUser ? Colors.white : Colors.black87;
    // Render text with simple bold parsing for **text**
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start), style: TextStyle(color: baseColor, fontSize: 14, height: 1.5)));
      }
      spans.add(TextSpan(text: match.group(1), style: TextStyle(color: baseColor, fontWeight: FontWeight.bold, fontSize: 14, height: 1.5)));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: TextStyle(color: baseColor, fontSize: 14, height: 1.5)));
    }
    return RichText(text: TextSpan(children: spans));
  }
}

class _TypingBubble extends StatefulWidget {
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4, right: 60),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        ),
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: (i == 0 ? _anim.value : i == 1 ? (_anim.value + 0.2).clamp(0, 1) : (_anim.value + 0.4).clamp(0, 1))),
                shape: BoxShape.circle,
              ),
            )),
          ),
        ),
      ),
    );
  }
}
