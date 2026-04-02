import 'package:flutter/material.dart';
import '../theme/neu_glass.dart';
import '../constants/app_colors.dart';

class NeuSlider extends StatefulWidget {
  final double value; // De 0.0 a 1.0
  final ValueChanged<double> onChanged;

  const NeuSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<NeuSlider> createState() => _NeuSliderState();
}

class _NeuSliderState extends State<NeuSlider> {
  void _updateValue(Offset localPosition, double width) {
    double newValue = (localPosition.dx / width).clamp(0.0, 1.0);
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final thumbSize = 24.0;
        
        return GestureDetector(
          onHorizontalDragUpdate: (details) => _updateValue(details.localPosition, width),
          onTapDown: (details) => _updateValue(details.localPosition, width),
          child: Container(
            height: 32,
            width: double.infinity,
            color: Colors.transparent, // Captura de gestos
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // 1. Track Inset (Fondo del slider)
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: NeuGlass.neuInset(context, radius: 10),
                ),
                
                // 2. Fill Degradado Menta
                Container(
                  height: 12,
                  width: widget.value * width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: AppColors.barraProgreso,
                  ),
                ),
                
                // 3. Thumb Raised (Botón deslizable)
                Positioned(
                  left: (widget.value * width) - (thumbSize / 2),
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: NeuGlass.neuRaised(context, radius: thumbSize / 2).copyWith(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? const Color(0xFF1E293B) 
                          : AppColors.crema,
                    ),
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.mentaMedio,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
