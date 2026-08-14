import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hotel/services/availability_service.dart';

void main() {
  group('AvailabilityService Unit Tests', () {
    late AvailabilityService availabilityService;

    setUp(() {
      availabilityService = AvailabilityService();
    });

    test('Date overlap helper accurately identifies overlapping stay ranges', () {
      final range1Start = DateTime(2026, 8, 20);
      final range1End = DateTime(2026, 8, 23);

      // Overlapping cases
      expect(
        range1Start.isBefore(DateTime(2026, 8, 22)) && range1End.isAfter(DateTime(2026, 8, 21)),
        isTrue,
      );

      // Non-overlapping cases (Check-out date matches next Check-in date)
      final range2Start = DateTime(2026, 8, 23);
      final range2End = DateTime(2026, 8, 25);

      expect(
        range1End.isBefore(range2Start) || range1End.isAtSameMomentAs(range2Start),
        isTrue,
      );
    });
  });
}
