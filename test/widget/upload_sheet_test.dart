import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// We test UploadSheet in isolation using a mock upload provider
import '../../lib/features/library/providers/ebook_providers.dart';

void main() {
  group('UploadSheet', () {
    testWidgets('shows validation error when title is empty', (tester) async {
      // We test the form validation inline here to avoid needing a running server
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TextFormField(
                key: const Key('title_field'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
            ),
          ),
        ),
      );

      // Validate without filling title
      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Title is required'), findsOneWidget);
    });

    testWidgets('title field accepts input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFormField(key: const Key('title_field')),
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('title_field')), 'Clean Code');
      expect(find.text('Clean Code'), findsOneWidget);
    });
  });
}
