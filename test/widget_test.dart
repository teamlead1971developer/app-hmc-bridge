import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_hmc_bridge/main.dart';

void main() {
  testWidgets('HomeScreen shows title, stats, and mode buttons', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AromaAtelierApp());
    await tester.pumpAndSettle();

    expect(find.text('Aroma Atelier'), findsOneWidget);
    // เซฟใหม่เริ่มวันที่ 1 พร้อมเหรียญตั้งต้น
    expect(find.text('เปิดร้าน — วันที่ 1'), findsOneWidget);
    expect(find.text('แต่งร้าน 🪴'), findsOneWidget);
    expect(find.text('🪙 120'), findsOneWidget);
  });
}
