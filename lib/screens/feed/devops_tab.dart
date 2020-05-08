import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/feed/build_dev_item.dart';

class DevOpsTab extends StatefulWidget {
  @override
  _DevOpsTabState createState() => _DevOpsTabState();
}

class _DevOpsTabState extends State<DevOpsTab> {
  @override
  Widget build(BuildContext context) {
    final List<Dev> _devOps = _getDevOps();
    return Container(
      child: ListView.builder(
          itemCount: _devOps.length,
          itemBuilder: (BuildContext context, int i) {
            return BuildDevItem(_devOps[i]);
          }),
    );
  }

  List<Dev> _getDevOps() {
    return [
      Dev(
        name: 'artemciy_dice',
        avatar: 'https://cdn.discordapp.com/avatars/209024368968204288/4ebef1887d9c9e94034387846711ff35.png?size=128',
      ),
      Dev(
        name: 'artemciy_dice',
        avatar: 'https://cdn.discordapp.com/avatars/209024368968204288/4ebef1887d9c9e94034387846711ff35.png?size=128',
      ),
    ];
  }
}

class Dev {
  Dev({
    @required this.name,
    this.avatar,
  });

  String name;
  String avatar;
}
