import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/shared/widgets/confirm_dialog.dart';
import '../../lib/core/theme/app_colors.dart';

void main() {
  group('ConfirmDialog', () {
    testWidgets('shows title and message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => ElevatedButton(
              key: const Key('show_dialog'),
              onPressed: () => showConfirmDialog(
                ctx,
                title:   'Delete "Clean Code"?',
                message: 'This will permanently remove the ebook.',
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('show_dialog')));
      await tester.pumpAndSettle();

      expect(find.text('Delete "Clean Code"?'), findsOneWidget);
      expect(find.textContaining('permanently remove'), findsOneWidget);
    });

    testWidgets('Cancel button dismisses dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => ElevatedButton(
              key: const Key('show_dialog'),
              onPressed: () => showConfirmDialog(
                ctx,
                title: 'Confirm?', message: 'Are you sure?',
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('show_dialog')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('cancel_button')));
      await tester.pumpAndSettle();

      expect(find.text('Confirm?'), findsNothing);
    });

    testWidgets('Confirm button returns true', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => ElevatedButton(
              key: const Key('show_dialog'),
              onPressed: () async {
                result = await showConfirmDialog(
                  ctx,
                  title: 'Confirm?', message: 'Are you sure?',
                );
              },
              child: const Text('Show'),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('show_dialog')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_button')));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });
  });
}
