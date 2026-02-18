import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../providers/reviews_provider.dart';
import '../widgets/star_rating_widget.dart';

class CreateReviewScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const CreateReviewScreen({super.key, required this.bookingId});

  @override
  ConsumerState<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends ConsumerState<CreateReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final createState = ref.watch(createReviewProvider);

    // Escuchar cambios de estado para navegacion
    ref.listen<CreateReviewState>(createReviewProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Resena enviada exitosamente'),
            backgroundColor: colors.success,
          ),
        );
        ref.read(createReviewProvider.notifier).reset();
        context.pop(true);
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calificar Servicio'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Titulo
              Text(
                'Como fue tu experiencia?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tu opinion ayuda a otros usuarios y al proveedor a mejorar.',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Estrellas interactivas
              StarRatingWidget(
                rating: _rating,
                onRatingChanged: (rating) {
                  setState(() => _rating = rating);
                },
                starSize: 52,
              ),
              const SizedBox(height: 8),
              Text(
                _getRatingLabel(),
                style: TextStyle(
                  color: _rating > 0
                      ? colors.secondary
                      : colors.textHint,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // Campo de comentario
              TextFormField(
                controller: _commentController,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Escribe tu comentario aqui...',
                  hintStyle: TextStyle(color: colors.textHint),
                  labelText: 'Comentario',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.surfaceVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.surfaceVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colors.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.error),
                  ),
                  filled: true,
                  fillColor: colors.surfaceVariant.withOpacity(0.3),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor escribe un comentario';
                  }
                  if (value.trim().length < 20) {
                    return 'El comentario debe tener al menos 20 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Boton enviar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: createState.isSubmitting
                      ? null
                      : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.textOnPrimary,
                    disabledBackgroundColor: colors.surfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: createState.isSubmitting
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: colors.textOnPrimary,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Enviar Resena',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitReview() {
    final colors = AppColors.of(context);

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecciona una calificacion'),
          backgroundColor: colors.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    ref.read(createReviewProvider.notifier).submitReview(
          bookingId: widget.bookingId,
          rating: _rating,
          comment: _commentController.text.trim(),
        );
  }

  String _getRatingLabel() {
    switch (_rating) {
      case 1:
        return 'Muy malo';
      case 2:
        return 'Malo';
      case 3:
        return 'Regular';
      case 4:
        return 'Bueno';
      case 5:
        return 'Excelente';
      default:
        return 'Toca las estrellas para calificar';
    }
  }
}
