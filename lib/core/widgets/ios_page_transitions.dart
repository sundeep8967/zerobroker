import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// iOS-style page transition that can be used with GoRouter or Navigator
class IOSPageTransition extends PageRouteBuilder {
  final Widget child;
  final Duration duration;

  IOSPageTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // iOS-style slide transition
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

/// iOS-style modal presentation
class IOSModalTransition extends PageRouteBuilder {
  final Widget child;
  final Duration duration;

  IOSModalTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          opaque: false,
          barrierColor: Colors.black54,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // iOS-style modal slide up transition
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

/// iOS-style swipe gesture detector
class IOSSwipeGestureDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;
  final double sensitivity;

  const IOSSwipeGestureDetector({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.sensitivity = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond;
        
        // Horizontal swipes
        if (velocity.dx.abs() > velocity.dy.abs()) {
          if (velocity.dx > sensitivity) {
            HapticFeedback.lightImpact();
            onSwipeRight?.call();
          } else if (velocity.dx < -sensitivity) {
            HapticFeedback.lightImpact();
            onSwipeLeft?.call();
          }
        }
        // Vertical swipes
        else {
          if (velocity.dy > sensitivity) {
            HapticFeedback.lightImpact();
            onSwipeDown?.call();
          } else if (velocity.dy < -sensitivity) {
            HapticFeedback.lightImpact();
            onSwipeUp?.call();
          }
        }
      },
      child: child,
    );
  }
}

/// iOS-style action sheet
class IOSActionSheet {
  static void show({
    required BuildContext context,
    required String title,
    String? message,
    required List<IOSActionSheetAction> actions,
    IOSActionSheetAction? cancelAction,
  }) {
    HapticFeedback.lightImpact();
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(title),
        message: message != null ? Text(message) : null,
        actions: actions.map((action) {
          return CupertinoActionSheetAction(
            onPressed: () {
              if (action.isDestructive) {
                HapticFeedback.heavyImpact();
              } else {
                HapticFeedback.lightImpact();
              }
              Navigator.pop(context);
              action.onPressed();
            },
            isDestructiveAction: action.isDestructive,
            child: Text(action.title),
          );
        }).toList(),
        cancelButton: cancelAction != null
            ? CupertinoActionSheetAction(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  cancelAction.onPressed();
                },
                child: Text(cancelAction.title),
              )
            : null,
      ),
    );
  }
}

class IOSActionSheetAction {
  final String title;
  final VoidCallback onPressed;
  final bool isDestructive;

  const IOSActionSheetAction({
    required this.title,
    required this.onPressed,
    this.isDestructive = false,
  });
}

/// iOS-style loading indicator
class IOSLoadingIndicator extends StatelessWidget {
  final double radius;
  final Color? color;

  const IOSLoadingIndicator({
    super.key,
    this.radius = 10.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoActivityIndicator(
      radius: radius,
      color: color,
    );
  }
}

/// iOS-style parallax scrolling effect
class IOSParallaxScrollView extends StatelessWidget {
  final Widget child;
  final Widget? background;
  final double parallaxFactor;

  const IOSParallaxScrollView({
    super.key,
    required this.child,
    this.background,
    this.parallaxFactor = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollUpdateNotification) {
          // Add parallax effect logic here
        }
        return false;
      },
      child: Stack(
        children: [
          if (background != null)
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, 0), // Calculate parallax offset
                child: background!,
              ),
            ),
          child,
        ],
      ),
    );
  }
}