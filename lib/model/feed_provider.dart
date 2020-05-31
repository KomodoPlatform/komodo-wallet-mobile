import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/utils/utils.dart';

class FeedProvider extends ChangeNotifier {
  FeedProvider() {
    ticker = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      _updateData();
    });
  }

  Timer ticker;
  List<Dev> _devOps;
  List<Issue> _issues;
  List<NewsItem> _news;

  @override
  void dispose() {
    super.dispose();
    ticker?.cancel();
  }

  List<Dev> getDevOps() => _devOps;
  List<Issue> getIssues() => _issues;
  Dev getDev(String id) {
    if (_devOps == null) return null;
    return _devOps.firstWhere((Dev dev) => dev.id == id);
  }

  List<NewsItem> getNews() => _news;

  void _updateData() {
    if (_devOps != devOpsListPlaceholder) {
      _devOps = devOpsListPlaceholder;
      notifyListeners();
    }
    if (_issues != issuesListPlaceholder) {
      _issues = issuesListPlaceholder;
      notifyListeners();
    }
    if (_news != newsPlaceholder) {
      _news = newsPlaceholder;
      notifyListeners();
    }
  }

  List<DevStatus> sortTimeLine(List<DevStatus> unsorted) {
    if (unsorted == null) return null;
    if (unsorted.isEmpty) return [];

    final List<DevStatus> _sorted = List.from(unsorted);
    _sorted.sort((a, b) {
      if (a.startTime > b.startTime) return 1;
      if (a.startTime < b.startTime) return -1;
      return 0;
    });

    return _sorted;
  }
}

class Dev {
  Dev({
    @required this.id,
    this.name,
    this.image,
    this.activity,
  });

  String id;
  String name;
  String image;
  List<DevStatus> activity;

  List<DevStatus> get sortedHistory => _getSortedHistory();
  DevStatus get latestStatus => _getLatestStatus();
  OnlineStatus get onlineStatus => _getOnlineStatus();
  String get currentStatusMessage => _getCurrentStatusMessage();

  List<DevStatus> _getSortedHistory() {
    if (activity == null) return null;

    final List<DevStatus> _sorted = List.from(activity);
    if (_sorted.isEmpty) return _sorted;

    _sorted.sort((a, b) {
      if (a.startTime < b.startTime) return 1;
      if (a.startTime > b.startTime) return -1;
      return 0;
    });

    return _sorted;
  }

  OnlineStatus _getOnlineStatus() {
    if (latestStatus == null) return OnlineStatus.unknown;

    switch (latestStatus.endTime) {
      case null:
        {
          return OnlineStatus.active;
        }
      default:
        {
          return OnlineStatus.inactive;
        }
    }
  }

  String _getCurrentStatusMessage() {
    if (latestStatus == null) return '';

    switch (latestStatus.endTime) {
      case null:
        {
          return latestStatus.message ??
              'Active now'; // TODO(yurii): localization
        }
      default:
        {
          return 'Last active: ${humanDate(latestStatus.endTime)}'; // TODO(yurii): localization
        }
    }
  }

  DevStatus _getLatestStatus() {
    if (sortedHistory == null || sortedHistory.isEmpty) return null;
    return sortedHistory[0];
  }
}

class DevStatus {
  DevStatus({
    @required this.id,
    this.devId,
    this.message,
    this.issue,
    this.startTime,
    this.endTime,
  });

  String id;
  String devId;
  String message;
  Issue issue;
  int startTime;
  int endTime;
}

class Issue {
  Issue({
    @required this.id,
    this.title,
    this.url,
    this.devs,
  });

  String id;
  String title;
  String url;
  List<String> devs;
}

enum OnlineStatus {
  active,
  inactive,
  unknown,
}

class NewsItem {
  NewsItem({this.date, this.content});

  String date;
  String content;
}

