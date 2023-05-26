import 'package:flutter/material.dart';
import 'package:komodo_dex/packages/accounts/bloc/active_account_bloc.dart';
import 'package:komodo_dex/packages/accounts/models/account.dart';
import 'package:komodo_dex/packages/portfolio/widgets/porfolio_header.dart';
import 'package:komodo_dex/screens/portfolio/coins_page.dart';
import 'package:provider/provider.dart';

class PortfolioHome extends StatelessWidget {
  const PortfolioHome({super.key});

  Widget build(BuildContext context) {
    final activeAccount = context.select<ActiveAccountBloc, Account?>(
      (bloc) => bloc.state.activeAccount,
    );

    if (activeAccount == null) {
      return CircularProgressIndicator.adaptive();
    }
    return Column(
      children: [
        PortfolioHeader(activeAccount: activeAccount),
        SizedBox(height: 16),
        Expanded(child: const ListCoins()),
      ],
    );
  }
}
