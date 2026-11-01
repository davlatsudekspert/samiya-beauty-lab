import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/backend_api.dart';
import '../data/personal_store.dart';
import '../features/auth/auth_service.dart';
import '../features/scanner/ingredient_models.dart';
import '../features/scanner/text_scanner.dart';

/// Qo'llab-quvvatlanadigan tillar: O'zbek, Rus, Ingliz, Arab (RTL).
const supportedLocales = <Locale>[Locale('uz'), Locale('ru'), Locale('en'), Locale('ar')];

/// Til o'z nomida ko'rsatiladi (hamma tilda bir xil), tarjima kalitlari kerak emas.
const languageNativeNames = <String, String>{'uz': 'O‘zbekcha', 'ru': 'Русский', 'en': 'English', 'ar': 'العربية'};

enum UserRole { user, student, cosmetologist, teacher }

// Named parametrlar private maydonga `this._x` bilan bog'lanmaydi (Dart cheklovi).
// ignore_for_file: prefer_initializing_formals

/// Ilovaning global holati: til, onboarding tugaganmi, rol. Diskda saqlanadi.
class AppState extends ChangeNotifier {
  AppState({
    Locale locale = const Locale('uz'),
    bool onboarded = false,
    UserRole? role,
    IngredientRepository? ingredients,
    AuthService? auth,
    BackendApi? backend,
    TextScanner? scanner,
    PersonalStore? personal,
    CampaignInfo campaign = CampaignInfo.open,
  }) : ingredients = ingredients ?? IngredientRepository(const []),
       auth = auth ?? const UnavailableAuthService(),
       backend = backend ?? const NoBackendApi(),
       scanner = scanner ?? const UnavailableTextScanner(),
       personal = personal ?? PersonalStore(persist: false),
       _campaign = campaign,
       _locale = locale,
       _onboarded = onboarded,
       _role = role {
    _user = this.auth.currentUser;
    _authSub = this.auth.changes.listen((u) {
      _user = u;
      notifyListeners();
      refreshMe();
    });
    if (_user != null) refreshMe();
  }

  MeInfo _me = MeInfo.none;

  /// Admin va Pro holati FAQAT serverdan (kirgan va backend sozlangan bo'lsa); xatoda xavfsiz tomon: false.
  bool get isAdmin => _user != null && _me.isAdmin;
  bool get isPro => _user != null && _me.pro;

  CampaignInfo _campaign;
  CampaignInfo get campaign => _campaign;

  /// Hamma bo'lim ochiqmi: Pro yoki kampaniya davom etmoqda (launchdan oldin ham ochiq).
  bool get unlocked => isPro || _campaign.allOpen;

  /// Kampaniya bosqichini serverdan oladi; oxirgi ma'lum holat saqlanadi (oflaynda chetlab o'tilmasin).
  Future<void> refreshCampaign() async {
    if (!backend.isConfigured) return;
    try {
      final c = await backend.campaign();
      if (c.phase != _campaign.phase || c.daysRemaining != _campaign.daysRemaining) {
        _campaign = c;
        notifyListeners();
      }
      final p = await SharedPreferences.getInstance();
      await p.setString('campaign_phase', c.phase);
      if (c.daysRemaining != null) await p.setInt('campaign_days', c.daysRemaining!);
    } catch (_) {
      // tarmoq xatosi: oxirgi ma'lum holat qoladi
    }
  }

  /// Serverdan /me ni olib, admin/Pro holatini yangilaydi. Hech qachon xato tashlamaydi.
  Future<void> refreshMe() async {
    final uid = _user?.uid;
    var next = MeInfo.none;
    if (uid != null && backend.isConfigured) {
      try {
        final token = await auth.idToken();
        if (token != null) next = await backend.me(token);
      } catch (_) {
        next = MeInfo.none;
      }
    }
    if (_user?.uid != uid) return; // kutish paytida boshqa foydalanuvchi/chiqish bo'ldi
    if (next.isAdmin != _me.isAdmin || next.pro != _me.pro) {
      _me = next;
      notifyListeners();
    }
  }

  Future<String> _adminToken() async {
    if (!isAdmin) throw StateError('admin emas');
    final token = await auth.idToken();
    if (token == null) throw StateError('token yo\'q');
    return token;
  }

