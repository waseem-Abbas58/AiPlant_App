import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:ai_plant_app/app/my_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('MyApp builds successfully', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}
