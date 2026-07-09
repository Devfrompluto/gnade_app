class AppUtils {
  /// Checks if data is null.
  static bool isNull(dynamic value) => value == null;

  /// Checks if data is null or blank (empty or only contains whitespace).
  static bool isBlank(dynamic value) {
    if (value == null) return true;
    if (value is String) {
      return value.trim().isEmpty;
    }
    if (value is Iterable || value is Map) {
      return value.isEmpty;
    }
    return false;
  }

  /// Uppercase first letter inside string and let the others lowercase.
  /// Example: your name => Your name
  static String? capitalizeFirst(String s) {
    if (isBlank(s)) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  /// Checks if string is phone number.
  static bool isPhoneNumber(String s) {
    if (s.length > 16 || s.length < 8) return false;
    return hasMatch(s, r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
  }

  /// Format a raw phone number input with a country dial code to E.164 format.
  /// Strips any leading '0' or non-digit characters.
  static String formatE164(String dialCode, String rawNumber) {
    String cleaned = rawNumber.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }
    return '$dialCode$cleaned';
  }

  static bool hasMatch(String? value, String pattern) {
    return (value == null) ? false : RegExp(pattern).hasMatch(value);
  }

  static bool isValidEmail(String s) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(s);
  }

  /// Checks if string is URL.
  static bool isURL(String s) => hasMatch(
        s,
        r"^((((H|h)(T|t)|(F|f))(T|t)(P|p)((S|s)?))\\://)?(www.|[a-zA-Z0-9].)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,6}(\:[0-9]{1,5})*(/($|[a-zA-Z0-9\.\,\;\?\'\\\+&%\$#\=~_\-]+))*$",
      );
}
