import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController {
  static const String _keySeenOnboarding = 'seen_onboarding';

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySeenOnboarding) ?? false;
  }

  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySeenOnboarding, true);
  }
}