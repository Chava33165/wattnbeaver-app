class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email es requerido';
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Email invalido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Contrasena requerida';
    if (value.length < 6) {
      return 'La contrasena debe tener al menos 6 caracteres';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) return 'Nombre es requerido';
    if (value.length < 3) return 'Nombre debe tener al menos 3 caracteres';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirma tu contrasena';
    if (value != password) return 'Las contrasenas no coinciden';
    return null;
  }

  static String passwordStrength(String password) {
    if (password.length < 6) return 'Debil';
    if (password.length >= 10 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]'))) {
      return 'Fuerte';
    }
    return 'Media';
  }
}
