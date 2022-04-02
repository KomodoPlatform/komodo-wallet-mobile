// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
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
  String get localeName => 'ru';

  static m0(name) => "${name} активирован успешно!";

  static m27(title) => "Отображаются только контакты с ${title} адресами";

  static m28(abbr) =>
      "Вы не можете отправить средства на адрес ${abbr}, потому что ${abbr} не активирован. Пожалуйста, перейдите в портфолио.";

  static m29(appName) =>
      "Нет! Мы никогда не храним конфиденциальные данные, включая ваши приватные ключи, seed ключи или PIN-код. Эти данные хранятся только на устройстве пользователя и никуда не передаются. Вы полностью контролируете свои активы.";

  static m30(appName) =>
      "${appName} доступен для мобильных устройств на Android и iPhone, а также как десктопное приложение на операционных системах Windows, Mac и Linux.";

  static m31(appName) =>
      "Другие DEX обычно позволяют торговать только активами, принадлежащими к одному блокчейну, используют прокси-токены и разрешают размещать только один ордер, использующий ваш баланс. \n\n${appName} позволяет вам торговать между разными блокчейнами без использования прокси-токенов. Вы также можете разместить несколько заказов, используя одни и те же средства. Например, вы можете выставить ордера на продажу 0,1 BTC за KMD, QTUM и VRSC - первый исполненный ордер автоматически отменит все остальные ордера.";

  static m32(appName) =>
      "Есть несколько факторов, определяющих время обработки каждого свопа. Время блокировки торгуемых активов зависит от каждой сети (биткоин блокчейн обычно является самым медленным). Кроме того, пользователь может редактировать параметры безопасности. Например, в ${appName} можно установить количество подтверждений, после которых KMD транзакция считается успешной, равным 3, что сокращает время обмена по сравнению с транзакциями, ожидающими<a href = \"https://komodoplatform.com/security-delayed-proof-of -work-dpow / \"> нотариального заверения</a>.";

  static m33(appName) =>
      "При торговле на ${appName} необходимо учитывать две категории комиссий. \n\n1. ${appName} взимает приблизительно 0,13% (1/777 объема торгов, но не ниже 0,0001) в качестве комиссии за торговлю для тейкер ордеров, а для ордеров-мейкеров комиссия равна нулю. \n\n2. Как мейкеры, так и тейкеры должны платят обычные комиссии за транзакции в используемых блокчейнах при совершении атомарного свопа .\n\nКомиссиии сети могут сильно различаться в зависимости от выбранной вами торговой пары.";

  static m34(name, link, appName, appCompanyShort) =>
      "Да! ${appName} предлагает поддержку через <a href=\"${link}\"> ${name} сервер ${appCompanyShort} </a>. Команда и сообщество всегда рады помочь!";

  static m35(appName) =>
      "Нет! ${appName} полностью децентрализована. Ограничить доступ пользователей третьими лицами невозможно.";

  static m36(appName, appCompanyShort) =>
      "${appName} разработан командой ${appCompanyShort}. ${appCompanyShort} - один из наиболее авторитетных блокчейн-проектов, работающих над инновационными решениями, такими как атомарные свопы, delayed Proof of Work и совместимая многоцепочечная архитектура.";

  static m37(appName) =>
      "Конечно! Вы можете обратиться к нашей документации для разработчиков для получения более подробной информации или связаться с нами по вопросам партнерства. У вас есть конкретный технический вопрос? Разработчики сообщества ${appName} всегда готовы помочь!";

  static m24(seconde) =>
      "Поиск сделки в процессе, пожалуйста , подождите ${seconde} секунд!";

  static m1(index) => "Введите ${index} слово";

  static m2(index) => "Какое ${index} слово в вашем seed-ключе?";

  static m40(name) => "Вы уверены, что хотите удалить ${name}?";

  static m44(appCompanyShort) => "Новости Комодо";

  static m25(coinName, number) =>
      "Минимальная сумма продажи составляет ${number} ${coinName}.";

  static m26(coinName, number) =>
      "Минимальная сумма покупки: ${number} ${coinName}";

  static m52(number) => "Создать ${number} ордер(ов):";

  static m17(coinName) => "Пожалуйста, введите сумму ${coinName}.";

  static m56(sell, buy) => "Своп ${sell}/${buy} успешно завершен";

  static m57(sell, buy) => "Своп ${sell}/${buy} не прошел";

  static m58(sell, buy) => "Своп ${sell}/${buy} начат";

  static m59(sell, buy) => "Превышен тайм-аут свопа ${sell}/${buy}";

  static m60(coin) => "Вы получили ${coin} транзакцию";

  static m18(assets) => "${assets} Активов";

  static m61(coin) => "Все ${coin} ордеры будут отменены.";

  static m62(delta) => "На -${delta}% ниже цен CEX";

  static m63(delta) => "На +${delta}% выше цен CEX";

  static m65(coin) => "Сумма (${coin})";

  static m66(coin) => "Цена (${coin})";

  static m67(coin) => "Всего (${coin})";

  static m69(appName) => "На каких устройствах я могу использовать ${appName}?";

  static m70(appName) =>
      "Чем торговля на ${appName} отличается от торговли на других DEX?";

  static m71(appName) => "Как рассчитываются комиссии на ${appName}?";

  static m72(appName) => "Кто стоит за ${appName}?";

  static m73(appName) =>
      "Можно ли разработать собственную white-label биржу на технологии ${appName}?";

  static m74(amount) => "Получено ${amount} KMD.";

  static m75(dd) => "${dd} дней}";

  static m76(hh, minutes) => "${hh}ч ${minutes}мин";

  static m77(mm) => "мин ${mm}";

  static m19(amount) => "Нажмите, чтобы увидеть ${amount} ордеров";

  static m20(coinName, address) => "Мой ${coinName} адрес: ${address}";

  static m83(description) =>
      "Выберите файл в формате mp3 или wav. Воспроизводится, когда ${description}.";

  static m84(description) => "Воспроизводится, когда ${description}";

  static m85(appName) =>
      "Если у вас есть какие-либо вопросы или вы считаете, что обнаружили техническую проблему с приложением ${appName}, вы можете сообщить об этом и получить поддержку от нашей команды.";

  static m89(version) => "Установлена версия ${version}";

  static m90(version) => "Доступна версия ${version}. Пожалуйста, обновитесь.";

  static m91(appName) => "Обновление ${appName}";

  static m21(appName) =>
      "${appName} mobile - это мульти-монетный кошелек с функциональностью DEX третьего поколения и многим другим.";

  static m22(amount, coinName) => "ВЫВЕСТИ ${amount} ${coinName}";

  static m23(amount, coin) => "Вы получите ${amount} ${coin}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "Active": MessageLookupByLibrary.simpleMessage("Активные"),
        "Applause": MessageLookupByLibrary.simpleMessage("Аплодисменты"),
        "Can\'t play that":
            MessageLookupByLibrary.simpleMessage("Невозможно воспроизвести"),
        "Failed": MessageLookupByLibrary.simpleMessage("Неудавшиеся \t"),
        "Maker": MessageLookupByLibrary.simpleMessage("Мейкер"),
        "Play at full volume": MessageLookupByLibrary.simpleMessage(
            "Воспроизводить на полную громкость"),
        "Sound": MessageLookupByLibrary.simpleMessage("Звук"),
        "Taker": MessageLookupByLibrary.simpleMessage("Тейкер"),
        "a swap fails":
            MessageLookupByLibrary.simpleMessage("своп не был завершен"),
        "a swap runs to completion":
            MessageLookupByLibrary.simpleMessage("своп завершается"),
        "accepteula": MessageLookupByLibrary.simpleMessage("Принять EULA"),
        "accepttac": MessageLookupByLibrary.simpleMessage("ПРИНЯТЬ УСЛОВИЯ"),
        "activateAccessBiometric": MessageLookupByLibrary.simpleMessage(
            "Активировать биометрическую защиту"),
        "activateAccessPin":
            MessageLookupByLibrary.simpleMessage("Активировать защиту PIN"),
        "addCoin": MessageLookupByLibrary.simpleMessage("Активировать монету"),
        "addingCoinSuccess": m0,
        "addressAdd": MessageLookupByLibrary.simpleMessage("Добавить адрес"),
        "addressBook": MessageLookupByLibrary.simpleMessage("Адресная книга"),
        "addressBookEmpty": MessageLookupByLibrary.simpleMessage("Нет записей"),
        "addressBookFilter": m27,
        "addressBookTitle":
            MessageLookupByLibrary.simpleMessage("Адресная книга"),
        "addressCoinInactive": m28,
        "addressNotFound": MessageLookupByLibrary.simpleMessage("Не найдено"),
        "addressSelectCoin":
            MessageLookupByLibrary.simpleMessage("Выбрать валюту"),
        "addressSend": MessageLookupByLibrary.simpleMessage("Адрес получателя"),
        "allowCustomSeed": MessageLookupByLibrary.simpleMessage(
            "Разрешить произвольный seed-ключ"),
        "amount": MessageLookupByLibrary.simpleMessage("Количество"),
        "amountToSell":
            MessageLookupByLibrary.simpleMessage("Сумма для продажи"),
        "answer_1": m29,
        "answer_10": m30,
        "answer_2": m31,
        "answer_3": m32,
        "answer_4": MessageLookupByLibrary.simpleMessage(
            "Да. Приложение appName должно оставаться подключенным к Интернету для успешного завершения каждого атомарного свопа (очень короткие перерывы в подключении обычно допустимы). В противном случае существует риск отмены сделки, если вы являетесь мейкером, и риск потери средств, если вы тейкер. Протокол атомарного свопа требует, чтобы оба участника оставались в сети и контролировали задействованные блокчейны, чтобы процесс оставался атомарным."),
        "answer_5": m33,
        "answer_6": m34,
        "answer_7": m35,
        "answer_8": m36,
        "answer_9": m37,
        "areYouSure": MessageLookupByLibrary.simpleMessage("ВЫ УВЕРЕНЫ?"),
        "authenticate": MessageLookupByLibrary.simpleMessage("аутентификация"),
        "availableVolume": MessageLookupByLibrary.simpleMessage("макс объем"),
        "back": MessageLookupByLibrary.simpleMessage("назад"),
        "backupTitle": MessageLookupByLibrary.simpleMessage("Бэкап"),
        "bestAvailableRate":
            MessageLookupByLibrary.simpleMessage("Обменный курс"),
        "buy": MessageLookupByLibrary.simpleMessage("Купить"),
        "buySuccessWaiting": MessageLookupByLibrary.simpleMessage(
            "Обмен начался, пожалуйста подождите!"),
        "buySuccessWaitingError": m24,
        "camoPinChange":
            MessageLookupByLibrary.simpleMessage("Изменить маскировочный PIN"),
        "camoPinCreate":
            MessageLookupByLibrary.simpleMessage("Создать Маскировочный PIN"),
        "camoPinDesc": MessageLookupByLibrary.simpleMessage(
            "Если вы разблокируете приложение с маскировочным PIN-кодом, будет показан поддельный баланс, а настройки маскировочного PIN-кода НЕ будут отображаться в приложении"),
        "camoPinInvalid":
            MessageLookupByLibrary.simpleMessage("Неверный маскировочный PIN "),
        "camoPinLink":
            MessageLookupByLibrary.simpleMessage("Маскировочный PIN"),
        "camoPinNotFound":
            MessageLookupByLibrary.simpleMessage("Маскировочный PIN не найден"),
        "camoPinOff": MessageLookupByLibrary.simpleMessage("Выкл"),
        "camoPinOn": MessageLookupByLibrary.simpleMessage("Вкл"),
        "camoPinSaved":
            MessageLookupByLibrary.simpleMessage("Маскировочный PIN сохранен"),
        "camoPinTitle":
            MessageLookupByLibrary.simpleMessage("Маскировочный PIN"),
        "camoSetupSubtitle": MessageLookupByLibrary.simpleMessage(
            "Введите новый маскировочный PIN"),
        "camoSetupTitle": MessageLookupByLibrary.simpleMessage(
            "Установить маскировочный PIN"),
        "cancel": MessageLookupByLibrary.simpleMessage("отменить"),
        "candleChartError": MessageLookupByLibrary.simpleMessage(
            "Что-то пошло не так. Попробуйте позже."),
        "cexChangeRate": MessageLookupByLibrary.simpleMessage("Цена CEXchange"),
        "cexData": MessageLookupByLibrary.simpleMessage("Данные CEX"),
        "cexDataDesc": MessageLookupByLibrary.simpleMessage(
            "Данные (цены, графики и т.д.), отмеченные этим значком, получены из сторонних источников (<a href=\"https://www.coingecko.com/\"> coingecko.com </a>, <a href = \" https://openrates.io/\">openrates.io </a>)."),
        "changePin": MessageLookupByLibrary.simpleMessage("Изменить PIN-код"),
        "checkForUpdates":
            MessageLookupByLibrary.simpleMessage("Проверить обновления"),
        "checkOut": MessageLookupByLibrary.simpleMessage("Всего"),
        "checkSeedPhrase":
            MessageLookupByLibrary.simpleMessage("Проверьте seed-ключ"),
        "checkSeedPhraseButton1":
            MessageLookupByLibrary.simpleMessage("ПРОДОЛЖИТЬ"),
        "checkSeedPhraseButton2":
            MessageLookupByLibrary.simpleMessage("ВЕРНУТЬСЯ И ПРОВЕРИТЬ СНОВА"),
        "checkSeedPhraseHint": m1,
        "checkSeedPhraseInfo": MessageLookupByLibrary.simpleMessage(
            "Ваш seed-ключ необходим для доступа к кошельку - поэтому мы хотим убедиться, что она правильная. Мы зададим вам три разных вопроса о вашей seed-фразе, чтобы убедиться, что вы сможете легко восстановить свой кошелек, когда захотите."),
        "checkSeedPhraseSubtile": m2,
        "checkSeedPhraseTitle": MessageLookupByLibrary.simpleMessage(
            "ДАВАЙТЕ ПЕРЕПРОВЕРИМ ВАШ SEED-КЛЮЧ"),
        "checkingUpdates":
            MessageLookupByLibrary.simpleMessage("Проверка обновлений..."),
        "claim": MessageLookupByLibrary.simpleMessage("Востребовать"),
        "claimTitle": MessageLookupByLibrary.simpleMessage(
            "Востребовать KMD вознаграждение? "),
        "clickToSee":
            MessageLookupByLibrary.simpleMessage("Нажмите, чтобы увидеть "),
        "clipboard": MessageLookupByLibrary.simpleMessage("Скопировано"),
        "clipboardCopy": MessageLookupByLibrary.simpleMessage("Скопировать"),
        "close": MessageLookupByLibrary.simpleMessage("Закрыть"),
        "code": MessageLookupByLibrary.simpleMessage("Код: "),
        "coinSelectClear": MessageLookupByLibrary.simpleMessage("Очистить"),
        "coinSelectNotFound":
            MessageLookupByLibrary.simpleMessage("Нет активных монет"),
        "coinSelectTitle":
            MessageLookupByLibrary.simpleMessage("Выбрать монету"),
        "comingSoon": MessageLookupByLibrary.simpleMessage("Скоро будет..."),
        "commingsoon": MessageLookupByLibrary.simpleMessage(
            "Детали TX скоро будут добавлены!"),
        "commingsoonGeneral": MessageLookupByLibrary.simpleMessage(
            "Детали будут скоро добавлены!"),
        "commissionFee": MessageLookupByLibrary.simpleMessage("комиссия"),
        "configureWallet": MessageLookupByLibrary.simpleMessage(
            "Настройка кошелька, пожалуйста, подождите"),
        "confirm": MessageLookupByLibrary.simpleMessage("подтвердить"),
        "confirmPassword":
            MessageLookupByLibrary.simpleMessage("Подтвердите пароль"),
        "confirmPin":
            MessageLookupByLibrary.simpleMessage("Подтвердите PIN-код"),
        "confirmSeed":
            MessageLookupByLibrary.simpleMessage("Подтвердите seed-ключ"),
        "confirmeula": MessageLookupByLibrary.simpleMessage(
            "Нажимая кнопку ниже, вы подтверждаете, что прочитали «EULA» и «Terms and Conditions» и принимаете их"),
        "connecting": MessageLookupByLibrary.simpleMessage("Соединение..."),
        "contactCancel": MessageLookupByLibrary.simpleMessage("Отмена"),
        "contactDelete":
            MessageLookupByLibrary.simpleMessage("Удалить контакт"),
        "contactDeleteBtn": MessageLookupByLibrary.simpleMessage("Удалить"),
        "contactDeleteWarning": m40,
        "contactDiscardBtn": MessageLookupByLibrary.simpleMessage("Сбросить"),
        "contactEdit": MessageLookupByLibrary.simpleMessage("Изменить"),
        "contactExit": MessageLookupByLibrary.simpleMessage("Выйти"),
        "contactExitWarning":
            MessageLookupByLibrary.simpleMessage("Сбросить изменения?"),
        "contactNotFound":
            MessageLookupByLibrary.simpleMessage("Контакты не найдены"),
        "contactSave": MessageLookupByLibrary.simpleMessage("Сохранить"),
        "contactTitle":
            MessageLookupByLibrary.simpleMessage("Контактная информация"),
        "create": MessageLookupByLibrary.simpleMessage("сделка"),
        "createAWallet":
            MessageLookupByLibrary.simpleMessage("СОЗДАТЬ КОШЕЛЕК"),
        "createContact":
            MessageLookupByLibrary.simpleMessage("Добавить контакт"),
        "createPin": MessageLookupByLibrary.simpleMessage("Задать PIN"),
        "currency": MessageLookupByLibrary.simpleMessage("Валюта"),
        "currencyDialogTitle": MessageLookupByLibrary.simpleMessage("Валюта"),
        "customFee": MessageLookupByLibrary.simpleMessage("Свои комиссии"),
        "customFeeWarning": MessageLookupByLibrary.simpleMessage(
            "Используйте настраиваемые комиссии только если знаете, что делаете!"),
        "dPow": MessageLookupByLibrary.simpleMessage("Защита Komodo dPoW"),
        "decryptingWallet":
            MessageLookupByLibrary.simpleMessage("Расшифровываю кошелек"),
        "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
        "deleteConfirm":
            MessageLookupByLibrary.simpleMessage("Подтвердить деактивацию"),
        "deleteSpan1":
            MessageLookupByLibrary.simpleMessage("Вы хотите удалить "),
        "deleteSpan2": MessageLookupByLibrary.simpleMessage(
            " из вашего портфолио? Все несовпавшие ордеры будут отменены."),
        "deleteWallet": MessageLookupByLibrary.simpleMessage("Удалить кошелек"),
        "dex": MessageLookupByLibrary.simpleMessage("DEX"),
        "disclaimerAndTos":
            MessageLookupByLibrary.simpleMessage("Disclaimer & ToS"),
        "done": MessageLookupByLibrary.simpleMessage("Готово"),
        "dontWantPassword": MessageLookupByLibrary.simpleMessage(
            "Я не хочу использовать пароль"),
        "editContact": MessageLookupByLibrary.simpleMessage("Редактировать"),
        "encryptingWallet":
            MessageLookupByLibrary.simpleMessage("Шифрую кошелек"),
        "enterNewPinCode":
            MessageLookupByLibrary.simpleMessage("Введите новый PIN"),
        "enterOldPinCode":
            MessageLookupByLibrary.simpleMessage("Введите свой старый PIN"),
        "enterPinCode":
            MessageLookupByLibrary.simpleMessage("Введите свой PIN-код"),
        "enterSeedPhrase":
            MessageLookupByLibrary.simpleMessage("Введите свою seed-фразу"),
        "enterpassword": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите Ваш пароль чтобы продолжить."),
        "errorAmountBalance":
            MessageLookupByLibrary.simpleMessage("Недостаточный баланс"),
        "errorNotAValidAddress":
            MessageLookupByLibrary.simpleMessage("Невалидный адрес"),
        "errorNotAValidAddressSegWit": MessageLookupByLibrary.simpleMessage(
            "Segwit адреса не поддерживаются"),
        "errorTryAgain": MessageLookupByLibrary.simpleMessage(
            "Ошибка, пожалуйста, попробуйте еще раз"),
        "errorTryLater":
            MessageLookupByLibrary.simpleMessage("Ошибка, попробуйте позже"),
        "errorValueEmpty": MessageLookupByLibrary.simpleMessage(
            "Значение слишком высокое или маленькое"),
        "errorValueNotEmpty":
            MessageLookupByLibrary.simpleMessage("Пожалуйста, введите данные"),
        "estimateValue":
            MessageLookupByLibrary.simpleMessage("Расчетная общая стоимость"),
        "eulaTitle2": MessageLookupByLibrary.simpleMessage(
            "TERMS and CONDITIONS: (ПОЛЬЗОВАТЕЛЬСКОЕ СОГЛАШЕНИЕ)\n\n"),
        "exampleHintSeed": MessageLookupByLibrary.simpleMessage(
            "Например: build case level ..."),
        "exchangeExpedient":
            MessageLookupByLibrary.simpleMessage("Ниже цен CEX"),
        "exchangeExpensive":
            MessageLookupByLibrary.simpleMessage("Выше цен CEX"),
        "exchangeTitle": MessageLookupByLibrary.simpleMessage("ОБМЕН"),
        "fakeBalanceAmt":
            MessageLookupByLibrary.simpleMessage("Поддельный баланс:"),
        "faqTitle":
            MessageLookupByLibrary.simpleMessage("Часто задаваемые вопросы"),
        "faucetName": MessageLookupByLibrary.simpleMessage("FAUCET"),
        "feedNewsTab": MessageLookupByLibrary.simpleMessage("Новости"),
        "feedNotFound":
            MessageLookupByLibrary.simpleMessage("Здесь ничего нет"),
        "feedNotifTitle": m44,
        "feedReadMore": MessageLookupByLibrary.simpleMessage("Узнать больше"),
        "feedTab": MessageLookupByLibrary.simpleMessage("Лента"),
        "feedTitle": MessageLookupByLibrary.simpleMessage("Лента новостей"),
        "feedUnableToProceed": MessageLookupByLibrary.simpleMessage(
            "Невозможно обновить ленту новостей"),
        "feedUnableToUpdate": MessageLookupByLibrary.simpleMessage(
            "Невозможно обновить ленту новостей"),
        "feedUpToDate":
            MessageLookupByLibrary.simpleMessage("Новых новостей нет"),
        "feedUpdated":
            MessageLookupByLibrary.simpleMessage("Лента новостей обновлена"),
        "feedback": MessageLookupByLibrary.simpleMessage("Отправить логи"),
        "from": MessageLookupByLibrary.simpleMessage("Из"),
        "gasPrice": MessageLookupByLibrary.simpleMessage("Цена Gas"),
        "generalPinNotActive": MessageLookupByLibrary.simpleMessage(
            "Общая защита PIN-кодом не активна. \nРежим маскировки будет недоступен. \nВключите защиту PIN-кодом."),
        "getBackupPhrase": MessageLookupByLibrary.simpleMessage(
            "Важно: перед тем как продолжить, сохраните свою seed-фразу в надежном месте!"),
        "goToPorfolio":
            MessageLookupByLibrary.simpleMessage("Перейти в портфолио"),
        "helpLink": MessageLookupByLibrary.simpleMessage("Поддержка"),
        "helpTitle": MessageLookupByLibrary.simpleMessage("Помощь и поддержка"),
        "hideBalance": MessageLookupByLibrary.simpleMessage("Спрятать баланс"),
        "hintConfirmPassword":
            MessageLookupByLibrary.simpleMessage("Подтвердите Пароль"),
        "hintCurrentPassword":
            MessageLookupByLibrary.simpleMessage("Текущий пароль"),
        "hintEnterPassword":
            MessageLookupByLibrary.simpleMessage("Введите свой пароль"),
        "hintEnterSeedPhrase":
            MessageLookupByLibrary.simpleMessage("Введите свой seed-ключ"),
        "hintNameYourWallet":
            MessageLookupByLibrary.simpleMessage("Назовите свой кошелек"),
        "hintPassword": MessageLookupByLibrary.simpleMessage("Пароль"),
        "history": MessageLookupByLibrary.simpleMessage("история"),
        "hours": MessageLookupByLibrary.simpleMessage("ч"),
        "infoPasswordDialog": MessageLookupByLibrary.simpleMessage(
            "Если вы решите не использовать пароль, вам нужно будет вводить свою seed-фразу каждый раз, когда вы хотите получить доступ к своему кошельку."),
        "infoTrade1": MessageLookupByLibrary.simpleMessage(
            "Запрос на обмен не может быть отменен и является окончательным!"),
        "infoTrade2": MessageLookupByLibrary.simpleMessage(
            "Эта транзакция может занять до 10 минут - НЕ закрывайте приложение!"),
        "infoWalletPassword": MessageLookupByLibrary.simpleMessage(
            "Вы можете зашифровать свой кошелек паролем. Если вы решите не использовать пароль, вам нужно будет вводить свою seed-фразу каждый раз, когда вы хотите получить доступ к своему кошельку."),
        "language": MessageLookupByLibrary.simpleMessage("Язык"),
        "legalTitle": MessageLookupByLibrary.simpleMessage("Легальные аспекты"),
        "loading": MessageLookupByLibrary.simpleMessage("Загрузка..."),
        "loadingOrderbook":
            MessageLookupByLibrary.simpleMessage("Загрузка ордербука..."),
        "lockScreen":
            MessageLookupByLibrary.simpleMessage("Экран заблокирован"),
        "lockScreenAuth": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, аутентифицируйтесь!"),
        "login": MessageLookupByLibrary.simpleMessage("войти"),
        "logout": MessageLookupByLibrary.simpleMessage("Выйти"),
        "logoutOnExit":
            MessageLookupByLibrary.simpleMessage("Log Out при выходе"),
        "logoutWarning": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите выйти?"),
        "logoutsettings":
            MessageLookupByLibrary.simpleMessage("Настройки Log Out"),
        "makeAorder": MessageLookupByLibrary.simpleMessage("разместить ордер"),
        "marketplace": MessageLookupByLibrary.simpleMessage("Маркетплейс"),
        "marketsChart": MessageLookupByLibrary.simpleMessage("График"),
        "marketsDepth": MessageLookupByLibrary.simpleMessage("Глубина"),
        "marketsNoAsks": MessageLookupByLibrary.simpleMessage("Нет асков"),
        "marketsNoBids": MessageLookupByLibrary.simpleMessage("Нет бидов"),
        "marketsOrderDetails":
            MessageLookupByLibrary.simpleMessage("Детали ордера"),
        "marketsOrderbook": MessageLookupByLibrary.simpleMessage("ОРДЕРБУК"),
        "marketsPrice": MessageLookupByLibrary.simpleMessage("ЦЕНА"),
        "marketsSelectCoins":
            MessageLookupByLibrary.simpleMessage("Пожалуйста, выберите монету"),
        "marketsTab": MessageLookupByLibrary.simpleMessage("Рынки"),
        "marketsTitle": MessageLookupByLibrary.simpleMessage("РЫНКИ"),
        "matchingCamoChange": MessageLookupByLibrary.simpleMessage("Изменить"),
        "matchingCamoPinError": MessageLookupByLibrary.simpleMessage(
            "Общий PIN и маскировочный PIN совпадают. \nРежим маскировки будет недоступен. \nИзмените маскировочный PIN"),
        "matchingCamoTitle":
            MessageLookupByLibrary.simpleMessage("Неверный PIN"),
        "max": MessageLookupByLibrary.simpleMessage("MAX"),
        "media": MessageLookupByLibrary.simpleMessage("Новости"),
        "mediaBrowse": MessageLookupByLibrary.simpleMessage("ПРОСМАТРИВАТЬ"),
        "mediaBrowseFeed":
            MessageLookupByLibrary.simpleMessage("ПОСМОТРЕТЬ ЛЕНТУ"),
        "mediaBy": MessageLookupByLibrary.simpleMessage("По"),
        "mediaNotSavedDescription": MessageLookupByLibrary.simpleMessage(
            "У вас нет сохраненных статей"),
        "mediaSaved": MessageLookupByLibrary.simpleMessage("СОХРАНЕННЫЕ"),
        "milliseconds": MessageLookupByLibrary.simpleMessage("мс"),
        "minValue": m25,
        "minValueBuy": m26,
        "minutes": MessageLookupByLibrary.simpleMessage("мин"),
        "moreTab": MessageLookupByLibrary.simpleMessage("Ещё"),
        "multiBaseAmtPlaceholder":
            MessageLookupByLibrary.simpleMessage("Сумма"),
        "multiBasePlaceholder": MessageLookupByLibrary.simpleMessage("Монета"),
        "multiBaseSelectTitle": MessageLookupByLibrary.simpleMessage("Продать"),
        "multiConfirmCancel": MessageLookupByLibrary.simpleMessage("Отменить"),
        "multiConfirmConfirm":
            MessageLookupByLibrary.simpleMessage("Подтвердить"),
        "multiConfirmTitle": m52,
        "multiCreate": MessageLookupByLibrary.simpleMessage("Создать"),
        "multiCreateOrder": MessageLookupByLibrary.simpleMessage("Ордер"),
        "multiCreateOrders": MessageLookupByLibrary.simpleMessage("Ордеры"),
        "multiEthFee": MessageLookupByLibrary.simpleMessage("комис."),
        "multiFiatCancel": MessageLookupByLibrary.simpleMessage("Отменить"),
        "multiFiatDesc": MessageLookupByLibrary.simpleMessage(
            "Введите сумму в фиате для получения:"),
        "multiFiatFill": MessageLookupByLibrary.simpleMessage("Автозаполнение"),
        "multiFixErrors": MessageLookupByLibrary.simpleMessage(
            "Исправьте ошибки, прежде чем продолжить"),
        "multiInvalidAmt":
            MessageLookupByLibrary.simpleMessage("Некорректная сумма"),
        "multiInvalidSellAmt":
            MessageLookupByLibrary.simpleMessage("Неверная сумма продажи"),
        "multiMaxSellAmt":
            MessageLookupByLibrary.simpleMessage("Макс сумма к продаже"),
        "multiMinReceiveAmt":
            MessageLookupByLibrary.simpleMessage("Мин сумма к получению"),
        "multiMinSellAmt":
            MessageLookupByLibrary.simpleMessage("Мин сумма к продаже"),
        "multiReceiveTitle": MessageLookupByLibrary.simpleMessage("Получить"),
        "multiSellTitle": MessageLookupByLibrary.simpleMessage("Продать:"),
        "multiTab": MessageLookupByLibrary.simpleMessage("Мульти"),
        "multiTableAmt": MessageLookupByLibrary.simpleMessage("Получ. сумма"),
        "multiTablePrice": MessageLookupByLibrary.simpleMessage("Цена/СЕХ"),
        "networkFee": MessageLookupByLibrary.simpleMessage("Комиссия сети"),
        "newAccount": MessageLookupByLibrary.simpleMessage("новый аккаунт"),
        "newAccountUpper":
            MessageLookupByLibrary.simpleMessage("Новый аккаунт"),
        "newsFeed": MessageLookupByLibrary.simpleMessage("Новостная лента"),
        "next": MessageLookupByLibrary.simpleMessage("далее"),
        "noArticles": MessageLookupByLibrary.simpleMessage(
            "Нет новостей - пожалуйста, зайдите позже!"),
        "noFunds": MessageLookupByLibrary.simpleMessage("Нет средств"),
        "noFundsDetected": MessageLookupByLibrary.simpleMessage(
            "Нет доступных средств - пожалуйста, внесите депозит."),
        "noInternet": MessageLookupByLibrary.simpleMessage(
            "Подключение к Интернету отсутствует"),
        "noMatchingOrders": MessageLookupByLibrary.simpleMessage(
            "Совпадающих ордеров не найдено"),
        "noOrder": m17,
        "noOrderAvailable": MessageLookupByLibrary.simpleMessage(
            "Нажмите, чтобы создать ордер"),
        "noRewardYet": MessageLookupByLibrary.simpleMessage(
            "Нет вознаграждения для востребования - повторите попытку через 1 час."),
        "noRewards": MessageLookupByLibrary.simpleMessage(
            "Нет доступных вознаграждений"),
        "noSuchCoin": MessageLookupByLibrary.simpleMessage("Нет такой монеты"),
        "noSwaps": MessageLookupByLibrary.simpleMessage("Нет истории."),
        "noTxs": MessageLookupByLibrary.simpleMessage("Нет транзакций"),
        "notEnoughtBalanceForFee": MessageLookupByLibrary.simpleMessage(
            "Недостаточно баланса для комиссий - выполните сделку на меньшую сумму"),
        "notifSwapCompletedText": m56,
        "notifSwapCompletedTitle":
            MessageLookupByLibrary.simpleMessage("Своп завершен"),
        "notifSwapFailedText": m57,
        "notifSwapFailedTitle":
            MessageLookupByLibrary.simpleMessage("Своп не был завершен"),
        "notifSwapStartedText": m58,
        "notifSwapStartedTitle":
            MessageLookupByLibrary.simpleMessage("Новый своп начался"),
        "notifSwapStatusTitle":
            MessageLookupByLibrary.simpleMessage("Статус свопа изменен"),
        "notifSwapTimeoutText": m59,
        "notifSwapTimeoutTitle":
            MessageLookupByLibrary.simpleMessage("Превышен тайм-аут свопа"),
        "notifTxText": m60,
        "notifTxTitle":
            MessageLookupByLibrary.simpleMessage("Входящая транзакция"),
        "numberAssets": m18,
        "orderCancel": m61,
        "orderCreated": MessageLookupByLibrary.simpleMessage("Ордер создан"),
        "orderCreatedInfo":
            MessageLookupByLibrary.simpleMessage("Ордер успешно создан"),
        "orderDetailsAddress": MessageLookupByLibrary.simpleMessage("Адрес"),
        "orderDetailsCancel": MessageLookupByLibrary.simpleMessage("Отменить"),
        "orderDetailsExpedient": m62,
        "orderDetailsExpensive": m63,
        "orderDetailsFor": MessageLookupByLibrary.simpleMessage("на"),
        "orderDetailsIdentical":
            MessageLookupByLibrary.simpleMessage("Совпадает с СЕХ"),
        "orderDetailsPrice": MessageLookupByLibrary.simpleMessage("Цена"),
        "orderDetailsReceive": MessageLookupByLibrary.simpleMessage("Получите"),
        "orderDetailsSelect": MessageLookupByLibrary.simpleMessage("Выбрать"),
        "orderDetailsSells":
            MessageLookupByLibrary.simpleMessage("Ордеры продаж"),
        "orderDetailsSettings": MessageLookupByLibrary.simpleMessage(
            "Из вкладки Подробности выберите Ордер одним долгим нажатием"),
        "orderDetailsSpend": MessageLookupByLibrary.simpleMessage("Отправьте"),
        "orderDetailsTitle":
            MessageLookupByLibrary.simpleMessage("Подробности"),
        "orderMatched": MessageLookupByLibrary.simpleMessage("Сделка найдена"),
        "orderMatching":
            MessageLookupByLibrary.simpleMessage("Поиск сделки в процессе"),
        "orders": MessageLookupByLibrary.simpleMessage("ордера"),
        "ordersActive": MessageLookupByLibrary.simpleMessage("Активные"),
        "ordersHistory": MessageLookupByLibrary.simpleMessage("История"),
        "ordersTableAmount": m65,
        "ordersTablePrice": m66,
        "ordersTableTotal": m67,
        "ownOrder": MessageLookupByLibrary.simpleMessage("Это ваш ордер!"),
        "paidWith": MessageLookupByLibrary.simpleMessage("Оплачено "),
        "placeOrder": MessageLookupByLibrary.simpleMessage("Разместить ордер"),
        "portfolio": MessageLookupByLibrary.simpleMessage("Портфолио"),
        "price": MessageLookupByLibrary.simpleMessage("цена"),
        "protectionCtrlConfirmations":
            MessageLookupByLibrary.simpleMessage("Подтверждений"),
        "protectionCtrlCustom": MessageLookupByLibrary.simpleMessage(
            "Установить свои настройки защиты"),
        "protectionCtrlOff": MessageLookupByLibrary.simpleMessage("ВЫКЛ"),
        "protectionCtrlOn": MessageLookupByLibrary.simpleMessage("ВКЛ"),
        "protectionCtrlWarning": MessageLookupByLibrary.simpleMessage(
            "Внимание, этот своп не защищен dPoW!"),
        "question_1": MessageLookupByLibrary.simpleMessage(
            "Вы храните мои приватные ключи?"),
        "question_10": m69,
        "question_2": m70,
        "question_3": MessageLookupByLibrary.simpleMessage(
            "Сколько времени занимает каждый атомарный своп?"),
        "question_4": MessageLookupByLibrary.simpleMessage(
            "Необходимо ли мне быть в сети во время свопа?"),
        "question_5": m71,
        "question_6": MessageLookupByLibrary.simpleMessage(
            "Предоставляете ли вы поддержку пользователей?"),
        "question_7": MessageLookupByLibrary.simpleMessage(
            "Есть ли у вас какие-либо географические ограничения?"),
        "question_8": m72,
        "question_9": m73,
        "receive": MessageLookupByLibrary.simpleMessage("ПОЛУЧИТЬ"),
        "receiveLower": MessageLookupByLibrary.simpleMessage("Получить"),
        "recommendSeedMessage": MessageLookupByLibrary.simpleMessage(
            "Мы рекомендуем хранить ее на оффлайн носителе."),
        "remove": MessageLookupByLibrary.simpleMessage("Отключить"),
        "requestedTrade":
            MessageLookupByLibrary.simpleMessage("Запрошенная сделка"),
        "restoreWallet": MessageLookupByLibrary.simpleMessage("ВОССТАНОВИТЬ"),
        "rewardsCancel": MessageLookupByLibrary.simpleMessage("Отменить"),
        "rewardsError": MessageLookupByLibrary.simpleMessage(
            "Что-то пошло не так. Попробуйте позже."),
        "rewardsInProgressLong":
            MessageLookupByLibrary.simpleMessage("Транзакция в процессе"),
        "rewardsInProgressShort":
            MessageLookupByLibrary.simpleMessage("обработка"),
        "rewardsLowAmountLong":
            MessageLookupByLibrary.simpleMessage("UTXO меньше 10"),
        "rewardsLowAmountShort":
            MessageLookupByLibrary.simpleMessage("<10 KMD"),
        "rewardsOneHourLong":
            MessageLookupByLibrary.simpleMessage("Час еще не прошел"),
        "rewardsOneHourShort":
            MessageLookupByLibrary.simpleMessage("Меньше часа"),
        "rewardsPopupOk": MessageLookupByLibrary.simpleMessage("ОК"),
        "rewardsPopupTitle":
            MessageLookupByLibrary.simpleMessage("Статус вознаграждений:"),
        "rewardsReadMore": MessageLookupByLibrary.simpleMessage(
            "Узнать больше о KMD вознаграждениях"),
        "rewardsReceive": MessageLookupByLibrary.simpleMessage("Получить"),
        "rewardsSuccess": m74,
        "rewardsTableRewards":
            MessageLookupByLibrary.simpleMessage("Вознаграждений \nKMD"),
        "rewardsTableStatus": MessageLookupByLibrary.simpleMessage("Статус"),
        "rewardsTableTime": MessageLookupByLibrary.simpleMessage("Осталось"),
        "rewardsTableTitle":
            MessageLookupByLibrary.simpleMessage("Инфо о вознаграждениях:"),
        "rewardsTableUXTO": MessageLookupByLibrary.simpleMessage("UTXO, \nKMD"),
        "rewardsTimeDays": m75,
        "rewardsTimeHours": m76,
        "rewardsTimeMin": m77,
        "rewardsTitle":
            MessageLookupByLibrary.simpleMessage("Инфо о вознаграждениях:"),
        "searchFilterCoin":
            MessageLookupByLibrary.simpleMessage("Поиск монеты"),
        "searchFilterSubtitleERC":
            MessageLookupByLibrary.simpleMessage("Выбрать все ERC токены"),
        "searchFilterSubtitleSmartChain":
            MessageLookupByLibrary.simpleMessage("Выбрать все Smartchain"),
        "searchFilterSubtitleutxo":
            MessageLookupByLibrary.simpleMessage("Выбрать все UTXO монеты"),
        "seconds": MessageLookupByLibrary.simpleMessage("сек"),
        "security": MessageLookupByLibrary.simpleMessage("Безопасность"),
        "seeOrders": m19,
        "seedPhraseTitle":
            MessageLookupByLibrary.simpleMessage("Ваш новый seed-ключ"),
        "selectCoin": MessageLookupByLibrary.simpleMessage("Выберите монету"),
        "selectCoinInfo": MessageLookupByLibrary.simpleMessage(
            "Выберите монеты, которые вы хотите добавить в свое портфолио."),
        "selectCoinTitle":
            MessageLookupByLibrary.simpleMessage("Активировать монеты:"),
        "selectCoinToBuy": MessageLookupByLibrary.simpleMessage(
            "Выберите монету, которую хотите купить"),
        "selectCoinToSell": MessageLookupByLibrary.simpleMessage(
            "Выберите монету, которую хотите продать"),
        "selectPaymentMethod":
            MessageLookupByLibrary.simpleMessage("Выберите способ оплаты"),
        "sell": MessageLookupByLibrary.simpleMessage("Продать"),
        "send": MessageLookupByLibrary.simpleMessage("ОТПРАВИТЬ"),
        "setUpPassword":
            MessageLookupByLibrary.simpleMessage("УСТАНОВИТЬ ПАРОЛЬ"),
        "settingDialogSpan1": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите удалить "),
        "settingDialogSpan2": MessageLookupByLibrary.simpleMessage(" кошелек?"),
        "settingDialogSpan3": MessageLookupByLibrary.simpleMessage(
            "Если это так, убедитесь, что вы "),
        "settingDialogSpan4":
            MessageLookupByLibrary.simpleMessage(" записали свой seed-ключ."),
        "settingDialogSpan5": MessageLookupByLibrary.simpleMessage(
            " Для того, чтобы восстановить свой кошелек в будущем."),
        "settingLanguageTitle": MessageLookupByLibrary.simpleMessage("Языки"),
        "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
        "share": MessageLookupByLibrary.simpleMessage("ПОДЕЛИТЬСЯ"),
        "shareAddress": m20,
        "showMyOrders":
            MessageLookupByLibrary.simpleMessage("ПОКАЗАТЬ МОИ ОРДЕРЫ"),
        "signInWithPassword":
            MessageLookupByLibrary.simpleMessage("Войти с паролем"),
        "signInWithSeedPhrase":
            MessageLookupByLibrary.simpleMessage("Войти с помощью seed-ключа"),
        "snackbarDismiss": MessageLookupByLibrary.simpleMessage("Убрать"),
        "soundCantPlayThatMsg": m83,
        "soundPlayedWhen": m84,
        "step": MessageLookupByLibrary.simpleMessage("Шаг"),
        "success": MessageLookupByLibrary.simpleMessage("Успех!"),
        "support": MessageLookupByLibrary.simpleMessage("Поддержка"),
        "supportLinksDesc": m85,
        "swap": MessageLookupByLibrary.simpleMessage("обмен"),
        "swapDetailTitle":
            MessageLookupByLibrary.simpleMessage("ПОДТВЕРДИТЕ ДЕТАЛИ ОБМЕНА"),
        "swapEstimated": MessageLookupByLibrary.simpleMessage("прибл"),
        "swapFailed": MessageLookupByLibrary.simpleMessage("Обмен не удался"),
        "swapOngoing": MessageLookupByLibrary.simpleMessage("Обмен в процессе"),
        "swapStarted": MessageLookupByLibrary.simpleMessage("Начато"),
        "swapSucceful": MessageLookupByLibrary.simpleMessage("Успешный обмен"),
        "swapTotal": MessageLookupByLibrary.simpleMessage("Всего"),
        "tagERC20": MessageLookupByLibrary.simpleMessage("ERC20"),
        "tagKMD": MessageLookupByLibrary.simpleMessage("KMD"),
        "timeOut": MessageLookupByLibrary.simpleMessage("Таймаут"),
        "titleCreatePassword":
            MessageLookupByLibrary.simpleMessage("СОЗДАТЬ ПАРОЛЬ"),
        "titleCurrentAsk": MessageLookupByLibrary.simpleMessage("Ордер выбран"),
        "to": MessageLookupByLibrary.simpleMessage("В"),
        "toAddress": MessageLookupByLibrary.simpleMessage("На адрес:"),
        "trade": MessageLookupByLibrary.simpleMessage("СДЕЛКА"),
        "tradeCompleted":
            MessageLookupByLibrary.simpleMessage("Обмен завершен!"),
        "tradeDetail": MessageLookupByLibrary.simpleMessage("ДЕТАЛИ СДЕЛКИ"),
        "tradingFee":
            MessageLookupByLibrary.simpleMessage("торговая комиссия:"),
        "txBlock": MessageLookupByLibrary.simpleMessage("Блок"),
        "txConfirmations":
            MessageLookupByLibrary.simpleMessage("Подтверждения"),
        "txConfirmed": MessageLookupByLibrary.simpleMessage("ПОДТВЕРЖДЕНА"),
        "txFee": MessageLookupByLibrary.simpleMessage("Комиссия"),
        "txFeeTitle": MessageLookupByLibrary.simpleMessage("комиссия сети:"),
        "txHash": MessageLookupByLibrary.simpleMessage("ID транзакции"),
        "txLimitExceeded": MessageLookupByLibrary.simpleMessage(
            "Слишком много запросов. \nПревышен лимит запросов истории транзакций. \nПовторите попытку позже."),
        "txNotConfirmed":
            MessageLookupByLibrary.simpleMessage("НЕПОДТВЕРЖДЕНА"),
        "unlock": MessageLookupByLibrary.simpleMessage("разблокировать"),
        "updatesAvailable":
            MessageLookupByLibrary.simpleMessage("Доступна новая версия"),
        "updatesChecking":
            MessageLookupByLibrary.simpleMessage("Проверка обновлений..."),
        "updatesCurrentVersion": m89,
        "updatesNotifAvailable": MessageLookupByLibrary.simpleMessage(
            "Доступна новая версия. Пожалуйста, обновитесь."),
        "updatesNotifAvailableVersion": m90,
        "updatesNotifTitle":
            MessageLookupByLibrary.simpleMessage("Доступно обновление"),
        "updatesSkip": MessageLookupByLibrary.simpleMessage("Пропустить"),
        "updatesTitle": m91,
        "updatesUpToDate": MessageLookupByLibrary.simpleMessage(
            "Установлена последняя версия"),
        "updatesUpdate": MessageLookupByLibrary.simpleMessage("Обновление"),
        "value": MessageLookupByLibrary.simpleMessage("Стоимость: "),
        "version": MessageLookupByLibrary.simpleMessage("версия"),
        "volumes": MessageLookupByLibrary.simpleMessage("Объемы"),
        "warningOkBtn": MessageLookupByLibrary.simpleMessage("OK"),
        "warningShareLogs": MessageLookupByLibrary.simpleMessage(
            "Предупреждение - в особых случаях логи могут содержать конфиденциальную информацию, которую можно использовать для доступа к монетам из незавершенных свопов!"),
        "welcomeInfo": m21,
        "welcomeLetSetUp":
            MessageLookupByLibrary.simpleMessage("ДАВАЙТЕ ВСЕ НАСТРОИМ!"),
        "welcomeTitle":
            MessageLookupByLibrary.simpleMessage("Добро пожаловать"),
        "welcomeWallet": MessageLookupByLibrary.simpleMessage("кошелек"),
        "withdraw": MessageLookupByLibrary.simpleMessage("Вывести"),
        "withdrawConfirm":
            MessageLookupByLibrary.simpleMessage("Подтвердите вывод"),
        "withdrawValue": m22,
        "wrongPassword": MessageLookupByLibrary.simpleMessage(
            "Пароли не совпадают. Пожалуйста, попробуйте еще раз."),
        "you have a fresh order that is trying to match with an existing order":
            MessageLookupByLibrary.simpleMessage(
                "есть новый ордер, который матчуется с вашим размещенным ордером"),
        "you have an active swap in progress":
            MessageLookupByLibrary.simpleMessage("у вас идет активный своп"),
        "you have an order that new orders can match with":
            MessageLookupByLibrary.simpleMessage(
                "у вас есть ордер, которому могут соответствовать новые ордеры"),
        "youAreSending":
            MessageLookupByLibrary.simpleMessage("Вы отправляете:"),
        "youWillReceiveClaim": m23,
        "youWillReceived": MessageLookupByLibrary.simpleMessage("Вы получите: ")
      };
}
