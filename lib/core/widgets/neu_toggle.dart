import 'package:flutter/material.dart';
import '../theme/neu_glass.dart';
import '../constants/app_colors.dart';

class NeuToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const NeuToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 56,
        height: 32,
        decoration: NeuGlass.neuInset(context, radius: 16),
        child: Stack(
          children: [
            // Animación del knob
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 26 : 4,
              top: 4,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? AppColors.mentaMedio : const Color(0xFF9A9490),
                  boxShadow: [
                    if (value)
                      BoxShadow(
                        color: AppColors.mentaMedio.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
