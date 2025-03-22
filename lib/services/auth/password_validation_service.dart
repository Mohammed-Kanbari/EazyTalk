class PasswordValidationService {
  // Validate minimum length requirement (6+ characters)
  static bool hasMinLength(String password) {
    return password.length >= 6;
  }
  
  // Validate capital letter requirement
  static bool hasCapitalLetter(String password) {
    return RegExp(r'[A-Z]').hasMatch(password);
  }
  
  // Validate number requirement
  static bool hasNumber(String password) {
    return RegExp(r'[0-9]').hasMatch(password);
  }
  
  // Validate that passwords match
  static bool doPasswordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
  
  // Check if password meets all criteria
  static bool isPasswordValid(String password) {
    return hasMinLength(password) && 
           hasCapitalLetter(password) && 
           hasNumber(password);
  }
}