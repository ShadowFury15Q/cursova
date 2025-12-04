import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await MobileAds.instance.initialize();
  await AppOpenAdManager.instance.loadAd();
  runApp(const AppRoot());
}



class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  bool _isLoading = false;

  AppOpenAdManager._internal();
  static final AppOpenAdManager instance = AppOpenAdManager._internal();

  Future<void> loadAd() async {
    if (_isLoading) return;
    _isLoading = true;

    AppOpenAd.load(
      adUnitId: kReleaseMode
          ? 'ca-app-pub-6412264727855282/3492086668'
          : 'ca-app-pub-3940256099942544/3419835294',
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _appOpenAd = null;
        },
      ),
    );
  }

  void showAdIfAvailable() {
    if (_appOpenAd == null) {
      // если ещё не загрузилось — пробуем загрузить и повторить попытку через секунду
      loadAd();
      Future.delayed(const Duration(seconds: 1), showAdIfAvailable);
      return;
    }
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );
    _appOpenAd!.show();
    _appOpenAd = null;
  }
}

class AppLang extends ChangeNotifier {
  String code = 'en';
  void setCode(String c) {
    if (c == code) return;
    code = c;
    notifyListeners();
  }
  void toggle() {
    if (code == 'uk') {
      code = 'en';
    } else if (code == 'en') {
      code = 'ru';
    } else {
      code = 'uk';
    }
    notifyListeners();
  }
  String t(String k) => _strings[code]![k] ?? k;


