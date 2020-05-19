import 'package:flutter/material.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/screens/feed/build_online_status.dart';

class BuildDevAvatar extends StatelessWidget {
  const BuildDevAvatar(
    this.dev, {
    this.size = 40,
    this.showOnlineStatus = true,
  });

  final Dev dev;
  final double size;
  final bool showOnlineStatus;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CircleAvatar(
          radius: size / 2,
          backgroundImage: dev.image != null ? NetworkImage(dev.image) : null,
          backgroundColor: Theme.of(context).disabledColor,
          child: dev.image == null
              ? Icon(
                  Icons.account_circle,
                  size: size,
                )
              : null,
        ),
        showOnlineStatus ? _buildOnlineStatus() : Container(),
      ],
    );
  }

  Widget _buildOnlineStatus() {
    if (dev.onlineStatus != OnlineStatus.active) return Container();
    
    return Positioned(
      right: 0,
      bottom: 0,
      child: BuildOnlineStatus(dev, size: size / 4,),
    );
  }
}
