import 'package:flutter_test/flutter_test.dart';
import 'package:notification_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NotificationHubApp());
    expect(find.text('Notification Hub'), findsOneWidget);
  });
}
