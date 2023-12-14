class CoinsCI {
  final String bundledCoinsRepoCommit;
  final String coinsRepoUrl;
  final String coinsRepoBranch;
  final bool runtimeUpdatesEnabled;
  final Map<String, String> mappedFiles;
  final Map<String, String> mappedFolders;

  CoinsCI({
    this.bundledCoinsRepoCommit,
    this.coinsRepoUrl,
    this.coinsRepoBranch,
    this.runtimeUpdatesEnabled,
    this.mappedFiles,
    this.mappedFolders,
  });

  factory CoinsCI.fromJson(Map<String, dynamic> json) {
    return CoinsCI(
      bundledCoinsRepoCommit: json['bundled_coins_repo_commit'],
      coinsRepoUrl: json['coins_repo_url'],
      coinsRepoBranch: json['coins_repo_branch'],
      runtimeUpdatesEnabled: json['runtime_updates_enabled'],
      mappedFiles: Map<String, String>.from(json['mapped_files']),
      mappedFolders: Map<String, String>.from(json['mapped_folders']),
    );
  }
}