  static const _strings = {
    'uk': {
      'app_title': 'Memo',
      'auth': 'Авторизація',
      'login': 'Вхід',
      'register': 'Реєстрація',
      'continue_google': 'Продовжити з Google',
      'email': 'Email',
      'password': 'Пароль',
      'repeat_password': 'Повторіть пароль',
      'forgot_password': 'Забули пароль?',
      'send_reset': 'Надіслати лист',
      'reset_email_sent': 'Лист для відновлення відправлено',
      'delete_account': 'Видалення облікового запису',
      'confirm_password': 'Підтвердіть пароль',
      'delete': 'Видалити',
      'delete_selected': 'Видалити вибрані',
      'sign_out': 'Вийти',
      'add': 'Додати фото',
      'take_photo': 'Зняти фото (камера)',
      'pick_gallery': 'Обрати з галереї',
      'no_photos': 'Ще немає фото',
      'created': 'Створено',
      'your_comment': 'Ваш коментар...',
      'add_comment': 'Додати',
      'no_comments': 'Немає коментарів',
      'full_screen': 'На весь екран',
      'language': 'Мова',
      'theme_light': 'Світла тема',
      'theme_dark': 'Темна тема',
      'search_comments': 'Пошук коментарів...',
      'nothing_found': 'Нічого не знайдено',
      'enter_comment_hint': 'Введіть коментар...',
      'sort': 'Сортування',
      'newest': 'Новіші спочатку',
      'oldest': 'Старіші спочатку',
      'by_name': 'За ім’ям',
      'layout': 'Відображення',
      'list': 'Список',
      'grid': 'Плитка',
      'select_mode_on': 'Режим вибору',
      'cancel': 'Скасувати',
      'delete_comment': 'Видалити коментар',
      'settings': 'Налаштування',
      'color_theme': 'Колір інтерфейсу',
      'color_theme_subtitle': 'Оберіть основний колір програми. Усі фіолетові елементи зміняться на вибраний відтінок.',
      'tutorial': 'Тутор',
      'tutorial_title': 'Тутор',
      'tutorial_body': 'Ласкаво просимо до Memo-Photo Memories\n\n'
          '1. Створіть акаунт або увійдіть. Скористайтеся формою реєстрації або входу. '
          'Ви можете натиснути на іконку ока, щоб показати або приховати пароль.\n\n'
          '2. Додайте перше спогад-фото. Натисніть кнопку "Додати фото" і виберіть фото з галереї. '
          'За бажанням додайте назву та опис.\n\n'
          '3. Переглядайте свої спогади. Усі збережені спогади відображаються на головному екрані. '
          'Натисніть на картку, щоб відкрити фото та деталі.\n\n'
          '4. Редагуйте або видаляйте спогад. Відкрийте спогад і використайте кнопки редагування або видалення, '
          'щоб змінити чи прибрати його.\n\n'
          '5. Вихід з акаунта. Скористайтеся кнопкою меню, щоб вийти з акаунта, коли завершите роботу.',
    },
    'en': {
      'app_title': 'Memo',
      'auth': 'Authentication',
      'login': 'Login',
      'register': 'Register',
      'continue_google': 'Continue with Google',
      'email': 'Email',
      'password': 'Password',
      'repeat_password': 'Repeat password',
      'forgot_password': 'Forgot password?',
      'send_reset': 'Send email',
      'reset_email_sent': 'Password reset email sent',
      'delete_account': 'Delete account',
      'confirm_password': 'Confirm password',
      'delete': 'Delete',
      'delete_selected': 'Delete selected',
      'sign_out': 'Sign out',
      'add': 'Add photo',
      'take_photo': 'Take photo (camera)',
      'pick_gallery': 'Pick from gallery',
      'no_photos': 'No photos yet',
      'created': 'Created',
      'your_comment': 'Your comment...',
      'add_comment': 'Add',
      'no_comments': 'No comments',
      'full_screen': 'Fullscreen',
      'language': 'Language',
      'theme_light': 'Light theme',
      'theme_dark': 'Dark theme',
      'search_comments': 'Search comments...',
      'nothing_found': 'Nothing found',
      'enter_comment_hint': 'Type comment...',
      'sort': 'Sort',
      'newest': 'Newest first',
      'oldest': 'Oldest first',
      'by_name': 'By name',
      'layout': 'Layout',
      'list': 'List',
      'grid': 'Grid',
      'select_mode_on': 'Select mode',
      'cancel': 'Cancel',
      'delete_comment': 'Delete comment',
      'settings': 'Settings',
      'color_theme': 'Interface color',
      'color_theme_subtitle': 'Choose the main app color. All current purple elements will use this color.',
      'tutorial': 'Tutorial',
      'tutorial_title': 'Tutorial',
      'tutorial_body': 'Welcome to Memo-Photo Memories\n\n'
          '1. Create an account or sign in. Use the registration or login form. '
          'You can tap the eye icon to show or hide your password.\n\n'
          '2. Add your first memory. Press the "Add photo" button and select a photo from your gallery. '
          'Add a title and description if you want.\n\n'
          '3. View your memories. All saved memories are shown on the main screen. '
          'Tap a card to open the full photo and details.\n\n'
          '4. Edit or delete a memory. Open a memory and use the edit or delete buttons to change or remove it.\n\n'
          '5. Logout. Use the menu button to log out of your account when you finish.',

    },
    'ru': {
      'app_title': 'Memo',
      'auth': 'Авторизация',
      'login': 'Вход',
      'register': 'Регистрация',
      'continue_google': 'Продолжить через Google',
      'email': 'Email',
      'password': 'Пароль',
      'repeat_password': 'Повторите пароль',
      'forgot_password': 'Забыли пароль?',
      'send_reset': 'Отправить письмо',
      'reset_email_sent': 'Письмо для сброса пароля отправлено',
      'delete_account': 'Удаление аккаунта',
      'confirm_password': 'Подтвердите пароль',
      'delete': 'Удалить',
      'delete_selected': 'Удалить выбранные',
      'sign_out': 'Выйти из аккаунта',
      'add': 'Добавить фото',
      'take_photo': 'Сделать фото (камера)',
      'pick_gallery': 'Выбрать из галереи',
      'no_photos': 'Пока нет фото',
      'created': 'Создано',
      'your_comment': 'Ваш комментарий',
      'add_comment': 'Добавить комментарий',
      'no_comments': 'Нет комментариев',
      'full_screen': 'На весь экран',
      'OK': 'ОК',
      'language': 'Язык',
      'theme_light': 'Светлая тема',
      'theme_dark': 'Тёмная тема',
      'search_comments': 'Поиск по комментариям...',
      'nothing_found': 'Ничего не найдено',
      'enter_comment_hint': 'Введите комментарий...',
      'sort': 'Сортировка',
      'newest': 'Сначала новые',
      'oldest': 'Сначала старые',
      'by_name': 'По имени',
      'layout': 'Вид',
      'list': 'Список',
      'grid': 'Сетка',
      'select_mode_on': 'Режим выбора',
      'cancel': 'Отмена',
      'delete_comment': 'Удалить комментарий',
      'settings': 'Настройки',
      'color_theme': 'Цвет интерфейса',
      'color_theme_subtitle': 'Выберите основной цвет приложения. Все фиолетовые элементы сменят цвет на выбранный.',
      'tutorial': 'Туториал',
      'tutorial_title': 'Туториал',
      'tutorial_body': 'Добро пожаловать в Memo-Photo Memories\n\n'
          '1. Создайте аккаунт или войдите. Используйте форму регистрации или входа. '
          'Вы можете нажать на иконку глаза, чтобы показать или скрыть пароль.\n\n'
          '2. Добавьте своё первое фото-воспоминание. Нажмите кнопку "Добавить фото" и выберите фото из галереи. '
          'При желании добавьте заголовок и описание.\n\n'
          '3. Просматривайте свои воспоминания. Все сохранённые фото отображаются на главном экране. '
          'Нажмите на карточку, чтобы открыть полное фото и детали.\n\n'
          '4. Редактируйте или удаляйте воспоминания. Откройте воспоминание и используйте кнопки редактирования или удаления, '
          'чтобы изменить или удалить его.\n\n'
          '5. Выход из аккаунта. Используйте кнопку меню, чтобы выйти из аккаунта, когда закончите работу.',
    }
  };
}

