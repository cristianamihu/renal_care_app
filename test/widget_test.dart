import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:renal_care_app/features/home/presentation/views/home_screen.dart';

//import 'package:renal_care_app/main.dart';
import 'package:renal_care_app/features/auth/domain/entities/user.dart';
//import 'package:renal_care_app/features/auth/domain/usecases/sign_in.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodel/auth_state.dart';
//import 'package:renal_care_app/core/di/auth_providers.dart';
//import 'package:renal_care_app/features/auth/domain/repositories/auth_repository.dart';

class FakeAuthNotifier extends StateNotifier<AuthState> {
  FakeAuthNotifier()
    : super(
        AuthState(
          status: AuthStatus.authenticated,
          user: User(uid: 'u1', email: 'x@x.x', role: UserRole.patient),
        ),
      );
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // 1. Construieşte doar HomePage într-un MaterialApp
    await tester.pumpWidget(
      const MaterialApp(home: HomePage(title: 'Test Counter')),
    );

    // Așteaptă ca router-ul să își termine animațiile / navigările
    await tester.pumpAndSettle();

    // Build our app and trigger a frame.
    //await tester.pumpWidget(const RenalCareApp());

    // Verifică că counter-ul e la 0
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Apasă butonul '+' și reconstruiește interfața
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verifică că counter-ul a crescut la 1
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
