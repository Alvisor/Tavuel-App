/// Form field validators for the Tavuel app.
///
/// All validators return `null` when valid, or an error message string
/// (in Spanish) when invalid. Compatible with Flutter's `TextFormField.validator`.
abstract class Validators {
  // ── Required Field ─────────────────────────────

  /// Validates that a field is not empty.
  static String? required(String? value, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio.';
    }
    return null;
  }

  // ── Email ──────────────────────────────────────

  /// Validates a well-formed email address.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es obligatorio.';
    }

    // RFC 5322 simplified pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido.';
    }

    return null;
  }

  // ── Password ───────────────────────────────────

  /// Validates a password with minimum security requirements.
  /// - At least 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one digit
  /// - At least one special character
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria.';
    }

    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Debe contener al menos una letra mayúscula.';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Debe contener al menos una letra minúscula.';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Debe contener al menos un número.';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Debe contener al menos un carácter especial.';
    }

    return null;
  }

  /// Validates that a confirmation password matches the original.
  static String? confirmPassword(String? value, String originalPassword) {
    final requiredError = required(value, 'La confirmación de contraseña');
    if (requiredError != null) return requiredError;

    if (value != originalPassword) {
      return 'Las contraseñas no coinciden.';
    }

    return null;
  }

  // ── Phone (Colombian +57) ─────────────────────

  /// Validates a Colombian phone number.
  ///
  /// Accepted formats:
  /// - 3001234567 (10 digits starting with 3)
  /// - +573001234567
  /// - 57 3001234567
  /// - +57 300 123 4567
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El número de teléfono es obligatorio.';
    }

    // Strip spaces, dashes, parentheses and the country code prefix
    String cleaned = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    // Remove leading country code if present
    if (cleaned.startsWith('57') && cleaned.length == 12) {
      cleaned = cleaned.substring(2);
    }

    // Colombian mobile numbers: 10 digits starting with 3
    final colombianMobileRegex = RegExp(r'^3\d{9}$');

    if (!colombianMobileRegex.hasMatch(cleaned)) {
      return 'Ingresa un número de celular colombiano válido (ej: 300 123 4567).';
    }

    return null;
  }

  /// Formats a raw phone number to the standard Colombian format with country code.
  static String formatColombianPhone(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (cleaned.startsWith('57') && cleaned.length == 12) {
      cleaned = cleaned.substring(2);
    }
    return '+57$cleaned';
  }

  // ── Name ───────────────────────────────────────

  /// Validates a person's name (first or last).
  static String? name(String? value, [String fieldName = 'El nombre']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio.';
    }

    if (value.trim().length < 2) {
      return '$fieldName debe tener al menos 2 caracteres.';
    }

    if (value.trim().length > 50) {
      return '$fieldName no debe superar los 50 caracteres.';
    }

    // Allow letters, spaces, hyphens, and accented characters (common in Colombian names)
    final nameRegex = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s\-']+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return '$fieldName solo puede contener letras y espacios.';
    }

    return null;
  }

  // ── Colombian ID (Cedula) ──────────────────────

  /// Validates a Colombian cedula de ciudadania.
  /// Cedulas are numeric and typically between 6 and 10 digits.
  static String? cedula(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El número de cédula es obligatorio.';
    }

    final cleaned = value.replaceAll(RegExp(r'[\s\.\-]'), '');

    if (!RegExp(r'^\d{6,10}$').hasMatch(cleaned)) {
      return 'Ingresa un número de cédula válido (6-10 dígitos).';
    }

    return null;
  }

  // ── Address ────────────────────────────────────

  /// Validates a Colombian street address.
  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La dirección es obligatoria.';
    }

    if (value.trim().length < 10) {
      return 'Ingresa una dirección más detallada.';
    }

    if (value.trim().length > 200) {
      return 'La dirección no debe superar los 200 caracteres.';
    }

    return null;
  }

  // ── Numeric / Price ────────────────────────────

  /// Validates that the value is a positive number.
  static String? positiveNumber(String? value, [String fieldName = 'El valor']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio.';
    }

    final number = double.tryParse(value.replaceAll(RegExp(r'[,\.]'), ''));
    if (number == null || number <= 0) {
      return '$fieldName debe ser un número positivo.';
    }

    return null;
  }

  /// Validates a price in Colombian pesos (COP).
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El precio es obligatorio.';
    }

    final cleaned = value.replaceAll(RegExp(r'[\s\$\.]'), '').replaceAll(',', '');
    final amount = double.tryParse(cleaned);

    if (amount == null || amount < 0) {
      return 'Ingresa un precio válido.';
    }

    if (amount < 5000) {
      return 'El precio mínimo es \$5.000 COP.';
    }

    if (amount > 50000000) {
      return 'El precio máximo es \$50.000.000 COP.';
    }

    return null;
  }

  // ── Review ─────────────────────────────────────

  /// Validates review text.
  static String? reviewText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Escribe tu comentario sobre el servicio.';
    }

    if (value.trim().length < 10) {
      return 'El comentario debe tener al menos 10 caracteres.';
    }

    if (value.trim().length > 500) {
      return 'El comentario no debe superar los 500 caracteres.';
    }

    return null;
  }

  // ── PQR Description ────────────────────────────

  /// Validates PQR (petition/complaint/claim) description.
  static String? pqrDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La descripción del PQR es obligatoria.';
    }

    if (value.trim().length < 20) {
      return 'Describe tu solicitud con al menos 20 caracteres.';
    }

    if (value.trim().length > 2000) {
      return 'La descripción no debe superar los 2000 caracteres.';
    }

    return null;
  }

  // ── Generic Length ─────────────────────────────

  /// Validates minimum character length.
  static String? minLength(String? value, int min, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio.';
    }

    if (value.trim().length < min) {
      return '$fieldName debe tener al menos $min caracteres.';
    }

    return null;
  }

  /// Validates maximum character length.
  static String? maxLength(String? value, int max, [String fieldName = 'Este campo']) {
    if (value != null && value.trim().length > max) {
      return '$fieldName no debe superar los $max caracteres.';
    }

    return null;
  }
}
