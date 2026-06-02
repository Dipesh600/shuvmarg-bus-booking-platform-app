/// Selects which backend the app connects to.
/// Change [ApiEndpoints._env] to switch environments.
enum DevTarget {
  /// flutter run -d macos  (Mac Desktop simulator)
  macDesktop,

  /// Android Studio AVD emulator — backend accessible via 10.0.2.2
  androidEmu,

  /// Real Android/iOS phone on the same Wi-Fi as your Mac
  physicalDevice,

  /// Live production server
  production,
}
