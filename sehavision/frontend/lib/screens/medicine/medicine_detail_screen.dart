import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medicine.dart';
import '../../providers/tts_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_localizations.dart';
import '../reminders/add_reminder_screen.dart';

class MedicineDetailScreen extends StatefulWidget {
  final Medicine medicine;

  const MedicineDetailScreen({super.key, required this.medicine});

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _speakMedicineInfo() async {
    final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
    await ttsProvider.speakMedicineInfo(
      widget.medicine.name,
      widget.medicine.brand,
      widget.medicine.dosage,
      widget.medicine.instructions,
    );
  }

  Future<void> _addReminder() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add reminders'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReminderScreen(medicine: widget.medicine),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final ttsProvider = Provider.of<TTSProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.medicine.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Medicine Image or Placeholder
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryDarkColor,
                        ],
                      ),
                    ),
                    child: widget.medicine.imagePaths?.isNotEmpty == true
                        ? Image.network(
                            widget.medicine.imagePaths!.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.medication,
                                size: 100,
                                color: Colors.white70,
                              );
                            },
                          )
                        : const Icon(
                            Icons.medication,
                            size: 100,
                            color: Colors.white70,
                          ),
                  ),

                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  ttsProvider.isEnabled ? Icons.volume_up : Icons.volume_off,
                ),
                onPressed: _speakMedicineInfo,
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Basic Info Card
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.medicine.name,
                                    style: AppTheme.heading3,
                                  ),
                                  if (widget.medicine.brand != null)
                                    Text(
                                      widget.medicine.brand!,
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Expiry Status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: widget.medicine.isExpired
                                    ? AppTheme.errorColor
                                    : widget.medicine.isExpiringSoon
                                        ? AppTheme.warningColor
                                        : AppTheme.successColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                widget.medicine.isExpired
                                    ? 'Expired'
                                    : widget.medicine.isExpiringSoon
                                        ? 'Expiring Soon'
                                        : 'Valid',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Dosage and Instructions
                        if (widget.medicine.dosage != null)
                          _buildInfoRow(
                            Icons.medication,
                            'Dosage',
                            widget.medicine.dosage!,
                          ),

                        if (widget.medicine.instructions != null)
                          _buildInfoRow(
                            Icons.info,
                            'Instructions',
                            widget.medicine.instructions!,
                          ),

                        if (widget.medicine.barcode != null)
                          _buildInfoRow(
                            Icons.qr_code,
                            'Barcode',
                            widget.medicine.barcode!,
                          ),

                        if (widget.medicine.expiryDate != null)
                          _buildInfoRow(
                            Icons.calendar_today,
                            'Expiry Date',
                            widget.medicine.expiryDate!
                                .toLocal()
                                .toString()
                                .split(' ')[0],
                          ),
                      ],
                    ),
                  ),
                ),

                // Tabs
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppTheme.textSecondaryColor,
                    tabs: const [
                      Tab(text: 'Details'),
                      Tab(text: 'Warnings'),
                      Tab(text: 'Interactions'),
                    ],
                  ),
                ),

                // Tab Content
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Details Tab
                      _buildDetailsTab(),
                      // Warnings Tab
                      _buildWarningsTab(),
                      // Interactions Tab
                      _buildInteractionsTab(),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReminder,
        icon: const Icon(Icons.add_alarm),
        label: const Text('Add Reminder'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: AppTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medicine Images
          if (widget.medicine.imagePaths?.isNotEmpty == true) ...[
            Text('Images', style: AppTheme.heading3),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.medicine.imagePaths!.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.medicine.imagePaths![index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Additional Details
          Text('Additional Information', style: AppTheme.heading3),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailItem(
                    'Medicine ID',
                    widget.medicine.id.toString(),
                  ),
                  _buildDetailItem('Name', widget.medicine.name),
                  if (widget.medicine.brand != null)
                    _buildDetailItem('Brand', widget.medicine.brand!),
                  if (widget.medicine.dosage != null)
                    _buildDetailItem('Dosage', widget.medicine.dosage!),
                  if (widget.medicine.barcode != null)
                    _buildDetailItem('Barcode', widget.medicine.barcode!),
                  if (widget.medicine.expiryDate != null)
                    _buildDetailItem(
                      'Expiry Date',
                      widget.medicine.expiryDate!.toLocal().toString().split(
                            ' ',
                          )[0],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.medicine.warnings != null &&
              widget.medicine.warnings!.isNotEmpty) ...[
            Text('Warnings', style: AppTheme.heading3),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: (widget.medicine.warnings?.split('\n') ?? [])
                      .map((warning) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning,
                            color: AppTheme.warningColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(warning, style: AppTheme.bodyMedium),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ] else ...[
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 64,
                    color: AppTheme.successColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No specific warnings for this medicine',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInteractionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.medicine.interactions != null &&
              widget.medicine.interactions!.isNotEmpty) ...[
            Text('Drug Interactions', style: AppTheme.heading3),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: widget.medicine.interactions!.map((interaction) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.merge_type,
                            color: AppTheme.errorColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              interaction,
                              style: AppTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ] else ...[
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 64,
                    color: AppTheme.successColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No known drug interactions',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value, style: AppTheme.bodyMedium)),
        ],
      ),
    );
  }
}
