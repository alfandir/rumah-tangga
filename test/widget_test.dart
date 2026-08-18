import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rumah_tangga/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await initializeDateFormatting('id_ID', null);
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RumahTanggaApp());

    // Verify that dashboard loaded.
    expect(find.text('Keuangan Rumah Tangga'), findsOneWidget);
  });
}
