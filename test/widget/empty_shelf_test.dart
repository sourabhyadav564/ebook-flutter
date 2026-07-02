import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/features/library/presentation/empty_shelf.dart';

void main() {
  group('EmptyShelf', () {
    testWidgets('shows "Your shelf is empty" message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: EmptyShelf())),
      );
      await tester.pumpAndSettle();
      expect(find.text('Your shelf is empty'), findsOneWidget);
    });

    testWidgets('shows instructional subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: EmptyShelf())),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('upload'), findsOneWidget);
    });
  });
}
