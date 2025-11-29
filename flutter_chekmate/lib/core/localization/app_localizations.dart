import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cache_service.dart';

/// Supported Languages - Top 30 by global speakers
/// Using Flutter's built-in localization support
class AppLocalizations {
  /// Top 30 supported languages with native names
  static const List<LanguageInfo> supportedLanguages = [
    // Top 10 by native speakers
    LanguageInfo('en', 'English', 'English', '🇺🇸'),
    LanguageInfo('zh', '中文', 'Chinese', '🇨🇳'),
    LanguageInfo('hi', 'हिन्दी', 'Hindi', '🇮🇳'),
    LanguageInfo('es', 'Español', 'Spanish', '🇪🇸'),
    LanguageInfo('ar', 'العربية', 'Arabic', '🇸🇦'),
    LanguageInfo('bn', 'বাংলা', 'Bengali', '🇧🇩'),
    LanguageInfo('pt', 'Português', 'Portuguese', '🇧🇷'),
    LanguageInfo('ru', 'Русский', 'Russian', '🇷🇺'),
    LanguageInfo('ja', '日本語', 'Japanese', '🇯🇵'),
    LanguageInfo('pa', 'ਪੰਜਾਬੀ', 'Punjabi', '🇮🇳'),
    
    // 11-20
    LanguageInfo('de', 'Deutsch', 'German', '🇩🇪'),
    LanguageInfo('jv', 'Basa Jawa', 'Javanese', '🇮🇩'),
    LanguageInfo('ko', '한국어', 'Korean', '🇰🇷'),
    LanguageInfo('fr', 'Français', 'French', '🇫🇷'),
    LanguageInfo('te', 'తెలుగు', 'Telugu', '🇮🇳'),
    LanguageInfo('vi', 'Tiếng Việt', 'Vietnamese', '🇻🇳'),
    LanguageInfo('mr', 'मराठी', 'Marathi', '🇮🇳'),
    LanguageInfo('ta', 'தமிழ்', 'Tamil', '🇮🇳'),
    LanguageInfo('tr', 'Türkçe', 'Turkish', '🇹🇷'),
    LanguageInfo('ur', 'اردو', 'Urdu', '🇵🇰'),
    
    // 21-30
    LanguageInfo('it', 'Italiano', 'Italian', '🇮🇹'),
    LanguageInfo('th', 'ไทย', 'Thai', '🇹🇭'),
    LanguageInfo('gu', 'ગુજરાતી', 'Gujarati', '🇮🇳'),
    LanguageInfo('pl', 'Polski', 'Polish', '🇵🇱'),
    LanguageInfo('uk', 'Українська', 'Ukrainian', '🇺🇦'),
    LanguageInfo('ml', 'മലയാളം', 'Malayalam', '🇮🇳'),
    LanguageInfo('kn', 'ಕನ್ನಡ', 'Kannada', '🇮🇳'),
    LanguageInfo('my', 'မြန်မာဘာသာ', 'Burmese', '🇲🇲'),
    LanguageInfo('nl', 'Nederlands', 'Dutch', '🇳🇱'),
    LanguageInfo('id', 'Bahasa Indonesia', 'Indonesian', '🇮🇩'),
  ];

  /// Get supported locales for MaterialApp
  static List<Locale> get supportedLocales {
    return supportedLanguages.map((lang) => Locale(lang.code)).toList();
  }

  /// Get localization delegates for MaterialApp
  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates {
    return [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      // Add custom app localizations delegate here
      _AppLocalizationsDelegate(),
    ];
  }

