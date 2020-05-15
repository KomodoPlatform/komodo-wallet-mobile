import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/feed/build_dev_item.dart';
import 'package:komodo_dex/screens/feed/dev.dart';
import 'package:komodo_dex/screens/feed/dev_detail_page.dart';

class DevOpsTab extends StatefulWidget {
  @override
  _DevOpsTabState createState() => _DevOpsTabState();
}

class _DevOpsTabState extends State<DevOpsTab> {
  String _selectedDevId;

  @override
  Widget build(BuildContext context) {
    final List<Dev> _devOps = _getDevOps();
    return Container(
      child: ListView.builder(
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
    return [
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
                message: 'news, design and layout, \'DevOps\' tab',
                startTime: 1588927072000,
                issue: Issue(
                  id: '701',
                  title: 'rewamp the news section rewamp',
                  url: 'https://github.com/ca333/komodoDEX/issues/701',
                )),
            DevStatus(
              id: '0',
              message: 'git',
              startTime: 1589009514000,
              endTime: 1589020314000,
            ),
            DevStatus(
                id: '1',
                message: '#757 orders duplicates',
                startTime: 1589020314000,
                endTime: 1589022774000,
                issue: Issue(
                  id: '757',
                  title: 'Orderbook page creating orders duplicates',
                  url: 'https://github.com/ca333/komodoDEX/issues/757',
                )),
            DevStatus(
                id: '2',
                message: 'news, design and layout, \'DevOps\' tab',
                startTime: 1589022774000,
                issue: Issue(
                  id: '701',
                  title: 'rewamp the news section rewamp',
                  url: 'https://github.com/ca333/komodoDEX/issues/701',
                )),
            DevStatus(
              id: '0',
              message: 'git',
              startTime: 1589109174000,
              endTime: 1589112774000,
            ),
            DevStatus(
                id: '1',
                message: '#757 orders duplicates',
                startTime: 1589112774000,
                endTime: 1589119974000,
                issue: Issue(
                  id: '757',
                  title: 'Orderbook page creating orders duplicates',
                  url: 'https://github.com/ca333/komodoDEX/issues/757',
                )),
            DevStatus(
                id: '2',
                message: 'news, design and layout, \'DevOps\' tab',
                startTime: 1589551974000,
                issue: Issue(
                  id: '701',
                  title: 'rewamp the news section rewamp',
                  url: 'https://github.com/ca333/komodoDEX/issues/701',
                )),
          ]),
    ];
  }
}
