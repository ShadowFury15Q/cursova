import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AppRoot());
}

class AppLang extends ChangeNotifier {
  String code = 'uk';
  void toggle() { code = (code == 'uk') ? 'en' : 'uk'; notifyListeners(); }
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

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LangProvider(
      notifier: _lang,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Memo',
        themeMode: _themeMode,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo), useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            final user = snap.data;
            if (user == null) return AuthPage(onToggleTheme: _toggleTheme);
            return HomePage(
              onToggleTheme: _toggleTheme,
              onToggleLang: _lang.toggle,
              isDark: _themeMode == ThemeMode.dark,
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
          IconButton(tooltip: L.t('language'), onPressed: L.toggle, icon: const Icon(Icons.language)),
          IconButton(tooltip: theme.brightness == Brightness.dark ? L.t('theme_light') : L.t('theme_dark'),
              onPressed: widget.onToggleTheme, icon: const Icon(Icons.brightness_6)),
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
            TextField(controller: _pass, obscureText: true, decoration: InputDecoration(labelText: L.t('password'))),
            if (!isLogin) ...[
              const SizedBox(height: 12),
              TextField(controller: _pass2, obscureText: true, decoration: InputDecoration(labelText: L.t('repeat_password'))),
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
  const HomePage({super.key, required this.onToggleTheme, required this.onToggleLang, required this.isDark});
  @override
  State<HomePage> createState() => _HomePageState();
}

enum SortMode { newest, oldest, name }

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _photos = [];
  bool _loading = true;
  bool _grid = false;
  SortMode _sort = SortMode.newest;

  bool _selectMode = false;
  final Set<String> _selected = {};

  @override
  void initState() { super.initState(); _loadFromCloud(); }

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
          IconButton(tooltip: L.t('language'), onPressed: widget.onToggleLang, icon: const Icon(Icons.language)),
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
                if (v == 'newest') { _sort = SortMode.newest; _applySort(); setState((){}); }
                if (v == 'oldest') { _sort = SortMode.oldest; _applySort(); setState((){}); }
                if (v == 'name')   { _sort = SortMode.name; _applySort(); setState((){}); }
                if (v == 'list')   { setState(()=> _grid = false); }
                if (v == 'grid')   { setState(()=> _grid = true); }
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
              if (v == 'signout') _signOut();
              if (v == 'delete') _deleteAccount();
            },
            itemBuilder: (context) => [
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
                                  Navigator.push(context, MaterialPageRoute(builder: (_)=> PhotoDetails(photo: p)));
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
                                  Navigator.push(context, MaterialPageRoute(builder: (_)=> PhotoDetails(photo: p)));
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
            return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
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

  @override
  void initState() { super.initState(); _loadComments(); }

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

  void _openFull() {
    Navigator.push(context, MaterialPageRoute(builder: (_)=> FullscreenImagePage(url: widget.photo['download_url'] as String)));
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