// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final MessageLookup messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'fr';

  static dynamic m0(dynamic name) => "${name} activé avec succès!";

  static dynamic m9(dynamic seconde) =>
      "Ordre en cours, veuillez patienter ${seconde} secondes!";

  static dynamic m1(dynamic index) => "Entrez le ${index} . mot";

  static dynamic m2(dynamic index) =>
      "Quel est le ${index} . mot dans votre passphrase?";

  static dynamic m10(dynamic coinName, dynamic number) =>
      "Le montant minimum à vendre est ${number} ${coinName}";

  static dynamic m11(dynamic coinName, dynamic number) =>
      "Le montant minimum à acheter est ${number} ${coinName}";

  static dynamic m3(dynamic coinName) =>
      "Aucun ordre ${coinName} disponible - réessayez ultérieurement ou créez un ordre.";

  static dynamic m4(dynamic assets) => "${assets} Actifs";

  static dynamic m5(dynamic amount) => "Cliquez pour voir ${amount} orders";

  static dynamic m6(dynamic coinName, dynamic address) =>
      "Mon adresse ${coinName} : ${address}";

  static dynamic m7(dynamic amount, dynamic coinName) =>
      "ENVOYER ${amount} ${coinName}";

  static dynamic m8(dynamic amount, dynamic coin) =>
      "Vous recevrez ${amount} ${coin}";

  final Map<String, dynamic> messages =
      _notInlinedMessages(_notInlinedMessages);
  static dynamic _notInlinedMessages(dynamic _) => <String, Function>{
        "accepteula": MessageLookupByLibrary.simpleMessage("Accepter le EULA"),
        "accepttac": MessageLookupByLibrary.simpleMessage(
            "Accepter les termes et conditions"),
        "activateAccessBiometric": MessageLookupByLibrary.simpleMessage(
            "Activer la protection biométrique"),
        "activateAccessPin": MessageLookupByLibrary.simpleMessage(
            "Activer la protection par code PIN"),
        "addCoin":
            MessageLookupByLibrary.simpleMessage("Activer la crypto-monnaie"),
        "addingCoinSuccess": m0,
        "addressSend":
            MessageLookupByLibrary.simpleMessage("Adresse du destinataire"),
        "allowCustomSeed": MessageLookupByLibrary.simpleMessage(
            "Autoriser les passphrases personnalisées"),
        "amount": MessageLookupByLibrary.simpleMessage("Montant"),
        "amountToSell":
            MessageLookupByLibrary.simpleMessage("Montant à vendre"),
        "appName": MessageLookupByLibrary.simpleMessage("atomicDEX"),
        "areYouSure": MessageLookupByLibrary.simpleMessage("ÊTES-VOUS SÛR?"),
        "articleFrom":
            MessageLookupByLibrary.simpleMessage("AtomicDEX NOUVELLES"),
        "availableVolume": MessageLookupByLibrary.simpleMessage("vol max"),
        "back": MessageLookupByLibrary.simpleMessage("retour"),
        "backupTitle": MessageLookupByLibrary.simpleMessage("Sauvegarde"),
        "bestAvailableRate":
            MessageLookupByLibrary.simpleMessage("Meilleur tarif disponible"),
        "buy": MessageLookupByLibrary.simpleMessage("Acheter"),
        "buySuccessWaiting": MessageLookupByLibrary.simpleMessage(
            "Échange émis, veuillez patienter!"),
        "buySuccessWaitingError": m9,
        "cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "changePin":
            MessageLookupByLibrary.simpleMessage("Changer le code PIN"),
        "checkOut": MessageLookupByLibrary.simpleMessage("Check-out"),
        "checkSeedPhrase":
            MessageLookupByLibrary.simpleMessage("Vérifier la passphrase"),
        "checkSeedPhraseButton1":
            MessageLookupByLibrary.simpleMessage("CONTINUER"),
        "checkSeedPhraseButton2": MessageLookupByLibrary.simpleMessage(
            "RETOURNEZ ET VÉRIFIEZ À NOUVEAU"),
        "checkSeedPhraseHint": m1,
        "checkSeedPhraseInfo": MessageLookupByLibrary.simpleMessage(
            "Votre pass-phrase est importante - c\'est pourquoi nous voulons nous assurer qu\'elle est correcte. Nous vous poserons trois questions différentes sur votre passphrase pour vous assurer que vous pourrez facilement restaurer votre portefeuille à tout moment."),
        "checkSeedPhraseSubtile": m2,
        "checkSeedPhraseTitle": MessageLookupByLibrary.simpleMessage(
            "VERIFIONS UNE NOUVELLE FOIS VOTRE PASSPHRASE"),
        "claim": MessageLookupByLibrary.simpleMessage("réclamer"),
        "claimTitle": MessageLookupByLibrary.simpleMessage(
            "Réclamer votre récompense KMD?"),
        "clickToSee":
            MessageLookupByLibrary.simpleMessage("Cliquez pour voir "),
        "clipboard":
            MessageLookupByLibrary.simpleMessage("Copié dans le presse-papier"),
        "clipboardCopy": MessageLookupByLibrary.simpleMessage(
            "Copier dans le presse-papier"),
        "close": MessageLookupByLibrary.simpleMessage("Fermer"),
        "code": MessageLookupByLibrary.simpleMessage("Code: "),
        "comingSoon": MessageLookupByLibrary.simpleMessage("Arrive bientôt..."),
        "commingsoon":
            MessageLookupByLibrary.simpleMessage("Détails TX à venir bientôt!"),
        "commingsoonGeneral":
            MessageLookupByLibrary.simpleMessage("Détails à venir bientôt!"),
        "commissionFee":
            MessageLookupByLibrary.simpleMessage("frais de commission"),
        "confirm": MessageLookupByLibrary.simpleMessage("confirmer"),
        "confirmPassword":
            MessageLookupByLibrary.simpleMessage("Confirmez le mot de passe"),
        "confirmPin":
            MessageLookupByLibrary.simpleMessage("Confirmer le code PIN"),
        "confirmSeed":
            MessageLookupByLibrary.simpleMessage("Confirmer la passphrase"),
        "confirmeula": MessageLookupByLibrary.simpleMessage(
            "En cliquant sur les boutons ci-dessous, vous confirmez avoir pris connaissance du \'EULA\' et des \'Conditions générales\' et les accepter."),
        "connecting": MessageLookupByLibrary.simpleMessage("Connection..."),
        "create": MessageLookupByLibrary.simpleMessage("Échange"),
        "createAWallet":
            MessageLookupByLibrary.simpleMessage("CRÉER UN PORTEFEUILLE"),
        "createPin": MessageLookupByLibrary.simpleMessage("Créer un code PIN"),
        "decryptingWallet": MessageLookupByLibrary.simpleMessage(
            "Décryptage du portefeuille..."),
        "delete": MessageLookupByLibrary.simpleMessage("Effacer"),
        "deleteWallet":
            MessageLookupByLibrary.simpleMessage("Supprimer le portefeuille"),
        "dex": MessageLookupByLibrary.simpleMessage("DEX"),
        "disclaimerAndTos": MessageLookupByLibrary.simpleMessage(
            "Avertissement et Conditions d\'utilisation"),
        "done": MessageLookupByLibrary.simpleMessage("Terminé"),
        "dontWantPassword": MessageLookupByLibrary.simpleMessage(
            "Je ne veux pas de mot de passe"),
        "encryptingWallet": MessageLookupByLibrary.simpleMessage(
            "Chiffrement du portefeuille..."),
        "enterPinCode":
            MessageLookupByLibrary.simpleMessage("Entrez votre code PIN"),
        "enterSeedPhrase":
            MessageLookupByLibrary.simpleMessage("Entrez votre passphrase"),
        "enterpassword": MessageLookupByLibrary.simpleMessage(
            "Veuillez entrer votre mot de passe pour continuer."),
        "errorAmountBalance":
            MessageLookupByLibrary.simpleMessage("Solde insuffisant"),
        "errorNotAValidAddress":
            MessageLookupByLibrary.simpleMessage("Adresse non valide"),
        "errorTryAgain":
            MessageLookupByLibrary.simpleMessage("Erreur, veuillez réessayer"),
        "errorTryLater": MessageLookupByLibrary.simpleMessage(
            "Erreur, merci d\'essayer plus tard"),
        "errorValueEmpty": MessageLookupByLibrary.simpleMessage(
            "La valeur est trop élevée ou trop basse"),
        "errorValueNotEmpty": MessageLookupByLibrary.simpleMessage(
            "S\'il vous plaît entrer des données"),
        "estimateValue":
            MessageLookupByLibrary.simpleMessage("Valeur totale estimée"),
        "ethFee": MessageLookupByLibrary.simpleMessage("Taxe ETH"),
        "ethNotActive": MessageLookupByLibrary.simpleMessage(
            "S\'il vous plaît activer ETH."),
        "eulaParagraphe1": MessageLookupByLibrary.simpleMessage(
            "Le présent contrat de licence d\'utilisateur final (\'EULA\') est un contrat légal entre vous et Komodo Platform. Cet accord de EULA régit votre acquisition et votre utilisation de notre logiciel mobile atomicDEX («Logiciel», «Application mobile», «Application» ou «Application») directement de Komodo Platform ou indirectement via une entité autorisée, revendeur ou distributeur Komodo Platform Distributeur\'). Veuillez lire attentivement cet accord de EULA avant de terminer le processus d\'installation et d\'utiliser le logiciel atomicDEX mobile. Il fournit une licence d\'utilisation du logiciel atomicDEX mobile et contient des informations sur la garantie et des exclusions de responsabilité. Si vous vous inscrivez au programme bêta du logiciel atomicDEX mobile, cet accord de EULA régira également cet essai. En cliquant sur \'accepter\' ou en installant et / ou en utilisant le logiciel atomicDEX mobile, vous confirmez votre acceptation du logiciel et acceptez d\'être lié par les termes du présent contrat de EULA. Si vous concluez ce contrat de licence utilisateur final au nom d\'une société ou d\'une autre entité juridique, vous déclarez que vous avez le pouvoir de lier cette entité et ses sociétés affiliées aux présentes conditions générales. Si vous ne disposez pas de cette autorité ou si vous n\'êtes pas d\'accord avec les termes et conditions de ce contrat de EULA, n\'installez ni n\'utilisez le logiciel, et vous ne devez pas accepter ce contrat de EULA. Le présent contrat de EULA ne s\'applique qu\'au logiciel fourni par Komodo Platform, que d\'autres logiciels soient mentionnés ou décrits dans les présentes. Les conditions s\'appliquent également aux mises à jour, aux suppléments, aux services Internet et aux services d\'assistance du logiciel Komodo Platform, à moins que d\'autres conditions ne les accompagnent à la livraison. Dans l\'affirmative, ces termes s\'appliquent. License Grant Komodo Platform vous accorde par la présente une licence personnelle, non transférable et non exclusive vous permettant d\'utiliser le logiciel atomicDEX mobile sur vos appareils conformément aux termes de cet accord de EULA. Vous êtes autorisé à charger le logiciel atomicDEX mobile (par exemple, un PC, un ordinateur portable, un téléphone portable ou une tablette) sous votre contrôle. Vous devez vous assurer que votre appareil répond aux exigences minimales en matière de sécurité et de ressources du logiciel atomicDEX mobile. Vous n\'êtes pas autorisé à: Editer, altérer, modifier, adapter, traduire ou modifier de quelque manière que ce soit tout ou partie du Logiciel, ni permettre que tout ou partie du Logiciel soit combiné ou intégré à un autre logiciel, ni décompilé , désassembler ou désosser le logiciel ou tenter de faire de telles choses. Reproduire, copier, distribuer, revendre ou utiliser le logiciel à des fins commerciales. Utiliser le logiciel de manière à enfreindre les lois locales, nationales ou internationales applicables. Utiliser le logiciel à des fins commerciales. Komodo Platform conserve à tout moment la propriété du logiciel tel que téléchargé à l\'origine et de tous les téléchargements ultérieurs du logiciel que vous avez effectués. Le logiciel (ainsi que les droits d\'auteur et autres droits de propriété intellectuelle de quelque nature que ce soit, y compris les modifications qui y sont apportées) sont et resteront la propriété de Komodo Platform. Komodo Platform se réserve le droit d\'octroyer des licences d\'utilisation du logiciel à des tiers. Résiliation Le présent contrat de EULA entre en vigueur à compter de la date à laquelle vous utilisez le logiciel pour la première fois et reste en vigueur jusqu\'à sa résiliation. Vous pouvez le résilier à tout moment en envoyant un avis écrit à Komodo Platform. Il sera également mis fin immédiatement si vous ne respectez aucune des conditions de cet accord de EULA. En cas de résiliation, les licences accordées par le présent contrat de EULA seront immédiatement résiliées et vous acceptez d\'arrêter tout accès et utilisation du logiciel. Les dispositions qui, de par leur nature, persistent et survivent survivront à toute résiliation de cet accord de EULA. Loi applicable Le présent contrat de EULA et tout litige né de ou en relation avec le présent contrat de EULA sont régis et interprétés conformément à la législation du Vietnam. Ce document a été mis à jour le 3 juillet 2019\n\n"),
        "eulaParagraphe10": MessageLookupByLibrary.simpleMessage(
            "Komodo Platform est le propriétaire et / ou l\'utilisateur autorisé de toutes les marques, marques de service, marques de design, brevets, droits d\'auteur, droits de la base de données et toute autre propriété intellectuelle apparaissant sur ou contenus dans l\'application, sauf indication contraire. Toutes les informations, textes, matériels, graphiques, logiciels et publicités figurant sur l\'interface de l\'application sont la propriété de Komodo Platform, de ses fournisseurs et de ses concédants de licence, sauf indication contraire expresse de Komodo Platform. Sauf dans les cas prévus dans les Conditions, l\'utilisation de l\'application ne vous octroie aucun droit, titre, intérêt ou licence sur une telle propriété intellectuelle. Vous pouvez y avoir accès sur l\'application. Nous possédons les droits ou avons la permission d\'utiliser les marques de commerce énumérées dans notre application. Vous n\'êtes pas autorisé à utiliser ces marques de commerce sans notre autorisation écrite - cela constituerait une violation des droits de propriété intellectuelle de notre société ou d\'une autre partie. Alternativement, nous pouvons vous autoriser à utiliser le contenu de notre application si vous nous avez déjà contacté et que nous acceptons par écrit.\n\n"),
        "eulaParagraphe11": MessageLookupByLibrary.simpleMessage(
            "Komodo Platform ne peut garantir la sécurité de vos systèmes informatiques. Nous déclinons toute responsabilité en cas de perte ou d\'altération des données stockées électroniquement ou de tout dommage causé à un système informatique en relation avec l\'utilisation de l\'application ou du contenu de l\'utilisateur. Komodo Platform ne fait aucune déclaration et ne donne aucune garantie d\'aucune sorte, expresse ou implicite, quant au fonctionnement de l\'application ou du contenu de l\'utilisateur. Vous acceptez expressément que votre utilisation de l\'application est entièrement à vos risques et périls. Vous acceptez que le contenu fourni dans l\'application et le contenu de l\'utilisateur ne constituent pas un conseil financier, juridique ou fiscal, et vous vous engagez à ne pas représenter le contenu de l\'utilisateur ou l\'application en tant que tels. Dans la mesure permise par la législation en vigueur, la demande est fournie «telle quelle, selon la disponibilité». Komodo Platform décline expressément toute responsabilité pour toute perte, blessure, réclamation, responsabilité ou dommage, ou pour tout dommage indirect, accessoire, spécial ou consécutif ou perte de profit de quelque nature que ce soit résultant, ou résultant de, de quelque manière que ce soit, de: (a) toute erreur ou omission dans l\'application et / ou dans le contenu de l\'utilisateur, y compris mais sans s\'y limiter, des inexactitudes techniques et des erreurs typographiques; (b) tout site Web, application ou contenu tiers, auquel on accède directement ou indirectement par des liens dans l\'application, y compris, sans limitation, toute erreur ou omission; c) l\'indisponibilité totale ou partielle de l\'application; (d) votre utilisation de l\'application; (e) votre utilisation de tout équipement ou logiciel en rapport avec l\'application. Tous les services offerts dans le cadre de la plate-forme sont fournis «tels quels», sans aucune représentation ni garantie, expresse, implicite ou légale. Dans les limites maximales permises par la loi applicable, nous déclinons expressément toute garantie implicite de titre, de qualité marchande, d\'adéquation à un usage particulier et / ou de non-violation. Nous ne faisons aucune déclaration ou garantie que l\'utilisation de la plate-forme sera continue, ininterrompue, rapide et sans erreur. Nous ne garantissons pas que toute plate-forme sera exempte de virus, de logiciels malveillants ou de tout autre matériel nuisible et que votre capacité à accéder à toute plate-forme sera ininterrompue. Tout défaut ou dysfonctionnement du produit doit être adressé à la tierce partie proposant la Plateforme, et non à Komodo. Nous ne serons pas responsables envers vous de toute perte de quelque nature que ce soit, à la suite de mesures prises ou fondées sur le matériel ou les informations contenus dans ou via la Plateforme. C\'est un logiciel expérimental et inachevé. À utiliser à vos risques et périls. Aucune garantie pour tout type de dommage. En utilisant cette application, vous acceptez ces termes et conditions.\n\n"),
        "eulaParagraphe12": MessageLookupByLibrary.simpleMessage(
            "Lorsque vous accédez aux services ou les utilisez, vous reconnaissez que vous êtes seul responsable de votre conduite lorsque vous accédez à et utilisez nos services. Sans limiter la portée générale de ce qui précède, vous acceptez de ne pas: (a) utiliser les services de manière à interférer avec, perturber, nuire ou empêcher les autres utilisateurs de profiter pleinement des services, ou à risquer d\'endommager, désactiver, surcharger ou nuire au fonctionnement de nos services de quelque manière que ce soit; (b) utiliser les services pour payer, soutenir ou se livrer de toute autre manière à des activités illégales, y compris, sans toutefois s\'y limiter, les jeux d\'argent illégaux, la fraude, le blanchiment d\'argent ou les activités terroristes; (c) utiliser un robot, une araignée, un robot d\'exploration, un grattoir ou tout autre moyen automatisé ou interface que nous ne fournissons pas pour accéder à nos services ou pour extraire des données; (d) utiliser ou tenter d\'utiliser le portefeuille ou les identifiants d\'un autre utilisateur sans autorisation; (e) Essayez de contourner les techniques de filtrage de contenu que nous employons ou tentez d\'accéder à tout service ou domaine de nos services auquel vous n\'êtes pas autorisé à accéder; (f) Introduisez dans les Services tout virus, cheval de Troie, vers, bombes logiques ou autre matériel nuisible; (g) développer des applications tierces qui interagissent avec nos services sans notre consentement écrit préalable; (h) Fournir des informations fausses, inexactes ou trompeuses; (i) Encourager ou inciter toute autre personne à se livrer à l\'une des activités interdites par la présente section.\n\n\n"),
        "eulaParagraphe13": MessageLookupByLibrary.simpleMessage(
            "Vous acceptez et comprenez qu\'il existe des risques liés à l\'utilisation de services impliquant des devises virtuelles, notamment, le risque de défaillance du matériel, des logiciels et des connexions Internet, le risque d\'introduction de logiciels malveillants et le risque que des tiers obtiennent des informations non autorisées. accès aux informations stockées dans votre portefeuille, y compris, sans toutefois s\'y limiter, vos clés publique et privée. Vous acceptez et comprenez que Komodo Platform ne sera pas responsable des défaillances de communication, des perturbations, des erreurs, des distorsions ou des retards que vous pourriez rencontrer lors de l\'utilisation des Services, quelle qu\'en soit la cause. Vous acceptez et reconnaissez qu\'il existe des risques associés à l\'utilisation de tout réseau monétaire virtuel, y compris, sans toutefois s\'y limiter, le risque de vulnérabilités inconnues ou de modifications imprévues du protocole réseau. Vous reconnaissez et acceptez que Komodo Platform n\'exerce aucun contrôle sur les réseaux de crypto-monnaie et ne saurait être tenu responsable des dommages résultant de tels risques, notamment de l\'impossibilité d\'annuler une transaction et des pertes associées. en raison d\'actions erronées ou frauduleuses. Le risque de perte lié à l\'utilisation de services impliquant des devises virtuelles peut être considérable et des pertes peuvent se produire sur une courte période. De plus, le prix et la liquidité sont soumis à des fluctuations importantes qui peuvent être imprévisibles. Les monnaies virtuelles n\'ont pas de cours légal et ne sont soutenues par aucun gouvernement souverain. En outre, le paysage législatif et réglementaire autour des monnaies virtuelles change constamment et peut affecter votre capacité à utiliser, transférer ou échanger des monnaies virtuelles. Les CFD sont des instruments complexes et présentent un risque élevé de perdre de l\'argent rapidement en raison d\'un effet de levier. 80,6% des comptes d’investisseurs privés perdent de l’argent lorsqu’ils échangent des CFD avec ce fournisseur. Vous devez vous demander si vous comprenez le fonctionnement des CFD et si vous pouvez vous permettre de prendre le risque élevé de perdre votre argent.\n\n"),
        "eulaParagraphe14": MessageLookupByLibrary.simpleMessage(
            "Vous acceptez d\'indemniser, de défendre et de tenir indemne Komodo Platform, ses dirigeants, administrateurs, employés, agents, concédants de licence, fournisseurs et tout fournisseur d\'informations tiers à l\'application de et contre toutes pertes, dépenses, dommages et frais, y compris les honoraires raisonnables d\'avocat, résultant d\'une violation des Conditions de votre part. Vous acceptez également d’indemniser Komodo Platform contre toute prétention selon laquelle les informations ou le matériel que vous avez soumis à Komodo Platform contreviennent à la loi ou aux droits de tiers (y compris, mais sans s\'y limiter, les actions en diffamation, invasion respect de la vie privée, abus de confiance, violation du droit d\'auteur ou violation de tout autre droit de propriété intellectuelle).\n\n"),
        "eulaParagraphe15": MessageLookupByLibrary.simpleMessage(
            "Afin d\'être complétée, toute transaction de devise virtuelle créée avec la plate-forme Komodo doit être confirmée et enregistrée dans le livre de devise virtuelle associé au réseau de devise virtuelle correspondant. Ces réseaux sont décentralisés, réseaux peer-to-peer, soutenus par des tiers indépendants, qui ne sont ni détenus, ni contrôlés, ni exploités par Komodo Platform. Komodo Platform n\'a aucun contrôle sur aucun réseau Virtual Currency et ne peut donc garantir et ne garantit pas que les détails de transaction que vous soumettez via nos Services seront confirmés sur le réseau Virtual Currency correspondant. Vous acceptez et comprenez que les détails de la transaction que vous soumettez via nos Services pourraient ne pas être complétés ou pourraient être considérablement retardés par le réseau Virtual Currency utilisé pour traiter la transaction. Nous ne garantissons pas que le portefeuille puisse transférer le titre ou les droits sur une devise virtuelle ou offrir quelque garantie que ce soit en ce qui concerne le titre. Une fois que les détails de la transaction ont été soumis à un réseau de devise virtuelle, nous ne pouvons pas vous aider à annuler ou à modifier autrement votre transaction ou ses détails. Komodo Platform n’a aucun contrôle sur les réseaux Virtual Currency et n’a pas la capacité de faciliter les demandes d’annulation ou de modification. Dans le cas d\'une fourchette, Komodo Platform pourrait ne pas être en mesure de prendre en charge les activités liées à votre devise virtuelle. Vous acceptez et comprenez que, dans le cas d\'une fourchette, les transactions pourraient ne pas être complétées, complétées partiellement, mal complétées ou considérablement retardées. Komodo Platform n\'est pas responsable des pertes que Vous avez causées, en tout ou en partie, directement ou indirectement, par une Fourche. En aucun cas, Komodo Platform, ses sociétés affiliées et ses prestataires de services, ou l’un de leurs dirigeants, administrateurs, agents, employés ou représentants respectifs, ne peuvent être tenus pour responsables de tout manque à gagner ou de tout dommage spécial, accessoire, indirect, immatériel ou consécutif, sur un contrat, un délit, une négligence, une responsabilité stricte ou autre, découlant de ou liée à une utilisation autorisée ou non des services, ou du présent contrat, même si un représentant autorisé de Komodo Platform a été informé de, ou aurait dû connaître la possibilité de tels dommages. Par exemple (et sans limiter la portée de la phrase précédente), vous ne pouvez pas récupérer vos pertes de profits, vos opportunités commerciales ou tout autre type de dommages spéciaux, accessoires, indirects, immatériels ou consécutifs. Certaines juridictions n\'autorisant pas l\'exclusion ou la limitation des dommages accessoires ou indirects, il est possible que la limitation ci-dessus ne vous concerne pas. Nous ne pourrons être tenus responsables de toute perte ni assumer aucune responsabilité pour des dommages ou des réclamations découlant en tout ou en partie, directement ou indirectement: (a) d\'une erreur de l\'utilisateur, telle que des mots de passe oubliés, des transactions mal construites ou une devise virtuelle erronée les adresses; (b) défaillance du serveur ou perte de données; (c) des portefeuilles ou des fichiers de portefeuille corrompus ou non performants; (d) accès non autorisé aux applications; (e) toute activité non autorisée, y compris, sans limitation, l\'utilisation de piratage, de virus, de phishing, de forçage brutal ou d\'autres moyens d\'attaque contre les Services.\n\n"),
        "eulaParagraphe16": MessageLookupByLibrary.simpleMessage(
            "Afin d\'éviter toute confusion, Komodo Platform ne fournit aucun conseil en investissement, fiscal ou juridique, et Komodo Platform ne négocie pas pour vous. Toutes les transactions de Komodo Platform sont exécutées automatiquement, en fonction des paramètres de vos instructions de commande et conformément aux procédures d\'exécution des transactions enregistrées. Vous êtes seul responsable de la détermination de la pertinence d\'un investissement, d\'une stratégie d\'investissement ou d\'une transaction connexe en fonction de votre investissement personnel objectifs, la situation financière et la tolérance au risque. Vous devez consulter votre conseiller juridique ou fiscal en fonction de votre situation spécifique. Ni Komodo, ni ses propriétaires, membres, dirigeants, administrateurs, associés, consultants, ni toute personne impliquée dans la publication de la présente demande, ne sont des conseillers en investissement, des courtiers ou des personne avec un conseiller en investissement inscrit ou un courtier-négociant et aucune de ce qui précède ne recommande que l\'achat ou la vente d\'actifs cryptographiques ou de titres d\'une société présentée dans l\'Application mobile soit approprié ou conseillé pour toute personne ou qu\'un investissement ou une transaction dans ces crypto-actifs ou valeurs sera rentable. Les informations contenues dans l\'application mobile ne constituent pas, et ne constitueront pas, une offre de vente ou la sollicitation d\'une offre d\'achat de tout crypto-actif ou de toute valeur. Les informations présentées dans l\'application mobile sont fournies à des fins d\'information uniquement et ne doivent pas être traitées comme des conseils ou des recommandations en vue d\'un investissement ou d\'une transaction spécifique. Veuillez consulter un professionnel qualifié avant de prendre toute décision. Les opinions et l\'analyse incluses dans cette candidature sont basées sur des informations provenant de sources considérées comme fiables et sont fournies «en l\'état» de bonne foi. Komodo ne fait aucune déclaration et ne donne aucune garantie, explicite, implicite ou légale, quant à l\'exactitude ou à l\'exhaustivité de ces informations, qui peuvent être modifiées sans préavis. Komodo ne peut être tenu responsable des erreurs ni des actions entreprises en relation avec ce qui précède. Les déclarations d\'opinion et de conviction sont celles des auteurs et / ou des éditeurs qui contribuent à cette application, et sont basées uniquement sur les informations que possèdent ces auteurs et / ou éditeurs. Il ne faut en aucun cas en déduire que Komodo ou ses auteurs ou éditeurs ont une connaissance particulière ou une connaissance plus approfondie des actifs cryptographiques ou des sociétés décrites, ni une expertise particulière dans les secteurs ou marchés dans lesquels les actifs cryptographiques et les sociétés opèrent et se font concurrence. cette application provient de sources réputées fiables; Toutefois, Komodo n\'assume aucune responsabilité quant à la vérification de l\'exactitude de ces informations et ne déclare aucunement que ces informations sont exactes ou complètes. Certaines déclarations incluses dans cette application peuvent être des déclarations prospectives basées sur les attentes actuelles. Komodo ne fait aucune déclaration et n\'assure aucune garantie quant à l\'exactitude de ces déclarations prospectives.Les personnes utilisant l\'application Komodo sont priées de consulter un professionnel qualifié en ce qui concerne un investissement ou une transaction dans un crypto-actif ou une entreprise profilée. ci-dessous. De plus, les personnes utilisant cette application déclarent expressément que le contenu de cette application n\'est pas et ne sera pas pris en compte dans les décisions d\'investissement ou de transaction de ces personnes. Les commerçants doivent vérifier de manière indépendante les informations fournies dans l’application Komodo en complétant leur propre devoir de vigilance à l’égard de tout crypto-actif ou entreprise dans laquelle ils envisagent un investissement ou une transaction de quelque nature que ce soit et examiner un ensemble complet d’informations sur cet crypto-actif ou entreprise, qui devrait inclure, sans toutefois s\'y limiter, les mises à jour de blogs et les communiqués de presse associés. Les performances passées des actifs et des titres cryptographiques profilés ne préjugent pas des résultats futurs. Les actifs cryptographiques et les entreprises figurant sur ce site peuvent ne pas disposer d\'un marché de négociation actif et investir dans un actif cryptographique ou un titre qui ne dispose pas d\'un marché de négociation actif ou des échanges sur certains supports, plates-formes et marchés sont considérés comme hautement spéculatifs et comportent un degré de risque élevé . Toute personne détenant de tels actifs cryptographiques et de tels titres devrait être financièrement capable et disposée à supporter le risque de perte et de la perte réelle de l’ensemble de sa transaction. Les informations contenues dans cette application ne sont pas conçues pour servir de base à une décision d\'investissement. Les personnes utilisant l\'application Komodo doivent confirmer, à leur entière satisfaction, la véracité de toute information avant de procéder à un investissement ou d\'effectuer une transaction. La décision d\'acheter ou de vendre tout crypto-actif ou toute sécurité susceptible d\'être présentée par Komodo est prise aux risques propres du lecteur. En tant que lecteur et utilisateur de cette application, vous acceptez qu\'en aucun cas, vous ne cherchiez à engager la responsabilité du propriétaire, des membres, des dirigeants, des administrateurs, des associés, des consultants ou des autres personnes impliquées dans la publication de cette application, pour tout dommage résultant de l\'utilisation informations contenues dans la présente demandeKomodo, ses contractants et ses sociétés affiliées, peuvent tirer profit de l’augmentation ou de la diminution de la valeur des actifs cryptographiques et des valeurs mobilières. De tels crypto-actifs et titres peuvent être achetés ou vendus de temps à autre, même après que Komodo ait diffusé des informations positives sur les crypto-actifs et les sociétés. Komodo n’a aucune obligation d’informer les lecteurs de ses activités commerciales ou des activités commerciales de ses propriétaires, membres, dirigeants, administrateurs, sous-traitants et sociétés affiliées et / ou de toute société affiliée aux propriétaires, membres, dirigeants, administrateurs, sous-traitants et relations de BC Relations. affiliés.Komodo et ses affiliés peuvent de temps à autre conclure des accords d\'achat d\'actifs cryptographiques ou de valeurs mobilières afin de constituer une méthode permettant d\'atteindre leurs objectifs.\n\n"),
        "eulaParagraphe17": MessageLookupByLibrary.simpleMessage(
            "Les Conditions sont en vigueur jusqu\'à leur résiliation par Komodo Platform. En cas de résiliation, vous n\'êtes plus autorisé à accéder à l\'Application, mais toutes les restrictions qui vous sont imposées ainsi que les renonciations et limitations de responsabilité énoncées dans les Conditions resteront en vigueur après la résiliation. Cette résiliation ne porte pas atteinte aux droits légaux que Komodo Platform pourrait avoir acquis contre Vous jusqu’à la date de la résiliation. Komodo Platform peut également supprimer l’application dans son ensemble, ainsi que toute section ou fonctionnalité de l’application, à tout moment. \n\n"),
        "eulaParagraphe18": MessageLookupByLibrary.simpleMessage(
            "Les dispositions des paragraphes précédents sont à l\'avantage de Komodo Platform et de ses dirigeants, administrateurs, employés, agents, concédants de licence, fournisseurs et de tout fournisseur d\'informations tiers à l\'Application. Chacune de ces personnes ou entités a le droit de revendiquer et de faire appliquer ces dispositions directement contre vous en son propre nom.\n\n"),
        "eulaParagraphe19": MessageLookupByLibrary.simpleMessage(
            "Nous pourrions être tenus de conserver et d’utiliser des données à caractère personnel pour répondre à nos obligations d’audit interne et externe, à des fins de sécurité des données et selon ce que nous estimons nécessaire ou approprié: (a) de nous conformer à nos obligations en vertu de la législation et de la réglementation applicables, notamment: lois et règlements en dehors de votre pays de résidence; (b) pour répondre aux demandes des tribunaux, des organismes chargés de l\'application de la loi, des organismes de réglementation et des autres autorités publiques et gouvernementales, qui peuvent inclure de telles autorités en dehors de votre pays de résidence; (c) surveiller le respect et appliquer les termes et conditions de notre plateforme; (d) effectuer des contrôles anti-blanchiment d\'argent, sanctionner ou «connaître votre client» conformément aux lois et réglementations en vigueur; (e) protéger nos droits, notre vie privée, notre sécurité, nos biens ou ceux d\'autres personnes. Nous pouvons également être tenus d\'utiliser et de conserver des données personnelles après la fermeture de votre compte pour des raisons légales, réglementaires et de conformité, telles que la prévention, la détection ou l\'investigation d\'un crime; la prévention des pertes; ou prévention de la fraude. Nous collectons et traitons également des données anonymes non personnelles et personnelles à des fins statistiques et d\'analyse, afin de nous aider à fournir un meilleur service. Ce document a été mis à jour le 3 juillet 2019\n\n"),
        "eulaParagraphe2": MessageLookupByLibrary.simpleMessage(
            "Cet avis de non-responsabilité s\'applique au contenu et aux services de l\'application AtomicDEX et est valable pour tous les utilisateurs de «l\'application» («logiciel», «application mobile», «application» ou «application»). L\'application appartient à Komodo Platform. Nous nous réservons le droit de modifier les conditions générales suivantes (régissant l\'utilisation de l\'application «atomicDEX mobile») à tout moment, sans préavis et à notre seule discrétion. Il est de votre responsabilité de vérifier périodiquement les présentes conditions d\'utilisation pour toute mise à jour de celles-ci, qui entrera en vigueur une fois publiée. Votre utilisation continue de l\'application sera considérée comme une acceptation des Conditions suivantes. Nous sommes une société constituée au Vietnam et les présentes conditions générales sont régies et soumises aux lois vietnamiennes. Si vous n\'acceptez pas ces conditions générales, vous ne devez pas utiliser ou accéder à ce logiciel.\n\n"),
        "eulaParagraphe3": MessageLookupByLibrary.simpleMessage(
            "En signant cet accord (chaque sujet accédant ou utilisant le site) Accord (en écriture) Vous déclarez que vous êtes un individu majeur (au moins 18 ans) et que vous avez la capacité de signer cet accord d’utilisateur et acceptez d\'être légalement lié par les termes et conditions du présent contrat d\'utilisation, tels qu\'ils sont incorporés ici et modifiés de temps à autre. Afin de pouvoir utiliser les services fournis par Komodo Platform, vous devrez peut-être fournir certains détails d\'identification conformément à notre programme de conformité «Connaissez votre client» et «Anti-blanchiment d\'argent».\n\n"),
        "eulaParagraphe4": MessageLookupByLibrary.simpleMessage(
            "Nous pouvons modifier les termes de cet accord d\'utilisateur à tout moment. De telles modifications prendront effet lors de la publication dans l\'application ou lors de l\'utilisation des services. Lisez attentivement le contrat d\'utilisation chaque fois que vous utilisez nos services. Votre utilisation continue des services signifiera que vous acceptez d\'être lié par le présent contrat d\'utilisation. Notre échec ou retard à appliquer ou à appliquer partiellement toute disposition de cet accord d\'utilisateur ne doit pas être interprété comme une renonciation à tout.\n\n"),
        "eulaParagraphe5": MessageLookupByLibrary.simpleMessage(
            "Vous n\'êtes pas autorisé à décompiler, décoder, désassembler, louer, louer, prêter, vendre, concéder en sous-licence ou créer des travaux dérivés de l\'application mobile atomicDEX ou du contenu de l\'utilisateur. Vous n\'êtes pas non plus autorisé à utiliser un logiciel de surveillance ou de détection de réseau pour déterminer l\'architecture logicielle ou extraire des informations sur l\'utilisation ou l\'identité des personnes ou des utilisateurs. Vous n\'êtes pas autorisé à copier, modifier, reproduire, republier, distribuer, afficher ou transmettre à des fins commerciales, à but non lucratif ou publiques tout ou partie de l\'application ou du contenu de l\'utilisateur sans notre autorisation écrite préalable.\n\n"),
        "eulaParagraphe6": MessageLookupByLibrary.simpleMessage(
            "Si vous créez un compte dans l\'application mobile, vous êtes responsable de la sécurité de votre compte et de toutes les activités qui s\'y déroulent, ainsi que de toute autre action effectuée en rapport avec celui-ci. Vous devez nous informer immédiatement de toute utilisation non autorisée de votre compte ou de toute autre violation de la sécurité. Nous ne serons pas tenus responsables d\'actes ou d\'omissions de votre part, y compris des dommages de toute nature résultant de tels actes ou omissions.\n\n"),
        "eulaParagraphe7": MessageLookupByLibrary.simpleMessage(
            "Nous ne sommes pas responsables des passphrases résidant dans l\'application mobile. En aucun cas, nous ne serons tenus responsables de quelque perte que ce soit. Il est de votre entière responsabilité de conserver une copie de sauvegarde appropriée de vos comptes / passphrases.\n\n"),
        "eulaParagraphe8": MessageLookupByLibrary.simpleMessage(
            "Vous ne devez pas agir ou vous abstenir d\'agir uniquement sur la base du contenu de cette application. Votre accès à cette application ne crée pas en soi une relation conseiller-client entre vous et nous. Le contenu de cette application ne constitue pas une sollicitation ni une incitation à investir dans des produits ou services financiers proposés par nous. Tous les conseils inclus dans cette application ont été préparés sans tenir compte de vos objectifs, de votre situation financière ou de vos besoins. Vous devez prendre en compte notre avis de divulgation des risques avant de prendre une décision quant à l’acquisition du produit décrit dans ce document.\n\n"),
        "eulaParagraphe9": MessageLookupByLibrary.simpleMessage(
            "Nous ne garantissons pas votre accès continu à l\'application, ni que votre accès ou votre utilisation sera sans erreur. Nous ne serons pas responsables en cas d\'indisponibilité de l\'application pour quelque raison que ce soit (par exemple, en raison de temps d\'arrêt de l\'ordinateur imputables à des dysfonctionnements, des mises à niveau, des problèmes de serveur, des activités de maintenance préventive ou corrective ou une interruption des fournitures de télécommunication). Nous nous réservons le droit à tout moment de: - refuser ou mettre fin à tout ou partie de votre accès à l\'application alors que, à notre avis, il existe des problèmes d\'utilisation déraisonnable, de problèmes de sécurité, d\'accès non autorisé ou de violation de l\'une de ces conditions; - bloquez ou suspendez votre compte, en tout ou en partie, supprimez vos paramètres par défaut, ou une partie de ceux-ci, sans préavis.\n\n\n"),
        "eulaTitle1": MessageLookupByLibrary.simpleMessage(
            "Contrat de licence utilisateur final (EULA) d’atomicDEX mobile:\n\n"),
        "eulaTitle10":
            MessageLookupByLibrary.simpleMessage("ACCÈS ET SÉCURITÉ\n\n"),
        "eulaTitle11": MessageLookupByLibrary.simpleMessage(
            "DROITS DE PROPRIÉTÉ INTELLECTUELLE\n\n"),
        "eulaTitle12":
            MessageLookupByLibrary.simpleMessage("AVERTISSEMENT\n\n"),
        "eulaTitle13": MessageLookupByLibrary.simpleMessage(
            "REPRÉSENTATIONS ET GARANTIES, INDEMNISATION ET LIMITATION DE RESPONSABILITÉ\n\n"),
        "eulaTitle14": MessageLookupByLibrary.simpleMessage(
            "FACTEURS DE RISQUE GÉNÉRAUX\n\n"),
        "eulaTitle15": MessageLookupByLibrary.simpleMessage("INDEMNITÉ\n\n"),
        "eulaTitle16": MessageLookupByLibrary.simpleMessage(
            "INFORMATIONS SUR LES RISQUES LIÉS AU PORTEFEUILLE\n\n"),
        "eulaTitle17": MessageLookupByLibrary.simpleMessage(
            "AUCUN CONSEIL D\'INVESTISSEMENT OU DE COURTAGE\n\n"),
        "eulaTitle18": MessageLookupByLibrary.simpleMessage("RÉSILIATION\n\n"),
        "eulaTitle19":
            MessageLookupByLibrary.simpleMessage("DROITS DE TIERCE PARTIE\n\n"),
        "eulaTitle2": MessageLookupByLibrary.simpleMessage(
            "TERMES ET CONDITIONS: (CONTRAT D\'UTILISATEUR DE L\'APPLICATION)\n\n"),
        "eulaTitle20":
            MessageLookupByLibrary.simpleMessage("NOS OBLIGATIONS LEGALES\n\n"),
        "eulaTitle3": MessageLookupByLibrary.simpleMessage(
            "TERMES ET CONDITIONS D\'UTILISATION ET LIMITATION DE RESPONSABILITÉ\n\n"),
        "eulaTitle4": MessageLookupByLibrary.simpleMessage("USAGE GÉNÉRAL\n\n"),
        "eulaTitle5": MessageLookupByLibrary.simpleMessage("MODIFICATIONS\n\n"),
        "eulaTitle6":
            MessageLookupByLibrary.simpleMessage("LIMITES D\'UTILISATION\n\n"),
        "eulaTitle7":
            MessageLookupByLibrary.simpleMessage("Comptes et abonnement\n\n"),
        "eulaTitle8":
            MessageLookupByLibrary.simpleMessage("Des sauvegardes\n\n"),
        "eulaTitle9":
            MessageLookupByLibrary.simpleMessage("AVERTISSEMENT GÉNÉRAL\n\n"),
        "exampleHintSeed": MessageLookupByLibrary.simpleMessage(
            "Exemple: build case level ..."),
        "exchangeTitle": MessageLookupByLibrary.simpleMessage("ÉCHANGE"),
        "feedback":
            MessageLookupByLibrary.simpleMessage("Envoyer des commentaires"),
        "from": MessageLookupByLibrary.simpleMessage("De"),
        "getBackupPhrase": MessageLookupByLibrary.simpleMessage(
            "Important: sauvegardez votre passphrase avant de continuer!"),
        "goToPorfolio":
            MessageLookupByLibrary.simpleMessage("Aller au portefeuille"),
        "hintConfirmPassword":
            MessageLookupByLibrary.simpleMessage("Confirmez le mot de passe"),
        "hintCurrentPassword":
            MessageLookupByLibrary.simpleMessage("Mot de passe actuel"),
        "hintEnterPassword":
            MessageLookupByLibrary.simpleMessage("Tapez votre mot de passe"),
        "hintEnterSeedPhrase":
            MessageLookupByLibrary.simpleMessage("Entrez votre passphrase"),
        "hintNameYourWallet":
            MessageLookupByLibrary.simpleMessage("Nommez votre portefeuille"),
        "hintPassword": MessageLookupByLibrary.simpleMessage("Mot de passe"),
        "history": MessageLookupByLibrary.simpleMessage("historique"),
        "infoPasswordDialog": MessageLookupByLibrary.simpleMessage(
            "Si vous n\'entrez pas de mot de passe, vous devrez entrer votre passphrase chaque fois que vous souhaitez accéder à votre portefeuille."),
        "infoTrade1": MessageLookupByLibrary.simpleMessage(
            "La demande d\'échange ne peut pas être annulée et constitue un événement final!"),
        "infoTrade2": MessageLookupByLibrary.simpleMessage(
            "Cette transaction peut prendre jusqu\'à 10 minutes. NE FERMEZ PAS cette application!"),
        "infoWalletPassword": MessageLookupByLibrary.simpleMessage(
            "Vous pouvez choisir de chiffrer votre portefeuille avec un mot de passe. Si vous choisissez de ne pas utiliser de mot de passe, vous devrez entrer votre passphrase chaque fois que vous souhaitez accéder à votre portefeuille."),
        "legalTitle": MessageLookupByLibrary.simpleMessage("Légal"),
        "loading": MessageLookupByLibrary.simpleMessage("Chargement..."),
        "loadingOrderbook":
            MessageLookupByLibrary.simpleMessage("Chargement des ordres ..."),
        "lockScreen":
            MessageLookupByLibrary.simpleMessage("L\'écran est verrouillé"),
        "lockScreenAuth": MessageLookupByLibrary.simpleMessage(
            "S\'il vous plaît authentifiez vous!"),
        "login": MessageLookupByLibrary.simpleMessage("se connecter"),
        "logout": MessageLookupByLibrary.simpleMessage("Se Déconnecter"),
        "logoutOnExit":
            MessageLookupByLibrary.simpleMessage("Déconnexion à la sortie"),
        "logoutsettings":
            MessageLookupByLibrary.simpleMessage("Paramètres de déconnexion"),
        "makeAorder": MessageLookupByLibrary.simpleMessage("creer un ordre"),
        "makerpaymentID": MessageLookupByLibrary.simpleMessage(
            "Identifiant du créateur d\'ordre"),
        "marketplace": MessageLookupByLibrary.simpleMessage("Marché"),
        "max": MessageLookupByLibrary.simpleMessage("MAX"),
        "media": MessageLookupByLibrary.simpleMessage("Média"),
        "mediaBrowse": MessageLookupByLibrary.simpleMessage("FEUILLETER"),
        "mediaBrowseFeed": MessageLookupByLibrary.simpleMessage("PARCOURIR"),
        "mediaBy": MessageLookupByLibrary.simpleMessage("Par"),
        "mediaNotSavedDescription": MessageLookupByLibrary.simpleMessage(
            "VOUS N\'AVEZ PAS D\'ARTICLES ENREGISTRÉS"),
        "mediaSaved": MessageLookupByLibrary.simpleMessage("ENREGISTRÉ"),
        "minValue": m10,
        "minValueBuy": m11,
        "networkFee": MessageLookupByLibrary.simpleMessage("Frais de réseau"),
        "newAccount": MessageLookupByLibrary.simpleMessage("nouveau compte"),
        "newAccountUpper":
            MessageLookupByLibrary.simpleMessage("Nouveau compte"),
        "newsFeed": MessageLookupByLibrary.simpleMessage("Fil d\'actualité"),
        "next": MessageLookupByLibrary.simpleMessage("suivant"),
        "noArticles": MessageLookupByLibrary.simpleMessage(
            "Pas d\'articles - s\'il vous plaît revenez plus tard!"),
        "noFunds": MessageLookupByLibrary.simpleMessage("Pas de fonds"),
        "noFundsDetected": MessageLookupByLibrary.simpleMessage(
            "Pas de fonds disponibles - faire un dépot s\'il vous plaît."),
        "noInternet":
            MessageLookupByLibrary.simpleMessage("Pas de connexion Internet"),
        "noOrder": m3,
        "noOrderAvailable":
            MessageLookupByLibrary.simpleMessage("Cliquez pour créer un ordre"),
        "noRewardYet": MessageLookupByLibrary.simpleMessage(
            "Aucune récompense ne peut être demandée - veuillez réessayer dans 1h."),
        "noSwaps": MessageLookupByLibrary.simpleMessage("Pas d\'historique."),
        "noTxs": MessageLookupByLibrary.simpleMessage("Aucune transactions"),
        "notEnoughEth": MessageLookupByLibrary.simpleMessage(
            "Pas assez d\'ETH pour la transaction!"),
        "notEnoughtBalanceForFee": MessageLookupByLibrary.simpleMessage(
            "Pas assez de solde pour les frais - échangez un montant inférieur"),
        "numberAssets": m4,
        "orderCreated": MessageLookupByLibrary.simpleMessage("Ordre créée"),
        "orderCreatedInfo":
            MessageLookupByLibrary.simpleMessage("Ordre créée avec succès"),
        "orderMatched": MessageLookupByLibrary.simpleMessage("Ordre trouvé"),
        "orderMatching":
            MessageLookupByLibrary.simpleMessage("Recherche d\'ordre"),
        "orders": MessageLookupByLibrary.simpleMessage("ordres"),
        "paidWith": MessageLookupByLibrary.simpleMessage("Payé avec "),
        "placeOrder":
            MessageLookupByLibrary.simpleMessage("Passer votre ordre"),
        "portfolio": MessageLookupByLibrary.simpleMessage("Portefeuille"),
        "price": MessageLookupByLibrary.simpleMessage("prix"),
        "receive": MessageLookupByLibrary.simpleMessage("RECEVOIR"),
        "receiveLower": MessageLookupByLibrary.simpleMessage("Recevoir"),
        "recommendSeedMessage": MessageLookupByLibrary.simpleMessage(
            "Nous vous recommandons de la stocker hors ligne."),
        "requestedTrade":
            MessageLookupByLibrary.simpleMessage("Commerce demandé"),
        "restoreWallet": MessageLookupByLibrary.simpleMessage("RESTAURER"),
        "security": MessageLookupByLibrary.simpleMessage("Sécurité"),
        "seeOrders": m5,
        "seedPhraseTitle":
            MessageLookupByLibrary.simpleMessage("Votre nouvelle passphrase"),
        "selectCoin": MessageLookupByLibrary.simpleMessage(
            "Sélectionnez une crypto-monnaie"),
        "selectCoinInfo": MessageLookupByLibrary.simpleMessage(
            "Sélectionnez les crypto-monnaie que vous souhaitez ajouter à votre portefeuille."),
        "selectCoinTitle":
            MessageLookupByLibrary.simpleMessage("Activer les crypto-monnaie:"),
        "selectCoinToBuy": MessageLookupByLibrary.simpleMessage(
            "Sélectionnez la crypto-monnaie que vous souhaitez acheter"),
        "selectCoinToSell": MessageLookupByLibrary.simpleMessage(
            "Sélectionnez la crypto-monnaie que vous souhaitez vendre"),
        "selectPaymentMethod": MessageLookupByLibrary.simpleMessage(
            "Sélectionnez votre méthode de paiement"),
        "sell": MessageLookupByLibrary.simpleMessage("Vendre"),
        "send": MessageLookupByLibrary.simpleMessage("ENVOYER"),
        "setUpPassword":
            MessageLookupByLibrary.simpleMessage("CONFIGURER UN MOT DE PASSE"),
        "settingDialogSpan1": MessageLookupByLibrary.simpleMessage(
            "Etes-vous sûr que vous voulez supprimer "),
        "settingDialogSpan2":
            MessageLookupByLibrary.simpleMessage(" portefeuille?"),
        "settingDialogSpan3":
            MessageLookupByLibrary.simpleMessage("Si oui, assurez-vous de "),
        "settingDialogSpan4": MessageLookupByLibrary.simpleMessage(
            " enregistrez votre passphrase."),
        "settingDialogSpan5": MessageLookupByLibrary.simpleMessage(
            " Afin de restaurer votre portefeuille à l\'avenir."),
        "settings": MessageLookupByLibrary.simpleMessage("Réglages"),
        "shareAddress": m6,
        "showMyOrders":
            MessageLookupByLibrary.simpleMessage("MONTRER MES COMMANDES"),
        "signInWithPassword": MessageLookupByLibrary.simpleMessage(
            "Se connecter avec mot de passe"),
        "signInWithSeedPhrase": MessageLookupByLibrary.simpleMessage(
            "Connectez-vous avec la passphrase"),
        "step": MessageLookupByLibrary.simpleMessage("Étape"),
        "success": MessageLookupByLibrary.simpleMessage("Succès!"),
        "swap": MessageLookupByLibrary.simpleMessage("échanger"),
        "swapDetailTitle": MessageLookupByLibrary.simpleMessage(
            "CONFIRMEZ LES DÉTAILS DE L’ÉCHANGE"),
        "swapFailed":
            MessageLookupByLibrary.simpleMessage("L\'échange a échoué"),
        "swapID": MessageLookupByLibrary.simpleMessage("Echange ID"),
        "swapOngoing": MessageLookupByLibrary.simpleMessage("Echange en cours"),
        "swapSucceful": MessageLookupByLibrary.simpleMessage("Échange réussi"),
        "takerpaymentsID": MessageLookupByLibrary.simpleMessage(
            "Identifiant du preneur d\'ordre"),
        "timeOut": MessageLookupByLibrary.simpleMessage("Temps écoulé"),
        "titleCreatePassword":
            MessageLookupByLibrary.simpleMessage("CRÉER UN MOT DE PASSE"),
        "to": MessageLookupByLibrary.simpleMessage("À"),
        "toAddress":
            MessageLookupByLibrary.simpleMessage("Adresse de destination:"),
        "trade": MessageLookupByLibrary.simpleMessage("COMMERCE"),
        "tradeCompleted":
            MessageLookupByLibrary.simpleMessage("ECHANGE TERMINÉ!"),
        "tradeDetail":
            MessageLookupByLibrary.simpleMessage("DÉTAILS DE L\'ÉCHANGE"),
        "txBlock": MessageLookupByLibrary.simpleMessage("Bloc"),
        "txConfirmations":
            MessageLookupByLibrary.simpleMessage("Confirmations"),
        "txConfirmed": MessageLookupByLibrary.simpleMessage("CONFIRMÉ"),
        "txFee": MessageLookupByLibrary.simpleMessage("Frais"),
        "txHash":
            MessageLookupByLibrary.simpleMessage("Identifiant de transaction"),
        "txNotConfirmed": MessageLookupByLibrary.simpleMessage("NON CONFIRMÉ"),
        "unlock": MessageLookupByLibrary.simpleMessage("ouvrir"),
        "value": MessageLookupByLibrary.simpleMessage("Valeur: "),
        "version": MessageLookupByLibrary.simpleMessage("version"),
        "viewSeed": MessageLookupByLibrary.simpleMessage("Voir la passphrase"),
        "volumes": MessageLookupByLibrary.simpleMessage("Les volumes"),
        "welcomeInfo": MessageLookupByLibrary.simpleMessage(
            "AtomicDEX mobile est un portefeuille multi crypto-monnaies de nouvelle génération doté de la fonctionnalité DEX native de troisième génération et encore bien plus."),
        "welcomeLetSetUp": MessageLookupByLibrary.simpleMessage("CONFIGURONS!"),
        "welcomeName": MessageLookupByLibrary.simpleMessage("AtomicDEX"),
        "welcomeTitle": MessageLookupByLibrary.simpleMessage("BIENVENUE"),
        "welcomeWallet": MessageLookupByLibrary.simpleMessage("portefeuille"),
        "withdraw": MessageLookupByLibrary.simpleMessage("Envoyer"),
        "withdrawConfirm":
            MessageLookupByLibrary.simpleMessage("Confirmer le retrait"),
        "withdrawValue": m7,
        "wrongPassword": MessageLookupByLibrary.simpleMessage(
            "Le mot de passe ne correspond pas. Veuillez réessayer."),
        "youAreSending": MessageLookupByLibrary.simpleMessage("Vous envoyez:"),
        "youWillReceiveClaim": m8,
        "youWillReceived":
            MessageLookupByLibrary.simpleMessage("Vous allez recevoir: ")
      };
}