List<Dev> devOpsListPlaceholder = [
  Dev(
    id: '0',
    name: 'ArtemGr',
    image: 'https://avatars2.githubusercontent.com/u/41847?s=460&v=4',
    activity: [],
  ),
  Dev(
    id: '1',
    name: 'tonymorony',
    //avatar: 'https://avatars0.githubusercontent.com/u/24797699?s=460&v=4',
  ),
  Dev(
    id: '2',
    name: 'MateusRodCosta',
    image: 'https://avatars1.githubusercontent.com/u/24463334?s=460&v=4',
  ),
  Dev(
      id: '3',
      name: 'yurii',
      image: 'https://avatars3.githubusercontent.com/u/29194552?s=150&v=4',
      activity: [
        DevStatus(
          id: '0',
          message: 'git',
          startTime: 1588922092000,
          endTime: 1588923652000,
        ),
        DevStatus(
            id: '1',
            message: '#757 orders duplicates',
            startTime: 1588923772000,
            endTime: 1588927072000,
            issue: Issue(
              id: '757',
              title: 'Orderbook page creating orders duplicates',
              url: 'https://github.com/ca333/komodoDEX/issues/757',
            )),
        DevStatus(
            id: '2',
            message: 'news, design and layout, \'DevOps\' tab 0',
            startTime: 1588927072000,
            issue: Issue(
              id: '701',
              title: 'rewamp the news section',
              url: 'https://github.com/ca333/komodoDEX/issues/701',
            )),
        DevStatus(
          id: '3',
          message: 'git',
          startTime: 1589009514000,
          endTime: 1589020314000,
        ),
        DevStatus(
            id: '4',
            message: '#757 orders duplicates',
            startTime: 1589020314000,
            endTime: 1589022774000,
            issue: Issue(
              id: '757',
              title: 'Orderbook page creating orders duplicates',
              url: 'https://github.com/ca333/komodoDEX/issues/757',
            )),
        DevStatus(
            id: '5',
            message: 'news, design and layout, \'DevOps\' tab 1',
            startTime: 1589022774000,
            issue: Issue(
              id: '701',
              title: 'rewamp the news section',
              url: 'https://github.com/ca333/komodoDEX/issues/701',
            )),
        DevStatus(
          id: '6',
          message: 'git',
          startTime: 1589109174000,
          endTime: 1589112774000,
        ),
        DevStatus(
            id: '7',
            message: '#757 orders duplicates',
            startTime: 1589112774000,
            endTime: 1589119974000,
            issue: Issue(
              id: '757',
              title: 'Orderbook page creating orders duplicates',
              url: 'https://github.com/ca333/komodoDEX/issues/757',
            )),
        DevStatus(
            id: '8',
            message: 'news, design and layout, \'DevOps\' tab 2',
            startTime: 1589551974000,
            issue: Issue(
              id: '701',
              title: 'rewamp the news section',
              url: 'https://github.com/ca333/komodoDEX/issues/701',
            )),
      ]),
];

List<Issue> issuesListPlaceholder = [
  Issue(
    id: '757',
    title: 'Orderbook page creating orders duplicates',
    url: 'https://github.com/ca333/komodoDEX/issues/757',
    devs: ['0', '3'],
  ),
  Issue(
    id: '701',
    title: 'rewamp the news section',
    url: 'https://github.com/ca333/komodoDEX/issues/701',
    devs: ['1', '2', '3'],
  ),
];

