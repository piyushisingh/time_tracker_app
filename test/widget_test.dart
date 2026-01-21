import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker_app/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const TimeTrackerApp());
    expect(find.text('Time Tracker'), findsOneWidget);
  });
}
