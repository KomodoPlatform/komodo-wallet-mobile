

# Contributing Guide

Thank you for your interest in contributing to our Flutter project! We truly appreciate your help in making our app better. Currently, our primary focus is on improving the code quality and addressing technical debt in our 4+ year old codebase, specifically the BLoC architecture. We want to ensure that our app's code is of the highest standard, both for refactored code and new features.

**Please note that this is a high-level guide. A comprehensive contributing guide with detailed conventions and architecture will be created.**

## Key Principles

1.  **Code Quality:** We are dedicated to maintaining a high-quality codebase. Your contributions should aim to improve code readability, maintainability, and performance.

2.  **BLoC Architecture:** All new and refactored code must follow the BLoC architecture pattern. This helps us maintain a consistent structure across the codebase and streamline the review process.

3.  **Balancing Features and Refactoring:** While we value new features, our current focus is on addressing technical debt. As such, we encourage you to focus on refactoring and improving existing code.

## Important Clarification

There is a folder named `lib/generic_blocs` containing files referred to as "blocs." Please note that despite their name, these files do not follow the BLoC architecture. New/refactored features should be created in the `lib/packages` folder and follow the BLoC pattern using the `bloc`/`flutter_bloc`/`hydrated_bloc` package.

## Contribution Process

1.  **Fork the repository:** Fork the main repository and create your feature or bugfix branch from the `dev` branch.
2.  **Understand the codebase:** Spend some time familiarizing yourself with the existing codebase, BLoC architecture, and any conventions followed in the project.
3.  **Open an issue:** Before starting any work, open an issue discussing the proposed changes or improvements. This helps avoid duplicate work and ensures that your changes align with the project's goals.
4.  **Start coding:** Once you've received feedback on the issue, begin implementing the changes on your branch. Ensure that your code adheres to the BLoC architecture and maintains a high level of quality.
5.  **Test your changes:** Make sure to test your changes thoroughly and ensure that they do not introduce new bugs or negatively impact performance.
6.  **Submit a pull request:** Once you're satisfied with your changes, submit a pull request to the `dev` branch. Be sure to reference the related issue in the PR description and provide a clear explanation of the changes.

## Pull Request Approval

To maintain our focus on code quality and addressing technical debt, we will only approve pull requests that:

1.  Strictly follow the BLoC architecture.
2.  Improve code quality, readability, and maintainability.
3.  Address existing technical debt or introduce new features that align with our current priorities.

## Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project, you agree to abide by its terms.

## Stay Updated

As this is just a placeholder guide, please stay tuned for the comprehensive contributing guide with detailed conventions and architecture. In the meantime, feel free to reach out to the maintainers with any questions or concerns. We're excited to have you on board and look forward to your contributions!

#   Useful Resources on BLoC and Best Practices

To help you get started with BLoC architecture and understand best practices, we've compiled a list of useful resources:

## BLoC Architecture

1. **Official BLoC Documentation:** This is the official [BLoC library documentation](https://bloclibrary.dev/) and provides a comprehensive guide on using BLoC in your Flutter projects.
2.  **A Flutter BLoC + Clean Architecture journey**: [This](https://medium.com/ideas-by-idean/a-flutter-bloc-clean-architecture-journey-to-release-the-1st-idean-flutter-app-db218021a804) is a great set of guidelines on when/how to separate blocs. Avoid broad/general mega BLoCs.

## Best Practices

1.  **Effective Dart Guide:** Google's official guide on [Effective Dart](https://dart.dev/guides/language/effective-dart) provides best practices for writing clean, idiomatic, and efficient Dart code.
2.  **Flutter Best Practices and Tips:** A comprehensive list of [Flutter best practices and tips](https://github.com/fluttercommunity/flutter-best-practices) curated by the Flutter Community.
3.  **Flutter Style Guide:** A [style guide for Flutter](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo) from the official Flutter repository, which can help you maintain a consistent coding style throughout your project.

## YouTube Channels and Blogs

1.  **FilledStacks:** The [FilledStacks YouTube channel](https://www.youtube.com/c/FilledStacks) offers various tutorials on Flutter development, including videos on BLoC and other state management techniques.
2.  **Reso Coder:** The [Reso Coder YouTube channel](https://www.youtube.com/c/ResoCoder) provides high-quality tutorials on various Flutter topics, including the BLoC pattern and clean architecture.
3.  **Flutter.dev blog:** The official [Flutter blog](https://medium.com/flutter) features articles on Flutter development, including BLoC architecture and best practices.

These resources should help you gain a deeper understanding of BLoC architecture and best practices in Flutter development. As you work on your contributions, don't hesitate to consult these resources and refer back to them for guidance. Good luck, and we look forward to your contributions!
