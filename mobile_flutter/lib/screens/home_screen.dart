import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/storage_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      _handleLogout();
      return;
    }

    final apiService = context.read<ApiService>();
    final response = await apiService.getCurrentUser(token);

    if (!mounted) return;
    if (response['success']) {
      setState(() {
        _isLoading = false;
        _userData = response;
      });
    } else {
      await StorageService.clearToken();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  void _handleLogout() async {
    await StorageService.clearToken();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final userData = _userData ?? {};
    final name = userData['name'] ?? 'User';
    final email = userData['email'] ?? 'user@example.com';
    final phone = userData['phone'] ?? '+91 98765 43210';
    final profileInitial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(name, email, phone, profileInitial),
          const Center(child: Text('Detections')),
          const Center(child: Text('Whitelist')),
          const Center(child: Text('Takedowns')),
          const Center(child: Text('Analytics')),
          _buildProfilePage(name, email, phone, profileInitial),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF45B5AA),
        unselectedItemColor: const Color(0xFFB0B0B0),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Detections'),
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Whitelist'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Takedowns'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeContent(String name, String email, String phone, String initial) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome back,', 
                      style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
                    ),
                    Text(name, 
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B1B1B),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF45B5AA),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Protection Active Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF45B5AA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shield,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Protection Active',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your likeness is being monitored across 6 major platforms',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Actively scanning YouTube, Instagram, Twitter, Facebook, TikTok & Snapchat',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Metrics Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE8E8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.warning_rounded, color: Color(0xFFFF6B6B), size: 20),
                        ),
                        const SizedBox(height: 12),
                        const Text('4',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B)),
                        ),
                        const SizedBox(height: 4),
                        const Text('New Detections',
                          style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4E8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.schedule, color: Color(0xFFFFA500), size: 20),
                        ),
                        const SizedBox(height: 12),
                        const Text('1',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B)),
                        ),
                        const SizedBox(height: 4),
                        const Text('Pending Actions',
                          style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Quick Access Section
            const Text(
              'QUICK ACCESS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF999999), letterSpacing: 0.5),
            ),
            const SizedBox(height: 16),
            _buildQuickAccessItem('View Detections', '6 total found'),
            const SizedBox(height: 12),
            _buildQuickAccessItem('Analytics Dashboard', 'View insights & trends'),
            const SizedBox(height: 12),
            _buildQuickAccessItem('Takedown Center', '1 successful'),
            const SizedBox(height: 32),

            // Recent Activity
            const Text(
              'RECENT ACTIVITY',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF999999), letterSpacing: 0.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E8E8)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Last Takedown',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B)),
                        ),
                        const SizedBox(height: 2),
                        Text('Completed 3 days ago',
                          style: TextStyle(fontSize: 13, color: const Color(0xFF999999)),
                        ),
                      ],
                    ),
                  ),
                  const Text('Success',
                    style: TextStyle(color: Color(0xFF45B5AA), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessItem(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.visibility, color: Color(0xFF45B5AA), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B)),
                ),
                const SizedBox(height: 2),
                Text(subtitle,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFCCCCCC)),
        ],
      ),
    );
  }

  Widget _buildProfilePage(String name, String email, String phone, String initial) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profile',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B)),
            ),
            const SizedBox(height: 32),

            // User Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8E8E8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFFFF8B6A),
                        child: Text(initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B)),
                            ),
                            const SizedBox(height: 4),
                            Text(email,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
                            ),
                            const SizedBox(height: 2),
                            Text(phone,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle, color: Color(0xFF45B5AA), size: 20),
                              const SizedBox(height: 8),
                              const Text('Face',
                                style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
                              ),
                              const SizedBox(height: 2),
                              const Text('Registered',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF45B5AA)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle, color: Color(0xFF45B5AA), size: 20),
                              const SizedBox(height: 8),
                              const Text('Voice',
                                style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
                              ),
                              const SizedBox(height: 2),
                              const Text('Registered',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF45B5AA)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings Items
            _buildSettingItem('Subscription Plan', '₹999/month', 'Pro Plan'),
            const SizedBox(height: 12),
            _buildSettingItem('Language', 'English', null),
            const SizedBox(height: 12),
            _buildSettingItem('Privacy & Data', null, null),
            const SizedBox(height: 12),
            _buildSettingItem('Help & Support', null, null),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE8E8),
                  foregroundColor: const Color(0xFFFF8B6A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, String? subtitle, String? action) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1B1B1B)),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...[
            Text(action,
              style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
            ),
            const SizedBox(width: 12),
          ],
          const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFCCCCCC)),
        ],
      ),
    );
  }
}
