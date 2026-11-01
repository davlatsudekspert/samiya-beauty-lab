import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/app/app_state.dart';
import 'package:samiya_beauty_lab/data/purchase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_auth.dart';
import 'support/pump.dart';

class FakePurchases implements PurchaseService {
  final logins = <String>[];
  bool pro = false;
  bool cancel = false;
  @override
  bool get isAvailable => true;
  @override
  Future<void> logIn(String uid) async => logins.add(uid);
  @override
  Future<void> logOut() async {}
  @override
  Future<List<ProOffer>> offers() async => const [
        ProOffer(id: 'monthly', price: '\$4.99', yearly: false),
        ProOffer(id: 'annual', price: '\$29.99', yearly: true),
      ];
  @override
  Future<bool> buy(ProOffer offer) async => pro = !cancel;
  @override
  Future<bool> restore() async => pro;
  @override
  Future<bool> hasPro() async => pro;
}

final _vertical = find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).first;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('kirmagan: narxlar ko\'rinadi, lekin avval kirish so\'raladi', (t) async {
    await pumpApp(t, state: AppState(onboarded: true, purchases: FakePurchases()), initial: '/pro');
    await t.pumpAndSettle();
    await t.scrollUntilVisible(find.byKey(const Key('pro-signin')), 250, scrollable: _vertical);
    await t.ensureVisible(find.byKey(const Key('pro-signin')));
    await t.pumpAndSettle();
    expect(find.textContaining('\$29.99'), findsOneWidget);
    expect(find.byKey(const Key('pro-buy')), findsNothing);
  });

  testWidgets('kirgan: yillik tanlangan, obuna -> Pro faol, uid RevenueCat\'ga bog\'langan', (t) async {
    final p = FakePurchases();
    final st = AppState(onboarded: true, purchases: p, auth: FakeAuthService.signedIn());
    await pumpApp(t, state: st, initial: '/pro');
    await t.pumpAndSettle();
    expect(p.logins, ['uid-1']);
    await t.scrollUntilVisible(find.byKey(const Key('pro-buy')), 250, scrollable: _vertical);
    await t.ensureVisible(find.byKey(const Key('pro-buy')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('pro-buy')));
    await t.pump();
    expect(st.isPro, isTrue);
    await t.pump(const Duration(seconds: 20));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('pro-buy')), findsNothing); // Pro faol: xarid bloki yashirinadi
  });

  testWidgets('tiklash: obuna yo\'q bo\'lsa halol xabar', (t) async {
    final st = AppState(onboarded: true, purchases: FakePurchases(), auth: FakeAuthService.signedIn());
    await pumpApp(t, state: st, initial: '/pro');
    await t.pumpAndSettle();
    await t.scrollUntilVisible(find.byKey(const Key('pro-restore')), 250, scrollable: _vertical);
    await t.ensureVisible(find.byKey(const Key('pro-restore')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('pro-restore')));
    await t.pump();
    await t.pumpAndSettle();
    expect(find.text('Faol Pro obunasi topilmadi.'), findsOneWidget);
    expect(st.isPro, isFalse);
  });

  for (final lang in ['uz', 'ru', 'en', 'ar']) {
    testWidgets('320x568, 1.5x, $lang: xarid bloki overflow qilmaydi', (t) async {
      await pumpApp(t,
          state: AppState(locale: Locale(lang), onboarded: true, purchases: FakePurchases(), auth: FakeAuthService.signedIn()),
          initial: '/pro', size: const Size(320, 568), textScale: 1.5);
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  }
}
