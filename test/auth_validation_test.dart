import 'package:flutter_test/flutter_test.dart';

import '../lib/services/auth_service.dart';

void main() {
  group('AuthService validation', () {
    test('accepts approved campus email domains', () {
      expect(AuthService.isCampusEmail('brendon@student.gsu.edu'), isTrue);
      expect(AuthService.isCampusEmail('brendon@gsu.edu'), isTrue);
    });

    test('rejects non-campus email domains', () {
      expect(AuthService.isCampusEmail('brendon@gmail.com'), isFalse);
      expect(AuthService.validateEmail('brendon@gmail.com'), isNotNull);
    });

    test('requires passwords to be at least six characters', () {
      expect(AuthService.validatePassword('12345'), isNotNull);
      expect(AuthService.validatePassword('123456'), isNull);
    });
  });
}