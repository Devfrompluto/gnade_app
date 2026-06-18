// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters, constant_identifier_names

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> _en = {
  "shared": {
    "get_started": "Get Started"
  },
  "onboarding": {
    "title": "Kinetic Retail",
    "subtitle": "Run your business, simply.",
    "already_have_account": "Already have an account? ",
    "sign_in": "Sign In"
  },
  "home": {
    "home_title": "Home",
    "welcome_home": "Welcome Home!",
    "home_subtitle": "You have successfully completed the onboarding process."
  },
  "auth": {
    "welcome_back": "Welcome back",
    "sign_in_to_continue": "Sign in to continue",
    "email": "Email",
    "email_or_employee_id": "Email or Employee ID",
    "email_required": "Email is required",
    "email_or_employee_id_required": "Email or Employee ID is required",
    "email_invalid": "Enter a valid email address",
    "password": "Password",
    "password_required": "Password is required",
    "password_too_short": "Password must be at least 6 characters",
    "remember_me": "Remember me",
    "forgot_password": "Forgot Password?",
    "login_button": "Login",
    "quick_pin_login": "Quick PIN Login",
    "dont_have_account": "Don't have an account? ",
    "sign_up": "Sign Up",
    "sign_up_subtitle": "Create a new account to get started.",
    "create_account": "Create Account",
    "create_account_subtitle": "Create a new account to get started.",
    "name": "Name",
    "name_required": "Name is required",
    "confirm_password": "Confirm Password",
    "confirm_password_required": "Confirm password is required",
    "passwords_do_not_match": "Passwords do not match",
    "create_account_button": "Create Account",
    "already_have_account": "Already have an account? ",
    "sign_in": "Sign In",
    "log_in": "Log In",
    "or_continue_with": "Or Continue With Account",
    "forgot_password_title": "Forgot Password",
    "forgot_password_subtitle": "Enter your email address to receive a reset link\nand regain access to your account.",
    "reset_link_sent": "Password reset link sent to your email.",
    "back_to_login": "Back to Login",
    "send_reset_link": "Send Reset Link"
  }
};
static const Map<String, Map<String,dynamic>> mapLocales = {"en": _en};
}
