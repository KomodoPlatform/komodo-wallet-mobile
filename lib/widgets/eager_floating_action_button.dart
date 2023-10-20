import 'package:flutter/material.dart';

/// An eager floating action button (FAB) that responds to taps even when it's not "ready".
///
/// The FAB, when tapped while not ready, will display a circular progress loader. If the FAB
/// becomes ready after being tapped, the provided `onTap` callback will be triggered automatically.
///
/// Usage:
///
/// ```dart
/// EagerFloatingActionButton(
///   isReady: someCondition,
///   onTap: () {
///     // Handle FAB tap here.
///   },
///   child: Icon(Icons.add),
/// )
/// ```
class EagerFloatingActionButton extends StatefulWidget {
  /// Creates an instance of the eager floating action button.
  const EagerFloatingActionButton({
    @required this.onTap,
    @required this.isReady,
    this.child,
    this.location,
  });

  /// The callback that is called when the FAB is tapped and is ready.
  ///
  /// If the FAB is tapped when not ready, this callback will be called once the FAB becomes ready.
  final VoidCallback onTap;

  /// Indicates whether the FAB is ready or not.
  ///
  /// If `false`, the FAB will show a circular progress loader when tapped.
  final bool isReady;

  /// The widget to display inside the FAB.
  ///
  /// Typically an [Icon].
  final Widget child;

  /// The location to place the FAB within the [Scaffold], if needed.
  final FloatingActionButtonLocation location;

  @override
  _EagerFloatingActionButtonState createState() =>
      _EagerFloatingActionButtonState();
}

class _EagerFloatingActionButtonState extends State<EagerFloatingActionButton> {
  bool _isLoading = false;

  @override
  void didUpdateWidget(EagerFloatingActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isReady == oldWidget.isReady) return;

    if (!_isLoading) return;

    if (widget.isReady && widget.onTap != null) {
      widget.onTap();
    }

    if (widget.isReady) {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTappable = widget.onTap != null && _isLoading == false;

    return FloatingActionButton(
      onPressed: isTappable
          ? () {
              if (!widget.isReady) {
                setState(() {
                  _isLoading = true;
                });
              } else {
                widget.onTap();
              }
            }
          : null,
      child: _isLoading
          ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : widget.child,
    );
  }
}