class LangProvider extends InheritedNotifier<AppLang> {
  const LangProvider({super.key, required super.notifier, required super.child});
  static AppLang of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LangProvider>()!.notifier!;
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final _lang = AppLang();
  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = Colors.indigo;


  static const _keyThemeMode = 'settings_theme_mode';
  static const _keyAccentColor = 'settings_accent_color';
  static const _keyLangCode = 'settings_lang_code';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppOpenAdManager.instance.showAdIfAvailable();
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_keyThemeMode);
    if (themeIndex != null &&
        themeIndex >= 0 &&
        themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
    }

    final accent = prefs.getInt(_keyAccentColor);
    if (accent != null) {
      _accentColor = Color(accent);
    }

    final langCode = prefs.getString(_keyLangCode);
    if (langCode != null && ['en', 'ru', 'uk'].contains(langCode)) {
      _lang.setCode(langCode);
    }

    if (mounted) setState(() {});
  }

  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, _themeMode.index);
  }

  Future<void> _saveAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAccentColor, _accentColor.value);
  }

  Future<void> _saveLang() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLangCode, _lang.code);
  }

  void _toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
    _saveThemeMode();
  }

  void _toggleLang() {
    _lang.toggle();
    _saveLang();
  }

  void _setAccentColor(Color color) {
    setState(() {
      _accentColor = color;
    });
    _saveAccentColor();
  }

  @override
  Widget build(BuildContext context) {

    final bool isYellowAccent =
        _accentColor.value == const Color(0xFFBCC100).value;

    return LangProvider(
      notifier: _lang,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Memo',
        themeMode: _themeMode,

        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: _accentColor,
          ).copyWith(
            primary: _accentColor,
            primaryContainer: _accentColor,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: _accentColor,
            foregroundColor: isYellowAccent ? Colors.black87 : null,
          ),
        ),

        darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: _accentColor,
            brightness: Brightness.dark,
          ).copyWith(
            primary: _accentColor,
            primaryContainer: _accentColor,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: _accentColor,
            foregroundColor: isYellowAccent ? Colors.black87 : null,
          ),
        ),

        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final user = snap.data;
            if (user == null) {
              return AuthPage(onToggleTheme: _toggleTheme);
            }
            return HomePage(
              onToggleTheme: _toggleTheme,
              onToggleLang: _toggleLang,
              isDark: _themeMode == ThemeMode.dark,
              accentColor: _accentColor,
              onAccentColorChanged: _setAccentColor,
            );
          },
        ),
      ),
    );
  }
}




class AuthPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const AuthPage({super.key, required this.onToggleTheme});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this)..addListener(() { if (mounted) setState(() {}); });
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  bool loading = false;
  bool _showPass = false;
  bool _showPass2 = false;


  Future<void> _forgotDialog() async {
    final L = LangProvider.of(context);
    final c = TextEditingController();
    await showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text(L.t('forgot_password')),
        content: TextField(controller: c, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: L.t('email'))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(L.t('cancel'))),
          FilledButton(onPressed: () async {
            final email = c.text.trim();
            if (email.isEmpty) return;
            try {
              await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(L.t('reset_email_sent'))));
                Navigator.pop(context);
              }
            } catch (e) {}
          }, child: Text(L.t('send_reset'))),
        ],
      );
    });
  }

  Future<void> _showTutorial() async {
    final L = LangProvider.of(context);
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(L.t('tutorial_title')),
          content: SingleChildScrollView(
            child: Text(L.t('tutorial_body')),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(L.t('OK')),
            ),
          ],
        );
      },
    );
  }


  Future<void> _signIn() async {
    try {
      setState(() => loading = true);
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text.trim(), password: _pass.text.trim());
    } on FirebaseAuthException catch (e) {
      _err(e.message);
    } finally { if (mounted) setState(() => loading = false); }
  }

  Future<void> _register() async {
    if (_pass.text != _pass2.text) { _err('Паролі не співпадають'); return; }
    try {
      setState(() => loading = true);
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text.trim(), password: _pass.text.trim());
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'email': _email.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      _err(e.message);
    } finally { if (mounted) setState(() => loading = false); }
  }

  Future<void> _signGoogle() async {
    try {
      final gUser = await GoogleSignIn().signIn();
      if (gUser == null) return;
      final gAuth = await gUser.authentication;
      final cred = GoogleAuthProvider.credential(accessToken: gAuth.accessToken, idToken: gAuth.idToken);
      await FirebaseAuth.instance.signInWithCredential(cred);
    } catch (e) {
      _err(e.toString());
    }
  }

  void _err(String? m) { if (m == null) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m))); }

  @override
  Widget build(BuildContext context) {
    final L = LangProvider.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_tab.index == 0 ? L.t('auth') : L.t('register')),
        bottom: TabBar(controller: _tab, tabs: [Tab(text: L.t('login')), Tab(text: L.t('register'))]),
        actions: [
          IconButton(
            tooltip: L.t('language'),
            onPressed: L.toggle,
            icon: Text(
              L.code == 'en'
                  ? '🇺🇸'
                  : L.code == 'ru'
                      ? '🇷🇺'
                      : '🇺🇦',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          IconButton(
            tooltip: theme.brightness == Brightness.dark ? L.t('theme_light') : L.t('theme_dark'),
            onPressed: widget.onToggleTheme,
            icon: Icon(theme.brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _form(L, isLogin: true),
          _form(L, isLogin: false),
        ],
      ),
    );
  }

  Widget _form(AppLang L, {required bool isLogin}) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: L.t('email'))),
            const SizedBox(height: 12),
            TextField(
              controller: _pass,
              obscureText: !_showPass,
              decoration: InputDecoration(
                labelText: L.t('password'),
                suffixIcon: IconButton(
                  icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _showPass = !_showPass;
                    });
                  },
                ),
              ),
            ),
            if (!isLogin) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _pass2,
                obscureText: !_showPass2,
                decoration: InputDecoration(
                  labelText: L.t('repeat_password'),
                  suffixIcon: IconButton(
                    icon: Icon(_showPass2 ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _showPass2 = !_showPass2;
                      });
                    },
                  ),
                ),
              ),

            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: loading ? null : (isLogin ? _signIn : _register),
              icon: Icon(isLogin ? Icons.login : Icons.person_add),
              label: Text(loading ? '...' : (isLogin ? L.t('login') : L.t('register'))),
            ),
            if (isLogin) TextButton(onPressed: _forgotDialog, child: Text(L.t('forgot_password'))),
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: _signGoogle, icon: const Icon(Icons.g_mobiledata, size: 28), label: Text(L.t('continue_google'))),
            TextButton(
              onPressed: _showTutorial,
              child: Text(L.t('tutorial')),
            ),

          ]),
        ),
      ),
    );

  }

}

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLang;
  final bool isDark;
  final Color accentColor;
  final ValueChanged<Color> onAccentColorChanged;
  const HomePage({
    super.key,
    required this.onToggleTheme,
    required this.onToggleLang,
    required this.isDark,
    required this.accentColor,
    required this.onAccentColorChanged,
  });
  @override
  State<HomePage> createState() => _HomePageState();
}

