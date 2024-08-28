import 'package:flutter/material.dart';

class CommonLoader extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Duration duration;

  const CommonLoader({
    Key? key,
    this.icon = Icons.sync, // Default icon
    this.size = 50.0, // Default size
    this.color = Colors.blue, // Default color
    this.duration = const Duration(seconds: 2), // Default rotation duration
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
        turns: AlwaysStoppedAnimation(1),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: duration,
          builder: (context, value, child) {
            return Transform.rotate(
              angle: value * 6.28, // 6.28 radians = 360 degrees
              child: Icon(
                icon,
                size: size,
                color: color,
              ),
            );
          },
          onEnd: () {
            // This will make the rotation continuous
            (context as Element).markNeedsBuild();
          },
        ),
      ),
    );
  }
}
