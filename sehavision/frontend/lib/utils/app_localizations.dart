import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('ar', 'SA'),
  ];

  // Common
  String get appName => _localizedValues[locale.languageCode]!['appName']!;
  String get ok => _localizedValues[locale.languageCode]!['ok']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get edit => _localizedValues[locale.languageCode]!['edit']!;
  String get add => _localizedValues[locale.languageCode]!['add']!;
  String get search => _localizedValues[locale.languageCode]!['search']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get success => _localizedValues[locale.languageCode]!['success']!;
  String get warning => _localizedValues[locale.languageCode]!['warning']!;

  // Authentication
  String get login => _localizedValues[locale.languageCode]!['login']!;
  String get register => _localizedValues[locale.languageCode]!['register']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get email => _localizedValues[locale.languageCode]!['email']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get confirmPassword =>
      _localizedValues[locale.languageCode]!['confirmPassword']!;
  String get name => _localizedValues[locale.languageCode]!['name']!;
  String get phone => _localizedValues[locale.languageCode]!['phone']!;
  String get forgotPassword =>
      _localizedValues[locale.languageCode]!['forgotPassword']!;
  String get dontHaveAccount =>
      _localizedValues[locale.languageCode]!['dontHaveAccount']!;
  String get alreadyHaveAccount =>
      _localizedValues[locale.languageCode]!['alreadyHaveAccount']!;

  // Navigation
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get scan => _localizedValues[locale.languageCode]!['scan']!;
  String get reminders => _localizedValues[locale.languageCode]!['reminders']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;

  // Medicine
  String get medicine => _localizedValues[locale.languageCode]!['medicine']!;
  String get medicines => _localizedValues[locale.languageCode]!['medicines']!;
  String get medicineName =>
      _localizedValues[locale.languageCode]!['medicineName']!;
  String get brand => _localizedValues[locale.languageCode]!['brand']!;
  String get dosage => _localizedValues[locale.languageCode]!['dosage']!;
  String get instructions =>
      _localizedValues[locale.languageCode]!['instructions']!;
  String get warnings => _localizedValues[locale.languageCode]!['warnings']!;
  String get interactions =>
      _localizedValues[locale.languageCode]!['interactions']!;
  String get expiryDate =>
      _localizedValues[locale.languageCode]!['expiryDate']!;
  String get barcode => _localizedValues[locale.languageCode]!['barcode']!;

  // Scan
  String get scanMedicine =>
      _localizedValues[locale.languageCode]!['scanMedicine']!;
  String get scanBarcode =>
      _localizedValues[locale.languageCode]!['scanBarcode']!;
  String get scanImage => _localizedValues[locale.languageCode]!['scanImage']!;
  String get takePhoto => _localizedValues[locale.languageCode]!['takePhoto']!;
  String get selectFromGallery =>
      _localizedValues[locale.languageCode]!['selectFromGallery']!;
  String get processing =>
      _localizedValues[locale.languageCode]!['processing']!;
  String get medicineRecognized =>
      _localizedValues[locale.languageCode]!['medicineRecognized']!;
  String get medicineNotRecognized =>
      _localizedValues[locale.languageCode]!['medicineNotRecognized']!;

  // Reminders
  String get reminder => _localizedValues[locale.languageCode]!['reminder']!;
  String get addReminder =>
      _localizedValues[locale.languageCode]!['addReminder']!;
  String get reminderTitle =>
      _localizedValues[locale.languageCode]!['reminderTitle']!;
  String get reminderDescription =>
      _localizedValues[locale.languageCode]!['reminderDescription']!;
  String get scheduledTime =>
      _localizedValues[locale.languageCode]!['scheduledTime']!;
  String get frequency => _localizedValues[locale.languageCode]!['frequency']!;
  String get once => _localizedValues[locale.languageCode]!['once']!;
  String get daily => _localizedValues[locale.languageCode]!['daily']!;
  String get weekly => _localizedValues[locale.languageCode]!['weekly']!;
  String get monthly => _localizedValues[locale.languageCode]!['monthly']!;

  // Settings
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get theme => _localizedValues[locale.languageCode]!['theme']!;
  String get lightTheme =>
      _localizedValues[locale.languageCode]!['lightTheme']!;
  String get darkTheme => _localizedValues[locale.languageCode]!['darkTheme']!;
  String get systemTheme =>
      _localizedValues[locale.languageCode]!['systemTheme']!;
  String get textToSpeech =>
      _localizedValues[locale.languageCode]!['textToSpeech']!;
  String get enableTTS => _localizedValues[locale.languageCode]!['enableTTS']!;
  String get notifications =>
      _localizedValues[locale.languageCode]!['notifications']!;
  String get enableNotifications =>
      _localizedValues[locale.languageCode]!['enableNotifications']!;
  String get about => _localizedValues[locale.languageCode]!['about']!;
  String get version => _localizedValues[locale.languageCode]!['version']!;

  // AR
  String get arMode => _localizedValues[locale.languageCode]!['arMode']!;
  String get arOverlay => _localizedValues[locale.languageCode]!['arOverlay']!;
  String get pointCamera =>
      _localizedValues[locale.languageCode]!['pointCamera']!;

  // Accessibility
  String get readAloud => _localizedValues[locale.languageCode]!['readAloud']!;
  String get stopReading =>
      _localizedValues[locale.languageCode]!['stopReading']!;
  String get accessibility =>
      _localizedValues[locale.languageCode]!['accessibility']!;
  String get largeText => _localizedValues[locale.languageCode]!['largeText']!;
  String get highContrast =>
      _localizedValues[locale.languageCode]!['highContrast']!;

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'SehaVision',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'search': 'Search',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'name': 'Name',
      'phone': 'Phone',
      'forgotPassword': 'Forgot Password?',
      'dontHaveAccount': "Don't have an account?",
      'alreadyHaveAccount': 'Already have an account?',
      'home': 'Home',
      'scan': 'Scan',
      'reminders': 'Reminders',
      'settings': 'Settings',
      'medicine': 'Medicine',
      'medicines': 'Medicines',
      'medicineName': 'Medicine Name',
      'brand': 'Brand',
      'dosage': 'Dosage',
      'instructions': 'Instructions',
      'warnings': 'Warnings',
      'interactions': 'Interactions',
      'expiryDate': 'Expiry Date',
      'barcode': 'Barcode',
      'scanMedicine': 'Scan Medicine',
      'scanBarcode': 'Scan Barcode',
      'scanImage': 'Scan Image',
      'takePhoto': 'Take Photo',
      'selectFromGallery': 'Select from Gallery',
      'processing': 'Processing...',
      'medicineRecognized': 'Medicine Recognized',
      'medicineNotRecognized': 'Medicine Not Recognized',
      'reminder': 'Reminder',
      'addReminder': 'Add Reminder',
      'reminderTitle': 'Reminder Title',
      'reminderDescription': 'Description',
      'scheduledTime': 'Scheduled Time',
      'frequency': 'Frequency',
      'once': 'Once',
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'language': 'Language',
      'theme': 'Theme',
      'lightTheme': 'Light',
      'darkTheme': 'Dark',
      'systemTheme': 'System',
      'textToSpeech': 'Text to Speech',
      'enableTTS': 'Enable TTS',
      'notifications': 'Notifications',
      'enableNotifications': 'Enable Notifications',
      'about': 'About',
      'version': 'Version',
      'arMode': 'AR Mode',
      'arOverlay': 'AR Overlay',
      'pointCamera': 'Point camera at medicine',
      'readAloud': 'Read Aloud',
      'stopReading': 'Stop Reading',
      'accessibility': 'Accessibility',
      'largeText': 'Large Text',
      'highContrast': 'High Contrast',
    },
    'ar': {
      'appName': 'صحة فيجن',
      'ok': 'موافق',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'delete': 'حذف',
      'edit': 'تعديل',
      'add': 'إضافة',
      'search': 'بحث',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجح',
      'warning': 'تحذير',
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'logout': 'تسجيل الخروج',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirmPassword': 'تأكيد كلمة المرور',
      'name': 'الاسم',
      'phone': 'الهاتف',
      'forgotPassword': 'نسيت كلمة المرور؟',
      'dontHaveAccount': 'ليس لديك حساب؟',
      'alreadyHaveAccount': 'لديك حساب بالفعل؟',
      'home': 'الرئيسية',
      'scan': 'مسح',
      'reminders': 'التذكيرات',
      'settings': 'الإعدادات',
      'medicine': 'الدواء',
      'medicines': 'الأدوية',
      'medicineName': 'اسم الدواء',
      'brand': 'العلامة التجارية',
      'dosage': 'الجرعة',
      'instructions': 'التعليمات',
      'warnings': 'التحذيرات',
      'interactions': 'التفاعلات',
      'expiryDate': 'تاريخ الانتهاء',
      'barcode': 'الباركود',
      'scanMedicine': 'مسح الدواء',
      'scanBarcode': 'مسح الباركود',
      'scanImage': 'مسح الصورة',
      'takePhoto': 'التقاط صورة',
      'selectFromGallery': 'اختيار من المعرض',
      'processing': 'جاري المعالجة...',
      'medicineRecognized': 'تم التعرف على الدواء',
      'medicineNotRecognized': 'لم يتم التعرف على الدواء',
      'reminder': 'تذكير',
      'addReminder': 'إضافة تذكير',
      'reminderTitle': 'عنوان التذكير',
      'reminderDescription': 'الوصف',
      'scheduledTime': 'الوقت المحدد',
      'frequency': 'التكرار',
      'once': 'مرة واحدة',
      'daily': 'يومياً',
      'weekly': 'أسبوعياً',
      'monthly': 'شهرياً',
      'language': 'اللغة',
      'theme': 'المظهر',
      'lightTheme': 'فاتح',
      'darkTheme': 'داكن',
      'systemTheme': 'النظام',
      'textToSpeech': 'تحويل النص إلى كلام',
      'enableTTS': 'تفعيل تحويل النص إلى كلام',
      'notifications': 'الإشعارات',
      'enableNotifications': 'تفعيل الإشعارات',
      'about': 'حول التطبيق',
      'version': 'الإصدار',
      'arMode': 'الواقع المعزز',
      'arOverlay': 'طبقة الواقع المعزز',
      'pointCamera': 'وجه الكاميرا نحو الدواء',
      'readAloud': 'قراءة بصوت عالي',
      'stopReading': 'إيقاف القراءة',
      'accessibility': 'إمكانية الوصول',
      'largeText': 'نص كبير',
      'highContrast': 'تباين عالي',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
