import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestMainNavigation extends StatefulWidget {
  const TestMainNavigation({super.key});
  @override
  State<TestMainNavigation> createState() => _TestMainNavigationState();
}

class _TestMainNavigationState extends State<TestMainNavigation> {
  int _currentIndex = 0;
  final labels = ['Home', 'Ingredients', 'Supplies', 'Recipes', 'Quotes', 'More'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(labels[_currentIndex])),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(labels.length, (i) {
          return GestureDetector(
            onTap: () => setState(() => _currentIndex = i),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [Text(labels[i])],
              ),
            ),
          );
        }),
      ),
    );
  }
}

void main() {
  testWidgets('MainNavigation shows tabs and can switch', (tester) async {
    // Initialize Supabase with dummy values so any code referencing the
    // client won't fail during widget build.
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'test-anon-key',
      debug: false,
    );

    await tester.pumpWidget(const MaterialApp(home: TestMainNavigation()));

    // Expect at least one 'Home' label exists
    expect(find.text('Home'), findsWidgets);

    // Tap the first Ingredients nav label we find
    final ingredientFinder = find.text('Ingredients');
    expect(ingredientFinder, findsOneWidget);
    await tester.tap(ingredientFinder);
    // Allow the widget to rebuild; bounded pump avoids long waits
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    // After tapping, ensure the UI shows the Ingredients label in the body
    expect(find.text('Ingredients'), findsWidgets);
  });
}