enum SortMode { newest, oldest, name }

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _photos = [];
  bool _loading = true;
  bool _grid = false;
  SortMode _sort = SortMode.newest;
  static const _keySort = 'home_sort_mode';
  static const _keyGrid = 'home_grid_mode';
  bool _selectMode = false;
  final Set<String> _selected = {};


  InterstitialAd? _homeInterstitialAd;
  bool _homeIsAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadFromCloud();
    _loadHomeInterstitial();
  }


  Future<void> _loadFromCloud() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final fs = FirebaseFirestore.instance;


    final snaps = await fs
        .collection('users').doc(uid).collection('photos')
        .orderBy('created_at', descending: true).get();

    _photos = snaps.docs.map((d) {
      final m = d.data();
      m['id'] = d.id;
      return m;
    }).toList();

    for (final m in _photos) {
      final cm = await fs
          .collection('users').doc(uid)
          .collection('photos').doc(m['id'] as String)
          .collection('comments')
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();
      m['last_comment'] = cm.docs.isEmpty ? '' : (cm.docs.first['text'] as String? ?? '');
    }

    _applySort();
    if (!mounted) return;
    setState(() { _loading = false; });
  }
  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final sortStr = prefs.getString(_keySort);
    if (sortStr == 'newest') _sort = SortMode.newest;
    if (sortStr == 'oldest') _sort = SortMode.oldest;
    if (sortStr == 'name')   _sort = SortMode.name;

    final grid = prefs.getBool(_keyGrid);
    if (grid != null) _grid = grid;

    if (mounted) setState(() {});
  }

  Future<void> _saveSort() async {
    final prefs = await SharedPreferences.getInstance();
    String v = 'newest';
    switch (_sort) {
      case SortMode.newest: v = 'newest'; break;
      case SortMode.oldest: v = 'oldest'; break;
      case SortMode.name:   v = 'name';   break;
    }
    await prefs.setString(_keySort, v);
  }

  Future<void> _saveGrid() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGrid, _grid);
  }

  void _applySort() {
    switch (_sort) {
      case SortMode.newest:
        _photos.sort((a,b)=> DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));
        break;
      case SortMode.oldest:
        _photos.sort((a,b)=> DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
        break;
      case SortMode.name:
        _photos.sort((a,b)=> (a['id'] as String).compareTo(b['id'] as String));
        break;
    }
  }


  void _loadHomeInterstitial() {
    InterstitialAd.load(
      adUnitId: kReleaseMode
          ? 'ca-app-pub-6412264727855282/1947070705'
          : 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _homeInterstitialAd = ad;
          _homeIsAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _homeInterstitialAd = null;
          _homeIsAdLoaded = false;
        },
      ),
    );
  }

  void _openPhotoFromHome(Map<String, dynamic> p) {
    if (_homeIsAdLoaded && _homeInterstitialAd != null) {
      _homeInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _homeInterstitialAd = null;
          _homeIsAdLoaded = false;
          _loadHomeInterstitial();
          _navigateToPhoto(p);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _homeInterstitialAd = null;
          _homeIsAdLoaded = false;
          _loadHomeInterstitial();
          _navigateToPhoto(p);
        },
      );
      _homeInterstitialAd!.show();
    } else {
      _navigateToPhoto(p);
      _loadHomeInterstitial();
    }
  }

  void _navigateToPhoto(Map<String, dynamic> p) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PhotoDetails(photo: p)),
    );
  }

  Future<void> _addPhoto(ImageSource src) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: src, imageQuality: 90);
    if (x == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final file = File(x.path);
    final name = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref('users/$uid/photos/$name');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    final doc = FirebaseFirestore.instance.collection('users').doc(uid).collection('photos').doc(name);
    await doc.set({'download_url': url, 'created_at': DateTime.now().toIso8601String()});
    await _loadFromCloud();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    try { await GoogleSignIn().signOut(); } catch (_) {}
  }

  void _toggleSelectMode() {
    setState(() {
      _selectMode = !_selectMode;
      if (!_selectMode) _selected.clear();
    });
  }

  void _toggleSelected(String id) {
    setState(() {
      if (_selected.contains(id)) { _selected.remove(id); } else { _selected.add(id); }
    });
  }

  Future<void> _deleteSelected() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final fs = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;
    for (final id in _selected.toList()) {
      try {
        await storage.ref('users/$uid/photos/$id').delete();
      } catch (_) {}
      final photoDoc = fs.collection('users').doc(uid).collection('photos').doc(id);
      final cm = await photoDoc.collection('comments').get();
      for (final c in cm.docs) { await c.reference.delete(); }
      await photoDoc.delete();
      _photos.removeWhere((e) => e['id'] == id);
      _selected.remove(id);
    }
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final L = LangProvider.of(context);
    final df = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memo'),
        actions: [
          IconButton(
            tooltip: L.t('language'),
            onPressed: widget.onToggleLang,
            icon: Text(
              L.code == 'en'
                  ? '🇺🇸'
                  : L.code == 'ru'
                      ? '🇷🇺'
                      : '🇺🇦',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          IconButton(tooltip: widget.isDark ? L.t('theme_light') : L.t('theme_dark'),
              onPressed: widget.onToggleTheme, icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode)),
          IconButton(
            tooltip: L.t('sort'),
            onPressed: () async {
              await showMenu<String>(
                context: context,
                position: const RelativeRect.fromLTRB(1000, 80, 16, 0),
                items: [
                  PopupMenuItem(value: 'newest', child: Text(L.t('newest'))),
                  PopupMenuItem(value: 'oldest', child: Text(L.t('oldest'))),
                  PopupMenuItem(value: 'name', child: Text(L.t('by_name'))),
                  const PopupMenuDivider(),
                  PopupMenuItem(value: 'list', child: Text('${L.t('layout')}: ${L.t('list')}')),
                  PopupMenuItem(value: 'grid', child: Text('${L.t('layout')}: ${L.t('grid')}')),
                ],
              ).then((v) {
                if (v == null) return;
                if (v == 'newest') {
                  setState(() {
                    _sort = SortMode.newest;
                    _applySort();
                  });
                  _saveSort();
                }
                if (v == 'oldest') {
                  setState(() {
                    _sort = SortMode.oldest;
                    _applySort();
                  });
                  _saveSort();
                }
                if (v == 'name') {
                  setState(() {
                    _sort = SortMode.name;
                    _applySort();
                  });
                  _saveSort();
                }
                if (v == 'list') {
                  setState(() => _grid = false);
                  _saveGrid();
                }
                if (v == 'grid') {
                  setState(() => _grid = true);
                  _saveGrid();
                }

              });
            },
            icon: const Icon(Icons.tune),
          ),
          IconButton(
            tooltip: L.t('search_comments'),
            onPressed: () async {
              final res = await showSearch<Map<String,dynamic>?>(
                context: context,
                delegate: CommentSearchDelegate(L: L),
              );
              if (res != null && mounted) {
                Navigator.push(context, MaterialPageRoute(builder: (_)=> PhotoDetails(photo: res)));
              }
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: _selectMode ? L.t('cancel') : L.t('select_mode_on'),
            onPressed: _toggleSelectMode,
            icon: Icon(_selectMode ? Icons.close : Icons.checklist),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsPage(
                      currentColor: widget.accentColor,
                      onColorSelected: widget.onAccentColorChanged,
                    ),
                  ),
                );
              }
              if (v == 'signout') _signOut();
              if (v == 'delete') _deleteAccount();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'settings', child: Text(L.t('settings'))),
              PopupMenuItem(value: 'signout', child: Text(L.t('sign_out'))),
              PopupMenuItem(value: 'delete', child: Text(L.t('delete_account'))),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
              ? Center(child: Text(L.t('no_photos')))
              : RefreshIndicator(
                  onRefresh: _loadFromCloud,
                  child: _grid
                      ? GridView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 1, mainAxisSpacing: 4, crossAxisSpacing: 4),
                          itemCount: _photos.length,
                          itemBuilder: (context, i) {
                            final p = _photos[i];
                            final id = p['id'] as String;
                            final created = DateTime.parse(p['created_at']);
                            final selected = _selected.contains(id);
                            return InkWell(
                              onLongPress: () { if (!_selectMode) _toggleSelectMode(); _toggleSelected(id); },
                              onTap: () {
                                if (_selectMode) { _toggleSelected(id); }
                                else {
                                  _openPhotoFromHome(p);
                                }
                              },
                              child: Stack(
                                children: [
                                  Positioned.fill(child: NetworkThumb(url: p['download_url'] as String)),
                                  Positioned(
                                    left: 6, bottom: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                                      child: Text(DateFormat('dd.MM.yyyy').format(created),
                                          style: const TextStyle(color: Colors.white, fontSize: 12)),
                                    ),
                                  ),
                                  if (_selectMode)
                                    Positioned(
                                      right: 6, top: 6,
                                      child: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: selected ? Colors.indigo : Colors.white70,
                                        child: Icon(selected ? Icons.check : Icons.radio_button_unchecked,
                                            size: 18, color: selected ? Colors.white : Colors.black54),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: _photos.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final p = _photos[i];
                            final id = p['id'] as String;
                            final created = DateTime.parse(p['created_at']);
                            final selected = _selected.contains(id);
                            final last = (p['last_comment'] as String?) ?? '';
                            return ListTile(
                              onLongPress: () { if (!_selectMode) _toggleSelectMode(); _toggleSelected(id); },
                              onTap: () {
                                if (_selectMode) {
                                  _toggleSelected(id);
                                } else {
                                  _openPhotoFromHome(p);
                                }
                              },
                              leading: NetworkThumb(url: p['download_url'] as String),
                              title: Text(df.format(created)),
                              subtitle: Text(last.isNotEmpty ? last : L.t('no_comments'), maxLines: 1, overflow: TextOverflow.ellipsis),
                              trailing: _selectMode
                                  ? Checkbox(value: selected, onChanged: (_)=> _toggleSelected(id))
                                  : IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _deleteOne(p),
                                    ),
                            );
                          },
                        ),
                ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectMode && _selected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton.extended(
                onPressed: _deleteSelected, icon: const Icon(Icons.delete), label: Text(L.t('delete_selected')),
              ),
            ),
          FloatingActionButton.extended(
            onPressed: () => _showAddMenu(context, LangProvider.of(context)),
            label: Text(LangProvider.of(context).t('add')),
            icon: const Icon(Icons.add_a_photo),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _homeInterstitialAd?.dispose();
    super.dispose();
  }

  Future<void> _deleteOne(Map<String,dynamic> p) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final id = p['id'] as String;
    try { await FirebaseStorage.instance.ref('users/$uid/photos/$id').delete(); } catch (_) {}
    final photoDoc = FirebaseFirestore.instance.collection('users').doc(uid).collection('photos').doc(id);
    final cm = await photoDoc.collection('comments').get();
    for (final c in cm.docs) { await c.reference.delete(); }
    await photoDoc.delete();
    setState(() { _photos.removeWhere((e) => e['id'] == id); });
  }

  void _showAddMenu(BuildContext context, AppLang L) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.camera_alt), title: Text(L.t('take_photo')),
              onTap: () { Navigator.pop(context); _addPhoto(ImageSource.camera); }),
          ListTile(leading: const Icon(Icons.photo_library), title: Text(L.t('pick_gallery')),
              onTap: () { Navigator.pop(context); _addPhoto(ImageSource.gallery); }),
        ]),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser!;
    final uid = user.uid;
    final storage = FirebaseStorage.instance;
    final fs = FirebaseFirestore.instance;

    final list = await storage.ref('users/$uid/photos').listAll();
    for (final it in list.items) { try { await it.delete(); } catch (_) {} }
    final snaps = await fs.collection('users').doc(uid).collection('photos').get();
    for (final d in snaps.docs) {
      final comments = await d.reference.collection('comments').get();
      for (final c in comments.docs) { await c.reference.delete(); }
      await d.reference.delete();
    }
    await fs.collection('users').doc(uid).delete();
    await user.delete();
  }
}
class NetworkThumb extends StatelessWidget {
  final String url;
  const NetworkThumb({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          loadingBuilder: (c, child, ev) {
            if (ev == null) return child;
            return const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (c, e, s) => const ColoredBox(
            color: Color(0x11000000),
            child: Center(child: Icon(Icons.broken_image)),
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorSelected;

  const SettingsPage({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final L = LangProvider.of(context);
    final colors = <Color>[
      const Color(0xFF3F00FF),
      Colors.indigo,
      Colors.blue,
      Colors.green,
      const Color(0xFF0029FF),
      const Color(0xFFBCC100),
      const Color(0xFFBF6C00),
      const Color(0xFFFF0000),
      const Color(0xFFAC00BF),
      Colors.pink,
      Colors.teal,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(L.t('settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            L.t('color_theme'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            L.t('color_theme_subtitle'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final c in colors)
                _ColorChoice(
                  color: c,
                  selected: c.value == currentColor.value,
                  onTap: () {
                    onColorSelected(c);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorChoice({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: selected
              ? Border.all(
            color: Theme.of(context).colorScheme.onPrimary,
            width: 3,
          )
              : null,
        ),
      ),
    );
  }
}



class PhotoDetails extends StatefulWidget {
  final Map<String, dynamic> photo;
  const PhotoDetails({super.key, required this.photo});
  @override
  State<PhotoDetails> createState() => _PhotoDetailsState();
}

class _PhotoDetailsState extends State<PhotoDetails> {
  final _comment = TextEditingController();
  final _search = TextEditingController();
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filtered = [];
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;


  @override
  void initState() {
    super.initState();
    _loadComments();
    _loadInterstitialAd();
  }

  String get _docName => (widget.photo['id'] as String);

  Future<void> _loadComments() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap = await FirebaseFirestore.instance
        .collection('users').doc(uid).collection('photos').doc(_docName)
        .collection('comments').orderBy('created_at', descending: true).get();
    setState(() { _docs = snap.docs; _filtered = _docs; });
  }

  void _filter(String q) {
    final t = q.toLowerCase();
    setState(() {
      _filtered = _docs.where((d) => (d['text'] as String).toLowerCase().contains(t)).toList();
    });
  }

  Future<void> _addComment() async {
    final txt = _comment.text.trim();
    if (txt.isEmpty) return;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users').doc(uid).collection('photos').doc(_docName)
        .collection('comments').add({'text': txt, 'created_at': DateTime.now().toIso8601String()});
    _comment.clear();
    _loadComments();
  }

  Future<void> _deleteComment(QueryDocumentSnapshot<Map<String, dynamic>> d) async {
    await d.reference.delete();
    setState(() { _docs.removeWhere((e) => e.id == d.id); _filtered.removeWhere((e) => e.id == d.id); });
  }

  void _loadInterstitialAd() {
  InterstitialAd.load(
    adUnitId: kReleaseMode
        ? 'ca-app-pub-6412264727855282/1947070705'
        : 'ca-app-pub-3940256099942544/1033173712',
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (ad) {
        _interstitialAd = ad;
        _isAdLoaded = true;
      },
      onAdFailedToLoad: (error) {
        _interstitialAd = null;
        _isAdLoaded = false;
      },
    ),
  );
}

void _navigateToFullscreen() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => FullscreenImagePage(
        url: widget.photo['download_url'] as String,
      ),
    ),
  );
}

void _openFull() {
  if (_isAdLoaded && _interstitialAd != null) {
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _isAdLoaded = false;
        _loadInterstitialAd();
        _navigateToFullscreen();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _isAdLoaded = false;
        _loadInterstitialAd();
        _navigateToFullscreen();
      },
    );
    _interstitialAd!.show();
  } else {
    _navigateToFullscreen();
  }
}


  @override
  Widget build(BuildContext context) {
    final L = LangProvider.of(context);
    final df = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(L.t('search_comments')),
        actions: [
          IconButton(onPressed: _openFull, icon: const Icon(Icons.fullscreen)),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              controller: _search, onChanged: _filter,
              decoration: InputDecoration(
                hintText: L.t('enter_comment_hint'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(widget.photo['download_url'] as String, fit: BoxFit.cover,
              loadingBuilder: (c, child, ev) => ev == null ? child : const Center(child: CircularProgressIndicator()),
              errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 64)),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Text(L.t('no_comments')))
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final d = _filtered[i];
                      final t = d['text'] as String;
                      final created = DateTime.parse(d['created_at'] as String);
                      return ListTile(
                        leading: const Icon(Icons.comment),
                        title: Text(t),
                        subtitle: Text(df.format(created)),
                        trailing: IconButton(
                          tooltip: L.t('delete_comment'),
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteComment(d),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                Expanded(child: TextField(controller: _comment, decoration: InputDecoration(hintText: L.t('your_comment')))),
                IconButton(onPressed: _addComment, icon: const Icon(Icons.send)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

@override
void dispose() {
  _comment.dispose();
  _search.dispose();
  _interstitialAd?.dispose();
  super.dispose();
}
}

class FullscreenImagePage extends StatefulWidget {
  final String url;
  const FullscreenImagePage({super.key, required this.url});
  @override
  State<FullscreenImagePage> createState() => _FullscreenImagePageState();
}

class _FullscreenImagePageState extends State<FullscreenImagePage> {
  bool _showUI = true;

  void _applySystemUi() {
    SystemChrome.setEnabledSystemUIMode(_showUI ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky);
  }

  @override
  void initState() { super.initState(); _applySystemUi(); }

  @override
  void dispose() { SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); super.dispose(); }

  void _toggleUi() { setState(() { _showUI = !_showUI; _applySystemUi(); }); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showUI ? AppBar(backgroundColor: Colors.black87, foregroundColor: Colors.white) : null,
      body: GestureDetector(
        onTap: _toggleUi,
        child: Center(
          child: InteractiveViewer(
            maxScale: 5, minScale: 1,
            child: Image.network(widget.url, fit: BoxFit.contain,
              loadingBuilder: (c, child, ev) => ev == null ? child : const Center(child: CircularProgressIndicator()),
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white70, size: 64),
            ),
          ),
        ),
      ),
      floatingActionButton: _showUI
          ? FloatingActionButton.small(
              backgroundColor: Colors.white10, foregroundColor: Colors.white,
              onPressed: () => Navigator.pop(context), child: const Icon(Icons.close),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}

class CommentSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final AppLang L;
  CommentSearchDelegate({required this.L})
      : super(searchFieldLabel: L.t('enter_comment_hint'));

  Future<List<Map<String, dynamic>>> _query(String q) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final photosSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('photos')
        .get();

    final List<Map<String, dynamic>> res = [];
    final lower = q.toLowerCase();

    for (final p in photosSnap.docs) {
      final data = p.data();
      data['id'] = p.id;
      final cmSnap = await p.reference.collection('comments').get();
      final has = cmSnap.docs.any(
        (c) => (c['text'] as String).toLowerCase().contains(lower),
      );
      if (has) res.add(data);
    }
    return res;
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            onPressed: () {
              query = '';
              showSuggestions(context);
            },
            icon: const Icon(Icons.clear),
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) =>
      IconButton(onPressed: () => close(context, null), icon: const Icon(Icons.arrow_back));

  @override
  Widget buildResults(BuildContext context) {
    final theme = Theme.of(context); // отримує поточну тему
    final df = DateFormat('dd.MM.yyyy HH:mm');

    return Material(
      color: theme.colorScheme.background, // фон згідно з темою
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _query(query),
        builder: (context, s) {
          if (s.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = s.data ?? const [];
          if (items.isEmpty) {
            return Center(
                child: Text(L.t('nothing_found'),
                    style: TextStyle(color: theme.colorScheme.onBackground)));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: theme.dividerColor,
            ),
            itemBuilder: (context, i) {
              final it = items[i];
              final created = DateTime.parse(it['created_at'] as String);
              return ListTile(
                leading: NetworkThumb(url: it['download_url'] as String),
                title: Text(df.format(created),
                    style: TextStyle(color: theme.colorScheme.onBackground)),
                subtitle: Text(
                  (it['last_comment'] ?? ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.7)),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PhotoDetails(photo: it)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final theme = Theme.of(context);
    if (query.isEmpty) {
      return Material(
        color: theme.colorScheme.background,
        child: Center(
          child: Text(L.t('enter_comment_hint'),
              style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.7))),
        ),
      );
    }
    return buildResults(context);
  }
}