  /// SAMIYA AI savoli: faqat kirgan foydalanuvchi; ilovadagi dalil kartochkalaridan qisqa kontekst qo'shiladi.
  Future<AiAnswer> askAi(String question, {required String requestId, List<AiTurn> history = const []}) async {
    final token = _user == null ? null : await auth.idToken();
    if (token == null) throw const BackendException(401, 'sign_in_required');
    if (!backend.isConfigured) throw const BackendException(503, 'ai_not_configured');
    return backend.askAi(
      token,
      requestId: requestId,
      question: question,
      lang: locale.languageCode,
      context: ingredients.aiContextFor(question),
      history: history,
    );
  }

  Future<AdminStats> adminStats() async => backend.adminStats(await _adminToken());
  Future<List<ProGrant>> listGrants() async => backend.listGrants(await _adminToken());
  Future<void> grantPro(String email, {int? days}) async => backend.grantPro(await _adminToken(), email, days: days);
  Future<void> revokePro(String email) async => backend.revokePro(await _adminToken(), email);

  /// Kirish xizmati (Firebase yoki "mavjud emas" holati).
  final AuthService auth;

  /// Backend mijozi (manzil berilmagan bo'lsa NoBackendApi).
  final BackendApi backend;

  /// Rasmdan tarkib matnini o'qish (qurilmada); veb/sinovda "mavjud emas".
  final TextScanner scanner;

  /// Teri afzalliklari, parvarish rejasi va kundalik (faqat qurilmada).
  final PersonalStore personal;
  AuthUser? _user;
  StreamSubscription<AuthUser?>? _authSub;

  /// Kirgan foydalanuvchi (mehmon rejimida null).
  AuthUser? get user => _user;

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  /// Ingredient bazasi (assets/content/ingredients.json), o'zgarmas.
  final IngredientRepository ingredients;

  Locale _locale;
  bool _onboarded;
  UserRole? _role;

  Locale get locale => _locale;
  bool get onboarded => _onboarded;
  UserRole? get role => _role;

  static Future<AppState> load({AuthService? auth, BackendApi? backend, TextScanner? scanner}) async {
    final p = await SharedPreferences.getInstance();
    final code = p.getString('locale');
    final roleName = p.getString('role');
    final repo = IngredientRepository.fromJson(await rootBundle.loadString('assets/content/ingredients.json'));
    return AppState(
      ingredients: repo,
      auth: auth,
      backend: backend,
      scanner: scanner,
      personal: await PersonalStore.load(),
      locale: Locale(languageNativeNames.containsKey(code) ? code! : 'uz'),
      onboarded: p.getBool('onboarded') ?? false,
      role: UserRole.values.where((r) => r.name == roleName).firstOrNull,
      campaign: CampaignInfo(phase: p.getString('campaign_phase') ?? 'prelaunch', daysRemaining: p.getInt('campaign_days')),
    )..refreshCampaign();
  }

  Future<void> setLocale(String code) async {
    assert(languageNativeNames.containsKey(code));
    _locale = Locale(code);
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString('locale', code);
  }

  Future<void> setRole(UserRole role) async {
    _role = role;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString('role', role.name);
  }

  Future<void> completeOnboarding() async {
    _onboarded = true;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setBool('onboarded', true);
  }

  Future<void> signOut() => auth.signOut();

  /// Hisobni o'chirish. Tartib muhim: AVVAL backend ma'lumotlari (token hali yaroqli), KEYIN auth hisobi.
  /// Backend o'chira olmasa auth hisobi saqlanadi (ma'lumot yetim qolmaydi, qayta urinish mumkin).
  /// Auth "yaqinda kirish" talab qilsa [AuthFailure.requiresRecentLogin]; backend o'chirilgan bo'lsa ham qayta urinish xavfsiz (idempotent).
  Future<void> deleteAccount() async {
    final token = await auth.idToken();
    if (backend.isConfigured) {
      if (token == null) throw const AuthException(AuthFailure.requiresRecentLogin);
      try {
        await backend.deleteMe(token);
      } on BackendException {
        throw const AuthException(AuthFailure.failed);
      }
    }
    await auth.deleteAccount();
    _role = null;
    notifyListeners();
    await (await SharedPreferences.getInstance()).remove('role');
    await personal.clear(); // qurilmadagi shaxsiy yozuvlar ham o'chadi
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
