// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, always_declare_return_types

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<Object> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'es';

  static m0(title) => "Solo mostrar contactos con direcciones ${title}";

  static m1(abbr) =>
      "No puede enviar fondos a la dirección ${abbr} porque ${abbr} no está activado. Por favor, vaya a la cartera.";

  static m2(appName) =>
      "¡No! ${appName} no tiene custodia. Nunca almacenamos datos confidenciales, incluidas sus claves privadas, frases iniciales o PIN. Estos datos solo se almacenan en el dispositivo del usuario y nunca lo abandonan. Usted tiene el control total de sus activos.";

  static m3(appName) =>
      "${appName} está disponible para dispositivos móviles en Android y iPhone, y para computadoras de escritorio en los sistemas operativos Windows, Mac y Linux.";

  static m4(appName) =>
      "Por lo general, otros DEX solo le permiten intercambiar monedas digitales que se basan en una sola red blockchain y solo permiten realizar un solo pedido con los mismos fondos.\n\n${appName} le permite intercambiar de forma nativa en blockchains diferentes. También puede realizar varios pedidos con los mismos fondos. Por ejemplo, puede vender 0.1 BTC por KMD, QTUM o VRSC: el primer pedido que se ejecuta automáticamente cancela todos los demás pedidos.";

  static m5(appName) =>
      "Varios factores determinan el tiempo de procesamiento de cada intercambio. El tiempo de procesar una transacción depende de cada red (Bitcoin suele ser la más lenta). Además, el usuario puede personalizar las preferencias de seguridad. Por ejemplo, puede pedirle a ${appName} que considere una transacción KMD procesada despues de solo 3 confirmaciones, lo que hace que el tiempo de intercambio sea más corto en comparación con la espera de una <a href=\"https://komodoplatform.com/security-delayed-proof-of-work-dpow/\">notarization</a>.";

  static m6(appName) =>
      "Hay dos categorías de tarifas a tener en cuenta al intercambiar en ${appName}.\n\n1. ${appName} cobra aproximadamente un 0,13 % (1/777 del volumen de la transacción, pero no menos de 0,0001) como tarifa de transacción para las órdenes del comprador, y las órdenes del vendedor no tienen tarifas.\n\n2. Tanto los vendedores como los compradores deberán pagar tarifas de red normales a las blockchains involucradas al realizar transacciones de intercambio atómico.\n\nLas tarifas de red pueden variar mucho según el par de monedas seleccionadas.";

  static m7(name, link, appName, appCompanyShort) =>
      "¡Sí! ${appName} ofrece soporte a través de <a href=\"${link}\">${appCompanyShort} ${name}</a>. ¡El equipo y la comunidad siempre están dispuestos a ayudar!";

  static m8(appName) =>
      "¡No! ${appName} es completamente descentralizado. No es posible limitar el acceso de los usuarios por parte de ningún tercero.";

  static m9(appName, appCompanyShort) =>
      "${appName} está desarrollado por el equipo de ${appCompanyShort}. ${appCompanyShort} es uno de los proyectos de blockchain más consolidados que trabaja en soluciones innovadoras como intercambios decentralizados, seguridad de blockchains y una arquitectura multicadena interoperable.";

  static m10(appName) =>
      "¡Absolutamente! Puede leer nuestra <a href=\"https://developers.atomicdex.io/\">documentación para desarrolladores</a> para obtener más detalles o comunicarse con nosotros si tiene alguna consulta sobre su asociación. ¿Tiene una pregunta técnica específica? ¡La comunidad de desarrolladores de ${appName} siempre está lista para ayudar!";

  static m11(batteryLevelCritical) =>
      "La carga de su batería es crítica (${batteryLevelCritical}%) para realizar un intercambio de manera segura. Póngalo a cargar y vuelva a intentarlo.";

  static m12(batteryLevelLow) =>
      "La carga de la batería es inferior al ${batteryLevelLow}%. Considere la posibilidad de cargar el teléfono.";

  static m13(index) => "¿Cuál es la palabra ${index} en su frase inicial?";

  static m14(iUnderstand) =>
      "Las frases semilla personalizadas pueden ser menos seguras y más fáciles de descifrar que una frase semilla o clave privada (WIF) compatible con BIP39 generada. Para confirmar que comprende el riesgo y sabe lo que está haciendo, escriba \"${iUnderstand}\" en el cuadro a continuación.";

  static m15(gas) => "No hay suficiente gas: usa al menos ${gas} Gwei";

  static m16(appCompanyLong) =>
      "${appCompanyLong} es el propietario y/o usuario autorizado de todas las marcas comerciales, marcas de servicio, marcas de diseño, patentes, derechos de autor, derechos de bases de datos y toda otra propiedad intelectual que aparezca o esté contenida en la aplicación, a menos que se indique lo contrario. Toda la información, texto, material, gráficos, software y anuncios en la interfaz de la aplicación son propiedad intelectual de ${appCompanyLong}, sus proveedores y licenciantes, a menos que ${appCompanyLong} indique expresamente lo contrario. \nExcepto por lo dispuesto en los Términos, el uso de la aplicación no le otorga ningún derecho, título, interés o licencia sobre dicha propiedad intelectual a la que pueda tener acceso en la aplicación. \nSomos propietarios de los derechos, o tenemos permiso para usar, las marcas registradas que figuran en nuestra aplicación. No está autorizado a usar ninguna de esas marcas comerciales sin nuestra autorización por escrito; hacerlo constituiría una violación de nuestros derechos de propiedad intelectual o de terceros. \nAlternativamente, podemos autorizarlo a usar el contenido de nuestra aplicación si se comunica con nosotros previamente y aceptamos por escrito.\n\n";

  static m17(appCompanyShort, appCompanyLong) =>
      "${appCompanyLong} no puede garantizar la seguridad de sus sistemas informáticos. No aceptamos responsabilidad por ninguna pérdida o corrupción de los datos almacenados electrónicamente o cualquier daño a cualquier sistema informático que se produzca en relación con el uso de la aplicación o del contenido del usuario.\n${appCompanyLong} no hace ninguna representación ni garantía de ningún tipo, expresa o implícita, en cuanto al funcionamiento de la aplicación o el contenido del usuario. Usted acepta expresamente que su uso de la aplicación es bajo su propio riesgo.\nUsted acepta que el contenido proporcionado en la aplicación y el contenido del usuario no constituyen un producto financiero, asesoramiento legal o fiscal, y acepta no representar el contenido del usuario o la aplicación como tal.\nEn la medida en que lo permita la legislación vigente, la aplicación se proporciona \'tal cual, según disponibilidad\'.\n\n${appCompanyLong} renuncia expresamente a toda responsabilidad por cualquier pérdida, lesión, reclamación, responsabilidad , o daño, o cualquier daño indirecto, incidental, especial o consecuente o pérdida de ganancias que resulte de, surja o esté relacionado de alguna manera con: \n(a) cualquier error u omisión en la aplicación y/o el usuario contenido, incluidos, entre otros, inexactitudes técnicas y errores tipográficos; \n(b) cualquier sitio web, aplicación o contenido de terceros al que se acceda directa o indirectamente a través de enlaces en la aplicación, incluidos, entre otros, los errores u omisiones; \n(c) la falta de disponibilidad de la aplicación o cualquier parte de ella; \n(d) su uso de la aplicación;\n(e) su uso de cualquier equipo o software en relación con la aplicación. \nTodos los Servicios ofrecidos en relación con la Plataforma se proporcionan \'tal cual\', sin ninguna representación o garantía, ya sea expresa, implícita o legal. En la medida máxima permitida por la ley aplicable, renunciamos específicamente a cualquier garantía implícita de título, comerciabilidad, idoneidad para un propósito particular y/o no infracción. No hacemos ninguna representación ni garantizamos que el uso de la Plataforma será continuo, ininterrumpido, oportuno o libre de errores.\nNo garantizamos que ninguna Plataforma esté libre de virus, malware u otro material dañino relacionado y que su la capacidad de acceder a cualquier Plataforma será ininterrumpida. Cualquier defecto o mal funcionamiento del producto debe dirigirse al tercero que ofrece la Plataforma, no a ${appCompanyShort}. \nNo seremos responsables ante Usted por ninguna pérdida de ningún tipo, por acción tomada o tomada en función del material o la información contenida en o a través de la Plataforma.\nEste es un software experimental e inacabado. Úselo bajo su propio riesgo. No hay garantía por cualquier tipo de daño. Al utilizar esta aplicación, usted acepta estos términos y condiciones.\n\n";

  static m18(appCompanyLong) =>
      "Usted acepta y comprende que existen riesgos asociados con la utilización de Servicios que involucran Monedas virtuales, incluidos, entre otros, el riesgo de fallas en el hardware, el software y las conexiones a Internet, el riesgo de introducción de software malicioso y el riesgo de que terceros puedan obtener información no autorizada. acceso a la información almacenada en su Wallet, incluidas, entre otras, sus claves públicas y privadas. Usted acepta y comprende que ${appCompanyLong} no será responsable de las fallas de comunicación, las interrupciones, los errores, las distorsiones o los retrasos que pueda experimentar al usar los Servicios, cualquiera que sea la causa.\nUsted acepta y reconoce que existen riesgos asociados con el uso de cualquier moneda virtual red, incluido, entre otros, el riesgo de vulnerabilidades desconocidas o cambios imprevistos en el protocolo de red. Usted reconoce y acepta que ${appCompanyLong} no tiene control sobre ninguna red de criptomonedas y no será responsable de ningún daño que ocurra como resultado de dichos riesgos, incluida, entre otros, la incapacidad de revertir una transacción y cualquier pérdida en conexión. con ello debido a acciones erróneas o fraudulentas.\nEl riesgo de pérdida en el uso de Servicios que involucran Monedas Virtuales puede ser sustancial y las pérdidas pueden ocurrir en un corto período de tiempo. Además, el precio y la liquidez están sujetos a fluctuaciones significativas que pueden ser impredecibles.\nLas monedas virtuales no son moneda de curso legal y no están respaldadas por ningún gobierno soberano. Además, el panorama legislativo y reglamentario en torno a las monedas virtuales cambia constantemente y puede afectar su capacidad para usar, transferir o intercambiar monedas virtuales.\nLos CFD son instrumentos complejos y conllevan un alto riesgo de perder dinero rápidamente debido al apalancamiento. El 80,6 % de las cuentas de inversores minoristas pierden dinero al operar con CFD con este proveedor. Debe considerar si comprende cómo funcionan los CFD y si puede permitirse asumir el alto riesgo de perder su dinero.\n\n";

  static m19(appCompanyLong) =>
      "Usted acepta indemnizar, defender y eximir de responsabilidad a ${appCompanyLong}, sus funcionarios, directores, empleados, agentes, otorgantes de licencias, proveedores y cualquier tercero proveedor de información de la aplicación de todas las pérdidas, gastos, daños y costos, incluidos los honorarios razonables de los abogados. , como resultado de cualquier violación de los Términos por su parte.\nTambién acepta indemnizar a ${appCompanyLong} contra cualquier reclamo de que la información o el material que ha enviado a ${appCompanyLong} viola cualquier ley o viola los derechos de terceros ( incluyendo, pero no limitado a, reclamos con respecto a difamación, invasión de privacidad, abuso de confianza, infracción de derechos de autor o infracción de cualquier otro derecho de propiedad intelectual).\n\n";

  static m20(appCompanyLong) =>
      "Para completarse, cualquier transacción de moneda virtual creada con ${appCompanyLong} debe confirmarse y registrarse en el libro mayor de moneda virtual asociado con la red de moneda virtual correspondiente. Dichas redes son redes descentralizadas de igual a igual respaldadas por terceros independientes, que no son propiedad de ${appCompanyLong} ni están controladas ni operadas por esta.\n${appCompanyLong} no tiene control sobre ninguna red de moneda virtual y, por lo tanto, no puede y no garantiza que cualquier detalle de transacción que envíe a través de nuestros Servicios se confirmará en la red de moneda virtual correspondiente. Usted acepta y comprende que los detalles de la transacción que envía a través de nuestros Servicios pueden no completarse, o pueden retrasarse sustancialmente, por la red de moneda virtual utilizada para procesar la transacción. No garantizamos que Wallet pueda transferir títulos o derechos en cualquier moneda virtual ni otorgamos ninguna garantía con respecto al título.\nUna vez que los detalles de la transacción se hayan enviado a una red de moneda virtual, no podemos ayudarlo a cancelar o modificar su transacción. o detalles de la transacción. ${appCompanyLong} no tiene control sobre ninguna red de moneda virtual y no tiene la capacidad de facilitar ninguna solicitud de cancelación o modificación.\nEn el caso de una bifurcación, es posible que ${appCompanyLong} no pueda respaldar la actividad relacionada con su moneda virtual. Usted acepta y comprende que, en el caso de una bifurcación, es posible que las transacciones no se completen, se completen parcialmente, se completen incorrectamente o se retrasen sustancialmente. ${appCompanyLong} no es responsable de ninguna pérdida sufrida por Usted causada en su totalidad o en parte, directa o indirectamente, por un Fork.\nEn ningún caso ${appCompanyLong}, sus afiliados y proveedores de servicios, o cualquiera de sus respectivos funcionarios, directores , agentes, empleados o representantes, serán responsables de cualquier pérdida de ganancias o daños especiales, incidentales, indirectos, intangibles o consecuentes, ya sea que se basen en un contrato, agravio, negligencia, responsabilidad estricta o de otro modo, que surja de o en conexión con autorizado o uso no autorizado de los servicios, o este acuerdo, incluso si un representante autorizado de ${appCompanyLong} ha sido informado, ha sabido o debería haber sabido de la posibilidad de tales daños. \nPor ejemplo (y sin limitar el alcance de la oración anterior), es posible que no se recupere por pérdida de ganancias, pérdida de oportunidades comerciales u otros tipos de daños especiales, incidentales, indirectos, intangibles o consecuentes. Algunas jurisdicciones no permiten la exclusión o limitación de daños incidentales o consecuentes, por lo que es posible que la limitación anterior no se aplique a usted. \nNo seremos responsables ante Usted por ninguna pérdida y no asumimos ninguna responsabilidad por daños o reclamos que surjan en su totalidad o en parte, directa o indirectamente de: (a) error del usuario, como contraseñas olvidadas, transacciones construidas incorrectamente o Virtual Direcciones de divisas; (b) falla del servidor o pérdida de datos; (c) Monederos o archivos de Monedero corruptos o que no funcionen; (d) acceso no autorizado a las aplicaciones; (e) cualquier actividad no autorizada, incluido, entre otros, el uso de piratería informática, virus, phishing, fuerza bruta u otros medios de ataque contra los Servicios.\n\n";

  static m21(appCompanyShort, appCompanyLong) =>
      "Para evitar dudas, ${appCompanyLong} no brinda asesoramiento legal, impositivo o de inversión, ni ${appCompanyLong} realiza operaciones de corretaje en su nombre. Todas las operaciones de ${appCompanyLong} se ejecutan automáticamente, según los parámetros de las instrucciones de su pedido y de acuerdo con los procedimientos de ejecución de operaciones publicados, y usted es el único responsable de determinar si cualquier inversión, estrategia de inversión o transacción relacionada es apropiada para usted en función de su información personal. objetivos de inversión, circunstancias financieras y tolerancia al riesgo. Debe consultar a su profesional legal o fiscal con respecto a su situación específica. Ni ${appCompanyShort} ni sus propietarios, miembros, funcionarios, directores, socios, consultores ni ninguna persona involucrada en la publicación de esta aplicación es un asesor de inversiones registrado o corredor de bolsa. o persona asociada con un asesor de inversiones o corredor de bolsa registrado y ninguno de los anteriores hace ninguna recomendación de que la compra o venta de criptoactivos o valores de cualquier empresa perfilada en la Aplicación móvil es adecuada o aconsejable para cualquier persona o que una inversión o la transacción en dichos criptoactivos o valores será rentable. La información contenida en la Aplicación móvil no pretende ser, y no constituirá, una oferta de venta o la solicitud de ninguna oferta para comprar ningún criptoactivo o valor. La información presentada en la Aplicación móvil se proporciona únicamente con fines informativos y no debe tratarse como un consejo o una recomendación para realizar una inversión o transacción específica. Por favor, consulte con un profesional calificado antes de tomar cualquier decisión. Las opiniones y análisis incluidos en esta solicitud se basan en información de fuentes consideradas confiables y se proporcionan \'tal cual\' de buena fe. ${appCompanyShort} no representa ni garantiza, de forma expresa, implícita o legal, la exactitud o integridad de dicha información, que puede estar sujeta a cambios sin previo aviso. ${appCompanyShort} no será responsable de ningún error o acción realizada en relación con lo anterior. Las declaraciones de opinión y creencia son las de los autores y/o editores que contribuyen a esta aplicación, y se basan únicamente en la información que poseen dichos autores y/o editores. No se debe inferir que ${appCompanyShort} o dichos autores o editores tienen un conocimiento especial o mayor sobre los criptoactivos o las empresas perfiladas o cualquier experiencia particular en las industrias o mercados en los que operan y compiten los criptoactivos y las empresas perfiladas. La información sobre esta solicitud se obtiene de fuentes consideradas confiables; sin embargo, ${appCompanyShort} no se hace responsable de verificar la precisión de dicha información y no garantiza que dicha información sea precisa o completa. Ciertas declaraciones incluidas en esta solicitud pueden ser declaraciones prospectivas basadas en las expectativas actuales. ${appCompanyShort} no representa ni garantiza que dichas declaraciones prospectivas serán precisas. Se insta a las personas que usan la aplicación ${appCompanyShort} a consultar con un profesional calificado con respecto a una inversión o transacción en cualquier cripto- activo o empresa perfilada en este documento. Además, las personas que utilizan esta aplicación declaran expresamente que el contenido de esta aplicación no es y no será una consideración en las decisiones de inversión o transacción de dichas personas. Los comerciantes deben verificar de forma independiente la información provista en la aplicación ${appCompanyShort} completando su propia diligencia debida en cualquier criptoactivo o empresa en la que estén contemplando una inversión o transacción de cualquier tipo y revisar un paquete completo de información sobre ese criptoactivo o empresa. , que debe incluir, entre otros, actualizaciones de blogs y comunicados de prensa relacionados. El rendimiento pasado de los criptoactivos y valores perfilados no es indicativo de resultados futuros. Los criptoactivos y las empresas descritas en este sitio pueden carecer de un mercado comercial activo e invertir en un criptoactivo o valor que carece de un mercado comercial activo o negociar en ciertos medios, plataformas y mercados se consideran altamente especulativos y conllevan un alto grado de riesgo. . Cualquier persona que posea dichos criptoactivos y valores debe estar financieramente capacitado y preparado para asumir el riesgo de pérdida y la pérdida real de toda su operación. La información de esta solicitud no está diseñada para ser utilizada como base para una decisión de inversión. Las personas que utilicen la aplicación ${appCompanyShort} deben confirmar a su entera satisfacción la veracidad de cualquier información antes de realizar cualquier inversión o transacción. La decisión de comprar o vender cualquier criptoactivo o valor que pueda presentar ${appCompanyShort} se toma pura y completamente bajo el propio riesgo del lector. Como lector y usuario de esta aplicación, usted acepta que bajo ninguna circunstancia buscará responsabilizar a los propietarios, miembros, funcionarios, directores, socios, consultores u otras personas involucradas en la publicación de esta aplicación por las pérdidas sufridas por el uso de la información contenida en esta aplicación\\${appCompanyShort} y sus contratistas y afiliados pueden beneficiarse en caso de que los activos criptográficos y los valores aumenten o disminuyan en valor. Dichos criptoactivos y valores pueden comprarse o venderse de vez en cuando, incluso después de que ${appCompanyShort} haya distribuido información positiva sobre los criptoactivos y las empresas. \\${appCompanyShort} no tiene la obligación de informar a los lectores sobre sus actividades comerciales o las actividades comerciales de cualquiera de sus propietarios, miembros, funcionarios, directores, contratistas y afiliados y/o cualquier empresa afiliada a los propietarios, miembros, funcionarios, directores, contratistas y afiliados.\\${appCompanyShort} y sus afiliados pueden ocasionalmente celebrar acuerdos para comprar criptoactivos o valores para proporcionar un método para alcanzar sus objetivos.\n\n";

  static m22(appCompanyLong) =>
      "Los Términos son efectivos hasta que sean rescindidos por ${appCompanyLong}. \nEn caso de rescisión, ya no estará autorizado a acceder a la Aplicación, pero todas las restricciones que se le impongan y las renuncias y limitaciones de responsabilidad establecidas en los Términos sobrevivirán a la rescisión. \nDicha rescisión no afectará ningún derecho legal que pueda haber acumulado ${appCompanyLong} contra usted hasta la fecha de rescisión. \n${appCompanyLong} también puede eliminar la Aplicación en su totalidad o cualquier sección o característica de la Aplicación en cualquier momento. \n\n";

  static m23(appCompanyLong) =>
      "Las disposiciones de los párrafos anteriores son para el beneficio de ${appCompanyLong} y sus funcionarios, directores, empleados, agentes, otorgantes de licencias, proveedores y cualquier tercero que proporcione información a la Aplicación. Cada una de estas personas o entidades tendrá derecho a hacer valer y hacer cumplir esas disposiciones directamente contra usted en su propio nombre.\n\n";

  static m24(appName, appCompanyLong) =>
      "${appName} mobile es una aplicación sin custodia, descentralizada y basada en blockchain y, como tal, ${appCompanyLong} nunca almacena ningún dato de usuario (cuentas y datos de autenticación). \nTambién recopilamos y procesamos datos anónimos no personales con fines estadísticos y de análisis, y para ayudarnos a brindar un mejor servicio.\n\nEste documento se actualizó por última vez el 31 de Enero de 2020\n\n";

  static m25(appName, appCompanyLong) =>
      "Este descargo de responsabilidad se aplica a los contenidos y servicios de la aplicación ${appName} y es válido para todos los usuarios de la \'Aplicación\' (\'Software\', \'Aplicación móvil\', \'Aplicación\' o \'Aplicación\').\n\nLa Aplicación es propiedad de ${appCompanyLong}.\n\nNos reservamos el derecho de modificar los siguientes Términos y condiciones (que rigen el uso de la aplicación \'${appName} móvil\') en cualquier momento sin previo aviso y a nuestro exclusivo criterio. Es su responsabilidad revisar periódicamente estos Términos y Condiciones para cualquier actualización de estos Términos, que entrarán en vigor una vez que se publiquen.\nEl uso continuado de la aplicación se considerará como la aceptación de los siguientes Términos. \nSomos una empresa constituida en Vietnam y estos Términos y condiciones se rigen y están sujetos a las leyes de Vietnam. \nSi no está de acuerdo con estos Términos y condiciones, no debe usar ni acceder a este software.\n\n";

  static m26(appName) =>
      "No está permitido descompilar, decodificar, desensamblar, alquilar, arrendar, prestar, vender, otorgar sublicencias o crear trabajos derivados de la aplicación móvil ${appName} o el contenido del usuario. Tampoco se le permite usar ningún software de monitoreo o detección de red para determinar la arquitectura del software, o extraer información sobre el uso o las identidades de las personas o los usuarios. \nNo tiene permitido copiar, modificar, reproducir, volver a publicar, distribuir, exhibir o transmitir con fines comerciales, sin fines de lucro o públicos, la totalidad o parte de la aplicación o el contenido del usuario sin nuestra autorización previa por escrito.\n\n";

  static m27(appName, appCompanyLong) =>
      "Si crea una cuenta en la Aplicación móvil, usted es responsable de mantener la seguridad de su cuenta y es completamente responsable de todas las actividades que ocurran en la cuenta y cualquier otra acción realizada en relación con ella. No seremos responsables de ningún acto u omisión por su parte, incluidos los daños de cualquier tipo incurridos como resultado de dichos actos u omisiones. \n\n ${appName} móvil es una implementación de billetera sin custodia y, por lo tanto, ${appCompanyLong} no puede acceder ni restaurar su cuenta en caso de pérdida (de datos).\n\n";

  static m28(appName) =>
      "Acuerdo de licencia de usuario final (EULA) de ${appName} móvil:\n\n";

  static m29(coin) => "Enviando solicitud a la llave ${coin}...";

  static m30(appCompanyShort) => "${appCompanyShort} noticias";

  static m31(coinName, number) =>
      "La cantidad mínima para vender es ${number} ${coinName}";

  static m32(coinName, number) =>
      "La cantidad mínima para comprar es ${number}${coinName}";

  static m33(buyCoin, buyAmount, sellCoin, sellAmount) =>
      "El monto mínimo del pedido es ${buyAmount}${buyCoin}\n(${sellAmount}${sellCoin})";

  static m34(coinName, number) =>
      "La cantidad mínima para vender es ${number}${coinName}";

  static m35(appName) =>
      "Tenga en cuenta que ahora está utilizando datos móviles y la participación en la red P2P de ${appName} consume tráfico de Internet. Es mejor usar una red WiFi si su plan de datos móviles es costoso.";

  static m36(coin) => "Active ${coin} y añada saldo primero";

  static m37(coinName) => "Ingrese la cantidad de ${coinName}.";

  static m38(coin) => "¡Ha recibido una transacción de ${coin}!";

  static m39(coin) => "Todos los pedidos de ${coin} serán cancelados.";

  static m40(delta) => "Expediente: CEX +${delta}%";

  static m41(delta) => "Caro: CEX ${delta}%";

  static m42(fill) => "${fill}% llenado";

  static m43(coin) => "Cantidad (${coin})";

  static m44(coin) => "Total (${coin})";

  static m45(abbr) => "${abbr} no está activo. Activa e inténtalo de nuevo..";

  static m46(appName) => "¿En qué dispositivos puedo usar ${appName}?";

  static m47(appName) =>
      "¿En qué se diferencia el comercio en ${appName} del comercio en otros DEX?";

  static m48(appName) => "¿Cómo se calculan las tarifas de ${appName}?";

  static m49(appName) => "¿Quién está detrás de ${appName}?";

  static m50(appName) =>
      "¿Es posible desarrollar mi propio intercambio con ${appName}?";

  static m51(dd) => "${dd} dias(s)";

  static m52(hh, minutes) => "${hh}h ${minutes}m";

  static m53(mm) => "${mm}min";

  static m54(coin) => "Ingrese la cantidad de ${coin} para comprar";

  static m55(maxCoins) =>
      "El número máximo de monedas activas es ${maxCoins}. Por favor, desactive algunos.";

  static m56(coin) => "${coin} no está activo!";

  static m57(coin) => "Ingrese la cantidad de ${coin} para vender";

  static m58(description) =>
      "Elija un archivo mp3 o wav, por favor. Lo reproduciremos cuando ${description}.";

  static m59(appName) =>
      "Si tiene alguna pregunta o cree que ha encontrado un problema técnico con la aplicación ${appName}, puede informar y obtener asistencia de nuestro equipo.";

  static m60(coin) => "Activa ${coin} y recarga el saldo primero";

  static m61(coin) =>
      "El saldo de ${coin} no es suficiente para pagar las tarifas de transacción.";

  static m62(appName) => "${appName} actualizar";

  static m63(appName) =>
      "${appName} móvil es una billetera multimoneda de próxima generación con funcionalidad DEX nativa de tercera generación y más.";

  static m64(appName) =>
      "Previamente le has negado a ${appName} el acceso a la cámara.\nCambia manualmente el permiso de la cámara en la configuración de tu teléfono para continuar con el escaneo del código QR.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "Active": MessageLookupByLibrary.simpleMessage("Activo"),
        "Applause": MessageLookupByLibrary.simpleMessage("Aplausos"),
        "Can\'t play that":
            MessageLookupByLibrary.simpleMessage("no puedo escuchar eso"),
        "Failed": MessageLookupByLibrary.simpleMessage("Fallido"),
        "Maker": MessageLookupByLibrary.simpleMessage("Vendedor"),
        "Play at full volume":
            MessageLookupByLibrary.simpleMessage("Juega a todo volumen"),
        "Sound": MessageLookupByLibrary.simpleMessage("Sonido"),
        "Taker": MessageLookupByLibrary.simpleMessage("Comprador"),
        "a swap fails":
            MessageLookupByLibrary.simpleMessage("un intercambio falla"),
        "a swap runs to completion": MessageLookupByLibrary.simpleMessage(
            "un intercambio se ejecuta hasta su finalización"),
        "accepteula": MessageLookupByLibrary.simpleMessage("Aceptar EULA"),
        "accepttac": MessageLookupByLibrary.simpleMessage(
            "Aceptar TERMINOS y CONDICIONES"),
        "activateAccessBiometric": MessageLookupByLibrary.simpleMessage(
            "Activar protección biométrica"),
        "activateAccessPin": MessageLookupByLibrary.simpleMessage(
            "Activar la protección con PIN"),
        "addCoin": MessageLookupByLibrary.simpleMessage("Activar moneda"),
        "addressAdd": MessageLookupByLibrary.simpleMessage("Añadir Direccion"),
        "addressBook": MessageLookupByLibrary.simpleMessage("Directorio"),
        "addressBookEmpty": MessageLookupByLibrary.simpleMessage(
            "La libreta de direcciones está vacía"),
        "addressBookFilter": m0,
        "addressBookTitle": MessageLookupByLibrary.simpleMessage("Directorio"),
        "addressCoinInactive": m1,
        "addressNotFound":
            MessageLookupByLibrary.simpleMessage("Nada Encontrado"),
        "addressSelectCoin":
            MessageLookupByLibrary.simpleMessage("Seleccionar Moneda"),
        "addressSend": MessageLookupByLibrary.simpleMessage(
            "Dirección de los destinatarios"),
        "allowCustomSeed": MessageLookupByLibrary.simpleMessage(
            "Permitir semilla personalizada"),
        "amount": MessageLookupByLibrary.simpleMessage("Cantidad"),
        "amountToSell":
            MessageLookupByLibrary.simpleMessage("Cantidad a Vender"),
        "answer_1": m2,
        "answer_10": m3,
        "answer_2": m4,
        "answer_3": m5,
        "answer_4": MessageLookupByLibrary.simpleMessage(
            "Si. Debe permanecer conectado al Internet y tener su aplicación ejecutándose para completar con éxito cada intercambio (las interrupciones muy breves en la conectividad generalmente no causan problemas). De lo contrario, existe el riesgo de cancelación de la operación y el riesgo de pérdida de fondos si es un comprador. El protocolo de intercambio atómico requiere que ambos participantes permanezcan en línea y monitoreen los blockchains involucrados para que el proceso permanezca atómico."),
        "answer_5": m6,
        "answer_6": m7,
        "answer_7": m8,
        "answer_8": m9,
        "answer_9": m10,
        "areYouSure": MessageLookupByLibrary.simpleMessage("ESTAS SEGURO?"),
        "authenticate": MessageLookupByLibrary.simpleMessage("autenticar"),
        "availableVolume":
            MessageLookupByLibrary.simpleMessage("volumen máximo"),
        "back": MessageLookupByLibrary.simpleMessage("back"),
        "backupTitle": MessageLookupByLibrary.simpleMessage("Respaldo"),
        "batteryCriticalError": m11,
        "batteryLowWarning": m12,
        "batterySavingWarning": MessageLookupByLibrary.simpleMessage(
            "Su teléfono está en modo de ahorro de batería. Deshabilite este modo o NO ponga la aplicación en segundo plano, de lo contrario, el sistema operativo podría eliminar la aplicación y fallar el intercambio."),
        "bestAvailableRate":
            MessageLookupByLibrary.simpleMessage("Tipo de cambio"),
        "buy": MessageLookupByLibrary.simpleMessage("Comprar"),
        "buyOrderType": MessageLookupByLibrary.simpleMessage(
            "Convertir a Vendedor si no coincide"),
        "buySuccessWaiting": MessageLookupByLibrary.simpleMessage(
            "Intercambio emitido, por favor espere!"),
        "buyTestCoinWarning": MessageLookupByLibrary.simpleMessage(
            "¡Advertencia, estás dispuesto a comprar monedas de prueba SIN valor real!"),
        "camoPinChange":
            MessageLookupByLibrary.simpleMessage("Cambiar PIN de camuflaje"),
        "camoPinCreate":
            MessageLookupByLibrary.simpleMessage("Crear PIN de camuflaje"),
        "camoPinDesc": MessageLookupByLibrary.simpleMessage(
            "Si desbloquea la aplicación con el PIN de camuflaje, se mostrará un saldo BAJO falso y la opción de configuración del PIN de camuflaje NO estará visible en la configuración"),
        "camoPinInvalid":
            MessageLookupByLibrary.simpleMessage("PIN de camuflaje no válido"),
        "camoPinLink": MessageLookupByLibrary.simpleMessage("Camuflajear PIN"),
        "camoPinNotFound": MessageLookupByLibrary.simpleMessage(
            "PIN de camuflaje no encontrado"),
        "camoPinOff": MessageLookupByLibrary.simpleMessage("Desactivado"),
        "camoPinOn": MessageLookupByLibrary.simpleMessage("Activado"),
        "camoPinSaved":
            MessageLookupByLibrary.simpleMessage("PIN de camuflaje guardado"),
        "camoPinTitle":
            MessageLookupByLibrary.simpleMessage("Camuflajear el PIN"),
        "camoSetupSubtitle": MessageLookupByLibrary.simpleMessage(
            "Ingrese el nuevo PIN de camuflaje"),
        "camoSetupTitle": MessageLookupByLibrary.simpleMessage(
            "Configuración de PIN de camuflaje"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "cancelButton": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "candleChartError": MessageLookupByLibrary.simpleMessage(
            "Algo salió mal. Vuelve a intentarlo más tarde."),
        "cantDeleteDefaultCoinOk": MessageLookupByLibrary.simpleMessage("Ok"),
        "cantDeleteDefaultCoinSpan": MessageLookupByLibrary.simpleMessage(
            " es una moneda predeterminada. Las monedas predeterminadas no se pueden desactivar."),
        "cantDeleteDefaultCoinTitle":
            MessageLookupByLibrary.simpleMessage("No se puede deshabilitar "),
        "cex": MessageLookupByLibrary.simpleMessage("CEX"),
        "cexChangeRate":
            MessageLookupByLibrary.simpleMessage("Tasa de Cambio CEX"),
        "cexData": MessageLookupByLibrary.simpleMessage("data de CEX"),
        "cexDataDesc": MessageLookupByLibrary.simpleMessage(
            "Los datos de mercados (precios, gráficos, etc.) marcados con este ícono provienen de fuentes de terceros (<a href=\"https://www.coingecko.com/\">coingecko.com</a>, <a href =\"https://openrates.io/\">openrates.io</a>)."),
        "changePin": MessageLookupByLibrary.simpleMessage("Cambiar código PIN"),
        "checkForUpdates":
            MessageLookupByLibrary.simpleMessage("Buscar actualizaciones"),
        "checkOut": MessageLookupByLibrary.simpleMessage("Verificar"),
        "checkSeedPhrase":
            MessageLookupByLibrary.simpleMessage("Comprobar la frase inicial"),
        "checkSeedPhraseButton1":
            MessageLookupByLibrary.simpleMessage("SEGUIR"),
        "checkSeedPhraseButton2":
            MessageLookupByLibrary.simpleMessage("VOLVER Y VERIFICAR DE NUEVO"),
        "checkSeedPhraseInfo": MessageLookupByLibrary.simpleMessage(
            "Tu frase semilla es importante, por eso nos gusta asegurarnos de que sea correcta. Le haremos tres preguntas diferentes sobre su frase semilla para asegurarnos de que podrá restaurar fácilmente su billetera cuando lo desee."),
        "checkSeedPhraseSubtile": m13,
        "checkSeedPhraseTitle": MessageLookupByLibrary.simpleMessage(
            "VAMOS A VERIFICAR DOS VECES TU FRASE SEMILLA"),
        "checkingUpdates": MessageLookupByLibrary.simpleMessage(
            "Comprobando actualizaciones..."),
        "chineseLanguage": MessageLookupByLibrary.simpleMessage("Chino"),
        "claim": MessageLookupByLibrary.simpleMessage("afirmar"),
        "claimTitle": MessageLookupByLibrary.simpleMessage(
            "¿Reclamar su recompensa KMD?"),
        "clickToSee": MessageLookupByLibrary.simpleMessage("Clic para ver "),
        "clipboard":
            MessageLookupByLibrary.simpleMessage("Copiado al portapapeles"),
        "clipboardCopy":
            MessageLookupByLibrary.simpleMessage("Copiar al portapapeles"),
        "close": MessageLookupByLibrary.simpleMessage("Cerrar"),
        "closePreview": MessageLookupByLibrary.simpleMessage("Cerrar prevista"),
        "code": MessageLookupByLibrary.simpleMessage("Código: "),
        "coinSelectClear": MessageLookupByLibrary.simpleMessage("Remover"),
        "coinSelectNotFound":
            MessageLookupByLibrary.simpleMessage("No hay monedas activas"),
        "coinSelectTitle":
            MessageLookupByLibrary.simpleMessage("Seleccionar moneda"),
        "comingSoon": MessageLookupByLibrary.simpleMessage("Próximamente..."),
        "commingsoon": MessageLookupByLibrary.simpleMessage(
            "Detalles de TX próximamente!"),
        "commingsoonGeneral":
            MessageLookupByLibrary.simpleMessage("¡Detalles muy pronto!"),
        "commissionFee":
            MessageLookupByLibrary.simpleMessage("cuota de comisión"),
        "comparedToCex":
            MessageLookupByLibrary.simpleMessage("comparable a CEX"),
        "configureWallet": MessageLookupByLibrary.simpleMessage(
            "Configurando su billetera, por favor espere..."),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
        "confirmPassword":
            MessageLookupByLibrary.simpleMessage("Confirmar contraseña"),
        "confirmPin":
            MessageLookupByLibrary.simpleMessage("Confirmar código PIN"),
        "confirmSeed":
            MessageLookupByLibrary.simpleMessage("Confirmar frase semilla"),
        "confirmeula": MessageLookupByLibrary.simpleMessage(
            "Al hacer clic en los botones a continuación, confirma haber leído el \'EULA\' y los \'Términos y condiciones\' y acepta estos"),
        "connecting": MessageLookupByLibrary.simpleMessage("Conectando..."),
        "contactCancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "contactDelete":
            MessageLookupByLibrary.simpleMessage("Borrar Contacto"),
        "contactDeleteBtn": MessageLookupByLibrary.simpleMessage("Borrar"),
        "contactDiscardBtn": MessageLookupByLibrary.simpleMessage("Descartar"),
        "contactEdit": MessageLookupByLibrary.simpleMessage("Editar"),
        "contactExit": MessageLookupByLibrary.simpleMessage("Salir"),
        "contactExitWarning":
            MessageLookupByLibrary.simpleMessage("Descartar tus cambios?"),
        "contactNotFound":
            MessageLookupByLibrary.simpleMessage("No se encontraron contactos"),
        "contactSave": MessageLookupByLibrary.simpleMessage("Guardar"),
        "contactTitle":
            MessageLookupByLibrary.simpleMessage("Detalles de contacto"),
        "contactTitleName": MessageLookupByLibrary.simpleMessage("Nombre"),
        "couldntImportError":
            MessageLookupByLibrary.simpleMessage("No se pudo importar: "),
        "create": MessageLookupByLibrary.simpleMessage("intercambiar"),
        "createAWallet":
            MessageLookupByLibrary.simpleMessage("CREAR UNA CARTERA"),
        "createContact": MessageLookupByLibrary.simpleMessage("Crear Contacto"),
        "createPin": MessageLookupByLibrary.simpleMessage("Crear numero PIN"),
        "currency": MessageLookupByLibrary.simpleMessage("Moneda"),
        "currencyDialogTitle": MessageLookupByLibrary.simpleMessage("Moneda"),
        "customFee": MessageLookupByLibrary.simpleMessage(
            "Costo de Transacción Personalizado"),
        "customFeeWarning": MessageLookupByLibrary.simpleMessage(
            "¡Solo use tarifas personalizadas si sabe lo que está haciendo!"),
        "customSeedWarning": m14,
        "decryptingWallet":
            MessageLookupByLibrary.simpleMessage("Billetera de descifrado"),
        "delete": MessageLookupByLibrary.simpleMessage("Borrar"),
        "deleteConfirm":
            MessageLookupByLibrary.simpleMessage("Confirmar desactivación"),
        "deleteSpan1":
            MessageLookupByLibrary.simpleMessage("¿Quieres eliminar "),
        "deleteSpan2": MessageLookupByLibrary.simpleMessage(
            " de tu cartera? Todos los pedidos no emparejados serán cancelados."),
        "deleteWallet":
            MessageLookupByLibrary.simpleMessage("Eliminar Billetera"),
        "details": MessageLookupByLibrary.simpleMessage("detalles"),
        "deutscheLanguage": MessageLookupByLibrary.simpleMessage("Alemán"),
        "developerTitle": MessageLookupByLibrary.simpleMessage("Desarrollador"),
        "dex": MessageLookupByLibrary.simpleMessage("DEX"),
        "dexIsNotAvailable": MessageLookupByLibrary.simpleMessage(
            "DEX no está disponible para esta moneda"),
        "disclaimerAndTos": MessageLookupByLibrary.simpleMessage(
            "Descargo de responsabilidad y condiciones de servicio"),
        "done": MessageLookupByLibrary.simpleMessage("Hecho"),
        "dontWantPassword":
            MessageLookupByLibrary.simpleMessage("no quiero una contraseña"),
        "editContact": MessageLookupByLibrary.simpleMessage("Editar contacto"),
        "emptyExportPass": MessageLookupByLibrary.simpleMessage(
            "La contraseña de cifrado no puede estar vacía"),
        "emptyImportPass": MessageLookupByLibrary.simpleMessage(
            "La contraseña no puede estar vacía"),
        "enableTestCoins":
            MessageLookupByLibrary.simpleMessage("Habilitar monedas de prueba"),
        "enablingTooManyAssetsSpan1":
            MessageLookupByLibrary.simpleMessage("Tu tienes "),
        "enablingTooManyAssetsSpan2": MessageLookupByLibrary.simpleMessage(
            " activos habilitados y tratando de habilitar "),
        "enablingTooManyAssetsSpan3": MessageLookupByLibrary.simpleMessage(
            " más. El límite máximo de activos habilitados es "),
        "enablingTooManyAssetsSpan4": MessageLookupByLibrary.simpleMessage(
            ". Desactive algunos antes de agregar otros nuevos."),
        "enablingTooManyAssetsTitle": MessageLookupByLibrary.simpleMessage(
            "Intentando habilitar demasiados activos"),
        "encryptingWallet":
            MessageLookupByLibrary.simpleMessage("Billetera cifrada"),
        "englishLanguage": MessageLookupByLibrary.simpleMessage("Inglés"),
        "enterNewPinCode":
            MessageLookupByLibrary.simpleMessage("Ingrese su nuevo PIN"),
        "enterOldPinCode":
            MessageLookupByLibrary.simpleMessage("Ingrese su antiguo PIN"),
        "enterPinCode":
            MessageLookupByLibrary.simpleMessage("Ingresa tu numero PIN"),
        "enterSeedPhrase": MessageLookupByLibrary.simpleMessage(
            "Ingrese su Semilla de 12 palabras"),
        "enterSellAmount": MessageLookupByLibrary.simpleMessage(
            "Primero debe ingresar el monto de la venta"),
        "enterpassword": MessageLookupByLibrary.simpleMessage(
            "Por favor ingrese su contraseña para continuar."),
        "errorAmountBalance": MessageLookupByLibrary.simpleMessage(
            "No hay suficiente equilibrio"),
        "errorNotAValidAddress":
            MessageLookupByLibrary.simpleMessage("No es una dirección válida"),
        "errorNotAValidAddressSegWit": MessageLookupByLibrary.simpleMessage(
            "Las direcciones de Segwit no son compatibles (todavía)"),
        "errorNotEnoughGas": m15,
        "errorTryAgain":
            MessageLookupByLibrary.simpleMessage("Error, inténtalo de nuevo"),
        "errorTryLater":
            MessageLookupByLibrary.simpleMessage("Error, intente más tarde"),
        "errorValueEmpty": MessageLookupByLibrary.simpleMessage(
            "El valor es demasiado alto o bajo"),
        "errorValueNotEmpty":
            MessageLookupByLibrary.simpleMessage("Por favor ingrese datos"),
        "estimateValue":
            MessageLookupByLibrary.simpleMessage("Valor total estimado"),
        "eulaParagraphe10": m16,
        "eulaParagraphe11": m17,
        "eulaParagraphe12": MessageLookupByLibrary.simpleMessage(
            "Al acceder o utilizar los Servicios, usted acepta que es el único responsable de su conducta al acceder y utilizar nuestros Servicios. Sin limitar la generalidad de lo anterior, usted acepta que no:\n(a) utilizará los Servicios de ninguna manera que pueda interferir, interrumpir, afectar negativamente o impedir que otros usuarios disfruten plenamente de los Servicios, o que pueda dañar, deshabilitar, sobrecargar o perjudicar el funcionamiento de nuestros Servicios de cualquier manera;\n(b) usar los Servicios para pagar, apoyar o participar en actividades ilegales, incluidas, entre otras, apuestas ilegales, fraude, lavado de dinero o actividades terroristas;\n(c) Usar cualquier robot, araña, rastreador, raspador u otro medio o interfaz automatizado no proporcionado por nosotros para acceder a nuestros Servicios o para extraer datos;\n(d) Usar o intentar usar la Cartera de otro usuario o credenciales sin autorización;\n(e) intentar eludir cualquier técnica de filtrado de contenido que empleemos, o intentar acceder a cualquier servicio o área de nuestros Servicios a los que no esté autorizado a acceder;\n(f) introducir en los Servicios cualquier virus, Troyanos, gusanos, bombas lógicas u otros elementos dañinos serie;\n(g) Desarrollar aplicaciones de terceros que interactúen con nuestros Servicios sin nuestro consentimiento previo por escrito;\n(h) Proporcionar información falsa, inexacta o engañosa; \n(i) Alentar o inducir a cualquier otra persona a participar en cualquiera de las actividades prohibidas en virtud de esta Sección.\n\n\n"),
        "eulaParagraphe13": m18,
        "eulaParagraphe14": m19,
        "eulaParagraphe15": m20,
        "eulaParagraphe16": m21,
        "eulaParagraphe17": m22,
        "eulaParagraphe18": m23,
        "eulaParagraphe19": m24,
        "eulaParagraphe2": m25,
        "eulaParagraphe3": MessageLookupByLibrary.simpleMessage(
            "Al celebrar este Acuerdo de usuario (cada sujeto que accede o utiliza el sitio) (este escrito), usted declara que es una persona mayor de edad (al menos 18 años o más) y tiene la capacidad de celebrar este Acuerdo de usuario y aceptar estar legalmente obligado por los términos y condiciones de este Acuerdo de usuario, tal como se incorpora aquí y se modifica ocasionalmente. \n\n"),
        "eulaParagraphe4": MessageLookupByLibrary.simpleMessage(
            "Podemos cambiar los términos de este Acuerdo de usuario en cualquier momento. Dichos cambios entrarán en vigencia cuando se publiquen en la aplicación o cuando utilice los Servicios.\n\n\nLea atentamente las Condiciones de uso cada vez que utilice nuestros Servicios. Su uso continuado de los Servicios significa su aceptación de estar sujeto al Acuerdo de usuario actual. Nuestra falla o demora en hacer cumplir o hacer cumplir parcialmente cualquier disposición de este Acuerdo de usuario no se interpretará como una renuncia a ninguna.\n\n"),
        "eulaParagraphe5": m26,
        "eulaParagraphe6": m27,
        "eulaParagraphe7": MessageLookupByLibrary.simpleMessage(
            "No somos responsables de las frases semilla que residen en la aplicación móvil. En ningún caso seremos responsables de ninguna pérdida de ningún tipo. Es su exclusiva responsabilidad mantener copias de seguridad adecuadas de sus cuentas y sus semillas.\n\n"),
        "eulaParagraphe8": MessageLookupByLibrary.simpleMessage(
            "No debe actuar ni abstenerse de actuar únicamente sobre la base del contenido de esta aplicación. \nSu acceso a esta aplicación no crea en sí mismo una relación de asesor-cliente entre usted y nosotros. \nEl contenido de esta aplicación no constituye una solicitud o incentivo para invertir en ningún producto o servicio financiero que ofrecemos. \nCualquier consejo incluido en esta aplicación ha sido elaborado sin tener en cuenta sus objetivos, situación financiera o necesidades. Debe considerar nuestro Aviso de divulgación de riesgos antes de tomar cualquier decisión sobre si adquirir el producto descrito en ese documento.\n\n"),
        "eulaParagraphe9": MessageLookupByLibrary.simpleMessage(
            "No garantizamos su acceso continuo a la aplicación o que su acceso o uso esté libre de errores. \nNo seremos responsables en caso de que la aplicación no esté disponible para usted por cualquier motivo (por ejemplo, debido a un tiempo de inactividad de la computadora atribuible a fallas en el funcionamiento, actualizaciones, problemas del servidor, actividades de mantenimiento preventivo o correctivo o interrupción en los suministros de telecomunicaciones). \n\n"),
        "eulaTitle1": m28,
        "eulaTitle10":
            MessageLookupByLibrary.simpleMessage("ACCESO Y SEGURIDAD\n\n"),
        "eulaTitle11": MessageLookupByLibrary.simpleMessage(
            "DERECHOS DE PROPIEDAD INTELECTUAL\n\n"),
        "eulaTitle12": MessageLookupByLibrary.simpleMessage(
            "DESCARGO DE RESPONSABILIDAD\n\n"),
        "eulaTitle13": MessageLookupByLibrary.simpleMessage(
            "DECLARACIONES Y GARANTÍAS, INDEMNIZACIÓN Y LIMITACIÓN DE RESPONSABILIDAD\n\n"),
        "eulaTitle14": MessageLookupByLibrary.simpleMessage(
            "FACTORES DE RIESGO GENERALES\n\n"),
        "eulaTitle15":
            MessageLookupByLibrary.simpleMessage("INDEMNIZACIÓN\n\n"),
        "eulaTitle16": MessageLookupByLibrary.simpleMessage(
            "DIVULGACIONES DE RIESGO RELACIONADAS CON LA CARTERA\n\n"),
        "eulaTitle17": MessageLookupByLibrary.simpleMessage(
            "SIN ASESORÍA DE INVERSIÓN NI INTERMEDIACIÓN\n\n"),
        "eulaTitle18": MessageLookupByLibrary.simpleMessage("TERMINACIÓN\n\n"),
        "eulaTitle19":
            MessageLookupByLibrary.simpleMessage("DERECHOS DE TERCEROS\n\n"),
        "eulaTitle2": MessageLookupByLibrary.simpleMessage(
            "TÉRMINOS y CONDICIONES: (ACUERDO DE USUARIO DE LA APLICACIÓN)\n\n"),
        "eulaTitle20": MessageLookupByLibrary.simpleMessage(
            "NUESTRAS OBLIGACIONES LEGALES\n\n"),
        "eulaTitle3": MessageLookupByLibrary.simpleMessage(
            "TÉRMINOS Y CONDICIONES DE USO Y EXENCIÓN DE RESPONSABILIDAD\n\n"),
        "eulaTitle4": MessageLookupByLibrary.simpleMessage("USO GENERAL\n\n"),
        "eulaTitle5":
            MessageLookupByLibrary.simpleMessage("MODIFICACIONES\n\n"),
        "eulaTitle6":
            MessageLookupByLibrary.simpleMessage("LIMITACIONES DE USO\n\n"),
        "eulaTitle7":
            MessageLookupByLibrary.simpleMessage("Cuentas y membresía\n\n"),
        "eulaTitle8":
            MessageLookupByLibrary.simpleMessage("Copias de Seguridad\n\n"),
        "eulaTitle9":
            MessageLookupByLibrary.simpleMessage("ADVERTENCIA GENERAL\n\n"),
        "exampleHintSeed": MessageLookupByLibrary.simpleMessage(
            "Ejemplo: compilar nivel de caso..."),
        "exchangeExpedient": MessageLookupByLibrary.simpleMessage("Expediente"),
        "exchangeExpensive": MessageLookupByLibrary.simpleMessage("Caro"),
        "exchangeIdentical":
            MessageLookupByLibrary.simpleMessage("Identico a CEX"),
        "exchangeTitle": MessageLookupByLibrary.simpleMessage("INTERCAMBIO"),
        "exportButton": MessageLookupByLibrary.simpleMessage("Exportar"),
        "exportContactsTitle":
            MessageLookupByLibrary.simpleMessage("Contactos"),
        "exportDesc": MessageLookupByLibrary.simpleMessage(
            "Seleccione elementos para exportar a un archivo cifrado."),
        "exportLink": MessageLookupByLibrary.simpleMessage("Exportar"),
        "exportNotesTitle": MessageLookupByLibrary.simpleMessage("Notas"),
        "exportSuccessTitle": MessageLookupByLibrary.simpleMessage(
            "Los elementos se han exportado correctamente:"),
        "exportSwapsTitle":
            MessageLookupByLibrary.simpleMessage("Intercambios"),
        "exportTitle": MessageLookupByLibrary.simpleMessage("Exportar"),
        "fakeBalanceAmt":
            MessageLookupByLibrary.simpleMessage("Cantidad de saldo falso:"),
        "faqTitle":
            MessageLookupByLibrary.simpleMessage("Preguntas frecuentes"),
        "faucetError": MessageLookupByLibrary.simpleMessage("Error"),
        "faucetInProgress": m29,
        "faucetName": MessageLookupByLibrary.simpleMessage("GRIFO"),
        "faucetSuccess": MessageLookupByLibrary.simpleMessage("Éxito"),
        "faucetTimedOut":
            MessageLookupByLibrary.simpleMessage("Tiempo de espera agotado"),
        "feedNewsTab": MessageLookupByLibrary.simpleMessage("Noticias"),
        "feedNotFound": MessageLookupByLibrary.simpleMessage("Nada aquí"),
        "feedNotifTitle": m30,
        "feedReadMore": MessageLookupByLibrary.simpleMessage("Leer más..."),
        "feedTab": MessageLookupByLibrary.simpleMessage("Informacion"),
        "feedTitle": MessageLookupByLibrary.simpleMessage("Noticias"),
        "feedUnableToProceed": MessageLookupByLibrary.simpleMessage(
            "No se puede continuar con la actualización de noticias"),
        "feedUnableToUpdate": MessageLookupByLibrary.simpleMessage(
            "No se puede obtener la actualización de noticias"),
        "feedUpToDate":
            MessageLookupByLibrary.simpleMessage("Ya está actualizado"),
        "feedUpdated": MessageLookupByLibrary.simpleMessage(
            "Fuente de noticias actualizada"),
        "feedback": MessageLookupByLibrary.simpleMessage(
            "Compartir archivo de registro"),
        "filtersAll": MessageLookupByLibrary.simpleMessage("Todo"),
        "filtersButton": MessageLookupByLibrary.simpleMessage("Filtro"),
        "filtersClearAll":
            MessageLookupByLibrary.simpleMessage("Borrar todos los filtros"),
        "filtersFailed": MessageLookupByLibrary.simpleMessage("Fallido"),
        "filtersFrom":
            MessageLookupByLibrary.simpleMessage("Partir de la fecha"),
        "filtersMaker": MessageLookupByLibrary.simpleMessage("Vendedor"),
        "filtersReceive":
            MessageLookupByLibrary.simpleMessage("Recibir moneda"),
        "filtersSell": MessageLookupByLibrary.simpleMessage("Vender moneda"),
        "filtersStatus": MessageLookupByLibrary.simpleMessage("Estado"),
        "filtersSuccessful": MessageLookupByLibrary.simpleMessage("Exitoso"),
        "filtersTaker": MessageLookupByLibrary.simpleMessage("Comprador"),
        "filtersTo": MessageLookupByLibrary.simpleMessage("Hasta la fecha"),
        "filtersType":
            MessageLookupByLibrary.simpleMessage("Comprador/Vendedor"),
        "frenchLanguage": MessageLookupByLibrary.simpleMessage("Francés"),
        "from": MessageLookupByLibrary.simpleMessage("Desde"),
        "gasLimit": MessageLookupByLibrary.simpleMessage("Limite de Gas"),
        "gasPrice": MessageLookupByLibrary.simpleMessage("Precio de Gas"),
        "generalPinNotActive": MessageLookupByLibrary.simpleMessage(
            "La protección general con PIN no está activa.\nEl modo de camuflaje no estará disponible.\nActive la protección con PIN."),
        "getBackupPhrase": MessageLookupByLibrary.simpleMessage(
            "Importante: ¡Haz una copia de seguridad de tu frase inicial antes de continuar!"),
        "goToPorfolio":
            MessageLookupByLibrary.simpleMessage("Ir al portafolio"),
        "helpLink": MessageLookupByLibrary.simpleMessage("Ayuda"),
        "helpTitle": MessageLookupByLibrary.simpleMessage("Ayuda y apoyo"),
        "hideBalance": MessageLookupByLibrary.simpleMessage("Ocultar saldos"),
        "hintConfirmPassword":
            MessageLookupByLibrary.simpleMessage("Confirmar contraseña"),
        "hintCreatePassword":
            MessageLookupByLibrary.simpleMessage("Crear contraseña"),
        "hintCurrentPassword":
            MessageLookupByLibrary.simpleMessage("Contraseña actual"),
        "hintEnterPassword":
            MessageLookupByLibrary.simpleMessage("Ingresa tu contraseña"),
        "hintEnterSeedPhrase":
            MessageLookupByLibrary.simpleMessage("Ingrese su frase inicial"),
        "hintNameYourWallet":
            MessageLookupByLibrary.simpleMessage("Nombra tu billetera"),
        "hintPassword": MessageLookupByLibrary.simpleMessage("Clave"),
        "history": MessageLookupByLibrary.simpleMessage("historia"),
        "hours": MessageLookupByLibrary.simpleMessage("h"),
        "hungarianLanguage": MessageLookupByLibrary.simpleMessage("Húngaro"),
        "iUnderstand": MessageLookupByLibrary.simpleMessage("Entiendo"),
        "importButton": MessageLookupByLibrary.simpleMessage("Importar"),
        "importDecryptError": MessageLookupByLibrary.simpleMessage(
            "Contraseña no válida o datos dañados"),
        "importDesc":
            MessageLookupByLibrary.simpleMessage("Elementos a importar:"),
        "importFileNotFound":
            MessageLookupByLibrary.simpleMessage("Archivo no encontrado"),
        "importInvalidSwapData": MessageLookupByLibrary.simpleMessage(
            "Datos de intercambio no válidos. Proporcione un archivo JSON de estado de intercambio válido."),
        "importLink": MessageLookupByLibrary.simpleMessage("Importar"),
        "importLoadDesc": MessageLookupByLibrary.simpleMessage(
            "Seleccione el archivo cifrado para importar."),
        "importLoadSwapDesc": MessageLookupByLibrary.simpleMessage(
            "Seleccione el archivo de intercambio de texto sin formato para importar."),
        "importLoading": MessageLookupByLibrary.simpleMessage("Abriendo..."),
        "importPassCancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "importPassOk": MessageLookupByLibrary.simpleMessage("Ok"),
        "importPassword": MessageLookupByLibrary.simpleMessage("Clave"),
        "importSingleSwapLink":
            MessageLookupByLibrary.simpleMessage("Importar un Intercambio"),
        "importSingleSwapTitle":
            MessageLookupByLibrary.simpleMessage("Importar Intercambio"),
        "importSomeItemsSkippedWarning": MessageLookupByLibrary.simpleMessage(
            "Se han saltado algunos elementos"),
        "importSuccessTitle": MessageLookupByLibrary.simpleMessage(
            "Los elementos se han importado correctamente:"),
        "importSwapFailed": MessageLookupByLibrary.simpleMessage(
            "No se pudo importar el intercambio"),
        "importSwapJsonDecodingError": MessageLookupByLibrary.simpleMessage(
            "Error al decodificar el archivo json"),
        "importTitle": MessageLookupByLibrary.simpleMessage("Importar"),
        "infoPasswordDialog": MessageLookupByLibrary.simpleMessage(
            "Utilice una contraseña segura y no la almacene en el mismo dispositivo"),
        "infoTrade1": MessageLookupByLibrary.simpleMessage(
            "¡La solicitud de intercambio no se puede deshacer y es un evento final!"),
        "infoTrade2": MessageLookupByLibrary.simpleMessage(
            "El intercambio puede tardar hasta 60 minutos. ¡NO cierres esta aplicación!"),
        "infoWalletPassword": MessageLookupByLibrary.simpleMessage(
            "Debe proporcionar una contraseña para el cifrado de la billetera por razones de seguridad."),
        "insufficientText": MessageLookupByLibrary.simpleMessage(
            "El volumen mínimo requerido por este pedido es"),
        "insufficientTitle":
            MessageLookupByLibrary.simpleMessage("Volumen insuficiente"),
        "internetRefreshButton":
            MessageLookupByLibrary.simpleMessage("Actualizar"),
        "internetRestored": MessageLookupByLibrary.simpleMessage(
            "Conexión a Internet restaurada"),
        "invalidSwap": MessageLookupByLibrary.simpleMessage(
            "No se puede continuar con el intercambio"),
        "invalidSwapDetailsLink":
            MessageLookupByLibrary.simpleMessage("Detalles"),
        "japaneseLanguage": MessageLookupByLibrary.simpleMessage("Japonés"),
        "language": MessageLookupByLibrary.simpleMessage("Idioma"),
        "legalTitle": MessageLookupByLibrary.simpleMessage("Legal"),
        "loading": MessageLookupByLibrary.simpleMessage("Cargando..."),
        "loadingOrderbook": MessageLookupByLibrary.simpleMessage(
            "Cargando libro de ordenes..."),
        "lockScreen":
            MessageLookupByLibrary.simpleMessage("La pantalla está bloqueada"),
        "lockScreenAuth":
            MessageLookupByLibrary.simpleMessage("¡Por favor, autentícate!"),
        "login": MessageLookupByLibrary.simpleMessage("acceso"),
        "logout": MessageLookupByLibrary.simpleMessage("Cerrar sesión"),
        "logoutOnExit":
            MessageLookupByLibrary.simpleMessage("Cerrar sesión al salir"),
        "logoutWarning": MessageLookupByLibrary.simpleMessage(
            "¿Estás seguro de que quieres cerrar sesión ahora?"),
        "logoutsettings": MessageLookupByLibrary.simpleMessage(
            "Configuración de cierre de sesión"),
        "makeAorder": MessageLookupByLibrary.simpleMessage("hacer un pedido"),
        "makerDetailsCancel":
            MessageLookupByLibrary.simpleMessage("Cancelar orden"),
        "makerDetailsCreated":
            MessageLookupByLibrary.simpleMessage("Createdo en"),
        "makerDetailsFor": MessageLookupByLibrary.simpleMessage("Recibir"),
        "makerDetailsId": MessageLookupByLibrary.simpleMessage("ID de Orden"),
        "makerDetailsNoSwaps": MessageLookupByLibrary.simpleMessage(
            "Este pedido no inició intercambios"),
        "makerDetailsPrice": MessageLookupByLibrary.simpleMessage("Precio"),
        "makerDetailsSell": MessageLookupByLibrary.simpleMessage("Vender"),
        "makerDetailsSwaps": MessageLookupByLibrary.simpleMessage(
            "Intercambios iniciados por este pedido"),
        "makerDetailsTitle": MessageLookupByLibrary.simpleMessage(
            "Detalles del pedido del fabricante"),
        "makerOrder": MessageLookupByLibrary.simpleMessage("Orden de Vendedor"),
        "marketplace": MessageLookupByLibrary.simpleMessage("Mercado"),
        "marketsChart": MessageLookupByLibrary.simpleMessage("Gráfico"),
        "marketsDepth": MessageLookupByLibrary.simpleMessage("Profundidad"),
        "marketsNoAsks": MessageLookupByLibrary.simpleMessage(
            "No se encontraron solicitudes"),
        "marketsNoBids":
            MessageLookupByLibrary.simpleMessage("No se encontraron ofertas"),
        "marketsOrderDetails":
            MessageLookupByLibrary.simpleMessage("Detalles del Pedido"),
        "marketsOrderbook":
            MessageLookupByLibrary.simpleMessage("LIBRO DE ORDENES"),
        "marketsPrice": MessageLookupByLibrary.simpleMessage("PRECIO"),
        "marketsSelectCoins": MessageLookupByLibrary.simpleMessage(
            "Por favor seleccione monedas"),
        "marketsTab": MessageLookupByLibrary.simpleMessage("Mercados"),
        "marketsTitle": MessageLookupByLibrary.simpleMessage("MERCADOS"),
        "matchExportPass": MessageLookupByLibrary.simpleMessage(
            "Las contraseñas deben coincidir"),
        "matchingCamoChange": MessageLookupByLibrary.simpleMessage("Cambiar"),
        "matchingCamoPinError": MessageLookupByLibrary.simpleMessage(
            "Su PIN general y el PIN de camuflaje son los mismos.\nEl modo de camuflaje no estará disponible.\nCambie el PIN de camuflaje."),
        "matchingCamoTitle":
            MessageLookupByLibrary.simpleMessage("PIN Invalido"),
        "max": MessageLookupByLibrary.simpleMessage("MAXIMO"),
        "media": MessageLookupByLibrary.simpleMessage("Noticias"),
        "mediaBrowse": MessageLookupByLibrary.simpleMessage("NAVEGAR"),
        "mediaBrowseFeed": MessageLookupByLibrary.simpleMessage("NAVEGAR RSS"),
        "mediaBy": MessageLookupByLibrary.simpleMessage("By"),
        "mediaNotSavedDescription": MessageLookupByLibrary.simpleMessage(
            "NO TIENES ARTÍCULOS GUARDADOS"),
        "mediaSaved": MessageLookupByLibrary.simpleMessage("GUARDADO"),
        "milliseconds": MessageLookupByLibrary.simpleMessage("ms"),
        "minValue": m31,
        "minValueBuy": m32,
        "minValueOrder": m33,
        "minValueSell": m34,
        "minVolumeIsTDH": MessageLookupByLibrary.simpleMessage(
            "Debe ser menor que el monto de venta"),
        "minVolumeTitle":
            MessageLookupByLibrary.simpleMessage("Volumen mínimo requerido"),
        "minVolumeToggle": MessageLookupByLibrary.simpleMessage(
            "Usar volumen mínimo personalizado"),
        "minutes": MessageLookupByLibrary.simpleMessage("m"),
        "mobileDataWarning": m35,
        "moreTab": MessageLookupByLibrary.simpleMessage("Mas"),
        "multiActivateGas": m36,
        "multiBaseAmtPlaceholder":
            MessageLookupByLibrary.simpleMessage("Cantidad"),
        "multiBasePlaceholder": MessageLookupByLibrary.simpleMessage("Moneda"),
        "multiBaseSelectTitle": MessageLookupByLibrary.simpleMessage("Vender"),
        "multiConfirmCancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "multiConfirmConfirm":
            MessageLookupByLibrary.simpleMessage("Confirmar"),
        "multiCreate": MessageLookupByLibrary.simpleMessage("Crear"),
        "multiCreateOrder": MessageLookupByLibrary.simpleMessage("Orden"),
        "multiCreateOrders": MessageLookupByLibrary.simpleMessage("Ordenes"),
        "multiEthFee": MessageLookupByLibrary.simpleMessage("costo"),
        "multiFiatCancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "multiFiatDesc": MessageLookupByLibrary.simpleMessage(
            "Ingrese la cantidad de dinero para recibir:"),
        "multiFiatFill": MessageLookupByLibrary.simpleMessage("Autollenarl"),
        "multiFixErrors": MessageLookupByLibrary.simpleMessage(
            "Corrija todos los errores antes de continuar"),
        "multiInvalidAmt":
            MessageLookupByLibrary.simpleMessage("Monto invalido"),
        "multiInvalidSellAmt":
            MessageLookupByLibrary.simpleMessage("Cantidad de venta no válido"),
        "multiMaxSellAmt": MessageLookupByLibrary.simpleMessage(
            "La cantidad máxima de venta es"),
        "multiMinReceiveAmt": MessageLookupByLibrary.simpleMessage(
            "La cantidad mínima recibida es"),
        "multiMinSellAmt": MessageLookupByLibrary.simpleMessage(
            "La cantidad mínima de venta es"),
        "multiReceiveTitle": MessageLookupByLibrary.simpleMessage("Recibir:"),
        "multiSellTitle": MessageLookupByLibrary.simpleMessage("Vender:"),
        "multiTab": MessageLookupByLibrary.simpleMessage("Multi"),
        "multiTableAmt": MessageLookupByLibrary.simpleMessage("Recibir Cntd."),
        "multiTablePrice": MessageLookupByLibrary.simpleMessage("Precio/CEX"),
        "networkFee": MessageLookupByLibrary.simpleMessage("Tarifa de red"),
        "newAccount": MessageLookupByLibrary.simpleMessage("nueva cuenta"),
        "newAccountUpper": MessageLookupByLibrary.simpleMessage("Nueva Cuenta"),
        "newsFeed": MessageLookupByLibrary.simpleMessage("Noticias"),
        "next": MessageLookupByLibrary.simpleMessage("próximo"),
        "noArticles": MessageLookupByLibrary.simpleMessage(
            "No hay noticias. Vuelva a consultar más tarde."),
        "noCoinFound": MessageLookupByLibrary.simpleMessage(
            "No se encontró ninguna moneda"),
        "noFunds": MessageLookupByLibrary.simpleMessage("Sin Fondos"),
        "noFundsDetected": MessageLookupByLibrary.simpleMessage(
            "No hay fondos disponibles, por favor deposite."),
        "noInternet":
            MessageLookupByLibrary.simpleMessage("Sin conexión a Internet"),
        "noItemsToExport": MessageLookupByLibrary.simpleMessage(
            "No hay artículos seleccionados"),
        "noItemsToImport": MessageLookupByLibrary.simpleMessage(
            "No hay artículos seleccionados"),
        "noMatchingOrders": MessageLookupByLibrary.simpleMessage(
            "No se encontraron pedidos coincidentes"),
        "noOrder": m37,
        "noOrderAvailable": MessageLookupByLibrary.simpleMessage(
            "Haga clic para crear un pedido"),
        "noRewardYet": MessageLookupByLibrary.simpleMessage(
            "No se puede reclamar ninguna recompensa. Vuelva a intentarlo en 1 hora."),
        "noRewards": MessageLookupByLibrary.simpleMessage(
            "No hay recompensas reclamables"),
        "noSuchCoin": MessageLookupByLibrary.simpleMessage("No hay tal moneda"),
        "noSwaps": MessageLookupByLibrary.simpleMessage("No historia."),
        "noTxs": MessageLookupByLibrary.simpleMessage("Sin transacciones"),
        "nonNumericInput":
            MessageLookupByLibrary.simpleMessage("El valor debe ser numérico."),
        "notEnoughtBalanceForFee": MessageLookupByLibrary.simpleMessage(
            "No hay suficiente saldo para las tarifas: opere con una cantidad menor"),
        "notePlaceholder": MessageLookupByLibrary.simpleMessage("Añadir Nota"),
        "noteTitle": MessageLookupByLibrary.simpleMessage("Nota"),
        "nothingFound": MessageLookupByLibrary.simpleMessage("Nada Encontrado"),
        "notifSwapCompletedTitle":
            MessageLookupByLibrary.simpleMessage("Intercambio completado"),
        "notifSwapFailedTitle":
            MessageLookupByLibrary.simpleMessage("Intercambio fallido"),
        "notifSwapStartedTitle":
            MessageLookupByLibrary.simpleMessage("Nuevo intercambio iniciado"),
        "notifSwapStatusTitle":
            MessageLookupByLibrary.simpleMessage("Cambio de estado cambiado"),
        "notifSwapTimeoutTitle": MessageLookupByLibrary.simpleMessage(
            "Se agotó el tiempo de intercambio"),
        "notifTxText": m38,
        "notifTxTitle":
            MessageLookupByLibrary.simpleMessage("Transaccion entrante"),
        "okButton": MessageLookupByLibrary.simpleMessage("Ok"),
        "oldLogsDelete": MessageLookupByLibrary.simpleMessage("Borrar"),
        "oldLogsTitle":
            MessageLookupByLibrary.simpleMessage("Registros antiguos"),
        "oldLogsUsed": MessageLookupByLibrary.simpleMessage("Espacio usado"),
        "orderCancel": m39,
        "orderCreated": MessageLookupByLibrary.simpleMessage("Pedido creado"),
        "orderCreatedInfo":
            MessageLookupByLibrary.simpleMessage("Pedido creado con éxito"),
        "orderDetailsAddress":
            MessageLookupByLibrary.simpleMessage("Direccion"),
        "orderDetailsCancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "orderDetailsExpedient": m40,
        "orderDetailsExpensive": m41,
        "orderDetailsFor": MessageLookupByLibrary.simpleMessage("for"),
        "orderDetailsIdentical":
            MessageLookupByLibrary.simpleMessage("Idéntico a CEX"),
        "orderDetailsMin": MessageLookupByLibrary.simpleMessage("min."),
        "orderDetailsPrice": MessageLookupByLibrary.simpleMessage("Precio"),
        "orderDetailsReceive": MessageLookupByLibrary.simpleMessage("Recibir"),
        "orderDetailsSelect":
            MessageLookupByLibrary.simpleMessage("Seleccione"),
        "orderDetailsSells": MessageLookupByLibrary.simpleMessage("Ventas"),
        "orderDetailsSettings": MessageLookupByLibrary.simpleMessage(
            "Abra detalles con un solo toque y seleccione Ordenar con un toque largo"),
        "orderDetailsSpend": MessageLookupByLibrary.simpleMessage("Gastar"),
        "orderDetailsTitle": MessageLookupByLibrary.simpleMessage("Detalles"),
        "orderFilled": m42,
        "orderMatched":
            MessageLookupByLibrary.simpleMessage("Orden Triangulada"),
        "orderMatching":
            MessageLookupByLibrary.simpleMessage("Triangulación de órdenes"),
        "orderTypePartial": MessageLookupByLibrary.simpleMessage(" Orden"),
        "orderTypeUnknown":
            MessageLookupByLibrary.simpleMessage("Orden desconocida"),
        "orders": MessageLookupByLibrary.simpleMessage("ordenes"),
        "ordersActive": MessageLookupByLibrary.simpleMessage("Activo"),
        "ordersHistory": MessageLookupByLibrary.simpleMessage("Historial"),
        "ordersTableAmount": m43,
        "ordersTableTotal": m44,
        "ownOrder":
            MessageLookupByLibrary.simpleMessage(" Esta es tu propia orden!"),
        "paidWith": MessageLookupByLibrary.simpleMessage("Pagado con "),
        "paymentUriDetailsAccept":
            MessageLookupByLibrary.simpleMessage("Pagar"),
        "paymentUriDetailsAcceptQuestion":
            MessageLookupByLibrary.simpleMessage("¿Acepta esta transacción?"),
        "paymentUriDetailsAddressSpan":
            MessageLookupByLibrary.simpleMessage("A Direccion "),
        "paymentUriDetailsAmountSpan":
            MessageLookupByLibrary.simpleMessage("Monto: "),
        "paymentUriDetailsCoinSpan":
            MessageLookupByLibrary.simpleMessage("Moneda: "),
        "paymentUriDetailsDeny":
            MessageLookupByLibrary.simpleMessage("Cancelar"),
        "paymentUriDetailsTitle":
            MessageLookupByLibrary.simpleMessage("Pago solicitado"),
        "paymentUriInactiveCoin": m45,
        "placeOrder": MessageLookupByLibrary.simpleMessage("Haga su pedido"),
        "portfolio": MessageLookupByLibrary.simpleMessage("Portfolio"),
        "price": MessageLookupByLibrary.simpleMessage("price"),
        "privateKey": MessageLookupByLibrary.simpleMessage("Llave Privada"),
        "privateKeys": MessageLookupByLibrary.simpleMessage("Llaves Privadas"),
        "protectionCtrlConfirmations":
            MessageLookupByLibrary.simpleMessage("Confirmaciones"),
        "protectionCtrlCustom": MessageLookupByLibrary.simpleMessage(
            "Usar configuraciones de protección personalizadas"),
        "protectionCtrlOff":
            MessageLookupByLibrary.simpleMessage("DESACTIVADO"),
        "protectionCtrlOn": MessageLookupByLibrary.simpleMessage("ACTIVADO"),
        "protectionCtrlWarning": MessageLookupByLibrary.simpleMessage(
            "Advertencia, este intercambio atómico no está protegido por dPoW. "),
        "pubkey": MessageLookupByLibrary.simpleMessage("Llave Publica"),
        "question_1": MessageLookupByLibrary.simpleMessage(
            "¿Guardás mis llaves privadas?"),
        "question_10": m46,
        "question_2": m47,
        "question_3": MessageLookupByLibrary.simpleMessage(
            "¿Cuánto tiempo toma cada intercambio atómico?"),
        "question_4": MessageLookupByLibrary.simpleMessage(
            "¿Necesito estar en línea durante la duración del intercambio?"),
        "question_5": m48,
        "question_6": MessageLookupByLibrary.simpleMessage(
            "¿Ofrecen soporte al usuario?"),
        "question_7": MessageLookupByLibrary.simpleMessage(
            "¿Tiene restricciones de país?"),
        "question_8": m49,
        "question_9": m50,
        "receive": MessageLookupByLibrary.simpleMessage("RECIBIR"),
        "receiveLower": MessageLookupByLibrary.simpleMessage("Recibir"),
        "recommendSeedMessage": MessageLookupByLibrary.simpleMessage(
            "Recomendamos almacenarlo fuera de línea."),
        "remove": MessageLookupByLibrary.simpleMessage("Desactivar"),
        "requestedTrade":
            MessageLookupByLibrary.simpleMessage("Comercio solicitado"),
        "reset": MessageLookupByLibrary.simpleMessage("RESETEAR"),
        "resetTitle":
            MessageLookupByLibrary.simpleMessage("Restablecer formulario"),
        "restoreWallet": MessageLookupByLibrary.simpleMessage("RESTAURAR"),
        "rewardsButton":
            MessageLookupByLibrary.simpleMessage("Reclama tus recompensas"),
        "rewardsCancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "rewardsError": MessageLookupByLibrary.simpleMessage(
            "Algo salió mal. Por favor, inténtelo de nuevo más tarde."),
        "rewardsInProgressLong": MessageLookupByLibrary.simpleMessage(
            "La transacción está en curso"),
        "rewardsInProgressShort":
            MessageLookupByLibrary.simpleMessage("procesando"),
        "rewardsLowAmountLong": MessageLookupByLibrary.simpleMessage(
            "Cantidad de UTXO inferior a 10 KMD"),
        "rewardsLowAmountShort":
            MessageLookupByLibrary.simpleMessage("<10 KMD"),
        "rewardsOneHourLong":
            MessageLookupByLibrary.simpleMessage("Aún no ha pasado una hora"),
        "rewardsOneHourShort": MessageLookupByLibrary.simpleMessage("<1 hora"),
        "rewardsPopupOk": MessageLookupByLibrary.simpleMessage("Ok"),
        "rewardsPopupTitle":
            MessageLookupByLibrary.simpleMessage("Estado de recompensas:"),
        "rewardsReadMore": MessageLookupByLibrary.simpleMessage(
            "Obtenga más información sobre las recompensas para usuarios activos de KMD"),
        "rewardsReceive": MessageLookupByLibrary.simpleMessage("Recibir"),
        "rewardsTableFiat": MessageLookupByLibrary.simpleMessage("Fiat"),
        "rewardsTableRewards":
            MessageLookupByLibrary.simpleMessage("Recompensas,\nKMD"),
        "rewardsTableStatus": MessageLookupByLibrary.simpleMessage("Estado"),
        "rewardsTableTime":
            MessageLookupByLibrary.simpleMessage("Tiempo restante"),
        "rewardsTableTitle":
            MessageLookupByLibrary.simpleMessage("Información de recompensas:"),
        "rewardsTableUXTO":
            MessageLookupByLibrary.simpleMessage("UTXO cantidad,\nKMD"),
        "rewardsTimeDays": m51,
        "rewardsTimeHours": m52,
        "rewardsTimeMin": m53,
        "rewardsTitle":
            MessageLookupByLibrary.simpleMessage("Información de recompensas"),
        "russianLanguage": MessageLookupByLibrary.simpleMessage("Ruso"),
        "searchFilterCoin":
            MessageLookupByLibrary.simpleMessage("Buscar una moneda"),
        "searchFilterSubtitleBEP": MessageLookupByLibrary.simpleMessage(
            "Seleccionar todos los tokens BEP"),
        "searchFilterSubtitleERC": MessageLookupByLibrary.simpleMessage(
            "Seleccionar todos los tokens ERC"),
        "searchFilterSubtitleQRC": MessageLookupByLibrary.simpleMessage(
            "Seleccionar todos los tokens QRC"),
        "searchFilterSubtitleSmartChain": MessageLookupByLibrary.simpleMessage(
            "Seleccione todos los SmartChains"),
        "searchFilterSubtitleTestCoins": MessageLookupByLibrary.simpleMessage(
            "Seleccionar todos los activos de prueba"),
        "searchFilterSubtitleutxo": MessageLookupByLibrary.simpleMessage(
            "Seleccione todas las monedas UTXO"),
        "seconds": MessageLookupByLibrary.simpleMessage("s"),
        "security": MessageLookupByLibrary.simpleMessage("Seguridad"),
        "seedPhrase": MessageLookupByLibrary.simpleMessage("Frase Semilla"),
        "seedPhraseTitle":
            MessageLookupByLibrary.simpleMessage("Tu nueva frase semilla"),
        "selectCoin":
            MessageLookupByLibrary.simpleMessage("Seleccionar moneda"),
        "selectCoinInfo": MessageLookupByLibrary.simpleMessage(
            "Seleccione las monedas que desea agregar a su cartera."),
        "selectCoinTitle":
            MessageLookupByLibrary.simpleMessage("Activar monedas:"),
        "selectCoinToBuy": MessageLookupByLibrary.simpleMessage(
            "Seleccione la moneda que desea COMPRAR"),
        "selectCoinToSell": MessageLookupByLibrary.simpleMessage(
            "Seleccione la moneda que desea VENDER"),
        "selectFileImport":
            MessageLookupByLibrary.simpleMessage("Seleccione Archivo"),
        "selectPaymentMethod":
            MessageLookupByLibrary.simpleMessage("Selecciona tu forma de pago"),
        "sell": MessageLookupByLibrary.simpleMessage("Vender"),
        "sellTestCoinWarning": MessageLookupByLibrary.simpleMessage(
            "¡Advertencia, estás dispuesto a vender monedas de prueba SIN valor real!"),
        "send": MessageLookupByLibrary.simpleMessage("ENVIAR"),
        "setUpPassword":
            MessageLookupByLibrary.simpleMessage("CONFIGURAR UNA CONTRASEÑA"),
        "settingDialogSpan1": MessageLookupByLibrary.simpleMessage(
            "Estás seguro de que quieres eliminar "),
        "settingDialogSpan2":
            MessageLookupByLibrary.simpleMessage(" billetera?"),
        "settingDialogSpan3":
            MessageLookupByLibrary.simpleMessage("Si es así, asegúrese de "),
        "settingDialogSpan4":
            MessageLookupByLibrary.simpleMessage(" guardar su frase inicial."),
        "settingDialogSpan5": MessageLookupByLibrary.simpleMessage(
            " Para restaurar su billetera en el futuro."),
        "settingLanguageTitle": MessageLookupByLibrary.simpleMessage("Idiomas"),
        "settings": MessageLookupByLibrary.simpleMessage("Ajustes"),
        "share": MessageLookupByLibrary.simpleMessage("Compartir"),
        "showMyOrders":
            MessageLookupByLibrary.simpleMessage("Mostrar mis pedidos"),
        "signInWithPassword": MessageLookupByLibrary.simpleMessage(
            "Iniciar sesión con contraseña"),
        "signInWithSeedPhrase": MessageLookupByLibrary.simpleMessage(
            "¿Olvidó la contraseña? Restaurar billetera desde semilla"),
        "simpleTradeActivate": MessageLookupByLibrary.simpleMessage("Activar"),
        "simpleTradeBuyHint": m54,
        "simpleTradeBuyTitle": MessageLookupByLibrary.simpleMessage("Comprar"),
        "simpleTradeClose": MessageLookupByLibrary.simpleMessage("Cerrar"),
        "simpleTradeMaxActiveCoins": m55,
        "simpleTradeNotActive": m56,
        "simpleTradeRecieve": MessageLookupByLibrary.simpleMessage("Recibir"),
        "simpleTradeSellHint": m57,
        "simpleTradeSellTitle": MessageLookupByLibrary.simpleMessage("Vender"),
        "simpleTradeSend": MessageLookupByLibrary.simpleMessage("Enviar"),
        "simpleTradeShowLess":
            MessageLookupByLibrary.simpleMessage("Muestra menos"),
        "simpleTradeShowMore":
            MessageLookupByLibrary.simpleMessage("Mostrar mas"),
        "snackbarDismiss": MessageLookupByLibrary.simpleMessage("Descartar"),
        "soundCantPlayThatMsg": m58,
        "soundSettingsLink": MessageLookupByLibrary.simpleMessage("Sonido"),
        "soundSettingsTitle":
            MessageLookupByLibrary.simpleMessage("Ajustes de sonido"),
        "soundsDialogTitle": MessageLookupByLibrary.simpleMessage("Sonidos"),
        "soundsDoNotShowAgain": MessageLookupByLibrary.simpleMessage(
            "Entendido, no lo muestres más."),
        "soundsExplanation": MessageLookupByLibrary.simpleMessage(
            "Escuchará notificaciones de sonido durante el proceso de intercambio y cuando tenga un pedido de fabricante activo.\nEl protocolo de intercambios atómicos requiere que los participantes estén en línea para un intercambio exitoso, y las notificaciones de sonido ayudan a lograrlo."),
        "soundsNote": MessageLookupByLibrary.simpleMessage(
            "Tenga en cuenta que puede configurar sus sonidos personalizados en la configuración de la aplicación."),
        "step": MessageLookupByLibrary.simpleMessage("Paso"),
        "success": MessageLookupByLibrary.simpleMessage("¡Éxito!"),
        "support": MessageLookupByLibrary.simpleMessage("Apoyo"),
        "supportLinksDesc": m59,
        "swap": MessageLookupByLibrary.simpleMessage("intercambio"),
        "swapCurrent": MessageLookupByLibrary.simpleMessage("Actual"),
        "swapDetailTitle": MessageLookupByLibrary.simpleMessage(
            "CONFIRMAR DETALLES DE CAMBIO"),
        "swapEstimated": MessageLookupByLibrary.simpleMessage("Estimado"),
        "swapFailed":
            MessageLookupByLibrary.simpleMessage("Intercambio fallido"),
        "swapGasActivate": m60,
        "swapGasAmount": m61,
        "swapOngoing":
            MessageLookupByLibrary.simpleMessage("Intercambio en curso"),
        "swapProgress":
            MessageLookupByLibrary.simpleMessage("Detalles del Progreso"),
        "swapStarted": MessageLookupByLibrary.simpleMessage("Iniciado"),
        "swapSucceful":
            MessageLookupByLibrary.simpleMessage("Intercambio exitoso"),
        "swapTotal": MessageLookupByLibrary.simpleMessage("Total"),
        "swapUUID": MessageLookupByLibrary.simpleMessage("Intercambiar UUID"),
        "switchTheme": MessageLookupByLibrary.simpleMessage("Cambiar Tema"),
        "tagBEP20": MessageLookupByLibrary.simpleMessage("BEP20"),
        "tagERC20": MessageLookupByLibrary.simpleMessage("ERC20"),
        "tagKMD": MessageLookupByLibrary.simpleMessage("KMD"),
        "tagQRC20": MessageLookupByLibrary.simpleMessage("QRC20"),
        "takerOrder":
            MessageLookupByLibrary.simpleMessage("Orden de Comprador"),
        "timeOut": MessageLookupByLibrary.simpleMessage("Se acabó el tiempo"),
        "titleCreatePassword":
            MessageLookupByLibrary.simpleMessage("CREA UNA CONTRASEÑA"),
        "titleCurrentAsk":
            MessageLookupByLibrary.simpleMessage("Pedido seleccionado"),
        "to": MessageLookupByLibrary.simpleMessage("Para"),
        "toAddress": MessageLookupByLibrary.simpleMessage("Hacia:"),
        "tooManyAssetsEnabledSpan1":
            MessageLookupByLibrary.simpleMessage("Tu tienes "),
        "tooManyAssetsEnabledSpan2": MessageLookupByLibrary.simpleMessage(
            " activos habilitados. El límite máximo de activos habilitados es "),
        "tooManyAssetsEnabledSpan3": MessageLookupByLibrary.simpleMessage(
            ". Desactive algunos antes de agregar otros nuevos."),
        "tooManyAssetsEnabledTitle": MessageLookupByLibrary.simpleMessage(
            "Demasiados recursos habilitados"),
        "trade": MessageLookupByLibrary.simpleMessage("INTERCAMBIO"),
        "tradeCompleted":
            MessageLookupByLibrary.simpleMessage("¡CAMBIO COMPLETADO!"),
        "tradeDetail":
            MessageLookupByLibrary.simpleMessage("DETALLES INTERCAMBIO"),
        "tradePreimageError": MessageLookupByLibrary.simpleMessage(
            "Error al calcular las tarifas comerciales"),
        "tradingFee":
            MessageLookupByLibrary.simpleMessage("tarifa de negociación:"),
        "traditionalChinese":
            MessageLookupByLibrary.simpleMessage("tradicional"),
        "turkishLanguage": MessageLookupByLibrary.simpleMessage("Turco"),
        "txBlock": MessageLookupByLibrary.simpleMessage("Bloque"),
        "txConfirmations":
            MessageLookupByLibrary.simpleMessage("Confirmaciones"),
        "txConfirmed": MessageLookupByLibrary.simpleMessage("CONFIRMADO"),
        "txFee": MessageLookupByLibrary.simpleMessage("Tarifa"),
        "txFeeTitle":
            MessageLookupByLibrary.simpleMessage("tarifa de transacción:"),
        "txHash": MessageLookupByLibrary.simpleMessage("ID de transacción"),
        "txLimitExceeded": MessageLookupByLibrary.simpleMessage(
            "Demasiadas solicitudes.\nSe excedió el límite de solicitudes del historial de transacciones.\nVuelva a intentarlo más tarde."),
        "txNotConfirmed": MessageLookupByLibrary.simpleMessage("INCONFIRMADO"),
        "unlock": MessageLookupByLibrary.simpleMessage("desbloquear"),
        "unspendable": MessageLookupByLibrary.simpleMessage("ingastable"),
        "updatesAvailable":
            MessageLookupByLibrary.simpleMessage("Nueva versión disponible"),
        "updatesChecking": MessageLookupByLibrary.simpleMessage(
            "Comprobando actualizaciones..."),
        "updatesNotifAvailable": MessageLookupByLibrary.simpleMessage(
            "Nueva versión disponible. Por favor actualice."),
        "updatesNotifTitle":
            MessageLookupByLibrary.simpleMessage("Actualización disponible"),
        "updatesSkip": MessageLookupByLibrary.simpleMessage("Saltar por ahora"),
        "updatesTitle": m62,
        "updatesUpToDate":
            MessageLookupByLibrary.simpleMessage("Ya está actualizado"),
        "updatesUpdate": MessageLookupByLibrary.simpleMessage("Actualizar"),
        "uriInsufficientBalanceSpan1": MessageLookupByLibrary.simpleMessage(
            "No hay suficiente saldo para escaneado "),
        "uriInsufficientBalanceSpan2":
            MessageLookupByLibrary.simpleMessage(" solicitud de pago."),
        "uriInsufficientBalanceTitle":
            MessageLookupByLibrary.simpleMessage("Saldo insuficiente"),
        "value": MessageLookupByLibrary.simpleMessage("Valor: "),
        "version": MessageLookupByLibrary.simpleMessage("version"),
        "viewInExplorerButton":
            MessageLookupByLibrary.simpleMessage("Explorador"),
        "viewSeedAndKeys":
            MessageLookupByLibrary.simpleMessage("Semilla y Claves Privadas"),
        "volumes": MessageLookupByLibrary.simpleMessage("Volumenes"),
        "walletOnly": MessageLookupByLibrary.simpleMessage("Solo billetera"),
        "warning": MessageLookupByLibrary.simpleMessage("¡Advertencia!"),
        "warningOkBtn": MessageLookupByLibrary.simpleMessage("Ok"),
        "warningShareLogs": MessageLookupByLibrary.simpleMessage(
            "Advertencia: en casos especiales, estos datos de registro contienen información confidencial que se puede usar para gastar monedas de intercambios fallidos."),
        "welcomeInfo": m63,
        "welcomeLetSetUp":
            MessageLookupByLibrary.simpleMessage("¡VAMOS A PREPARARNOS!"),
        "welcomeTitle": MessageLookupByLibrary.simpleMessage("BIENVENIDO"),
        "welcomeWallet": MessageLookupByLibrary.simpleMessage("wallet"),
        "withdraw": MessageLookupByLibrary.simpleMessage("Retirar"),
        "withdrawCameraAccessText": m64,
        "withdrawCameraAccessTitle":
            MessageLookupByLibrary.simpleMessage("Acceso Denegado"),
        "withdrawConfirm":
            MessageLookupByLibrary.simpleMessage("Confirmar Retiro"),
        "withdrawConfirmError": MessageLookupByLibrary.simpleMessage(
            "Algo salió mal. Vuelva a intentarlo más tarde."),
        "wrongCoinSpan1": MessageLookupByLibrary.simpleMessage(
            "Está intentando escanear un código QR de pago para "),
        "wrongCoinSpan2":
            MessageLookupByLibrary.simpleMessage(" pero tu estas en la "),
        "wrongCoinSpan3":
            MessageLookupByLibrary.simpleMessage(" pantalla de retirar"),
        "wrongCoinTitle":
            MessageLookupByLibrary.simpleMessage("Moneda equivocada"),
        "wrongPassword": MessageLookupByLibrary.simpleMessage(
            "Las contraseñas no coinciden. Inténtalo de nuevo."),
        "youAreSending":
            MessageLookupByLibrary.simpleMessage("Usted está enviando:"),
        "youWillReceived":
            MessageLookupByLibrary.simpleMessage("Usted recibirá: ")
      };
}
