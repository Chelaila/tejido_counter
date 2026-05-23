import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CounterTile extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool large;
  final String? subtitle;

  const CounterTile({
    super.key,
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.large = false,
    this.subtitle,
  });

  void _tap(VoidCallback callback) {
    HapticFeedback.lightImpact();
    callback();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: large ? 2 : 0,
      color: large ? colorScheme.primaryContainer : colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: large ? 20 : 14,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: large
                    ? colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: large ? 72 : 42,
                fontWeight: FontWeight.w300,
                height: 1,
                color: large
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 11,
                  color: large
                      ? colorScheme.onPrimaryContainer.withValues(alpha: 0.6)
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CounterButton(
                  icon: Icons.remove,
                  onTap: () => _tap(onDecrement),
                  large: large,
                  color: large ? colorScheme.onPrimaryContainer : null,
                ),
                SizedBox(width: large ? 40 : 24),
                _CounterButton(
                  icon: Icons.add,
                  onTap: () => _tap(onIncrement),
                  large: large,
                  color: large ? colorScheme.onPrimaryContainer : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool large;
  final Color? color;

  const _CounterButton({
    required this.icon,
    required this.onTap,
    this.large = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final size = large ? 64.0 : 48.0;
    final iconSize = large ? 32.0 : 22.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: (color ?? Theme.of(context).colorScheme.outline)
                  .withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: color ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
