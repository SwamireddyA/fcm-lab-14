/// Validates FCM custom data and maps it to a bundled asset.
/// Only allow-listed values are accepted, so a payload can never
/// produce an arbitrary asset path.
class PayloadResult {
  const PayloadResult.valid(this.asset, this.assetPath) : error = null;
  const PayloadResult.invalid(this.error)
      : asset = null,
        assetPath = null;

  final String? asset;
  final String? assetPath;
  final String? error;

  bool get isValid => error == null;
}

class PayloadValidator {
  static const supportedAction = 'update_ui';
  static const supportedAssets = <String, String>{
    'default': 'assets/images/default.png',
    'promo': 'assets/images/promo.png',
  };

  static PayloadResult validate(Map<String, dynamic> data) {
    final action = data['action'];
    if (action == null) return const PayloadResult.invalid('Missing "action" key');
    if (action != supportedAction) {
      return PayloadResult.invalid('Unsupported action "$action"');
    }
    final asset = data['asset'];
    if (asset == null) return const PayloadResult.invalid('Missing "asset" key');
    final path = supportedAssets[asset];
    if (path == null) {
      return PayloadResult.invalid(
          'Unsupported asset "$asset" (allowed: ${supportedAssets.keys.join(', ')})');
    }
    return PayloadResult.valid(asset as String, path);
  }
}
