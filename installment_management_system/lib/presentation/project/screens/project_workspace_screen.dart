import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../files/screens/upload_file_tab.dart';
import '../../files/screens/file_list_tab.dart';
import '../../calculator/screens/calculator_tab.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

class ProjectWorkspaceScreen extends ConsumerStatefulWidget {
  const ProjectWorkspaceScreen({super.key});

  @override
  ConsumerState<ProjectWorkspaceScreen> createState() => _ProjectWorkspaceScreenState();
}

class _ProjectWorkspaceScreenState extends ConsumerState<ProjectWorkspaceScreen> {
  int _selectedIndex = 0;

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const UploadFileTab();
      case 1:
        return const FileListTab();
      case 2:
        return const CalculatorTab();
      default:
        return const UploadFileTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // We use custom back if needed
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: Row(
              children: [
                Text(
                  ref.watch(authViewModelProvider).currentUser?['username'] ?? 'User', 
                  style: const TextStyle(color: AppTheme.textPrimaryColor, fontWeight: FontWeight.w600, fontSize: 16)
                ),
                const Icon(Icons.keyboard_arrow_down, color: AppTheme.textPrimaryColor),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabCard('Upload File', Icons.upload_file, 0),
                const SizedBox(width: 16),
                _buildTabCard('File List', Icons.list_alt, 1),
                const SizedBox(width: 16),
                _buildTabCard('Calculator', Icons.calculate_outlined, 2),
                const SizedBox(width: 16),
                _buildTabCard('Dashbord', Icons.dashboard_outlined, 3), // Exact spelling from video
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabCard(String title, IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (index == 3) {
            Navigator.of(context).pop(); // Dashbord goes back to main dashboard
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
            ],
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppTheme.warningColor), // Orange/yellow icon as in video
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
