import 'package:flutter_test/flutter_test.dart';
import 'package:school_core/models/models.dart';

void main() {
  test('school_core models can be imported', () {
    // Test that we can import the enums and basic types
    expect(UserRole.values.isNotEmpty, true);
    expect(Gender.values.isNotEmpty, true);
    expect(SchoolType.values.isNotEmpty, true);

    print('All school_core imports working correctly!');
  });
}