List<NewsItem> newsPlaceholder = [
  NewsItem(
    date: '2020-05-25T08:17:53.312+00:00',
    content:
        '''@everyone \n\nWe have published another article from our Blockchain Fundamentals series. 📚\n\n**What’s A Merkle Tree? A Simple Guide To Merkle Trees**\n\nIf you’re involved in the world of blockchain, you may have come across the phrase \"merkle tree\" before. While Merkle trees are not a widely-understood concept, they’re also not terribly complicated. This post will explain Merkle trees in plain English and help you understand how they make blockchain technology possible.\n\nRead more here.\nhttps://komodoplatform.com/whats-merkle-tree/''',
  ),
  NewsItem(
    date: '2020-05-25T08:17:53.312+00:00',
    content: '''
    *italics* or _italics_	
    __*underline italics*__
    **bold**	
    __**underline bold**__
    ***bold italics***	
    __***underline bold italics***__
    __underline__	
    ~~Strikethrough~~

    test h**e**r**e**

    link:  **https://www.google.com/search?q=escape_me_please**
    ''',
  ),
  NewsItem(
    date: '2020-05-25T08:17:53.312+00:00',
    content: '''Komodo v0.6.0 Upgrade Is Coming On June 14

Komodo’s fourth annual Notary Node Election came to an end on May 4, 2020, and the Komodo team would like to congratulate and welcome all of the operators who won a seat in the Notary Node network. 

To officially bring these new Notary Node operators into the network, an upgrade to the Komodo daemon to version 0.6.0 will be activated on June 14, 2020 at block height 1,922,000. The upgrade is mandatory for all miners, exchanges, wallet providers, and other individuals running a full node. Please be sure to update prior to June 14.

Read more here.
https://komodoplatform.com/komodo-v0-6-0-upgrade/''',
  ),
  NewsItem(
    date: '2020-05-25T08:17:53.312+00:00',
    content: '''@everyone 

Weekly Update - May 22, 2020

It's Friday again, which means it's time for another weekly wrap-up. We have summarized the most important events for the last 7 days.

Read the weekly update here.
https://community.komodoplatform.com/post/5ec7e12b7ef3b37cbbaa285f''',
  ),
  NewsItem(
    date: '2020-05-22T08:17:53.312+00:00',
    content: '''Happy Bitcoin Pizza Day @everyone :pizza: 

To honor the 10th anniversary of the Bitcoin Pizza Day we are running a microbounty campaign!

All you need to do to win your 15 KMD is tweet out a pic of your pizza (a slice or a whole pie— both work!) with an AtomicDEX logo visible in the photo. It can be your phone with the AtomicDEX app open, a screen with the AtomicDEX homepage open, or anything else that clearly shows the AtomicDEX logo. 

Get creative! The 3 coolest photos, as judged by the Komodo team, will get a small bonus in KMD.

You must also tag @AtomicDEX twitter account in your tweet.

The first 50 participants will each win 15 KMD! After that, no prizes will be awarded, so grab a pizza and tweet your pic as soon as possible.

https://twitter.com/AtomicDex/status/1263771506175283201?s=20''',
  ),
  NewsItem(content: '''Emojis corrupted on Android
    
👨‍🦯	:man_with_probing_cane:
👨‍🦼	:man_in_motorized_wheelchair:
👨‍🦽	:man_in_manual_wheelchair:
👩‍🦯	:woman_with_probing_cane:
👩‍🦼	:woman_in_motorized_wheelchair:
👩‍🦽	:woman_in_manual_wheelchair:
🛕	:hindu_temple:
🛺	:auto_rickshaw:
🟠	:large_orange_circle:
🟡	:large_yellow_circle:
🟢	:large_green_circle:
🟣	:large_purple_circle:
🟤	:large_brown_circle:
🟥	:large_red_square:
🟦	:large_blue_square:
🟧	:large_orange_square:
🟨	:large_yellow_square:
🟩	:large_green_square:
🟪	:large_purple_square:
🟫	:large_brown_square:
🤍	:white_heart:
🤎	:brown_heart:
🤏	:pinching_hand:
🤿	:diving_mask:
🥱	:yawning_face:
🥻	:sari:
🦥	:sloth:
🦦	:otter:
🦧	:orangutan:
🦨	:skunk:
🦩	:flamingo:
🦪	:oyster:
🦮	:guide_dog:
🦯	:probing_cane:
🦺	:safety_vest:
🦻	:ear_with_hearing_aid:
🦼	:motorized_wheelchair:
🦽	:manual_wheelchair:
🦾	:mechanical_arm:
🦿	:mechanical_leg:
🧃	:beverage_box:
🧄	:garlic:
🧅	:onion:
🧆	:falafel:
🧇	:waffle:
🧈	:butter:
🧉	:mate_drink:
🧊	:ice_cube:
🧍‍♀️	:woman_standing:
🧍‍♂️	:man_standing:
🧍	:standing_person:
🧎‍♀️	:woman_kneeling:
🧎‍♂️	:man_kneeling:
🧎	:kneeling_person:
🧏‍♀️	:deaf_woman:
🧏‍♂️	:deaf_man:
🧏	:deaf_person:
🧑‍🦯	:person_with_probing_cane:
🧑‍🦼	:person_in_motorized_wheelchair:
🧑‍🦽	:person_in_manual_wheelchair:
🩰	:ballet_shoes:
🩱	:one-piece_swimsuit:
🩲	:briefs:
🩳	:shorts:
🩸	:drop_of_blood:
🩹	:adhesive_bandage:
🩺	:stethoscope:
🪀	:yo-yo:
🪁	:kite:
🪂	:parachute:
🪐	:ringed_planet:
🪑	:chair:
🪒	:razor:
🪓	:axe:
🪔	:diya_lamp:
🪕	:banjo:
    '''),
  NewsItem(content: '''Emojis corrupted on iOs:

#️⃣	:hash:
*️⃣	:keycap_star:
0️⃣	:zero:
1️⃣	:one:
2️⃣	:two:
3️⃣	:three:
4️⃣	:four:
5️⃣	:five:
6️⃣	:six:
7️⃣	:seven:
8️⃣	:eight:
9️⃣	:nine:
👨‍🦯	:man_with_probing_cane:
👨‍🦼	:man_in_motorized_wheelchair:
👨‍🦽	:man_in_manual_wheelchair:
👩‍🦯	:woman_with_probing_cane:
👩‍🦼	:woman_in_motorized_wheelchair:
👩‍🦽	:woman_in_manual_wheelchair:
🛕	:hindu_temple:
🛺	:auto_rickshaw:
🟠	:large_orange_circle:
🟡	:large_yellow_circle:
🟢	:large_green_circle:
🟣	:large_purple_circle:
🟤	:large_brown_circle:
🟥	:large_red_square:
🟦	:large_blue_square:
🟧	:large_orange_square:
🟨	:large_yellow_square:
🟩	:large_green_square:
🟪	:large_purple_square:
🟫	:large_brown_square:
🤍	:white_heart:
🤎	:brown_heart:
🤏	:pinching_hand:
🤿	:diving_mask:
🥱	:yawning_face:
🥻	:sari:
🦥	:sloth:
🦦	:otter:
🦧	:orangutan:
🦨	:skunk:
🦩	:flamingo:
🦪	:oyster:
🦮	:guide_dog:
🦯	:probing_cane:
🦺	:safety_vest:
🦻	:ear_with_hearing_aid:
🦼	:motorized_wheelchair:
🦽	:manual_wheelchair:
🦾	:mechanical_arm:
🦿	:mechanical_leg:
🧃	:beverage_box:
🧄	:garlic:
🧅	:onion:
🧆	:falafel:
🧇	:waffle:
🧈	:butter:
🧉	:mate_drink:
🧊	:ice_cube:
🧍‍♀️	:woman_standing:
🧍‍♂️	:man_standing:
🧍	:standing_person:
🧎‍♀️	:woman_kneeling:
🧎‍♂️	:man_kneeling:
🧎	:kneeling_person:
🧏‍♀️	:deaf_woman:
🧏‍♂️	:deaf_man:
🧏	:deaf_person:
🧑‍🦯	:person_with_probing_cane:
🧑‍🦼	:person_in_motorized_wheelchair:
🧑‍🦽	:person_in_manual_wheelchair:
🩰	:ballet_shoes:
🩱	:one-piece_swimsuit:
🩲	:briefs:
🩳	:shorts:
🩸	:drop_of_blood:
🩹	:adhesive_bandage:
🩺	:stethoscope:
🪀	:yo-yo:
🪁	:kite:
🪂	:parachute:
🪐	:ringed_planet:
🪑	:chair:
🪒	:razor:
🪓	:axe:
🪔	:diya_lamp:
🪕	:banjo:
    '''),
  NewsItem(
    // https://unicodey.com/emoji-data/table.htm
    content:
        '''#️⃣ *️⃣ 0️⃣ 1️⃣ 2️⃣ 3️⃣ 4️⃣ 5️⃣ 6️⃣ 7️⃣ 8️⃣ 9️⃣ ©️ ®️ 🀄 🃏 🅰️ 🅱️ 🅾️ 🅿️ 🆎 🆑 🆒 🆓 🆔 🆕 🆖 🆗 🆘 🆙 🆚 🇦🇨 🇦🇩 🇦🇪 🇦🇫 🇦🇬 🇦🇮 🇦🇱 🇦🇲 🇦🇴 🇦🇶 🇦🇷 🇦🇸 🇦🇹 🇦🇺 🇦🇼 🇦🇽 🇦🇿 🇧🇦 🇧🇧 🇧🇩 🇧🇪 🇧🇫 🇧🇬 🇧🇭 🇧🇮 🇧🇯 🇧🇱 🇧🇲 🇧🇳 🇧🇴 🇧🇶 🇧🇷 🇧🇸 🇧🇹 🇧🇻 🇧🇼 🇧🇾 🇧🇿 🇨🇦 🇨🇨 🇨🇩 🇨🇫 🇨🇬 🇨🇭 🇨🇮 🇨🇰 🇨🇱 🇨🇲 🇨🇳 🇨🇴 🇨🇵 🇨🇷 🇨🇺 🇨🇻 🇨🇼 🇨🇽 🇨🇾 🇨🇿 🇩🇪 🇩🇬 🇩🇯 🇩🇰 🇩🇲 🇩🇴 🇩🇿 🇪🇦 🇪🇨 🇪🇪 🇪🇬 🇪🇭 🇪🇷 🇪🇸 🇪🇹 🇪🇺 🇫🇮 🇫🇯 🇫🇰 🇫🇲 🇫🇴 🇫🇷 🇬🇦 🇬🇧 🇬🇩 🇬🇪 🇬🇫 🇬🇬 🇬🇭 🇬🇮 🇬🇱 🇬🇲 🇬🇳 🇬🇵 🇬🇶 🇬🇷 🇬🇸 🇬🇹 🇬🇺 🇬🇼 🇬🇾 🇭🇰 🇭🇲 🇭🇳 🇭🇷 🇭🇹 🇭🇺 🇮🇨 🇮🇩 🇮🇪 🇮🇱 🇮🇲 🇮🇳 🇮🇴 🇮🇶 🇮🇷 🇮🇸 🇮🇹 🇯🇪 🇯🇲 🇯🇴 🇯🇵 🇰🇪 🇰🇬 🇰🇭 🇰🇮 🇰🇲 🇰🇳 🇰🇵 🇰🇷 🇰🇼 🇰🇾 🇰🇿 🇱🇦 🇱🇧 🇱🇨 🇱🇮 🇱🇰 🇱🇷 🇱🇸 🇱🇹 🇱🇺 🇱🇻 🇱🇾 🇲🇦 🇲🇨 🇲🇩 🇲🇪 🇲🇫 🇲🇬 🇲🇭 🇲🇰 🇲🇱 🇲🇲 🇲🇳 🇲🇴 🇲🇵 🇲🇶 🇲🇷 🇲🇸 🇲🇹 🇲🇺 🇲🇻 🇲🇼 🇲🇽 🇲🇾 🇲🇿 🇳🇦 🇳🇨 🇳🇪 🇳🇫 🇳🇬 🇳🇮 🇳🇱 🇳🇴 🇳🇵 🇳🇷 🇳🇺 🇳🇿 🇴🇲 🇵🇦 🇵🇪 🇵🇫 🇵🇬 🇵🇭 🇵🇰 🇵🇱 🇵🇲 🇵🇳 🇵🇷 🇵🇸 🇵🇹 🇵🇼 🇵🇾 🇶🇦 🇷🇪 🇷🇴 🇷🇸 🇷🇺 🇷🇼 🇸🇦 🇸🇧 🇸🇨 🇸🇩 🇸🇪 🇸🇬 🇸🇭 🇸🇮 🇸🇯 🇸🇰 🇸🇱 🇸🇲 🇸🇳 🇸🇴 🇸🇷 🇸🇸 🇸🇹 🇸🇻 🇸🇽 🇸🇾 🇸🇿 🇹🇦 🇹🇨 🇹🇩 🇹🇫 🇹🇬 🇹🇭 🇹🇯 🇹🇰 🇹🇱 🇹🇲 🇹🇳 🇹🇴 🇹🇷 🇹🇹 🇹🇻 🇹🇼 🇹🇿 🇺🇦 🇺🇬 🇺🇲 🇺🇳 🇺🇸 🇺🇾 🇺🇿 🇻🇦 🇻🇨 🇻🇪 🇻🇬 🇻🇮 🇻🇳 🇻🇺 🇼🇫 🇼🇸 🇽🇰 🇾🇪 🇾🇹 🇿🇦 🇿🇲 🇿🇼 🈁 🈂️ 🈚 🈯 🈲 🈳 🈴 🈵 🈶 🈷️ 🈸 🈹 🈺 🉐 🉑 🌀 🌁 🌂 🌃 🌄 🌅 🌆 🌇 🌈 🌉 🌊 🌋 🌌 🌍 🌎 🌏 🌐 🌑 🌒 🌓 🌔 🌕 🌖 🌗 🌘 🌙 🌚 🌛 🌜 🌝 🌞 🌟 🌠 🌡️ 🌤️ 🌥️ 🌦️ 🌧️ 🌨️ 🌩️ 🌪️ 🌫️ 🌬️ 🌭 🌮 🌯 🌰 🌱 🌲 🌳 🌴 🌵 🌶️ 🌷 🌸 🌹 🌺 🌻 🌼 🌽 🌾 🌿 🍀 🍁 🍂 🍃 🍄 🍅 🍆 🍇 🍈 🍉 🍊 🍋 🍌 🍍 🍎 🍏 🍐 🍑 🍒 🍓 🍔 🍕 🍖 🍗 🍘 🍙 🍚 🍛 🍜 🍝 🍞 🍟 🍠 🍡 🍢 🍣 🍤 🍥 🍦 🍧 🍨 🍩 🍪 🍫 🍬 🍭 🍮 🍯 🍰 🍱 🍲 🍳 🍴 🍵 🍶 🍷 🍸 🍹 🍺 🍻 🍼 🍽️ 🍾 🍿 🎀 🎁 🎂 🎃 🎄 🎅 🎆 🎇 🎈 🎉 🎊 🎋 🎌 🎍 🎎 🎏 🎐 🎑 🎒 🎓 🎖️ 🎗️ 🎙️ 🎚️ 🎛️ 🎞️ 🎟️ 🎠 🎡 🎢 🎣 🎤 🎥 🎦 🎧 🎨 🎩 🎪 🎫 🎬 🎭 🎮 🎯 🎰 🎱 🎲 🎳 🎴 🎵 🎶 🎷 🎸 🎹 🎺 🎻 🎼 🎽 🎾 🎿 🏀 🏁 🏂 🏃‍♀️ 🏃‍♂️ 🏃 🏄‍♀️ 🏄‍♂️ 🏄 🏅 🏆 🏇 🏈 🏉 🏊‍♀️ 🏊‍♂️ 🏊 🏋️‍♀️ 🏋️‍♂️ 🏋️ 🏌️‍♀️ 🏌️‍♂️ 🏌️ 🏍️ 🏎️ 🏏 🏐 🏑 🏒 🏓 🏔️ 🏕️ 🏖️ 🏗️ 🏘️ 🏙️ 🏚️ 🏛️ 🏜️ 🏝️ 🏞️ 🏟️ 🏠 🏡 🏢 🏣 🏤 🏥 🏦 🏧 🏨 🏩 🏪 🏫 🏬 🏭 🏮 🏯 🏰 🏳️‍🌈 🏳️ 🏴‍☠️ 🏴󠁧󠁢󠁥󠁮󠁧󠁿 🏴󠁧󠁢󠁳󠁣󠁴󠁿 🏴󠁧󠁢󠁷󠁬󠁳󠁿 🏴 🏵️ 🏷️ 🏸 🏹 🏺 🏻 🏼 🏽 🏾 🏿 🐀 🐁 🐂 🐃 🐄 🐅 🐆 🐇 🐈 🐉 🐊 🐋 🐌 🐍 🐎 🐏 🐐 🐑 🐒 🐓 🐔 🐕‍🦺 🐕 🐖 🐗 🐘 🐙 🐚 🐛 🐜 🐝 🐞 🐟 🐠 🐡 🐢 🐣 🐤 🐥 🐦 🐧 🐨 🐩 🐪 🐫 🐬 🐭 🐮 🐯 🐰 🐱 🐲 🐳 🐴 🐵 🐶 🐷 🐸 🐹 🐺 🐻 🐼 🐽 🐾 🐿️ 👀 👁️‍🗨️ 👁️ 👂 👃 👄 👅 👆 👇 👈 👉 👊 👋 👌 👍 👎 👏 👐 👑 👒 👓 👔 👕 👖 👗 👘 👙 👚 👛 👜 👝 👞 👟 👠 👡 👢 👣 👤 👥 👦 👧 👨‍🌾 👨‍🍳 👨‍🎓 👨‍🎤 👨‍🎨 👨‍🏫 👨‍🏭 👨‍👦‍👦 👨‍👦 👨‍👧‍👦 👨‍👧‍👧 👨‍👧 👨‍👨‍👦 👨‍👨‍👦‍👦 👨‍👨‍👧 👨‍👨‍👧‍👦 👨‍👨‍👧‍👧 👨‍👩‍👦 👨‍👩‍👦‍👦 👨‍👩‍👧 👨‍👩‍👧‍👦 👨‍👩‍👧‍👧 👨‍💻 👨‍💼 👨‍🔧 👨‍🔬 👨‍🚀 👨‍🚒 👨‍🦯 👨‍🦰 👨‍🦱 👨‍🦲 👨‍🦳 👨‍🦼 👨‍🦽 👨‍⚕️ 👨‍⚖️ 👨‍✈️ 👨‍❤️‍👨 👨‍❤️‍💋‍👨 👨 👩‍🌾 👩‍🍳 👩‍🎓 👩‍🎤 👩‍🎨 👩‍🏫 👩‍🏭 👩‍👦‍👦 👩‍👦 👩‍👧‍👦 👩‍👧‍👧 👩‍👧 👩‍👩‍👦 👩‍👩‍👦‍👦 👩‍👩‍👧 👩‍👩‍👧‍👦 👩‍👩‍👧‍👧 👩‍💻 👩‍💼 👩‍🔧 👩‍🔬 👩‍🚀 👩‍🚒 👩‍🦯 👩‍🦰 👩‍🦱 👩‍🦲 👩‍🦳 👩‍🦼 👩‍🦽 👩‍⚕️ 👩‍⚖️ 👩‍✈️ 👩‍❤️‍👨 👩‍❤️‍👩 👩‍❤️‍💋‍👨 👩‍❤️‍💋‍👩 👩 👪 👫 👬 👭 👮‍♀️ 👮‍♂️ 👮 👯‍♀️ 👯‍♂️ 👯 👰 👱‍♀️ 👱‍♂️ 👱 👲 👳‍♀️ 👳‍♂️ 👳 👴 👵 👶 👷‍♀️ 👷‍♂️ 👷 👸 👹 👺 👻 👼 👽 👾 👿 💀 💁‍♀️ 💁‍♂️ 💁 💂‍♀️ 💂‍♂️ 💂 💃 💄 💅 💆‍♀️ 💆‍♂️ 💆 💇‍♀️ 💇‍♂️ 💇 💈 💉 💊 💋 💌 💍 💎 💏 💐 💑 💒 💓 💔 💕 💖 💗 💘 💙 💚 💛 💜 💝 💞 💟 💠 💡 💢 💣 💤 💥 💦 💧 💨 💩 💪 💫 💬 💭 💮 💯 💰 💱 💲 💳 💴 💵 💶 💷 💸 💹 💺 💻 💼 💽 💾 💿 📀 📁 📂 📃 📄 📅 📆 📇 📈 📉 📊 📋 📌 📍 📎 📏 📐 📑 📒 📓 📔 📕 📖 📗 📘 📙 📚 📛 📜 📝 📞 📟 📠 📡 📢 📣 📤 📥 📦 📧 📨 📩 📪 📫 📬 📭 📮 📯 📰 📱 📲 📳 📴 📵 📶 📷 📸 📹 📺 📻 📼 📽️ 📿 🔀 🔁 🔂 🔃 🔄 🔅 🔆 🔇 🔈 🔉 🔊 🔋 🔌 🔍 🔎 🔏 🔐 🔑 🔒 🔓 🔔 🔕 🔖 🔗 🔘 🔙 🔚 🔛 🔜 🔝 🔞 🔟 🔠 🔡 🔢 🔣 🔤 🔥 🔦 🔧 🔨 🔩 🔪 🔫 🔬 🔭 🔮 🔯 🔰 🔱 🔲 🔳 🔴 🔵 🔶 🔷 🔸 🔹 🔺 🔻 🔼 🔽 🕉️ 🕊️ 🕋 🕌 🕍 🕎 🕐 🕑 🕒 🕓 🕔 🕕 🕖 🕗 🕘 🕙 🕚 🕛 🕜 🕝 🕞 🕟 🕠 🕡 🕢 🕣 🕤 🕥 🕦 🕧 🕯️ 🕰️ 🕳️ 🕴️ 🕵️‍♀️ 🕵️‍♂️ 🕵️ 🕶️ 🕷️ 🕸️ 🕹️ 🕺 🖇️ 🖊️ 🖋️ 🖌️ 🖍️ 🖐️ 🖕 🖖 🖤 🖥️ 🖨️ 🖱️ 🖲️ 🖼️ 🗂️ 🗃️ 🗄️ 🗑️ 🗒️ 🗓️ 🗜️ 🗝️ 🗞️ 🗡️ 🗣️ 🗨️ 🗯️ 🗳️ 🗺️ 🗻 🗼 🗽 🗾 🗿 😀 😁 😂 😃 😄 😅 😆 😇 😈 😉 😊 😋 😌 😍 😎 😏 😐 😑 😒 😓 😔 😕 😖 😗 😘 😙 😚 😛 😜 😝 😞 😟 😠 😡 😢 😣 😤 😥 😦 😧 😨 😩 😪 😫 😬 😭 😮 😯 😰 😱 😲 😳 😴 😵 😶 😷 😸 😹 😺 😻 😼 😽 😾 😿 🙀 🙁 🙂 🙃 🙄 🙅‍♀️ 🙅‍♂️ 🙅 🙆‍♀️ 🙆‍♂️ 🙆 🙇‍♀️ 🙇‍♂️ 🙇 🙈 🙉 🙊 🙋‍♀️ 🙋‍♂️ 🙋 🙌 🙍‍♀️ 🙍‍♂️ 🙍 🙎‍♀️ 🙎‍♂️ 🙎 🙏 🚀 🚁 🚂 🚃 🚄 🚅 🚆 🚇 🚈 🚉 🚊 🚋 🚌 🚍 🚎 🚏 🚐 🚑 🚒 🚓 🚔 🚕 🚖 🚗 🚘 🚙 🚚 🚛 🚜 🚝 🚞 🚟 🚠 🚡 🚢 🚣‍♀️ 🚣‍♂️ 🚣 🚤 🚥 🚦 🚧 🚨 🚩 🚪 🚫 🚬 🚭 🚮 🚯 🚰 🚱 🚲 🚳 🚴‍♀️ 🚴‍♂️ 🚴 🚵‍♀️ 🚵‍♂️ 🚵 🚶‍♀️ 🚶‍♂️ 🚶 🚷 🚸 🚹 🚺 🚻 🚼 🚽 🚾 🚿 🛀 🛁 🛂 🛃 🛄 🛅 🛋️ 🛌 🛍️ 🛎️ 🛏️ 🛐 🛑 🛒 🛕 🛠️ 🛡️ 🛢️ 🛣️ 🛤️ 🛥️ 🛩️ 🛫 🛬 🛰️ 🛳️ 🛴 🛵 🛶 🛷 🛸 🛹 🛺 🟠 🟡 🟢 🟣 🟤 🟥 🟦 🟧 🟨 🟩 🟪 🟫 🤍 🤎 🤏 🤐 🤑 🤒 🤓 🤔 🤕 🤖 🤗 🤘 🤙 🤚 🤛 🤜 🤝 🤞 🤟 🤠 🤡 🤢 🤣 🤤 🤥 🤦‍♀️ 🤦‍♂️ 🤦 🤧 🤨 🤩 🤪 🤫 🤬 🤭 🤮 🤯 🤰 🤱 🤲 🤳 🤴 🤵 🤶 🤷‍♀️ 🤷‍♂️ 🤷 🤸‍♀️ 🤸‍♂️ 🤸 🤹‍♀️ 🤹‍♂️ 🤹 🤺 🤼‍♀️ 🤼‍♂️ 🤼 🤽‍♀️ 🤽‍♂️ 🤽 🤾‍♀️ 🤾‍♂️ 🤾 🤿 🥀 🥁 🥂 🥃 🥄 🥅 🥇 🥈 🥉 🥊 🥋 🥌 🥍 🥎 🥏 🥐 🥑 🥒 🥓 🥔 🥕 🥖 🥗 🥘 🥙 🥚 🥛 🥜 🥝 🥞 🥟 🥠 🥡 🥢 🥣 🥤 🥥 🥦 🥧 🥨 🥩 🥪 🥫 🥬 🥭 🥮 🥯 🥰 🥱 🥳 🥴 🥵 🥶 🥺 🥻 🥼 🥽 🥾 🥿 🦀 🦁 🦂 🦃 🦄 🦅 🦆 🦇 🦈 🦉 🦊 🦋 🦌 🦍 🦎 🦏 🦐 🦑 🦒 🦓 🦔 🦕 🦖 🦗 🦘 🦙 🦚 🦛 🦜 🦝 🦞 🦟 🦠 🦡 🦢 🦥 🦦 🦧 🦨 🦩 🦪 🦮 🦯 🦴 🦵 🦶 🦷 🦸‍♀️ 🦸‍♂️ 🦸 🦹‍♀️ 🦹‍♂️ 🦹 🦺 🦻 🦼 🦽 🦾 🦿 🧀 🧁 🧂 🧃 🧄 🧅 🧆 🧇 🧈 🧉 🧊 🧍‍♀️ 🧍‍♂️ 🧍 🧎‍♀️ 🧎‍♂️ 🧎 🧏‍♀️ 🧏‍♂️ 🧏 🧐 🧑‍🌾 🧑‍🍳 🧑‍🎓 🧑‍🎤 🧑‍🎨 🧑‍🏫 🧑‍🏭 🧑‍💻 🧑‍💼 🧑‍🔧 🧑‍🔬 🧑‍🚀 🧑‍🚒 🧑‍🤝‍🧑 🧑‍🦯 🧑‍🦰 🧑‍🦱 🧑‍🦲 🧑‍🦳 🧑‍🦼 🧑‍🦽 🧑‍⚕️ 🧑‍⚖️ 🧑‍✈️ 🧑 🧒 🧓 🧔 🧕 🧖‍♀️ 🧖‍♂️ 🧖 🧗‍♀️ 🧗‍♂️ 🧗 🧘‍♀️ 🧘‍♂️ 🧘 🧙‍♀️ 🧙‍♂️ 🧙 🧚‍♀️ 🧚‍♂️ 🧚 🧛‍♀️ 🧛‍♂️ 🧛 🧜‍♀️ 🧜‍♂️ 🧜 🧝‍♀️ 🧝‍♂️ 🧝 🧞‍♀️ 🧞‍♂️ 🧞 🧟‍♀️ 🧟‍♂️ 🧟 🧠 🧡 🧢 🧣 🧤 🧥 🧦 🧧 🧨 🧩 🧪 🧫 🧬 🧭 🧮 🧯 🧰 🧱 🧲 🧳 🧴 🧵 🧶 🧷 🧸 🧹 🧺 🧻 🧼 🧽 🧾 🧿 🩰 🩱 🩲 🩳 🩸 🩹 🩺 🪀 🪁 🪂 🪐 🪑 🪒 🪓 🪔 🪕 ‼️ ⁉️ ™️ ℹ️ ↔️ ↕️ ↖️ ↗️ ↘️ ↙️ ↩️ ↪️ ⌚ ⌛ ⌨️ ⏏️ ⏩ ⏪ ⏫ ⏬ ⏭️ ⏮️ ⏯️ ⏰ ⏱️ ⏲️ ⏳ ⏸️ ⏹️ ⏺️ Ⓜ️ ▪️ ▫️ ▶️ ◀️ ◻️ ◼️ ◽ ◾ ☀️ ☁️ ☂️ ☃️ ☄️ ☎️ ☑️ ☔ ☕ ☘️ ☝️ ☠️ ☢️ ☣️ ☦️ ☪️ ☮️ ☯️ ☸️ ☹️ ☺️ ♀️ ♂️ ♈ ♉ ♊ ♋ ♌ ♍ ♎ ♏ ♐ ♑ ♒ ♓ ♟️ ♠️ ♣️ ♥️ ♦️ ♨️ ♻️ ♾️ ♿ ⚒️ ⚓ ⚔️ ⚕️ ⚖️ ⚗️ ⚙️ ⚛️ ⚜️ ⚠️ ⚡ ⚪ ⚫ ⚰️ ⚱️ ⚽ ⚾ ⛄ ⛅ ⛈️ ⛎ ⛏️ ⛑️ ⛓️ ⛔ ⛩️ ⛪ ⛰️ ⛱️ ⛲ ⛳ ⛴️ ⛵ ⛷️ ⛸️ ⛹️‍♀️ ⛹️‍♂️ ⛹️ ⛺ ⛽ ✂️ ✅ ✈️ ✉️ ✊ ✋ ✌️ ✍️ ✏️ ✒️ ✔️ ✖️ ✝️ ✡️ ✨ ✳️ ✴️ ❄️ ❇️ ❌ ❎ ❓ ❔ ❕ ❗ ❣️ ❤️ ➕ ➖ ➗ ➡️ ➰ ➿ ⤴️ ⤵️ ⬅️ ⬆️ ⬇️ ⬛ ⬜ ⭐ ⭕ 〰️ 〽️ ㊗️ ㊙️''',
  ),
];
