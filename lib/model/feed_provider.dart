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
    _devOps = devOpsListPlaceholder;
    _issues = issuesListPlaceholder;
    _news = newsPlaceholder;

    notifyListeners();
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
      content: '''
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
©️	:copyright:
®️	:registered:
🀄	:mahjong:
🃏	:black_joker:
🅰️	:a:
🅱️	:b:
🅾️	:o2:
🅿️	:parking:
🆎	:ab:
🆑	:cl:
🆒	:cool:
🆓	:free:
🆔	:id:
🆕	:new:
🆖	:ng:
🆗	:ok:
🆘	:sos:
🆙	:up:
🆚	:vs:
🇦🇨	:flag-ac:
🇦🇩	:flag-ad:
🇦🇪	:flag-ae:
🇦🇫	:flag-af:
🇦🇬	:flag-ag:
🇦🇮	:flag-ai:
🇦🇱	:flag-al:
🇦🇲	:flag-am:
🇦🇴	:flag-ao:
🇦🇶	:flag-aq:
🇦🇷	:flag-ar:
🇦🇸	:flag-as:
🇦🇹	:flag-at:
🇦🇺	:flag-au:
🇦🇼	:flag-aw:
🇦🇽	:flag-ax:
🇦🇿	:flag-az:
🇧🇦	:flag-ba:
🇧🇧	:flag-bb:
🇧🇩	:flag-bd:
🇧🇪	:flag-be:
🇧🇫	:flag-bf:
🇧🇬	:flag-bg:
🇧🇭	:flag-bh:
🇧🇮	:flag-bi:
🇧🇯	:flag-bj:
🇧🇱	:flag-bl:
🇧🇲	:flag-bm:
🇧🇳	:flag-bn:
🇧🇴	:flag-bo:
🇧🇶	:flag-bq:
🇧🇷	:flag-br:
🇧🇸	:flag-bs:
🇧🇹	:flag-bt:
🇧🇻	:flag-bv:
🇧🇼	:flag-bw:
🇧🇾	:flag-by:
🇧🇿	:flag-bz:
🇨🇦	:flag-ca:
🇨🇨	:flag-cc:
🇨🇩	:flag-cd:
🇨🇫	:flag-cf:
🇨🇬	:flag-cg:
🇨🇭	:flag-ch:
🇨🇮	:flag-ci:
🇨🇰	:flag-ck:
🇨🇱	:flag-cl:
🇨🇲	:flag-cm:
🇨🇳	:cn:
🇨🇴	:flag-co:
🇨🇵	:flag-cp:
🇨🇷	:flag-cr:
🇨🇺	:flag-cu:
🇨🇻	:flag-cv:
🇨🇼	:flag-cw:
🇨🇽	:flag-cx:
🇨🇾	:flag-cy:
🇨🇿	:flag-cz:
🇩🇪	:de:
🇩🇬	:flag-dg:
🇩🇯	:flag-dj:
🇩🇰	:flag-dk:
🇩🇲	:flag-dm:
🇩🇴	:flag-do:
🇩🇿	:flag-dz:
🇪🇦	:flag-ea:
🇪🇨	:flag-ec:
🇪🇪	:flag-ee:
🇪🇬	:flag-eg:
🇪🇭	:flag-eh:
🇪🇷	:flag-er:
🇪🇸	:es:
🇪🇹	:flag-et:
🇪🇺	:flag-eu:
🇫🇮	:flag-fi:
🇫🇯	:flag-fj:
🇫🇰	:flag-fk:
🇫🇲	:flag-fm:
🇫🇴	:flag-fo:
🇫🇷	:fr:
🇬🇦	:flag-ga:
🇬🇧	:gb:
🇬🇩	:flag-gd:
🇬🇪	:flag-ge:
🇬🇫	:flag-gf:
🇬🇬	:flag-gg:
🇬🇭	:flag-gh:
🇬🇮	:flag-gi:
🇬🇱	:flag-gl:
🇬🇲	:flag-gm:
🇬🇳	:flag-gn:
🇬🇵	:flag-gp:
🇬🇶	:flag-gq:
🇬🇷	:flag-gr:
🇬🇸	:flag-gs:
🇬🇹	:flag-gt:
🇬🇺	:flag-gu:
🇬🇼	:flag-gw:
🇬🇾	:flag-gy:
🇭🇰	:flag-hk:
🇭🇲	:flag-hm:
🇭🇳	:flag-hn:
🇭🇷	:flag-hr:
🇭🇹	:flag-ht:
🇭🇺	:flag-hu:
🇮🇨	:flag-ic:
🇮🇩	:flag-id:
🇮🇪	:flag-ie:
🇮🇱	:flag-il:
🇮🇲	:flag-im:
🇮🇳	:flag-in:
🇮🇴	:flag-io:
🇮🇶	:flag-iq:
🇮🇷	:flag-ir:
🇮🇸	:flag-is:
🇮🇹	:it:
🇯🇪	:flag-je:
🇯🇲	:flag-jm:
🇯🇴	:flag-jo:
🇯🇵	:jp:
🇰🇪	:flag-ke:
🇰🇬	:flag-kg:
🇰🇭	:flag-kh:
🇰🇮	:flag-ki:
🇰🇲	:flag-km:
🇰🇳	:flag-kn:
🇰🇵	:flag-kp:
🇰🇷	:kr:
🇰🇼	:flag-kw:
🇰🇾	:flag-ky:
🇰🇿	:flag-kz:
🇱🇦	:flag-la:
🇱🇧	:flag-lb:
🇱🇨	:flag-lc:
🇱🇮	:flag-li:
🇱🇰	:flag-lk:
🇱🇷	:flag-lr:
🇱🇸	:flag-ls:
🇱🇹	:flag-lt:
🇱🇺	:flag-lu:
🇱🇻	:flag-lv:
🇱🇾	:flag-ly:
🇲🇦	:flag-ma:
🇲🇨	:flag-mc:
🇲🇩	:flag-md:
🇲🇪	:flag-me:
🇲🇫	:flag-mf:
🇲🇬	:flag-mg:
🇲🇭	:flag-mh:
🇲🇰	:flag-mk:
🇲🇱	:flag-ml:
🇲🇲	:flag-mm:
🇲🇳	:flag-mn:
🇲🇴	:flag-mo:
🇲🇵	:flag-mp:
🇲🇶	:flag-mq:
🇲🇷	:flag-mr:
🇲🇸	:flag-ms:
🇲🇹	:flag-mt:
🇲🇺	:flag-mu:
🇲🇻	:flag-mv:
🇲🇼	:flag-mw:
🇲🇽	:flag-mx:
🇲🇾	:flag-my:
🇲🇿	:flag-mz:
🇳🇦	:flag-na:
🇳🇨	:flag-nc:
🇳🇪	:flag-ne:
🇳🇫	:flag-nf:
🇳🇬	:flag-ng:
🇳🇮	:flag-ni:
🇳🇱	:flag-nl:
🇳🇴	:flag-no:
🇳🇵	:flag-np:
🇳🇷	:flag-nr:
🇳🇺	:flag-nu:
🇳🇿	:flag-nz:
🇴🇲	:flag-om:
🇵🇦	:flag-pa:
🇵🇪	:flag-pe:
🇵🇫	:flag-pf:
🇵🇬	:flag-pg:
🇵🇭	:flag-ph:
🇵🇰	:flag-pk:
🇵🇱	:flag-pl:
🇵🇲	:flag-pm:
🇵🇳	:flag-pn:
🇵🇷	:flag-pr:
🇵🇸	:flag-ps:
🇵🇹	:flag-pt:
🇵🇼	:flag-pw:
🇵🇾	:flag-py:
🇶🇦	:flag-qa:
🇷🇪	:flag-re:
🇷🇴	:flag-ro:
🇷🇸	:flag-rs:
🇷🇺	:ru:
🇷🇼	:flag-rw:
🇸🇦	:flag-sa:
🇸🇧	:flag-sb:
🇸🇨	:flag-sc:
🇸🇩	:flag-sd:
🇸🇪	:flag-se:
🇸🇬	:flag-sg:
🇸🇭	:flag-sh:
🇸🇮	:flag-si:
🇸🇯	:flag-sj:
🇸🇰	:flag-sk:
🇸🇱	:flag-sl:
🇸🇲	:flag-sm:
🇸🇳	:flag-sn:
🇸🇴	:flag-so:
🇸🇷	:flag-sr:
🇸🇸	:flag-ss:
🇸🇹	:flag-st:
🇸🇻	:flag-sv:
🇸🇽	:flag-sx:
🇸🇾	:flag-sy:
🇸🇿	:flag-sz:
🇹🇦	:flag-ta:
🇹🇨	:flag-tc:
🇹🇩	:flag-td:
🇹🇫	:flag-tf:
🇹🇬	:flag-tg:
🇹🇭	:flag-th:
🇹🇯	:flag-tj:
🇹🇰	:flag-tk:
🇹🇱	:flag-tl:
🇹🇲	:flag-tm:
🇹🇳	:flag-tn:
🇹🇴	:flag-to:
🇹🇷	:flag-tr:
🇹🇹	:flag-tt:
🇹🇻	:flag-tv:
🇹🇼	:flag-tw:
🇹🇿	:flag-tz:
🇺🇦	:flag-ua:
🇺🇬	:flag-ug:
🇺🇲	:flag-um:
🇺🇳	:flag-un:
🇺🇸	:us:
🇺🇾	:flag-uy:
🇺🇿	:flag-uz:
🇻🇦	:flag-va:
🇻🇨	:flag-vc:
🇻🇪	:flag-ve:
🇻🇬	:flag-vg:
🇻🇮	:flag-vi:
🇻🇳	:flag-vn:
🇻🇺	:flag-vu:
🇼🇫	:flag-wf:
🇼🇸	:flag-ws:
🇽🇰	:flag-xk:
🇾🇪	:flag-ye:
🇾🇹	:flag-yt:
🇿🇦	:flag-za:
🇿🇲	:flag-zm:
🇿🇼	:flag-zw:
🈁	:koko:
🈂️	:sa:
🈚	:u7121:
🈯	:u6307:
🈲	:u7981:
🈳	:u7a7a:
🈴	:u5408:
🈵	:u6e80:
🈶	:u6709:
🈷️	:u6708:
🈸	:u7533:
🈹	:u5272:
🈺	:u55b6:
🉐	:ideograph_advantage:
🉑	:accept:
🌀	:cyclone:
🌁	:foggy:
🌂	:closed_umbrella:
🌃	:night_with_stars:
🌄	:sunrise_over_mountains:
🌅	:sunrise:
🌆	:city_sunset:
🌇	:city_sunrise:
🌈	:rainbow:
🌉	:bridge_at_night:
🌊	:ocean:
🌋	:volcano:
🌌	:milky_way:
🌍	:earth_africa:
🌎	:earth_americas:
🌏	:earth_asia:
🌐	:globe_with_meridians:
🌑	:new_moon:
🌒	:waxing_crescent_moon:
🌓	:first_quarter_moon:
🌔	:moon:
🌕	:full_moon:
🌖	:waning_gibbous_moon:
🌗	:last_quarter_moon:
🌘	:waning_crescent_moon:
🌙	:crescent_moon:
🌚	:new_moon_with_face:
🌛	:first_quarter_moon_with_face:
🌜	:last_quarter_moon_with_face:
🌝	:full_moon_with_face:
🌞	:sun_with_face:
🌟	:star2:
🌠	:stars:
🌡️	:thermometer:
🌤️	:mostly_sunny:
🌥️	:barely_sunny:
🌦️	:partly_sunny_rain:
🌧️	:rain_cloud:
🌨️	:snow_cloud:
🌩️	:lightning:
🌪️	:tornado:
🌫️	:fog:
🌬️	:wind_blowing_face:
🌭	:hotdog:
🌮	:taco:
🌯	:burrito:
🌰	:chestnut:
🌱	:seedling:
🌲	:evergreen_tree:
🌳	:deciduous_tree:
🌴	:palm_tree:
🌵	:cactus:
🌶️	:hot_pepper:
🌷	:tulip:
🌸	:cherry_blossom:
🌹	:rose:
🌺	:hibiscus:
🌻	:sunflower:
🌼	:blossom:
🌽	:corn:
🌾	:ear_of_rice:
🌿	:herb:
🍀	:four_leaf_clover:
🍁	:maple_leaf:
🍂	:fallen_leaf:
🍃	:leaves:
🍄	:mushroom:
🍅	:tomato:
🍆	:eggplant:
🍇	:grapes:
🍈	:melon:
🍉	:watermelon:
🍊	:tangerine:
🍋	:lemon:
🍌	:banana:
🍍	:pineapple:
🍎	:apple:
🍏	:green_apple:
🍐	:pear:
🍑	:peach:
🍒	:cherries:
🍓	:strawberry:
🍔	:hamburger:
🍕	:pizza:
🍖	:meat_on_bone:
🍗	:poultry_leg:
🍘	:rice_cracker:
🍙	:rice_ball:
🍚	:rice:
🍛	:curry:
🍜	:ramen:
🍝	:spaghetti:
🍞	:bread:
🍟	:fries:
🍠	:sweet_potato:
🍡	:dango:
🍢	:oden:
🍣	:sushi:
🍤	:fried_shrimp:
🍥	:fish_cake:
🍦	:icecream:
🍧	:shaved_ice:
🍨	:ice_cream:
🍩	:doughnut:
🍪	:cookie:
🍫	:chocolate_bar:
🍬	:candy:
🍭	:lollipop:
🍮	:custard:
🍯	:honey_pot:
🍰	:cake:
🍱	:bento:
🍲	:stew:
🍳	:fried_egg:
🍴	:fork_and_knife:
🍵	:tea:
🍶	:sake:
🍷	:wine_glass:
🍸	:cocktail:
🍹	:tropical_drink:
🍺	:beer:
🍻	:beers:
🍼	:baby_bottle:
🍽️	:knife_fork_plate:
🍾	:champagne:
🍿	:popcorn:
🎀	:ribbon:
🎁	:gift:
🎂	:birthday:
🎃	:jack_o_lantern:
🎄	:christmas_tree:
🎅	:santa:
🎆	:fireworks:
🎇	:sparkler:
🎈	:balloon:
🎉	:tada:
🎊	:confetti_ball:
🎋	:tanabata_tree:
🎌	:crossed_flags:
🎍	:bamboo:
🎎	:dolls:
🎏	:flags:
🎐	:wind_chime:
🎑	:rice_scene:
🎒	:school_satchel:
🎓	:mortar_board:
🎖️	:medal:
🎗️	:reminder_ribbon:
🎙️	:studio_microphone:
🎚️	:level_slider:
🎛️	:control_knobs:
🎞️	:film_frames:
🎟️	:admission_tickets:
🎠	:carousel_horse:
🎡	:ferris_wheel:
🎢	:roller_coaster:
🎣	:fishing_pole_and_fish:
🎤	:microphone:
🎥	:movie_camera:
🎦	:cinema:
🎧	:headphones:
🎨	:art:
🎩	:tophat:
🎪	:circus_tent:
🎫	:ticket:
🎬	:clapper:
🎭	:performing_arts:
🎮	:video_game:
🎯	:dart:
🎰	:slot_machine:
🎱	:8ball:
🎲	:game_die:
🎳	:bowling:
🎴	:flower_playing_cards:
🎵	:musical_note:
🎶	:notes:
🎷	:saxophone:
🎸	:guitar:
🎹	:musical_keyboard:
🎺	:trumpet:
🎻	:violin:
🎼	:musical_score:
🎽	:running_shirt_with_sash:
🎾	:tennis:
🎿	:ski:
🏀	:basketball:
🏁	:checkered_flag:
🏂	:snowboarder:
🏃‍♀️	:woman-running:
🏃‍♂️	:man-running:
🏃	:runner:
🏄‍♀️	:woman-surfing:
🏄‍♂️	:man-surfing:
🏄	:surfer:
🏅	:sports_medal:
🏆	:trophy:
🏇	:horse_racing:
🏈	:football:
🏉	:rugby_football:
🏊‍♀️	:woman-swimming:
🏊‍♂️	:man-swimming:
🏊	:swimmer:
🏋️‍♀️	:woman-lifting-weights:
🏋️‍♂️	:man-lifting-weights:
🏋️	:weight_lifter:
🏌️‍♀️	:woman-golfing:
🏌️‍♂️	:man-golfing:
🏌️	:golfer:
🏍️	:racing_motorcycle:
🏎️	:racing_car:
🏏	:cricket_bat_and_ball:
🏐	:volleyball:
🏑	:field_hockey_stick_and_ball:
🏒	:ice_hockey_stick_and_puck:
🏓	:table_tennis_paddle_and_ball:
🏔️	:snow_capped_mountain:
🏕️	:camping:
🏖️	:beach_with_umbrella:
🏗️	:building_construction:
🏘️	:house_buildings:
🏙️	:cityscape:
🏚️	:derelict_house_building:
🏛️	:classical_building:
🏜️	:desert:
🏝️	:desert_island:
🏞️	:national_park:
🏟️	:stadium:
🏠	:house:
🏡	:house_with_garden:
🏢	:office:
🏣	:post_office:
🏤	:european_post_office:
🏥	:hospital:
🏦	:bank:
🏧	:atm:
🏨	:hotel:
🏩	:love_hotel:
🏪	:convenience_store:
🏫	:school:
🏬	:department_store:
🏭	:factory:
🏮	:izakaya_lantern:
🏯	:japanese_castle:
🏰	:european_castle:
🏳️‍🌈	:rainbow-flag:
🏳️	:waving_white_flag:
🏴‍☠️	:pirate_flag:
🏴󠁧󠁢󠁥󠁮󠁧󠁿	:flag-england:
🏴󠁧󠁢󠁳󠁣󠁴󠁿	:flag-scotland:
🏴󠁧󠁢󠁷󠁬󠁳󠁿	:flag-wales:
🏴	:waving_black_flag:
🏵️	:rosette:
🏷️	:label:
🏸	:badminton_racquet_and_shuttlecock:
🏹	:bow_and_arrow:
🏺	:amphora:
🏻	:skin-tone-2:
🏼	:skin-tone-3:
🏽	:skin-tone-4:
🏾	:skin-tone-5:
🏿	:skin-tone-6:
🐀	:rat:
🐁	:mouse2:
🐂	:ox:
🐃	:water_buffalo:
🐄	:cow2:
🐅	:tiger2:
🐆	:leopard:
🐇	:rabbit2:
🐈	:cat2:
🐉	:dragon:
🐊	:crocodile:
🐋	:whale2:
🐌	:snail:
🐍	:snake:
🐎	:racehorse:
🐏	:ram:
🐐	:goat:
🐑	:sheep:
🐒	:monkey:
🐓	:rooster:
🐔	:chicken:
🐕‍🦺	:service_dog:
🐕	:dog2:
🐖	:pig2:
🐗	:boar:
🐘	:elephant:
🐙	:octopus:
🐚	:shell:
🐛	:bug:
🐜	:ant:
🐝	:bee:
🐞	:beetle:
🐟	:fish:
🐠	:tropical_fish:
🐡	:blowfish:
🐢	:turtle:
🐣	:hatching_chick:
🐤	:baby_chick:
🐥	:hatched_chick:
🐦	:bird:
🐧	:penguin:
🐨	:koala:
🐩	:poodle:
🐪	:dromedary_camel:
🐫	:camel:
🐬	:dolphin:
🐭	:mouse:
🐮	:cow:
🐯	:tiger:
🐰	:rabbit:
🐱	:cat:
🐲	:dragon_face:
🐳	:whale:
🐴	:horse:
🐵	:monkey_face:
🐶	:dog:
🐷	:pig:
🐸	:frog:
🐹	:hamster:
🐺	:wolf:
🐻	:bear:
🐼	:panda_face:
🐽	:pig_nose:
🐾	:feet:
🐿️	:chipmunk:
👀	:eyes:
👁️‍🗨️	:eye-in-speech-bubble:
👁️	:eye:
👂	:ear:
👃	:nose:
👄	:lips:
👅	:tongue:
👆	:point_up_2:
👇	:point_down:
👈	:point_left:
👉	:point_right:
👊	:facepunch:
👋	:wave:
👌	:ok_hand:
👍	:+1:
👎	:-1:
👏	:clap:
👐	:open_hands:
👑	:crown:
👒	:womans_hat:
👓	:eyeglasses:
👔	:necktie:
👕	:shirt:
👖	:jeans:
👗	:dress:
👘	:kimono:
👙	:bikini:
👚	:womans_clothes:
👛	:purse:
👜	:handbag:
👝	:pouch:
👞	:mans_shoe:
👟	:athletic_shoe:
👠	:high_heel:
👡	:sandal:
👢	:boot:
👣	:footprints:
👤	:bust_in_silhouette:
👥	:busts_in_silhouette:
👦	:boy:
👧	:girl:
👨‍🌾	:male-farmer:
👨‍🍳	:male-cook:
👨‍🎓	:male-student:
👨‍🎤	:male-singer:
👨‍🎨	:male-artist:
👨‍🏫	:male-teacher:
👨‍🏭	:male-factory-worker:
👨‍👦‍👦	:man-boy-boy:
👨‍👦	:man-boy:
👨‍👧‍👦	:man-girl-boy:
👨‍👧‍👧	:man-girl-girl:
👨‍👧	:man-girl:
👨‍👨‍👦	:man-man-boy:
👨‍👨‍👦‍👦	:man-man-boy-boy:
👨‍👨‍👧	:man-man-girl:
👨‍👨‍👧‍👦	:man-man-girl-boy:
👨‍👨‍👧‍👧	:man-man-girl-girl:
👨‍👩‍👦	:man-woman-boy:
👨‍👩‍👦‍👦	:man-woman-boy-boy:
👨‍👩‍👧	:man-woman-girl:
👨‍👩‍👧‍👦	:man-woman-girl-boy:
👨‍👩‍👧‍👧	:man-woman-girl-girl:
👨‍💻	:male-technologist:
👨‍💼	:male-office-worker:
👨‍🔧	:male-mechanic:
👨‍🔬	:male-scientist:
👨‍🚀	:male-astronaut:
👨‍🚒	:male-firefighter:
👨‍🦯	:man_with_probing_cane:
👨‍🦰	:red_haired_man:
👨‍🦱	:curly_haired_man:
👨‍🦲	:bald_man:
👨‍🦳	:white_haired_man:
👨‍🦼	:man_in_motorized_wheelchair:
👨‍🦽	:man_in_manual_wheelchair:
👨‍⚕️	:male-doctor:
👨‍⚖️	:male-judge:
👨‍✈️	:male-pilot:
👨‍❤️‍👨	:man-heart-man:
👨‍❤️‍💋‍👨	:man-kiss-man:
👨	:man:
👩‍🌾	:female-farmer:
👩‍🍳	:female-cook:
👩‍🎓	:female-student:
👩‍🎤	:female-singer:
👩‍🎨	:female-artist:
👩‍🏫	:female-teacher:
👩‍🏭	:female-factory-worker:
👩‍👦‍👦	:woman-boy-boy:
👩‍👦	:woman-boy:
👩‍👧‍👦	:woman-girl-boy:
👩‍👧‍👧	:woman-girl-girl:
👩‍👧	:woman-girl:
👩‍👩‍👦	:woman-woman-boy:
👩‍👩‍👦‍👦	:woman-woman-boy-boy:
👩‍👩‍👧	:woman-woman-girl:
👩‍👩‍👧‍👦	:woman-woman-girl-boy:
👩‍👩‍👧‍👧	:woman-woman-girl-girl:
👩‍💻	:female-technologist:
👩‍💼	:female-office-worker:
👩‍🔧	:female-mechanic:
👩‍🔬	:female-scientist:
👩‍🚀	:female-astronaut:
👩‍🚒	:female-firefighter:
👩‍🦯	:woman_with_probing_cane:
👩‍🦰	:red_haired_woman:
👩‍🦱	:curly_haired_woman:
👩‍🦲	:bald_woman:
👩‍🦳	:white_haired_woman:
👩‍🦼	:woman_in_motorized_wheelchair:
👩‍🦽	:woman_in_manual_wheelchair:
👩‍⚕️	:female-doctor:
👩‍⚖️	:female-judge:
👩‍✈️	:female-pilot:
👩‍❤️‍👨	:woman-heart-man:
👩‍❤️‍👩	:woman-heart-woman:
👩‍❤️‍💋‍👨	:woman-kiss-man:
👩‍❤️‍💋‍👩	:woman-kiss-woman:
👩	:woman:
👪	:family:
👫	:couple:
👬	:two_men_holding_hands:
👭	:two_women_holding_hands:
👮‍♀️	:female-police-officer:
👮‍♂️	:male-police-officer:
👮	:cop:
👯‍♀️	:woman-with-bunny-ears-partying:
👯‍♂️	:man-with-bunny-ears-partying:
👯	:dancers:
👰	:bride_with_veil:
👱‍♀️	:blond-haired-woman:
👱‍♂️	:blond-haired-man:
👱	:person_with_blond_hair:
👲	:man_with_gua_pi_mao:
👳‍♀️	:woman-wearing-turban:
👳‍♂️	:man-wearing-turban:
👳	:man_with_turban:
👴	:older_man:
👵	:older_woman:
👶	:baby:
👷‍♀️	:female-construction-worker:
👷‍♂️	:male-construction-worker:
👷	:construction_worker:
👸	:princess:
👹	:japanese_ogre:
👺	:japanese_goblin:
👻	:ghost:
👼	:angel:
👽	:alien:
👾	:space_invader:
👿	:imp:
💀	:skull:
💁‍♀️	:woman-tipping-hand:
💁‍♂️	:man-tipping-hand:
💁	:information_desk_person:
💂‍♀️	:female-guard:
💂‍♂️	:male-guard:
💂	:guardsman:
💃	:dancer:
💄	:lipstick:
💅	:nail_care:
💆‍♀️	:woman-getting-massage:
💆‍♂️	:man-getting-massage:
💆	:massage:
💇‍♀️	:woman-getting-haircut:
💇‍♂️	:man-getting-haircut:
💇	:haircut:
💈	:barber:
💉	:syringe:
💊	:pill:
💋	:kiss:
💌	:love_letter:
💍	:ring:
💎	:gem:
💏	:couplekiss:
💐	:bouquet:
💑	:couple_with_heart:
💒	:wedding:
💓	:heartbeat:
💔	:broken_heart:
💕	:two_hearts:
💖	:sparkling_heart:
💗	:heartpulse:
💘	:cupid:
💙	:blue_heart:
💚	:green_heart:
💛	:yellow_heart:
💜	:purple_heart:
💝	:gift_heart:
💞	:revolving_hearts:
💟	:heart_decoration:
💠	:diamond_shape_with_a_dot_inside:
💡	:bulb:
💢	:anger:
💣	:bomb:
💤	:zzz:
💥	:boom:
💦	:sweat_drops:
💧	:droplet:
💨	:dash:
💩	:hankey:
💪	:muscle:
💫	:dizzy:
💬	:speech_balloon:
💭	:thought_balloon:
💮	:white_flower:
💯	:100:
💰	:moneybag:
💱	:currency_exchange:
💲	:heavy_dollar_sign:
💳	:credit_card:
💴	:yen:
💵	:dollar:
💶	:euro:
💷	:pound:
💸	:money_with_wings:
💹	:chart:
💺	:seat:
💻	:computer:
💼	:briefcase:
💽	:minidisc:
💾	:floppy_disk:
💿	:cd:
📀	:dvd:
📁	:file_folder:
📂	:open_file_folder:
📃	:page_with_curl:
📄	:page_facing_up:
📅	:date:
📆	:calendar:
📇	:card_index:
📈	:chart_with_upwards_trend:
📉	:chart_with_downwards_trend:
📊	:bar_chart:
📋	:clipboard:
📌	:pushpin:
📍	:round_pushpin:
📎	:paperclip:
📏	:straight_ruler:
📐	:triangular_ruler:
📑	:bookmark_tabs:
📒	:ledger:
📓	:notebook:
📔	:notebook_with_decorative_cover:
📕	:closed_book:
📖	:book:
📗	:green_book:
📘	:blue_book:
📙	:orange_book:
📚	:books:
📛	:name_badge:
📜	:scroll:
📝	:memo:
📞	:telephone_receiver:
📟	:pager:
📠	:fax:
📡	:satellite_antenna:
📢	:loudspeaker:
📣	:mega:
📤	:outbox_tray:
📥	:inbox_tray:
📦	:package:
📧	:e-mail:
📨	:incoming_envelope:
📩	:envelope_with_arrow:
📪	:mailbox_closed:
📫	:mailbox:
📬	:mailbox_with_mail:
📭	:mailbox_with_no_mail:
📮	:postbox:
📯	:postal_horn:
📰	:newspaper:
📱	:iphone:
📲	:calling:
📳	:vibration_mode:
📴	:mobile_phone_off:
📵	:no_mobile_phones:
📶	:signal_strength:
📷	:camera:
📸	:camera_with_flash:
📹	:video_camera:
📺	:tv:
📻	:radio:
📼	:vhs:
📽️	:film_projector:
📿	:prayer_beads:
🔀	:twisted_rightwards_arrows:
🔁	:repeat:
🔂	:repeat_one:
🔃	:arrows_clockwise:
🔄	:arrows_counterclockwise:
🔅	:low_brightness:
🔆	:high_brightness:
🔇	:mute:
🔈	:speaker:
🔉	:sound:
🔊	:loud_sound:
🔋	:battery:
🔌	:electric_plug:
🔍	:mag:
🔎	:mag_right:
🔏	:lock_with_ink_pen:
🔐	:closed_lock_with_key:
🔑	:key:
🔒	:lock:
🔓	:unlock:
🔔	:bell:
🔕	:no_bell:
🔖	:bookmark:
🔗	:link:
🔘	:radio_button:
🔙	:back:
🔚	:end:
🔛	:on:
🔜	:soon:
🔝	:top:
🔞	:underage:
🔟	:keycap_ten:
🔠	:capital_abcd:
🔡	:abcd:
🔢	:1234:
🔣	:symbols:
🔤	:abc:
🔥	:fire:
🔦	:flashlight:
🔧	:wrench:
🔨	:hammer:
🔩	:nut_and_bolt:
🔪	:hocho:
🔫	:gun:
🔬	:microscope:
🔭	:telescope:
🔮	:crystal_ball:
🔯	:six_pointed_star:
🔰	:beginner:
🔱	:trident:
🔲	:black_square_button:
🔳	:white_square_button:
🔴	:red_circle:
🔵	:large_blue_circle:
🔶	:large_orange_diamond:
🔷	:large_blue_diamond:
🔸	:small_orange_diamond:
🔹	:small_blue_diamond:
🔺	:small_red_triangle:
🔻	:small_red_triangle_down:
🔼	:arrow_up_small:
🔽	:arrow_down_small:
🕉️	:om_symbol:
🕊️	:dove_of_peace:
🕋	:kaaba:
🕌	:mosque:
🕍	:synagogue:
🕎	:menorah_with_nine_branches:
🕐	:clock1:
🕑	:clock2:
🕒	:clock3:
🕓	:clock4:
🕔	:clock5:
🕕	:clock6:
🕖	:clock7:
🕗	:clock8:
🕘	:clock9:
🕙	:clock10:
🕚	:clock11:
🕛	:clock12:
🕜	:clock130:
🕝	:clock230:
🕞	:clock330:
🕟	:clock430:
🕠	:clock530:
🕡	:clock630:
🕢	:clock730:
🕣	:clock830:
🕤	:clock930:
🕥	:clock1030:
🕦	:clock1130:
🕧	:clock1230:
🕯️	:candle:
🕰️	:mantelpiece_clock:
🕳️	:hole:
🕴️	:man_in_business_suit_levitating:
🕵️‍♀️	:female-detective:
🕵️‍♂️	:male-detective:
🕵️	:sleuth_or_spy:
🕶️	:dark_sunglasses:
🕷️	:spider:
🕸️	:spider_web:
🕹️	:joystick:
🕺	:man_dancing:
🖇️	:linked_paperclips:
🖊️	:lower_left_ballpoint_pen:
🖋️	:lower_left_fountain_pen:
🖌️	:lower_left_paintbrush:
🖍️	:lower_left_crayon:
🖐️	:raised_hand_with_fingers_splayed:
🖕	:middle_finger:
🖖	:spock-hand:
🖤	:black_heart:
🖥️	:desktop_computer:
🖨️	:printer:
🖱️	:three_button_mouse:
🖲️	:trackball:
🖼️	:frame_with_picture:
🗂️	:card_index_dividers:
🗃️	:card_file_box:
🗄️	:file_cabinet:
🗑️	:wastebasket:
🗒️	:spiral_note_pad:
🗓️	:spiral_calendar_pad:
🗜️	:compression:
🗝️	:old_key:
🗞️	:rolled_up_newspaper:
🗡️	:dagger_knife:
🗣️	:speaking_head_in_silhouette:
🗨️	:left_speech_bubble:
🗯️	:right_anger_bubble:
🗳️	:ballot_box_with_ballot:
🗺️	:world_map:
🗻	:mount_fuji:
🗼	:tokyo_tower:
🗽	:statue_of_liberty:
🗾	:japan:
🗿	:moyai:
😀	:grinning:
😁	:grin:
😂	:joy:
😃	:smiley:
😄	:smile:
😅	:sweat_smile:
😆	:laughing:
😇	:innocent:
😈	:smiling_imp:
😉	:wink:
😊	:blush:
😋	:yum:
😌	:relieved:
😍	:heart_eyes:
😎	:sunglasses:
😏	:smirk:
😐	:neutral_face:
😑	:expressionless:
😒	:unamused:
😓	:sweat:
😔	:pensive:
😕	:confused:
😖	:confounded:
😗	:kissing:
😘	:kissing_heart:
😙	:kissing_smiling_eyes:
😚	:kissing_closed_eyes:
😛	:stuck_out_tongue:
😜	:stuck_out_tongue_winking_eye:
😝	:stuck_out_tongue_closed_eyes:
😞	:disappointed:
😟	:worried:
😠	:angry:
😡	:rage:
😢	:cry:
😣	:persevere:
😤	:triumph:
😥	:disappointed_relieved:
😦	:frowning:
😧	:anguished:
😨	:fearful:
😩	:weary:
😪	:sleepy:
😫	:tired_face:
😬	:grimacing:
😭	:sob:
😮	:open_mouth:
😯	:hushed:
😰	:cold_sweat:
😱	:scream:
😲	:astonished:
😳	:flushed:
😴	:sleeping:
😵	:dizzy_face:
😶	:no_mouth:
😷	:mask:
😸	:smile_cat:
😹	:joy_cat:
😺	:smiley_cat:
😻	:heart_eyes_cat:
😼	:smirk_cat:
😽	:kissing_cat:
😾	:pouting_cat:
😿	:crying_cat_face:
🙀	:scream_cat:
🙁	:slightly_frowning_face:
🙂	:slightly_smiling_face:
🙃	:upside_down_face:
🙄	:face_with_rolling_eyes:
🙅‍♀️	:woman-gesturing-no:
🙅‍♂️	:man-gesturing-no:
🙅	:no_good:
🙆‍♀️	:woman-gesturing-ok:
🙆‍♂️	:man-gesturing-ok:
🙆	:ok_woman:
🙇‍♀️	:woman-bowing:
🙇‍♂️	:man-bowing:
🙇	:bow:
🙈	:see_no_evil:
🙉	:hear_no_evil:
🙊	:speak_no_evil:
🙋‍♀️	:woman-raising-hand:
🙋‍♂️	:man-raising-hand:
🙋	:raising_hand:
🙌	:raised_hands:
🙍‍♀️	:woman-frowning:
🙍‍♂️	:man-frowning:
🙍	:person_frowning:
🙎‍♀️	:woman-pouting:
🙎‍♂️	:man-pouting:
🙎	:person_with_pouting_face:
🙏	:pray:
🚀	:rocket:
🚁	:helicopter:
🚂	:steam_locomotive:
🚃	:railway_car:
🚄	:bullettrain_side:
🚅	:bullettrain_front:
🚆	:train2:
🚇	:metro:
🚈	:light_rail:
🚉	:station:
🚊	:tram:
🚋	:train:
🚌	:bus:
🚍	:oncoming_bus:
🚎	:trolleybus:
🚏	:busstop:
🚐	:minibus:
🚑	:ambulance:
🚒	:fire_engine:
🚓	:police_car:
🚔	:oncoming_police_car:
🚕	:taxi:
🚖	:oncoming_taxi:
🚗	:car:
🚘	:oncoming_automobile:
🚙	:blue_car:
🚚	:truck:
🚛	:articulated_lorry:
🚜	:tractor:
🚝	:monorail:
🚞	:mountain_railway:
🚟	:suspension_railway:
🚠	:mountain_cableway:
🚡	:aerial_tramway:
🚢	:ship:
🚣‍♀️	:woman-rowing-boat:
🚣‍♂️	:man-rowing-boat:
🚣	:rowboat:
🚤	:speedboat:
🚥	:traffic_light:
🚦	:vertical_traffic_light:
🚧	:construction:
🚨	:rotating_light:
🚩	:triangular_flag_on_post:
🚪	:door:
🚫	:no_entry_sign:
🚬	:smoking:
🚭	:no_smoking:
🚮	:put_litter_in_its_place:
🚯	:do_not_litter:
🚰	:potable_water:
🚱	:non-potable_water:
🚲	:bike:
🚳	:no_bicycles:
🚴‍♀️	:woman-biking:
🚴‍♂️	:man-biking:
🚴	:bicyclist:
🚵‍♀️	:woman-mountain-biking:
🚵‍♂️	:man-mountain-biking:
🚵	:mountain_bicyclist:
🚶‍♀️	:woman-walking:
🚶‍♂️	:man-walking:
🚶	:walking:
🚷	:no_pedestrians:
🚸	:children_crossing:
🚹	:mens:
🚺	:womens:
🚻	:restroom:
🚼	:baby_symbol:
🚽	:toilet:
🚾	:wc:
🚿	:shower:
🛀	:bath:
🛁	:bathtub:
🛂	:passport_control:
🛃	:customs:
🛄	:baggage_claim:
🛅	:left_luggage:
🛋️	:couch_and_lamp:
🛌	:sleeping_accommodation:
🛍️	:shopping_bags:
🛎️	:bellhop_bell:
🛏️	:bed:
🛐	:place_of_worship:
🛑	:octagonal_sign:
🛒	:shopping_trolley:
🛕	:hindu_temple:
🛠️	:hammer_and_wrench:
🛡️	:shield:
🛢️	:oil_drum:
🛣️	:motorway:
🛤️	:railway_track:
🛥️	:motor_boat:
🛩️	:small_airplane:
🛫	:airplane_departure:
🛬	:airplane_arriving:
🛰️	:satellite:
🛳️	:passenger_ship:
🛴	:scooter:
🛵	:motor_scooter:
🛶	:canoe:
🛷	:sled:
🛸	:flying_saucer:
🛹	:skateboard:
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
🤐	:zipper_mouth_face:
🤑	:money_mouth_face:
🤒	:face_with_thermometer:
🤓	:nerd_face:
🤔	:thinking_face:
🤕	:face_with_head_bandage:
🤖	:robot_face:
🤗	:hugging_face:
🤘	:the_horns:
🤙	:call_me_hand:
🤚	:raised_back_of_hand:
🤛	:left-facing_fist:
🤜	:right-facing_fist:
🤝	:handshake:
🤞	:crossed_fingers:
🤟	:i_love_you_hand_sign:
🤠	:face_with_cowboy_hat:
🤡	:clown_face:
🤢	:nauseated_face:
🤣	:rolling_on_the_floor_laughing:
🤤	:drooling_face:
🤥	:lying_face:
🤦‍♀️	:woman-facepalming:
🤦‍♂️	:man-facepalming:
🤦	:face_palm:
🤧	:sneezing_face:
🤨	:face_with_raised_eyebrow:
🤩	:star-struck:
🤪	:zany_face:
🤫	:shushing_face:
🤬	:face_with_symbols_on_mouth:
🤭	:face_with_hand_over_mouth:
🤮	:face_vomiting:
🤯	:exploding_head:
🤰	:pregnant_woman:
🤱	:breast-feeding:
🤲	:palms_up_together:
🤳	:selfie:
🤴	:prince:
🤵	:man_in_tuxedo:
🤶	:mrs_claus:
🤷‍♀️	:woman-shrugging:
🤷‍♂️	:man-shrugging:
🤷	:shrug:
🤸‍♀️	:woman-cartwheeling:
🤸‍♂️	:man-cartwheeling:
🤸	:person_doing_cartwheel:
🤹‍♀️	:woman-juggling:
🤹‍♂️	:man-juggling:
🤹	:juggling:
🤺	:fencer:
🤼‍♀️	:woman-wrestling:
🤼‍♂️	:man-wrestling:
🤼	:wrestlers:
🤽‍♀️	:woman-playing-water-polo:
🤽‍♂️	:man-playing-water-polo:
🤽	:water_polo:
🤾‍♀️	:woman-playing-handball:
🤾‍♂️	:man-playing-handball:
🤾	:handball:
🤿	:diving_mask:
🥀	:wilted_flower:
🥁	:drum_with_drumsticks:
🥂	:clinking_glasses:
🥃	:tumbler_glass:
🥄	:spoon:
🥅	:goal_net:
🥇	:first_place_medal:
🥈	:second_place_medal:
🥉	:third_place_medal:
🥊	:boxing_glove:
🥋	:martial_arts_uniform:
🥌	:curling_stone:
🥍	:lacrosse:
🥎	:softball:
🥏	:flying_disc:
🥐	:croissant:
🥑	:avocado:
🥒	:cucumber:
🥓	:bacon:
🥔	:potato:
🥕	:carrot:
🥖	:baguette_bread:
🥗	:green_salad:
🥘	:shallow_pan_of_food:
🥙	:stuffed_flatbread:
🥚	:egg:
🥛	:glass_of_milk:
🥜	:peanuts:
🥝	:kiwifruit:
🥞	:pancakes:
🥟	:dumpling:
🥠	:fortune_cookie:
🥡	:takeout_box:
🥢	:chopsticks:
🥣	:bowl_with_spoon:
🥤	:cup_with_straw:
🥥	:coconut:
🥦	:broccoli:
🥧	:pie:
🥨	:pretzel:
🥩	:cut_of_meat:
🥪	:sandwich:
🥫	:canned_food:
🥬	:leafy_green:
🥭	:mango:
🥮	:moon_cake:
🥯	:bagel:
🥰	:smiling_face_with_3_hearts:
🥱	:yawning_face:
🥳	:partying_face:
🥴	:woozy_face:
🥵	:hot_face:
🥶	:cold_face:
🥺	:pleading_face:
🥻	:sari:
🥼	:lab_coat:
🥽	:goggles:
🥾	:hiking_boot:
🥿	:womans_flat_shoe:
🦀	:crab:
🦁	:lion_face:
🦂	:scorpion:
🦃	:turkey:
🦄	:unicorn_face:
🦅	:eagle:
🦆	:duck:
🦇	:bat:
🦈	:shark:
🦉	:owl:
🦊	:fox_face:
🦋	:butterfly:
🦌	:deer:
🦍	:gorilla:
🦎	:lizard:
🦏	:rhinoceros:
🦐	:shrimp:
🦑	:squid:
🦒	:giraffe_face:
🦓	:zebra_face:
🦔	:hedgehog:
🦕	:sauropod:
🦖	:t-rex:
🦗	:cricket:
🦘	:kangaroo:
🦙	:llama:
🦚	:peacock:
🦛	:hippopotamus:
🦜	:parrot:
🦝	:raccoon:
🦞	:lobster:
🦟	:mosquito:
🦠	:microbe:
🦡	:badger:
🦢	:swan:
🦥	:sloth:
🦦	:otter:
🦧	:orangutan:
🦨	:skunk:
🦩	:flamingo:
🦪	:oyster:
🦮	:guide_dog:
🦯	:probing_cane:
🦴	:bone:
🦵	:leg:
🦶	:foot:
🦷	:tooth:
🦸‍♀️	:female_superhero:
🦸‍♂️	:male_superhero:
🦸	:superhero:
🦹‍♀️	:female_supervillain:
🦹‍♂️	:male_supervillain:
🦹	:supervillain:
🦺	:safety_vest:
🦻	:ear_with_hearing_aid:
🦼	:motorized_wheelchair:
🦽	:manual_wheelchair:
🦾	:mechanical_arm:
🦿	:mechanical_leg:
🧀	:cheese_wedge:
🧁	:cupcake:
🧂	:salt:
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
🧐	:face_with_monocle:
🧑‍🌾	:farmer:
🧑‍🍳	:cook:
🧑‍🎓	:student:
🧑‍🎤	:singer:
🧑‍🎨	:artist:
🧑‍🏫	:teacher:
🧑‍🏭	:factory_worker:
🧑‍💻	:technologist:
🧑‍💼	:office_worker:
🧑‍🔧	:mechanic:
🧑‍🔬	:scientist:
🧑‍🚀	:astronaut:
🧑‍🚒	:firefighter:
🧑‍🤝‍🧑	:people_holding_hands:
🧑‍🦯	:person_with_probing_cane:
🧑‍🦰	:red_haired_person:
🧑‍🦱	:curly_haired_person:
🧑‍🦲	:bald_person:
🧑‍🦳	:white_haired_person:
🧑‍🦼	:person_in_motorized_wheelchair:
🧑‍🦽	:person_in_manual_wheelchair:
🧑‍⚕️	:health_worker:
🧑‍⚖️	:judge:
🧑‍✈️	:pilot:
🧑	:adult:
🧒	:child:
🧓	:older_adult:
🧔	:bearded_person:
🧕	:person_with_headscarf:
🧖‍♀️	:woman_in_steamy_room:
🧖‍♂️	:man_in_steamy_room:
🧖	:person_in_steamy_room:
🧗‍♀️	:woman_climbing:
🧗‍♂️	:man_climbing:
🧗	:person_climbing:
🧘‍♀️	:woman_in_lotus_position:
🧘‍♂️	:man_in_lotus_position:
🧘	:person_in_lotus_position:
🧙‍♀️	:female_mage:
🧙‍♂️	:male_mage:
🧙	:mage:
🧚‍♀️	:female_fairy:
🧚‍♂️	:male_fairy:
🧚	:fairy:
🧛‍♀️	:female_vampire:
🧛‍♂️	:male_vampire:
🧛	:vampire:
🧜‍♀️	:mermaid:
🧜‍♂️	:merman:
🧜	:merperson:
🧝‍♀️	:female_elf:
🧝‍♂️	:male_elf:
🧝	:elf:
🧞‍♀️	:female_genie:
🧞‍♂️	:male_genie:
🧞	:genie:
🧟‍♀️	:female_zombie:
🧟‍♂️	:male_zombie:
🧟	:zombie:
🧠	:brain:
🧡	:orange_heart:
🧢	:billed_cap:
🧣	:scarf:
🧤	:gloves:
🧥	:coat:
🧦	:socks:
🧧	:red_envelope:
🧨	:firecracker:
🧩	:jigsaw:
🧪	:test_tube:
🧫	:petri_dish:
🧬	:dna:
🧭	:compass:
🧮	:abacus:
🧯	:fire_extinguisher:
🧰	:toolbox:
🧱	:bricks:
🧲	:magnet:
🧳	:luggage:
🧴	:lotion_bottle:
🧵	:thread:
🧶	:yarn:
🧷	:safety_pin:
🧸	:teddy_bear:
🧹	:broom:
🧺	:basket:
🧻	:roll_of_paper:
🧼	:soap:
🧽	:sponge:
🧾	:receipt:
🧿	:nazar_amulet:
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
‼️	:bangbang:
⁉️	:interrobang:
™️	:tm:
ℹ️	:information_source:
↔️	:left_right_arrow:
↕️	:arrow_up_down:
↖️	:arrow_upper_left:
↗️	:arrow_upper_right:
↘️	:arrow_lower_right:
↙️	:arrow_lower_left:
↩️	:leftwards_arrow_with_hook:
↪️	:arrow_right_hook:
⌚	:watch:
⌛	:hourglass:
⌨️	:keyboard:
⏏️	:eject:
⏩	:fast_forward:
⏪	:rewind:
⏫	:arrow_double_up:
⏬	:arrow_double_down:
⏭️	:black_right_pointing_double_triangle_with_vertical_bar:
⏮️	:black_left_pointing_double_triangle_with_vertical_bar:
⏯️	:black_right_pointing_triangle_with_double_vertical_bar:
⏰	:alarm_clock:
⏱️	:stopwatch:
⏲️	:timer_clock:
⏳	:hourglass_flowing_sand:
⏸️	:double_vertical_bar:
⏹️	:black_square_for_stop:
⏺️	:black_circle_for_record:
Ⓜ️	:m:
▪️	:black_small_square:
▫️	:white_small_square:
▶️	:arrow_forward:
◀️	:arrow_backward:
◻️	:white_medium_square:
◼️	:black_medium_square:
◽	:white_medium_small_square:
◾	:black_medium_small_square:
☀️	:sunny:
☁️	:cloud:
☂️	:umbrella:
☃️	:snowman:
☄️	:comet:
☎️	:phone:
☑️	:ballot_box_with_check:
☔	:umbrella_with_rain_drops:
☕	:coffee:
☘️	:shamrock:
☝️	:point_up:
☠️	:skull_and_crossbones:
☢️	:radioactive_sign:
☣️	:biohazard_sign:
☦️	:orthodox_cross:
☪️	:star_and_crescent:
☮️	:peace_symbol:
☯️	:yin_yang:
☸️	:wheel_of_dharma:
☹️	:white_frowning_face:
☺️	:relaxed:
♀️	:female_sign:
♂️	:male_sign:
♈	:aries:
♉	:taurus:
♊	:gemini:
♋	:cancer:
♌	:leo:
♍	:virgo:
♎	:libra:
♏	:scorpius:
♐	:sagittarius:
♑	:capricorn:
♒	:aquarius:
♓	:pisces:
♟️	:chess_pawn:
♠️	:spades:
♣️	:clubs:
♥️	:hearts:
♦️	:diamonds:
♨️	:hotsprings:
♻️	:recycle:
♾️	:infinity:
♿	:wheelchair:
⚒️	:hammer_and_pick:
⚓	:anchor:
⚔️	:crossed_swords:
⚕️	:medical_symbol:
⚖️	:scales:
⚗️	:alembic:
⚙️	:gear:
⚛️	:atom_symbol:
⚜️	:fleur_de_lis:
⚠️	:warning:
⚡	:zap:
⚪	:white_circle:
⚫	:black_circle:
⚰️	:coffin:
⚱️	:funeral_urn:
⚽	:soccer:
⚾	:baseball:
⛄	:snowman_without_snow:
⛅	:partly_sunny:
⛈️	:thunder_cloud_and_rain:
⛎	:ophiuchus:
⛏️	:pick:
⛑️	:helmet_with_white_cross:
⛓️	:chains:
⛔	:no_entry:
⛩️	:shinto_shrine:
⛪	:church:
⛰️	:mountain:
⛱️	:umbrella_on_ground:
⛲	:fountain:
⛳	:golf:
⛴️	:ferry:
⛵	:boat:
⛷️	:skier:
⛸️	:ice_skate:
⛹️‍♀️	:woman-bouncing-ball:
⛹️‍♂️	:man-bouncing-ball:
⛹️	:person_with_ball:
⛺	:tent:
⛽	:fuelpump:
✂️	:scissors:
✅	:white_check_mark:
✈️	:airplane:
✉️	:email:
✊	:fist:
✋	:hand:
✌️	:v:
✍️	:writing_hand:
✏️	:pencil2:
✒️	:black_nib:
✔️	:heavy_check_mark:
✖️	:heavy_multiplication_x:
✝️	:latin_cross:
✡️	:star_of_david:
✨	:sparkles:
✳️	:eight_spoked_asterisk:
✴️	:eight_pointed_black_star:
❄️	:snowflake:
❇️	:sparkle:
❌	:x:
❎	:negative_squared_cross_mark:
❓	:question:
❔	:grey_question:
❕	:grey_exclamation:
❗	:exclamation:
❣️	:heavy_heart_exclamation_mark_ornament:
❤️	:heart:
➕	:heavy_plus_sign:
➖	:heavy_minus_sign:
➗	:heavy_division_sign:
➡️	:arrow_right:
➰	:curly_loop:
➿	:loop:
⤴️	:arrow_heading_up:
⤵️	:arrow_heading_down:
⬅️	:arrow_left:
⬆️	:arrow_up:
⬇️	:arrow_down:
⬛	:black_large_square:
⬜	:white_large_square:
⭐	:star:
⭕	:o:
〰️	:wavy_dash:
〽️	:part_alternation_mark:
㊗️	:congratulations:
㊙️	:secret:
    '''),
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
];
