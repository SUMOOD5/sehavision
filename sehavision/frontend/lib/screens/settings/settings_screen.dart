import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tts_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/health_ai_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.textPrimaryColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          // المظهر
          _buildSectionHeader('المظهر'),
          _buildAppearanceSettings(context),

          // إمكانية الوصول
          _buildSectionHeader('إمكانية الوصول'),
          _buildAccessibilitySettings(context),

          // الحساب
          _buildSectionHeader('الحساب'),
          _buildAccountSettings(context),

          // حول التطبيق
          _buildSectionHeader('حول التطبيق'),
          _buildAboutSettings(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title,
        style: AppTheme.heading3.copyWith(color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildAppearanceSettings(BuildContext context) {
    return GradientCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.palette_rounded,
                color: AppTheme.primaryColor,
              ),
            ),
            title: const Text('المظهر الداكن'),
            subtitle: const Text('مفعل دائماً'),
            trailing: const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilitySettings(BuildContext context) {
    final ttsProvider = Provider.of<TTSProvider>(context);

    return GradientCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('تحويل النص إلى كلام'),
            subtitle: const Text('تفعيل الإعلانات الصوتية'),
            value: ttsProvider.isEnabled,
            onChanged: (value) {
              ttsProvider.setEnabled(value);
            },
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.volume_up_rounded,
                color: AppTheme.accentColor,
              ),
            ),
          ),
          if (ttsProvider.isEnabled) ...[
            const Divider(),
            ListTile(
              title: const Text('سرعة الكلام'),
              subtitle: Slider(
                value: ttsProvider.rate,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                onChanged: (value) {
                  ttsProvider.setRate(value);
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('نبرة الصوت'),
              subtitle: Slider(
                value: ttsProvider.pitch,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                onChanged: (value) {
                  ttsProvider.setPitch(value);
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('مستوى الصوت'),
              subtitle: Slider(
                value: ttsProvider.volume,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                onChanged: (value) {
                  ttsProvider.setVolume(value);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountSettings(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return GradientCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        children: [
          if (authProvider.isAuthenticated) ...[
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppTheme.secondaryColor,
                ),
              ),
              title: const Text('الملف الشخصي'),
              subtitle: Text(authProvider.user?.name ?? 'المستخدم'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                _showProfileDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: AppTheme.warningColor,
                ),
              ),
              title: const Text('تغيير كلمة المرور'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                _showChangePasswordDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppTheme.errorColor,
                ),
              ),
              title: const Text('تسجيل الخروج'),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ] else ...[
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.login_rounded,
                  color: AppTheme.primaryColor,
                ),
              ),
              title: const Text('تسجيل الدخول'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAboutSettings(BuildContext context) {
    return GradientCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_rounded,
                color: AppTheme.infoColor,
              ),
            ),
            title: const Text('إصدار التطبيق'),
            subtitle: const Text('1.0.0'),
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.help_rounded,
                color: AppTheme.accentColor,
              ),
            ),
            title: const Text('المساعدة والدعم'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () {
              _showHelpDialog(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.privacy_tip_rounded,
                color: AppTheme.successColor,
              ),
            ),
            title: const Text('سياسة الخصوصية'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () {
              _showPrivacyDialog(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: AppTheme.warningColor,
              ),
            ),
            title: const Text('شروط الخدمة'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () {
              _showTermsDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final nameController = TextEditingController(
      text: authProvider.user?.name ?? '',
    );
    final phoneController = TextEditingController(
      text: authProvider.user?.phone ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('تعديل الملف الشخصي'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: AppTheme.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'الاسم',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              style: AppTheme.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'الهاتف',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: AppTheme.labelLarge.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await authProvider.updateProfile(
                nameController.text.trim(),
                phoneController.text.trim().isEmpty
                    ? null
                    : phoneController.text.trim(),
              );

              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث الملف الشخصي بنجاح'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: Text(
              'حفظ',
              style: AppTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('تغيير كلمة المرور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              style: AppTheme.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الحالية',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: AppTheme.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              style: AppTheme.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور الجديدة',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: AppTheme.labelLarge.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('كلمات المرور غير متطابقة'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }

              final success = await authProvider.changePassword(
                currentPasswordController.text,
                newPasswordController.text,
              );

              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تغيير كلمة المرور بنجاح'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: Text(
              'تغيير',
              style: AppTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: AppTheme.labelLarge.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              authProvider.logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(
              'تسجيل الخروج',
              style: AppTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('المساعدة والدعم'),
        content: const SingleChildScrollView(
          child: Text(
            'صحة فيجن هو تطبيق للتعرف على الأدوية يساعدك في تحديد الأدوية باستخدام تقنية الذكاء الاصطناعي والواقع المعزز.\n\n'
            'المميزات:\n'
            '• مسح عبوات الأدوية بكاميرا الهاتف\n'
            '• الحصول على معلومات مفصلة عن الدواء\n'
            '• تعيين تذكيرات للأدوية\n'
            '• فحص التفاعلات الدوائية\n'
            '• تحويل النص إلى كلام لإمكانية الوصول\n\n'
            'للحصول على الدعم، يرجى التواصل معنا على support@sehavision.com',
            style: AppTheme.bodyMedium,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: AppTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('سياسة الخصوصية'),
        content: const SingleChildScrollView(
          child: Text(
            'سياسة الخصوصية\n\n'
            'يجمع هذا التطبيق ويعالج البيانات الشخصية وفقاً لقوانين الخصوصية المعمول بها.\n\n'
            'جمع البيانات:\n'
            '• معلومات حساب المستخدم (الاسم، البريد الإلكتروني، الهاتف)\n'
            '• تاريخ مسح الأدوية\n'
            '• إعدادات التذكيرات\n\n'
            'استخدام البيانات:\n'
            '• لتقديم معلومات شخصية عن الأدوية\n'
            '• لإرسال تذكيرات الأدوية\n'
            '• لتحسين وظائف التطبيق\n\n'
            'أمان البيانات:\n'
            '• جميع البيانات مشفرة ومخزنة بأمان\n'
            '• لا نشارك البيانات الشخصية مع أطراف ثالثة\n'
            '• يمكن للمستخدمين حذف بياناتهم في أي وقت\n\n'
            'لمزيد من المعلومات، يرجى التواصل معنا على privacy@sehavision.com',
            style: AppTheme.bodyMedium,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: AppTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('شروط الخدمة'),
        content: const SingleChildScrollView(
          child: Text(
            'شروط الخدمة\n\n'
            'باستخدام صحة فيجن، فإنك توافق على الشروط التالية:\n\n'
            '1. استخدام التطبيق لأغراض إعلامية فقط\n'
            '2. استشر دائماً المتخصصين في الرعاية الصحية للحصول على المشورة الطبية\n'
            '3. التطبيق لا يحل محل الاستشارة الطبية المهنية\n'
            '4. المستخدمون مسؤولون عن دقة المعلومات المدخلة\n'
            '5. لا يجوز استخدام التطبيق لأغراض غير قانونية\n\n'
            'القيود:\n'
            '• التطبيق مقدم "كما هو" بدون ضمانات\n'
            '• لسنا مسؤولين عن أي قرارات طبية تتخذ بناءً على معلومات التطبيق\n'
            '• توفر الخدمة غير مضمون\n\n'
            'للأسئلة حول هذه الشروط، يرجى التواصل معنا على legal@sehavision.com',
            style: AppTheme.bodyMedium,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: AppTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
