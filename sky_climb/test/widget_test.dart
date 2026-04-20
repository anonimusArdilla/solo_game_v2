import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sky_climb/app/app.dart';

void main() {
  testWidgets('App shows home screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: SkyClimbApp()));
    await tester.pumpAndSettle();

    expect(find.text('Sky Climb'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
