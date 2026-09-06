import 'package:bai_01/features/app/presentation/bloc/theme_bloc.dart';
import 'package:bai_01/features/app/presentation/bloc/theme_event.dart';
import 'package:bai_01/features/app/presentation/bloc/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  
  bool _notificationsEnabled = true;
  bool _biometricsEnabled = true;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt hệ thống', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader('Tùy chọn ứng dụng'),
          
          _buildSwitchTile(
            'Nhận thông báo Push',
            Icons.notifications_active_outlined,
            _notificationsEnabled,
            (val) => setState(() => _notificationsEnabled = val),
          ),
          

          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return _buildSwitchTile(
                'Chế độ Tối (Dark Mode)',
                Icons.dark_mode_outlined,
                themeState.isDarkMode, // lấy state màu
                (val) {
                  // nahr event đổi màu
                  context.read<ThemeBloc>().add(ThemeChanged(val));
                },
              );
            },
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Bảo mật'),
          _buildSwitchTile(
            'Đăng nhập bằng Face ID / Vân tay',
            Icons.fingerprint,
            _biometricsEnabled,
            (val) => setState(() => _biometricsEnabled = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSwitchTile(String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
    );
  }
}