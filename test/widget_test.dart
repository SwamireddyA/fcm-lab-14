import 'package:fcm_lab/models/payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('valid promo payload maps to promo asset', () {
    final r = PayloadValidator.validate({'action': 'update_ui', 'asset': 'promo'});
    expect(r.isValid, isTrue);
    expect(r.assetPath, 'assets/images/promo.png');
  });

  test('missing asset is rejected', () {
    final r = PayloadValidator.validate({'action': 'update_ui'});
    expect(r.isValid, isFalse);
  });

  test('unknown asset is rejected', () {
    final r = PayloadValidator.validate({'action': 'update_ui', 'asset': 'unknown'});
    expect(r.isValid, isFalse);
  });

  test('unsupported action is rejected', () {
    final r = PayloadValidator.validate({'action': 'delete_all', 'asset': 'promo'});
    expect(r.isValid, isFalse);
  });
}
