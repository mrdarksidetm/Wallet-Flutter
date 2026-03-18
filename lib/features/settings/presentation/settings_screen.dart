import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFFD2691E);
    const bgColor = Color(0xFF211811);
    const onBgColor = Colors.white;
    const textMuted = Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: onBgColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings', style: TextStyle(color: onBgColor, fontSize: 20, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor, width: 2),
                          image: const DecorationImage(
                            image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuD0m0ChODA7kWlR5YBZxtWxLJksb_Q08ItwWYOyO6WF-z-mijz-8eVMaeMKE5I_57rJ9UzM0qqgbnp_67NILkeS2kOzxSV26IPrhYXua-sF-ZBnZZasWuHyksQAZPoc5yg-qt3zxyLMzEGXQAcnZfjucvhKDFaRrrX4sqRT45Wv48oTs6SQ4hcgLVlQNJOLD4vf4FSa8usb4RZwv3m5vu-tkp5P02WhKJDUIcDUBnVz8cl3JVYZDW6nrcb_5_Q0CGZz3Xyi6bVarG0"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Abhijeet Yadav', style: TextStyle(color: onBgColor, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('abhijeet.yadav@example.com', style: TextStyle(color: textMuted, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: primaryColor.withOpacity(0.2)),
            
            // General
            _buildSectionTitle('General', primaryColor),
            _buildSettingsItem(Icons.palette, 'App theme', 'System default', primaryColor),
            _buildSettingsItem(Icons.payments, 'Currency', 'INR (₹)', primaryColor),
            _buildSettingsItem(Icons.language, 'Language', 'English (US)', primaryColor),

            // Data
            _buildSectionTitle('Data', primaryColor),
            _buildSettingsItem(Icons.cloud_upload, 'Backup & Restore', 'Last backup: 2 hours ago', primaryColor),
            _buildSettingsItem(Icons.file_upload, 'Export Data', 'CSV, PDF, JSON', primaryColor),

            // Security
            _buildSectionTitle('Security', primaryColor),
            _buildSettingsSwitch(Icons.lock, 'App Lock', 'Secure your financial data', true, primaryColor),
            _buildSettingsSwitch(Icons.fingerprint, 'Biometric login', 'Use Fingerprint or Face ID', false, primaryColor),

            // About
            _buildSectionTitle('About', primaryColor),
            _buildSettingsItem(Icons.info, 'App version', 'v2.4.0 (Stable)', primaryColor, showChevron: false),
            _buildSettingsItem(Icons.policy, 'Privacy policy', null, primaryColor, chevronIcon: Icons.open_in_new),

            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: BorderSide(color: primaryColor.withOpacity(0.2), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: primaryColor),
                    SizedBox(width: 8),
                    Text('Sign Out', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            Center(
              child: Text(
                'MADE WITH ❤️ FOR PAISA',
                style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 2),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, top: 24.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String? subtitle, Color primaryColor, {bool showChevron = true, IconData chevronIcon = Icons.chevron_right}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: primaryColor),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)) : null,
      trailing: showChevron ? Icon(chevronIcon, color: const Color(0xFF94A3B8)) : null,
      onTap: () {},
    );
  }

  Widget _buildSettingsSwitch(IconData icon, String title, String subtitle, bool value, Color primaryColor) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: primaryColor),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
      subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
      trailing: Switch(
        value: value,
        onChanged: (val) {},
        activeColor: Colors.white,
        activeTrackColor: primaryColor,
      ),
    );
  }
}
