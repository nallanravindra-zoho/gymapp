import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/features/account/auth_service.dart';
import 'package:wellbeing/features/groups/groups_remote.dart';
import 'package:wellbeing/features/groups/invite_links.dart';

import '../test_helpers.dart';

const me = 'me';

FakeAuthService signedIn() => FakeAuthService(
  signedIn: const AccountUser(id: me, displayName: 'Divya'),
);

FakeGroupsRemote server() {
  final s = FakeGroupsRemote(me: me, myName: 'Divya');
  s.seedGroup(
    'Walkers',
    id: 'w1',
    owner: 'asha',
    includeMe: false,
    code: 'walk00000001',
  );
  return s;
}

const link = 'wellbeing://join/walk00000001';

void main() {
  group('the pending invite', () {
    test('a link or code is kept, and handled only once', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(pendingInviteProvider.notifier);
      expect(n.offer(link), isTrue);
      expect(c.read(pendingInviteProvider), 'walk00000001');
      expect(n.take(), 'walk00000001');
      expect(n.take(), isNull);
    });

    test('anything else is ignored', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(pendingInviteProvider.notifier);
      expect(n.offer('https://example.com/x'), isFalse);
      expect(n.offer('hi'), isFalse);
      expect(c.read(pendingInviteProvider), isNull);
    });
  });

  group('tapping an invite link', () {
    appTest(
      'starting the app from a link opens Groups and asks to join',
      (tester, db) async {
        expect(find.text('Join Walkers?'), findsOneWidget);
        expect(find.textContaining('choose to share'), findsOneWidget);
        expect(testGroups.isMember('w1'), isFalse, reason: 'asked first');

        await tester.tap(find.text('Join'));
        await tester.pumpAndSettle();
        expect(testGroups.isMember('w1'), isTrue);
        expect(find.text('This week'), findsOneWidget, reason: 'group opened');
      },
      auth: signedIn(),
      groups: server(),
      startLink: link,
    );

    appTest(
      'a link that arrives while the app is open does the same',
      (tester, db) async {
        expect(find.text('Join Walkers?'), findsNothing);
        testLinks.emit(link);
        await tester.pumpAndSettle();
        expect(find.text('Join Walkers?'), findsOneWidget);
        await tester.tap(find.text('Join'));
        await tester.pumpAndSettle();
        expect(testGroups.isMember('w1'), isTrue);
      },
      auth: signedIn(),
      groups: server(),
    );

    appTest(
      'declining joins nothing and does not ask again',
      (tester, db) async {
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(testGroups.isMember('w1'), isFalse);
        expect(find.text('Join Walkers?'), findsNothing);
        // Switching away and back must not bring the question back.
        await tester.tap(find.text('Today'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Groups'));
        await tester.pumpAndSettle();
        expect(find.text('Join Walkers?'), findsNothing);
      },
      auth: signedIn(),
      groups: server(),
      startLink: link,
    );

    appTest(
      'an invalid or expired invite is explained',
      (tester, db) async {
        testLinks.emit('wellbeing://join/doesnotexist1');
        await tester.pumpAndSettle();
        expect(
          find.text('That invite is not valid. Ask for a new one.'),
          findsOneWidget,
        );
      },
      auth: signedIn(),
      groups: server(),
    );

    appTest(
      'a link that is not an invite is ignored',
      (tester, db) async {
        testLinks.emit('https://example.com/join/walk00000001');
        await tester.pumpAndSettle();
        expect(find.text('Join Walkers?'), findsNothing);
        expect(find.text('Groups need an account'), findsNothing);
        expect(testGroups.calls, isNot(contains('previewInvite')));
      },
      auth: signedIn(),
      groups: server(),
    );

    appTest(
      'tapped while signed out: says so, then asks once signed in',
      (tester, db) async {
        expect(find.text('Groups need an account'), findsOneWidget);
        expect(
          find.textContaining('You have an invite to a group'),
          findsOneWidget,
        );
        expect(find.text('Join Walkers?'), findsNothing);

        // Signing in (the sign-in screen is the Account screen).
        await tester.tap(find.text('Sign in'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue with Google'));
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.text('Join Walkers?'), findsOneWidget);
        await tester.tap(find.text('Join'));
        await tester.pumpAndSettle();
        expect(testGroups.isMember('w1'), isTrue);
      },
      auth: FakeAuthService()
        ..signInAs = const AccountUser(id: me, displayName: 'Divya'),
      groups: server(),
      startLink: link,
    );
  });

  group('the Android side', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    final activity = File(
      'android/app/src/main/kotlin/com/gymapp/wellbeing/MainActivity.kt',
    ).readAsStringSync();

    test('the app claims wellbeing://join links', () {
      expect(manifest, contains('android.intent.action.VIEW'));
      expect(manifest, contains('android.intent.category.BROWSABLE'));
      expect(manifest, contains('android:scheme="wellbeing"'));
      expect(manifest, contains('android:host="join"'));
    });

    test('Flutter\'s own deep-link routing stays off', () {
      expect(manifest, contains('flutter_deeplinking_enabled'));
      expect(
        RegExp(r'flutter_deeplinking_enabled"\s+android:value="false"')
            .hasMatch(manifest),
        isTrue,
      );
    });

    test('the activity reads the starting link and new ones', () {
      expect(activity, contains('"initialLink"'));
      expect(activity, contains('onNewIntent'));
      expect(activity, contains('wellbeing/links'));
    });

    test('the channel name matches the Dart side', () {
      final dart = File('lib/features/groups/invite_links.dart')
          .readAsStringSync();
      expect(dart, contains("'wellbeing/links'"));
    });
  });
}
