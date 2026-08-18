import 'package:ar_location_viewer/ar_location_viewer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ar_location_viewer_example/main.dart';

void main() {
  testWidgets('renders the AR location viewer', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(ArLocationWidget), findsOneWidget);
  });
}
