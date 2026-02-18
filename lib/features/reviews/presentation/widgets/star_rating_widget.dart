import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

/// Widget interactivo de seleccion de estrellas (1-5).
/// Soporta tap y drag para seleccionar la calificacion.
class StarRatingWidget extends StatefulWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final double starSize;
  final Color? activeColor;
  final Color? inactiveColor;

  const StarRatingWidget({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.starSize = 48,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _hoverRating = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final active = widget.activeColor ?? colors.secondary;
    final inactive = widget.inactiveColor ?? colors.textHint.withOpacity(0.3);

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        _updateRatingFromPosition(details.localPosition);
      },
      onHorizontalDragEnd: (_) {
        if (_hoverRating > 0) {
          widget.onRatingChanged(_hoverRating);
        }
        setState(() => _hoverRating = 0);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final starNumber = index + 1;
          final isActive = starNumber <= (
              _hoverRating > 0 ? _hoverRating : widget.rating);

          return GestureDetector(
            onTap: () {
              widget.onRatingChanged(starNumber);
              _animationController.forward(from: 0);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: 1.0,
                  end: isActive ? 1.0 : 1.0,
                ),
                duration: const Duration(milliseconds: 200),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: starNumber == widget.rating ? 1.1 : 1.0,
                    child: Icon(
                      isActive ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: widget.starSize,
                      color: isActive ? active : inactive,
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  void _updateRatingFromPosition(Offset position) {
    final totalWidth = (widget.starSize + 8) * 5;
    final starWidth = totalWidth / 5;
    final rating = (position.dx / starWidth).ceil().clamp(1, 5);

    if (rating != _hoverRating) {
      setState(() => _hoverRating = rating);
    }
  }
}