  /// Get language info by code
  static LanguageInfo? getLanguageInfo(String code) {
    try {
      return supportedLanguages.firstWhere((lang) => lang.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Get device locale or default to English
  static Locale getDeviceLocale(BuildContext context) {
    final deviceLocale = View.of(context).platformDispatcher.locale;
    final isSupported = supportedLanguages.any((lang) => lang.code == deviceLocale.languageCode);
    return isSupported ? deviceLocale : const Locale('en');
  }
}

/// Language information model
class LanguageInfo {
  const LanguageInfo(this.code, this.nativeName, this.englishName, this.flag);
  
  final String code;
  final String nativeName;
  final String englishName;
  final String flag;

  Locale get locale => Locale(code);
  
  String get displayName => '$flag $nativeName';
  String get fullDisplayName => '$flag $nativeName ($englishName)';
}

/// Custom app localizations delegate
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppStrings> {
  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLanguages.any((lang) => lang.code == locale.languageCode);
  }

  @override
  Future<AppStrings> load(Locale locale) async {
    return AppStrings(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// App strings - localized strings for the app
/// This uses a simple key-value approach for easy maintenance
class AppStrings {
  AppStrings(this.locale);
  
  final Locale locale;

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings) ?? AppStrings(const Locale('en'));
  }

  /// Get localized string by key
  String get(String key) {
    return _localizedStrings[locale.languageCode]?[key] ?? 
           _localizedStrings['en']?[key] ?? 
           key;
  }

  // Common strings
  String get appName => get('app_name');
  String get home => get('home');
  String get explore => get('explore');
  String get create => get('create');
  String get messages => get('messages');
  String get profile => get('profile');
  String get settings => get('settings');
  String get search => get('search');
  String get notifications => get('notifications');
  String get logout => get('logout');
  String get login => get('login');
  String get signUp => get('sign_up');
  String get email => get('email');
  String get password => get('password');
  String get forgotPassword => get('forgot_password');
  String get post => get('post');
  String get story => get('story');
  String get rateDate => get('rate_date');
  String get goLive => get('go_live');
  String get like => get('like');
  String get comment => get('comment');
  String get share => get('share');
  String get follow => get('follow');
  String get following => get('following');
  String get followers => get('followers');
  String get edit => get('edit');
  String get delete => get('delete');
  String get cancel => get('cancel');
  String get save => get('save');
  String get done => get('done');
  String get next => get('next');
  String get back => get('back');
  String get loading => get('loading');
  String get error => get('error');
  String get retry => get('retry');
  String get noData => get('no_data');
  String get camera => get('camera');
  String get gallery => get('gallery');
  String get video => get('video');
  String get photo => get('photo');
  
  // ChekMate specific
  String get wow => get('wow');
  String get gtfoh => get('gtfoh');
  String get chekmate => get('chekmate');
  String get wisdomScore => get('wisdom_score');
  String get dateExperience => get('date_experience');

  /// Localized strings map
  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': _englishStrings,
    'es': _spanishStrings,
    'fr': _frenchStrings,
    'de': _germanStrings,
    'pt': _portugueseStrings,
    'zh': _chineseStrings,
    'ja': _japaneseStrings,
    'ko': _koreanStrings,
    'ar': _arabicStrings,
    'hi': _hindiStrings,
    'ru': _russianStrings,
    'it': _italianStrings,
    'tr': _turkishStrings,
    'vi': _vietnameseStrings,
    'th': _thaiStrings,
    'id': _indonesianStrings,
    'nl': _dutchStrings,
    'pl': _polishStrings,
    'uk': _ukrainianStrings,
    // Add more as needed - these are the most common
  };

  static const Map<String, String> _englishStrings = {
    'app_name': 'ChekMate',
    'home': 'Home',
    'explore': 'Explore',
    'create': 'Create',
    'messages': 'Messages',
    'profile': 'Profile',
    'settings': 'Settings',
    'search': 'Search',
    'notifications': 'Notifications',
    'logout': 'Logout',
    'login': 'Login',
    'sign_up': 'Sign Up',
    'email': 'Email',
    'password': 'Password',
    'forgot_password': 'Forgot Password?',
    'post': 'Post',
    'story': 'Story',
    'rate_date': 'Rate Date',
    'go_live': 'Go Live',
    'like': 'Like',
    'comment': 'Comment',
    'share': 'Share',
    'follow': 'Follow',
    'following': 'Following',
    'followers': 'Followers',
    'edit': 'Edit',
    'delete': 'Delete',
    'cancel': 'Cancel',
    'save': 'Save',
    'done': 'Done',
    'next': 'Next',
    'back': 'Back',
    'loading': 'Loading...',
    'error': 'Error',
    'retry': 'Retry',
    'no_data': 'No data available',
    'camera': 'Camera',
    'gallery': 'Gallery',
    'video': 'Video',
    'photo': 'Photo',
    'wow': 'WOW',
    'gtfoh': 'GTFOH',
    'chekmate': 'ChekMate',
    'wisdom_score': 'Wisdom Score',
    'date_experience': 'Date Experience',
  };

  static const Map<String, String> _spanishStrings = {
    'app_name': 'ChekMate',
    'home': 'Inicio',
    'explore': 'Explorar',
    'create': 'Crear',
    'messages': 'Mensajes',
    'profile': 'Perfil',
    'settings': 'Ajustes',
    'search': 'Buscar',
    'notifications': 'Notificaciones',
    'logout': 'Cerrar sesión',
    'login': 'Iniciar sesión',
    'sign_up': 'Registrarse',
    'email': 'Correo electrónico',
    'password': 'Contraseña',
    'forgot_password': '¿Olvidaste tu contraseña?',
    'post': 'Publicar',
    'story': 'Historia',
    'rate_date': 'Calificar Cita',
    'go_live': 'En Vivo',
    'like': 'Me gusta',
    'comment': 'Comentar',
    'share': 'Compartir',
    'follow': 'Seguir',
    'following': 'Siguiendo',
    'followers': 'Seguidores',
    'edit': 'Editar',
    'delete': 'Eliminar',
    'cancel': 'Cancelar',
    'save': 'Guardar',
    'done': 'Hecho',
    'next': 'Siguiente',
    'back': 'Atrás',
    'loading': 'Cargando...',
    'error': 'Error',
    'retry': 'Reintentar',
    'no_data': 'Sin datos disponibles',
    'camera': 'Cámara',
    'gallery': 'Galería',
    'video': 'Video',
    'photo': 'Foto',
    'wow': 'WOW',
    'gtfoh': 'GTFOH',
    'chekmate': 'ChekMate',
    'wisdom_score': 'Puntuación de Sabiduría',
    'date_experience': 'Experiencia de Cita',
  };

  static const Map<String, String> _frenchStrings = {
    'app_name': 'ChekMate',
    'home': 'Accueil',
    'explore': 'Explorer',
    'create': 'Créer',
    'messages': 'Messages',
    'profile': 'Profil',
    'settings': 'Paramètres',
    'search': 'Rechercher',
    'notifications': 'Notifications',
    'logout': 'Déconnexion',
    'login': 'Connexion',
    'sign_up': 'S\'inscrire',
    'email': 'E-mail',
    'password': 'Mot de passe',
    'forgot_password': 'Mot de passe oublié?',
    'post': 'Publier',
    'story': 'Story',
    'rate_date': 'Noter le Rendez-vous',
    'go_live': 'En Direct',
    'like': 'J\'aime',
    'comment': 'Commenter',
    'share': 'Partager',
    'follow': 'Suivre',
    'following': 'Abonnements',
    'followers': 'Abonnés',
    'edit': 'Modifier',
    'delete': 'Supprimer',
    'cancel': 'Annuler',
    'save': 'Enregistrer',
    'done': 'Terminé',
    'next': 'Suivant',
    'back': 'Retour',
    'loading': 'Chargement...',
    'error': 'Erreur',
    'retry': 'Réessayer',
    'no_data': 'Aucune donnée disponible',
    'camera': 'Caméra',
    'gallery': 'Galerie',
    'video': 'Vidéo',
    'photo': 'Photo',
    'wow': 'WOW',
    'gtfoh': 'GTFOH',
    'chekmate': 'ChekMate',
    'wisdom_score': 'Score de Sagesse',
    'date_experience': 'Expérience de Rendez-vous',
  };

  static const Map<String, String> _germanStrings = {
    'app_name': 'ChekMate',
    'home': 'Startseite',
    'explore': 'Entdecken',
    'create': 'Erstellen',
    'messages': 'Nachrichten',
    'profile': 'Profil',
    'settings': 'Einstellungen',
    'search': 'Suchen',
    'notifications': 'Benachrichtigungen',
    'logout': 'Abmelden',
    'login': 'Anmelden',
    'sign_up': 'Registrieren',
    'email': 'E-Mail',
    'password': 'Passwort',
    'forgot_password': 'Passwort vergessen?',
    'post': 'Posten',
    'story': 'Story',
    'rate_date': 'Date Bewerten',
    'go_live': 'Live Gehen',
    'like': 'Gefällt mir',
    'comment': 'Kommentieren',
    'share': 'Teilen',
    'follow': 'Folgen',
    'following': 'Gefolgt',
    'followers': 'Follower',
    'edit': 'Bearbeiten',
    'delete': 'Löschen',
    'cancel': 'Abbrechen',
    'save': 'Speichern',
    'done': 'Fertig',
    'next': 'Weiter',
    'back': 'Zurück',
    'loading': 'Laden...',
    'error': 'Fehler',
    'retry': 'Wiederholen',
    'no_data': 'Keine Daten verfügbar',
    'camera': 'Kamera',
    'gallery': 'Galerie',
    'video': 'Video',
    'photo': 'Foto',
    'wow': 'WOW',
    'gtfoh': 'GTFOH',
    'chekmate': 'ChekMate',
    'wisdom_score': 'Weisheitspunktzahl',
    'date_experience': 'Date-Erfahrung',
  };

  static const Map<String, String> _portugueseStrings = {
    'app_name': 'ChekMate',
    'home': 'Início',
    'explore': 'Explorar',
    'create': 'Criar',
    'messages': 'Mensagens',
    'profile': 'Perfil',
    'settings': 'Configurações',
    'search': 'Pesquisar',
    'notifications': 'Notificações',
    'logout': 'Sair',
    'login': 'Entrar',
    'sign_up': 'Cadastrar',
    'email': 'E-mail',
    'password': 'Senha',
    'forgot_password': 'Esqueceu a senha?',
    'post': 'Publicar',
    'story': 'Story',
    'rate_date': 'Avaliar Encontro',
    'go_live': 'Ao Vivo',
    'like': 'Curtir',
    'comment': 'Comentar',
    'share': 'Compartilhar',
    'follow': 'Seguir',
    'following': 'Seguindo',
    'followers': 'Seguidores',
    'edit': 'Editar',
    'delete': 'Excluir',
    'cancel': 'Cancelar',
    'save': 'Salvar',
    'done': 'Concluído',
    'next': 'Próximo',
    'back': 'Voltar',
    'loading': 'Carregando...',
    'error': 'Erro',
    'retry': 'Tentar novamente',
    'no_data': 'Sem dados disponíveis',
    'camera': 'Câmera',
    'gallery': 'Galeria',
    'video': 'Vídeo',
    'photo': 'Foto',
    'wow': 'WOW',
    'gtfoh': 'GTFOH',
    'chekmate': 'ChekMate',
    'wisdom_score': 'Pontuação de Sabedoria',
    'date_experience': 'Experiência de Encontro',
  };

  static const Map<String, String> _chineseStrings = {
    'app_name': 'ChekMate',
    'home': '首页',
    'explore': '发现',
    'create': '创建',
    'messages': '消息',
    'profile': '个人资料',
    'settings': '设置',
    'search': '搜索',
    'notifications': '通知',
    'logout': '退出登录',
    'login': '登录',
    'sign_up': '注册',
    'email': '邮箱',
    'password': '密码',
    'forgot_password': '忘记密码？',
    'post': '发布',
    'story': '故事',
    'rate_date': '评价约会',
    'go_live': '直播',
    'like': '喜欢',
    'comment': '评论',
    'share': '分享',
    'follow': '关注',
    'following': '正在关注',
    'followers': '粉丝',
    'edit': '编辑',
    'delete': '删除',
    'cancel': '取消',
    'save': '保存',
    'done': '完成',
    'next': '下一步',
    'back': '返回',
    'loading': '加载中...',
    'error': '错误',
    'retry': '重试',
    'no_data': '暂无数据',
    'camera': '相机',
    'gallery': '相册',
    'video': '视频',
    'photo': '照片',
    'wow': 'WOW',
    'gtfoh': 'GTFOH',
    'chekmate': 'ChekMate',
    'wisdom_score': '智慧分数',
    'date_experience': '约会体验',
  };

  static const Map<String, String> _japaneseStrings = {
    'app_name': 'ChekMate',
    'home': 'ホーム',
    'explore': '探索',
    'create': '作成',
    'messages': 'メッセージ',
    'profile': 'プロフィール',
    'settings': '設定',
    'search': '検索',
    'notifications': '通知',
    'logout': 'ログアウト',
    'login': 'ログイン',
    'sign_up': '登録',
    'email': 'メール',
    'password': 'パスワード',
    'forgot_password': 'パスワードを忘れた？',
    'post': '投稿',
    'story': 'ストーリー',
    'rate_date': 'デートを評価',
    'go_live': 'ライブ配信',
    'like': 'いいね',
    'comment': 'コメント',
    'share': 'シェア',
    'follow': 'フォロー',
    'following': 'フォロー中',
    'followers': 'フォロワー',
    'edit': '編集',
    'delete': '削除',
    'cancel': 'キャンセル',
    'save': '保存',
    'done': '完了',
    'next': '次へ',
    'back': '戻る',
    'loading': '読み込み中...',
    'error': 'エラー',
    'retry': '再試行',
    'no_data': 'データがありません',
    'camera': 'カメラ',
    'gallery': 'ギャラリー',
    'video': 'ビデオ',
    'photo': '写真',
    'wow': 'WOW',
    'gtfoh': 'GTFOH',
    'chekmate': 'ChekMate',
    'wisdom_score': '知恵スコア',
    'date_experience': 'デート体験',
  };

  static const Map<String, String> _koreanStrings = {
    'app_name': 'ChekMate',
    'home': '홈',
    'explore': '탐색',
    'create': '만들기',
    'messages': '메시지',
    'profile': '프로필',
    'settings': '설정',
    'search': '검색',
    'notifications': '알림',
    'logout': '로그아웃',
    'login': '로그인',
    'sign_up': '가입',
    'email': '이메일',
    'password': '비밀번호',
    'forgot_password': '비밀번호를 잊으셨나요?',
    'post': '게시',
    'story': '스토리',
    'rate_date': '데이트 평가',
    'go_live': '라이브',
    'like': '좋아요',
    'comment': '댓글',
    'share': '공유',
    'follow': '팔로우',
    'following': '팔로잉',
    'followers': '팔로워',
    'edit': '수정',
    'delete': '삭제',
    'cancel': '취소',
    'save': '저장',
    'done': '완료',
    'next': '다음',
    'back': '뒤로',
    'loading': '로딩 중...',
    'error': '오류',
    'retry': '재시도',
    'no_data': '데이터 없음',
    'camera': '카메라',
    'gallery': '갤러리',
    'video': '비디오',
    'photo': '사진',
    'wow': 'WOW',
    'gtfoh': 'GTFOH',
    'chekmate': 'ChekMate',
    'wisdom_score': '지혜 점수',
    'date_experience': '데이트 경험',
  };

  static const Map<String, String> _arabicStrings = {
    'app_name': 'ChekMate',
    'home': 'الرئيسية',
    'explore': 'استكشاف',
    'create': 'إنشاء',
    'messages': 'الرسائل',
    'profile': 'الملف الشخصي',
    'settings': 'الإعدادات',
    'search': 'بحث',
    'notifications': 'الإشعارات',
    'logout': 'تسجيل الخروج',
    'login': 'تسجيل الدخول',
    'sign_up': 'التسجيل',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'forgot_password': 'نسيت كلمة المرور؟',
    'post': 'نشر',
    'story': 'قصة',
    'rate_date': 'تقييم الموعد',
    'go_live': 'بث مباشر',
    'like': 'إعجاب',
    'comment': 'تعليق',
    'share': 'مشاركة',
    'follow': 'متابعة',
    'following': 'يتابع',
    'followers': 'المتابعون',
    'edit': 'تعديل',
    'delete': 'حذف',
    'cancel': 'إلغاء',
    'save': 'حفظ',
    'done': 'تم',
    'next': 'التالي',
    'back': 'رجوع',
    'loading': 'جاري التحميل...',
    'error': 'خطأ',
    'retry': 'إعادة المحاولة',
    'no_data': 'لا توجد بيانات',
    'camera': 'الكاميرا',
    'gallery': 'المعرض',
    'video': 'فيديو',
    'photo': 'صورة',
    'wow': 'واو',
    'gtfoh': 'GTFOH',
    'chekmate': 'ChekMate',
    'wisdom_score': 'نقاط الحكمة',
    'date_experience': 'تجربة الموعد',
  };

  static const Map<String, String> _hindiStrings = {
    'app_name': 'ChekMate',
    'home': 'होम',
    'explore': 'खोजें',
    'create': 'बनाएं',
    'messages': 'संदेश',
    'profile': 'प्रोफ़ाइल',
    'settings': 'सेटिंग्स',
    'search': 'खोज',
    'notifications': 'सूचनाएं',
    'logout': 'लॉग आउट',
    'login': 'लॉग इन',
    'sign_up': 'साइन अप',
    'email': 'ईमेल',
    'password': 'पासवर्ड',
    'forgot_password': 'पासवर्ड भूल गए?',
    'post': 'पोस्ट',
    'story': 'स्टोरी',
    'rate_date': 'डेट रेट करें',
    'go_live': 'लाइव जाएं',
    'like': 'पसंद',
    'comment': 'टिप्पणी',
    'share': 'शेयर',
    'follow': 'फॉलो',
    'following': 'फॉलोइंग',
    'followers': 'फॉलोअर्स',
    'edit': 'संपादित करें',
    'delete': 'हटाएं',
    'cancel': 'रद्द करें',
    'save': 'सहेजें',
    'done': 'हो गया',
    'next': 'अगला',
    'back': 'वापस',
    'loading': 'लोड हो रहा है...',
    'error': 'त्रुटि',
    'retry': 'पुनः प्रयास करें',
    'no_data': 'कोई डेटा नहीं',
    'camera': 'कैमरा',
    'gallery': 'गैलरी',
    'video': 'वीडियो',
    'photo': 'फोटो',
    'wow': 'वाह',
    'gtfoh': 'GTFOH',
    'chekmate': 'ChekMate',
    'wisdom_score': 'ज्ञान स्कोर',
    'date_experience': 'डेट अनुभव',
  };

  static const Map<String, String> _russianStrings = {
    'app_name': 'ChekMate',
    'home': 'Главная',
    'explore': 'Обзор',
    'create': 'Создать',
    'messages': 'Сообщения',
    'profile': 'Профиль',
    'settings': 'Настройки',
    'search': 'Поиск',
    'notifications': 'Уведомления',
    'logout': 'Выйти',
    'login': 'Войти',
    'sign_up': 'Регистрация',
    'email': 'Эл. почта',
    'password': 'Пароль',
    'forgot_password': 'Забыли пароль?',
    'post': 'Опубликовать',
    'story': 'История',
    'rate_date': 'Оценить свидание',
    'go_live': 'Прямой эфир',
    'like': 'Нравится',
    'comment': 'Комментарий',
    'share': 'Поделиться',
    'follow': 'Подписаться',
    'following': 'Подписки',
    'followers': 'Подписчики',
    'edit': 'Редактировать',
    'delete': 'Удалить',
    'cancel': 'Отмена',
    'save': 'Сохранить',
    'done': 'Готово',
    'next': 'Далее',
    'back': 'Назад',
    'loading': 'Загрузка...',
    'error': 'Ошибка',
    'retry': 'Повторить',
    'no_data': 'Нет данных',
    'camera': 'Камера',
    'gallery': 'Галерея',
    'video': 'Видео',
    'photo': 'Фото',
    'wow': 'ВАУ',
    'gtfoh': 'GTFOH',
    'chekmate': 'ChekMate',
    'wisdom_score': 'Рейтинг мудрости',
    'date_experience': 'Опыт свидания',
  };

  // Simplified versions for remaining languages (can be expanded)
  static const Map<String, String> _italianStrings = {
    'app_name': 'ChekMate',
    'home': 'Home',
    'explore': 'Esplora',
    'create': 'Crea',
    'messages': 'Messaggi',
    'profile': 'Profilo',
    'settings': 'Impostazioni',
    'search': 'Cerca',
    'notifications': 'Notifiche',
    'logout': 'Esci',
    'login': 'Accedi',
    'sign_up': 'Registrati',
    'loading': 'Caricamento...',
    'error': 'Errore',
    'retry': 'Riprova',
  };

  static const Map<String, String> _turkishStrings = {
    'app_name': 'ChekMate',
    'home': 'Ana Sayfa',
    'explore': 'Keşfet',
    'create': 'Oluştur',
    'messages': 'Mesajlar',
    'profile': 'Profil',
    'settings': 'Ayarlar',
    'search': 'Ara',
    'notifications': 'Bildirimler',
    'logout': 'Çıkış',
    'login': 'Giriş',
    'sign_up': 'Kayıt Ol',
    'loading': 'Yükleniyor...',
    'error': 'Hata',
    'retry': 'Tekrar Dene',
  };

  static const Map<String, String> _vietnameseStrings = {
    'app_name': 'ChekMate',
    'home': 'Trang chủ',
    'explore': 'Khám phá',
    'create': 'Tạo',
    'messages': 'Tin nhắn',
    'profile': 'Hồ sơ',
    'settings': 'Cài đặt',
    'search': 'Tìm kiếm',
    'notifications': 'Thông báo',
    'logout': 'Đăng xuất',
    'login': 'Đăng nhập',
    'sign_up': 'Đăng ký',
    'loading': 'Đang tải...',
    'error': 'Lỗi',
    'retry': 'Thử lại',
  };

  static const Map<String, String> _thaiStrings = {
    'app_name': 'ChekMate',
    'home': 'หน้าแรก',
    'explore': 'สำรวจ',
    'create': 'สร้าง',
    'messages': 'ข้อความ',
    'profile': 'โปรไฟล์',
    'settings': 'ตั้งค่า',
    'search': 'ค้นหา',
    'notifications': 'การแจ้งเตือน',
    'logout': 'ออกจากระบบ',
    'login': 'เข้าสู่ระบบ',
    'sign_up': 'สมัครสมาชิก',
    'loading': 'กำลังโหลด...',
    'error': 'ข้อผิดพลาด',
    'retry': 'ลองอีกครั้ง',
  };

  static const Map<String, String> _indonesianStrings = {
    'app_name': 'ChekMate',
    'home': 'Beranda',
    'explore': 'Jelajahi',
    'create': 'Buat',
    'messages': 'Pesan',
    'profile': 'Profil',
    'settings': 'Pengaturan',
    'search': 'Cari',
    'notifications': 'Notifikasi',
    'logout': 'Keluar',
    'login': 'Masuk',
    'sign_up': 'Daftar',
    'loading': 'Memuat...',
    'error': 'Kesalahan',
    'retry': 'Coba lagi',
  };

  static const Map<String, String> _dutchStrings = {
    'app_name': 'ChekMate',
    'home': 'Home',
    'explore': 'Ontdekken',
    'create': 'Maken',
    'messages': 'Berichten',
    'profile': 'Profiel',
    'settings': 'Instellingen',
    'search': 'Zoeken',
    'notifications': 'Meldingen',
    'logout': 'Uitloggen',
    'login': 'Inloggen',
    'sign_up': 'Registreren',
    'loading': 'Laden...',
    'error': 'Fout',
    'retry': 'Opnieuw proberen',
  };

  static const Map<String, String> _polishStrings = {
    'app_name': 'ChekMate',
    'home': 'Strona główna',
    'explore': 'Odkrywaj',
    'create': 'Utwórz',
    'messages': 'Wiadomości',
    'profile': 'Profil',
    'settings': 'Ustawienia',
    'search': 'Szukaj',
    'notifications': 'Powiadomienia',
    'logout': 'Wyloguj',
    'login': 'Zaloguj',
    'sign_up': 'Zarejestruj się',
    'loading': 'Ładowanie...',
    'error': 'Błąd',
    'retry': 'Ponów',
  };

  static const Map<String, String> _ukrainianStrings = {
    'app_name': 'ChekMate',
    'home': 'Головна',
    'explore': 'Огляд',
    'create': 'Створити',
    'messages': 'Повідомлення',
    'profile': 'Профіль',
    'settings': 'Налаштування',
    'search': 'Пошук',
    'notifications': 'Сповіщення',
    'logout': 'Вийти',
    'login': 'Увійти',
    'sign_up': 'Реєстрація',
    'loading': 'Завантаження...',
    'error': 'Помилка',
    'retry': 'Повторити',
  };
}

/// Language Provider - manages current language
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(Locale(CacheService.getLanguage()));

  void setLanguage(String languageCode) {
    CacheService.setLanguage(languageCode);
    state = Locale(languageCode);
  }

  void setLocale(Locale locale) {
    CacheService.setLanguage(locale.languageCode);
    state = locale;
  }
}
