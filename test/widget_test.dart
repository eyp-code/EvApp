import 'package:ev_masraflari_app/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EvApp opens and navigates between main sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EvApp());

    expect(find.text('Ev Özeti'), findsOneWidget);
    expect(find.text('Masraflar'), findsNothing);

    await tester.tap(find.text('Masraf'));
    await tester.pumpAndSettle();

    expect(find.text('Masraflar'), findsOneWidget);
  });
}
