// Abstract class representing a protocol associated with an address
abstract class Protocol {
  String get id;
  String get name;
  String get description;
}

// Specific implementation for the Ethereum protocol
class EthereumProtocol implements Protocol {
  @override
  String get id => 'ETH';

  @override
  String get name => 'Ethereum';

  @override
  String get description =>
      'A decentralized, open-source blockchain with smart contract functionality';
}

// Specific implementation for the ERC20 protocol
class ERC20Protocol implements Protocol {
  @override
  String get id => 'ERC20';

  @override
  String get name => 'ERC20';

  @override
  String get description =>
      'A technical standard for tokens on the Ethereum blockchain';
}

// Specific implementation for the Binance Smart Chain protocol
class BinanceSmartChainProtocol implements Protocol {
  @override
  String get id => 'BSC';

  @override
  String get name => 'Binance Smart Chain';

  @override
  String get description =>
      'A blockchain network built for running smart contract-based applications';
}

// Specific implementation for the Bitcoin Cash protocol
class BitcoinCashProtocol implements Protocol {
  @override
  String get id => 'BCH';

  @override
  String get name => 'Bitcoin Cash';

  @override
  String get description =>
      'A peer-to-peer electronic cash system that aims to be a spendable digital currency';
}

// Specific implementation for the Simple Ledger Protocol
class SimpleLedgerProtocol implements Protocol {
  @override
  String get id => 'SLP';

  @override
  String get name => 'Simple Ledger Protocol';

  @override
  String get description =>
      'A token system for the Bitcoin Cash network that supports the creation and management of tokens';
}
