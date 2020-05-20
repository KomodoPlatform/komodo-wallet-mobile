import 'package:flutter/material.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/screens/feed/build_dev_item.dart';
import 'package:komodo_dex/screens/feed/dev_detail_page.dart';
import 'package:provider/provider.dart';

class DevOpsTab extends StatefulWidget {
  @override
  _DevOpsTabState createState() => _DevOpsTabState();
}

class _DevOpsTabState extends State<DevOpsTab> {
  String _selectedDevId;

  @override
  Widget build(BuildContext context) {
    final List<Dev> _devOps = _getDevOps();
    if (_devOps == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container(
      child: ListView.builder(
          padding: const EdgeInsets.only(top: 12),
          itemCount: _devOps.length,
          itemBuilder: (BuildContext context, int i) {
            final bool _isSelected = _selectedDevId == _devOps[i].id;

            void _toggleSelected() {
              setState(() {
                _selectedDevId = _isSelected ? null : _devOps[i].id;
              });
            }

            return BuildDevItem(
              _devOps[i],
              selected: _devOps[i].id == _selectedDevId,
              onTap: () {
                setState(() {
                  _selectedDevId = null;
                });

                if (_isSelected) return;

                Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) =>
                          DevDetailsPage(dev: _devOps[i])),
                );
              },
              onMoreTap: _toggleSelected,
              onLongPress: _toggleSelected,
            );
          }),
    );
  }

  List<Dev> _getDevOps() {
    return Provider.of<FeedProvider>(context).getDevOps();
  }
}
