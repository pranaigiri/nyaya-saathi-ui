import 'package:flutter/material.dart';

Future<T?> showSpringBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return Navigator.of(context, rootNavigator: true).push(
    SpringSheetRoute<T>(
      builder: builder,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    ),
  );
}

class SpringSheetRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;
  final bool isDismissible;
  final bool enableDrag;

  SpringSheetRoute({
    required this.builder,
    this.isDismissible = true,
    this.enableDrag = true,
  });

  @override
  Color? get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => isDismissible;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 250);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    Widget content = builder(context);
    if (enableDrag) {
      content = _SpringDismissibleSheet(
        onDismiss: () => Navigator.of(context).pop(),
        child: content,
      );
    }
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: content,
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    );
  }
}

class _SpringDismissibleSheet extends StatefulWidget {
  final Widget child;
  final VoidCallback onDismiss;

  const _SpringDismissibleSheet({
    required this.child,
    required this.onDismiss,
  });

  @override
  State<_SpringDismissibleSheet> createState() => _SpringDismissibleSheetState();
}

class _SpringDismissibleSheetState extends State<_SpringDismissibleSheet>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  late AnimationController _springController;
  late Animation<double> _springAnimation;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        setState(() {
          _dragOffset = _springAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta != null && details.primaryDelta! > 0 || _dragOffset > 0) {
      setState(() {
        _dragOffset = (_dragOffset + details.primaryDelta!).clamp(0.0, 500.0);
      });
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (_dragOffset > 100 || velocity > 500) {
      widget.onDismiss();
    } else {
      _springAnimation = Tween<double>(
        begin: _dragOffset,
        end: 0.0,
      ).animate(
        CurvedAnimation(
          parent: _springController,
          curve: Curves.easeOutCubic,
        ),
      );
      _springController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: Transform.translate(
        offset: Offset(0, _dragOffset),
        child: widget.child,
      ),
    );
  }
}
