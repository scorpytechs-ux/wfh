import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:installment_management_system/data/repositories/form_repository.dart';
import 'package:installment_management_system/presentation/files/state/form_data_model.dart';
import 'score_summary_screen.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/blocked_screen.dart';
import '../../files/state/project_state_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../project/screens/project_workspace_screen.dart';
import '../../forms/screens/scored_forms_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {

  void _handleLogout() async {
    ref.read(projectStateProvider.notifier).clearForms();
    await ref.read(authViewModelProvider.notifier).logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _showProfileDialog() {
    final user = ref.read(authViewModelProvider).currentUser;
    final name = user != null ? user['name'] : 'Unknown';
    final email = user != null ? user['email'] : 'Unknown';
    final username = user != null ? user['username'] : 'Unknown';
    final createdAt = user != null ? user['createdAt'] : 'Unknown';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildProfileRow('Name', ': $name', 'Email', ': $email'),
                const SizedBox(height: 16),
                _buildProfileRow('Username', ': $username', 'Joined', ': $createdAt'),
              ],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileRow(String label1, String val1, String label2, String val2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 80, child: Text(label1, style: const TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: Text(val1, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600))),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 80, child: Text(label2, style: const TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: Text(val2, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600))),
            ],
          ),
        ),
      ],
    );
  }

  void _handleSubmitProject() async {
    final user = ref.read(authViewModelProvider).currentUser;
    final forms = ref.read(projectStateProvider);
    final int targetCount = (user != null && user['monthlyTarget'] != null) ? user['monthlyTarget'] : 0;
    
    int completedFormsCount = forms.where((form) => form.isComplete).length;

    bool isComplete = completedFormsCount >= targetCount;

    if (!isComplete) {
      // Instantly block the user ID in the database
      await ref.read(authViewModelProvider.notifier).blockCurrentUser();
      ref.read(authViewModelProvider.notifier).logout(); // Log them out
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => BlockedScreen(targetCount: targetCount)),
          (route) => false,
        );
      }
    } else {
      final formRepo = FormRepository();
      for (var form in forms) {
        if (user != null) {
          await formRepo.saveForm(form, user['id']);
        }
      }

      // We keep the forms in state so the progress counters remain accurate
      // (We no longer call clearForms here)

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project submitted successfully! Waiting for admin review.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authViewModelProvider).currentUser;
    final forms = ref.watch(projectStateProvider);
    
    final int monthlyTarget = user != null && user['monthlyTarget'] != null ? user['monthlyTarget'] : 0;
    
    int completedFormsCount = forms.where((form) => form.isComplete).length;
    if (user != null && user['stats'] != null && user['stats']['activeCount'] != null) {
      completedFormsCount = user['stats']['activeCount'];
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _handleLogout();
                }
              },
              child: Row(
                children: [
                  Text(
                    ref.watch(authViewModelProvider).currentUser?['username'] ?? 'User', 
                    style: const TextStyle(color: AppTheme.textPrimaryColor, fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: AppTheme.textPrimaryColor),
                ],
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Top row showing targets
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 64),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTargetCard('Project Target Progress', completedFormsCount, monthlyTarget, Colors.blue),
              ],
            ),
          ),
          
          // Original dashboard buttons
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBigCard('Project', Icons.folder, () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ProjectWorkspaceScreen()),
                      );
                    }),
              const SizedBox(width: 24),
              _buildBigCard('Scored Forms', Icons.assignment_turned_in_outlined, () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ScoredFormsScreen()),
                );
              }),
              const SizedBox(width: 24),
              _buildBigCard('Submit Project', Icons.send_outlined, _handleSubmitProject),
            ],
          ),
        ),
      ),
    ),
   ],
  ),
);
  }

  Widget _buildBigCard(String title, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppTheme.textPrimaryColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 32.0),
                child: Icon(icon, size: 48, color: AppTheme.secondaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetCard(String title, int current, int target, MaterialColor color) {
    final int displayCurrent = current > target && target > 0 ? target : current;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.shade200, width: 2),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color.shade700, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(displayCurrent.toString(), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor)),
                Text(' / $target', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
