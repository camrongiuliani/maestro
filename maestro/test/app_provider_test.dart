import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_core/maestro_core.dart';

void main() {

  group( 'ApplicationProvider Tests', () {

    testWidgets('App Provider Update Should Notify Test', (tester) async {
      await tester.pumpWidget(
        AppProvider(
          application: Application.headless( storageID: '${DateTime.now().millisecondsSinceEpoch}' ),
          viewModel: AppViewModel(),
          child: Container(),
        ),
      );

      var e = tester.element( find.byType( AppProvider ) );
      expect( e.widget, isA<AppProvider>() );
      var ap = e.widget as AppProvider;

      expect( ap.updateShouldNotify( ap ), isFalse );
    });

    testWidgets('App Provider App Exists Test', (tester) async {

      await tester.pumpWidget(
        AppProvider(
          application: Application.headless( storageID: '${DateTime.now().millisecondsSinceEpoch}' ),
          viewModel: AppViewModel(),
          child: Container(),
        ),
      );

      await tester.pumpAndSettle( const Duration( seconds: 1 ) );

      expect(
            () => Application.of(tester.element(find.byType(Container))),
        returnsNormally,
        reason: 'Application should not be null.',
      );

      expect(
        Application.maybeOf(tester.element(find.byType(Container))),
        isNotNull,
        reason: 'Application should not be null.',
      );
    });

    testWidgets('App Provider App Not Exists Test', (tester) async {

      await tester.pumpWidget(Container());

      await tester.pumpAndSettle( const Duration( milliseconds: 100 ) );

      expect(
            () => Application.of(tester.element(find.byType(Container))),
        throwsAssertionError,
        reason: 'Should throw an assertion because we did not use maybeOf and app does not exist in context.',
      );

      expect(
          Application.maybeOf(tester.element(find.byType(Container))),
          isNull,
          reason: 'Application should be null since no provider was used.'
      );
    });
  });
}