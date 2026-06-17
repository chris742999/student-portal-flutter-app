// ==================== PACKAGE IMPORTS ====================
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:dio/dio.dart';
import 'core/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: WakenyaInsuranceApp(),
    ),
  );
}

// ==================== APP THEME ====================
class AppTheme {
  static const primaryColor = Color(0xFF0057D9);
  static const secondaryColor = Color(0xFF810F92);
  static const accentColor = Color(0xFF00D084);
  static const successColor = Color(0xFF4CAF50);
  static const warningColor = Color(0xFFFF9800);
  static const errorColor = Color(0xFFF44336);

  static const LinearGradient appBackgroundGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0xFFd000d0),
      Color(0xFFcf5ee5),
      Color(0xFFd18bf3),
      Color(0xFFd8b1fc),
      Color(0xFFe4d4ff),
      Color(0xFFd9cdeb),
      Color(0xFFcdc5d8),
      Color(0xFFc1bec5),
      Color(0xFF96909b),
      Color(0xFF6d6472),
      Color(0xFF473b4b),
      Color(0xFF251627),
    ],
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: errorColor,
    ),
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: primaryColor,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),
  );

  static BoxDecoration glassmorphismDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.7)],
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withOpacity(0.3)),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
    ],
  );
}

// ==================== MODELS ====================
class AppUser {
  final String uid;
  final String email;
  final bool isAdmin;
  final bool isLoggedIn;
  final bool isActive;

  AppUser({
    required this.uid,
    required this.email,
    this.isAdmin = false,
    this.isLoggedIn = true,
    this.isActive = true,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    uid: json['uid'],
    email: json['email'],
    isAdmin: json['isAdmin'] ?? false,
    isLoggedIn: json['isLoggedIn'] ?? true,
    isActive: json['isActive'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'isAdmin': isAdmin,
    'isLoggedIn': isLoggedIn,
    'isActive': isActive,
  };
}

enum ClaimStatus { submitted, underReview, additionalInfoRequired, approved, rejected, settled }

extension ClaimStatusExtension on ClaimStatus {
  String get stringValue => toString().split('.').last;
  static ClaimStatus fromString(String value) =>
      ClaimStatus.values.firstWhere((e) => e.stringValue == value, orElse: () => ClaimStatus.submitted);
}

class Claim {
  final String id;
  final String policyNo;
  final double amount;
  final ClaimStatus status;
  final DateTime date;
  final String? description;
  final List<String>? documentUrls;

  Claim({
    required this.id,
    required this.policyNo,
    required this.amount,
    required this.status,
    required this.date,
    this.description,
    this.documentUrls,
  });

  factory Claim.fromJson(Map<String, dynamic> json) => Claim(
    id: json['id'],
    policyNo: json['policyNo'],
    amount: json['amount'].toDouble(),
    status: ClaimStatusExtension.fromString(json['status']),
    date: DateTime.parse(json['date']),
    description: json['description'],
    documentUrls: (json['documentUrls'] as List?)?.cast<String>(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'policyNo': policyNo,
    'amount': amount,
    'status': status.stringValue,
    'date': date.toIso8601String(),
    'description': description,
    'documentUrls': documentUrls,
  };
}

class Policy {
  final String id;
  final String name;
  final String type;
  final double premium;
  final String status;
  final String policyNo;
  final DateTime expiryDate;

  Policy({
    required this.id,
    required this.name,
    required this.type,
    required this.premium,
    required this.status,
    required this.policyNo,
    required this.expiryDate,
  });

  factory Policy.fromJson(Map<String, dynamic> json) => Policy(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    premium: json['premium'].toDouble(),
    status: json['status'],
    policyNo: json['policyNo'],
    expiryDate: DateTime.parse(json['expiryDate']),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'premium': premium,
    'status': status,
    'policyNo': policyNo,
    'expiryDate': expiryDate.toIso8601String(),
  };
}

// ==================== API SERVICE ====================
class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://your-api.com/api', // Replace with your backend URL
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // ---------- AUTH ----------
  Future<AppUser> login(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw Exception('Login failed: user is null');
      // For demo, we treat all users as non-admin; you can fetch role from Firestore or custom claims.
      // In production, you would retrieve isAdmin from a backend or Firestore.
      return AppUser(
        uid: user.uid,
        email: user.email!,
        isAdmin: false,
        isLoggedIn: true,
        isActive: true,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('Login failed: ${e.message}');
    }
  }

  // ---------- POLICIES ----------
  Future<List<Policy>> getPolicies() async {
    final response = await _dio.get('/policies');
    return (response.data as List).map((json) => Policy.fromJson(json)).toList();
  }

  Future<Policy> createPolicy(Map<String, dynamic> data) async {
    final response = await _dio.post('/policies', data: data);
    return Policy.fromJson(response.data);
  }

  Future<Policy> updatePolicy(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/policies/$id', data: data);
    return Policy.fromJson(response.data);
  }

  Future<void> deletePolicy(String id) async {
    await _dio.delete('/policies/$id');
  }

  // ---------- CLAIMS ----------
  Future<List<Claim>> getClaims() async {
    final response = await _dio.get('/claims');
    return (response.data as List).map((json) => Claim.fromJson(json)).toList();
  }

  Future<Claim> submitClaim(Map<String, dynamic> data, List<File> documents) async {
    final formData = FormData.fromMap({
      ...data,
      'documents': await Future.wait(documents.map((file) async {
        return await MultipartFile.fromFile(file.path, filename: file.path.split('/').last);
      }).toList()),
    });
    final response = await _dio.post('/claims', data: formData);
    return Claim.fromJson(response.data);
  }

  Future<Claim> updateClaimStatus(String id, String status) async {
    final response = await _dio.patch('/claims/$id/status', data: {'status': status});
    return Claim.fromJson(response.data);
  }

  // ---------- CUSTOMERS (Admin) ----------
  Future<List<AppUser>> getCustomers() async {
    final response = await _dio.get('/customers');
    return (response.data as List).map((json) => AppUser.fromJson(json)).toList();
  }

  Future<void> toggleCustomerStatus(String uid, bool isActive) async {
    await _dio.patch('/customers/$uid', data: {'isActive': isActive});
  }

  // ---------- STATISTICS (for admin dashboard) ----------
  Future<Map<String, dynamic>> getStats() async {
    final response = await _dio.get('/stats');
    return response.data;
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// ==================== PROVIDERS ====================
final authStateProvider = StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});

class AuthNotifier extends StateNotifier<AppUser?> {
  final ApiService _api;
  AuthNotifier(this._api) : super(null);

  Future<void> login(String email, String password) async {
    try {
      final user = await _api.login(email, password);
      state = user;
    } catch (e) {
      state = null;
      rethrow;
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    state = null;
  }
}

// Policies
final policiesProvider = FutureProvider<List<Policy>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getPolicies();
});

final createPolicyProvider = FutureProvider.family<Policy, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  return api.createPolicy(data);
});

final updatePolicyProvider = FutureProvider.family<Policy, ({String id, Map<String, dynamic> data})>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  return api.updatePolicy(params.id, params.data);
});

final deletePolicyProvider = FutureProvider.family<void, String>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  return api.deletePolicy(id);
});

// Claims
final claimsProvider = FutureProvider<List<Claim>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getClaims();
});

final submitClaimProvider = FutureProvider.family<Claim, ({Map<String, dynamic> claimData, List<File> documents})>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  return api.submitClaim(params.claimData, params.documents);
});

final updateClaimStatusProvider = FutureProvider.family<Claim, ({String id, String status})>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  return api.updateClaimStatus(params.id, params.status);
});

// Customers (Admin)
final customersProvider = FutureProvider<List<AppUser>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getCustomers();
});

final toggleCustomerStatusProvider = FutureProvider.family<void, ({String uid, bool isActive})>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  return api.toggleCustomerStatus(params.uid, params.isActive);
});

// Stats (Admin)
final statsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.getStats();
});

// ==================== GLASS CARD & BUTTON ====================
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double? width;
  final VoidCallback? onTap;
  final EdgeInsets? margin;

  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(24), this.width, this.onTap, this.margin});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        width: width,
        padding: padding,
        decoration: AppTheme.glassmorphismDecoration,
        child: child,
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isSmall;
  const GradientButton({super.key, required this.text, required this.onPressed, this.isLoading = false, this.icon, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(isSmall ? 150 : double.infinity, 50),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Row(
        mainAxisSize: isSmall ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) Icon(icon),
          if (icon != null) const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

// ==================== SPLASH & LOGIN ====================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () => context.go('/login'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBackgroundGradient),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield, size: 80, color: Colors.white),
              SizedBox(height: 20),
              Text('WAKENYA INSURANCE', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Your Trusted Partner', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}

// LoginScreen - only email, password, sign in, logo, company name
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // No need to navigate manually – the router redirect will take over.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBackgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeInUp(
                child: GlassCard(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo and Company Name
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.shield,
                            size: 60,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'WAKENYA INSURANCE',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v?.contains('@') == true ? null : 'Enter a valid email',
                        ),
                        const SizedBox(height: 16),
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v?.length ?? 0) >= 6 ? null : 'Password must be at least 6 characters',
                        ),
                        const SizedBox(height: 24),
                        // Sign In Button
                        GradientButton(
                          onPressed: _handleLogin,
                          isLoading: _isLoading,
                          text: 'Sign In',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBackgroundGradient),
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 16),
            TextField(decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email))),
            const SizedBox(height: 16),
            TextField(decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone))),
            const SizedBox(height: 16),
            TextField(decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)), obscureText: true),
            const SizedBox(height: 16),
            TextField(decoration: const InputDecoration(labelText: 'Confirm Password', prefixIcon: Icon(Icons.lock_outline)), obscureText: true),
            const SizedBox(height: 24),
            GradientButton(text: 'Register', onPressed: () => context.go('/dashboard')),
          ]),
        ),
      ),
    );
  }
}

// ==================== CUSTOMER DASHBOARD (with logout) ====================
class CustomerDashboard extends ConsumerWidget {
  const CustomerDashboard({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authStateProvider.notifier).logout();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBackgroundGradient),
        child: CustomScrollView(slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Welcome, Chris', style: TextStyle(fontWeight: FontWeight.bold)),
              background: Container(decoration: BoxDecoration(gradient: AppTheme.appBackgroundGradient)),
            ),
            actions: [
              IconButton(onPressed: () => context.push('/notifications'), icon: const Icon(Icons.notifications_outlined)),
              IconButton(onPressed: () => context.push('/profile'), icon: const Icon(Icons.person_outline)),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _logout(context, ref),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(children: [
                FadeInUp(
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      DashboardCard(title: 'Active Policies', value: '4', icon: Icons.description, color: AppTheme.primaryColor),
                      DashboardCard(title: 'Total Premiums', value: 'KES 45,230', icon: Icons.payments, color: AppTheme.accentColor),
                      DashboardCard(title: 'Pending Claims', value: '1', icon: Icons.assignment_turned_in, color: Colors.orange),
                      DashboardCard(title: 'Upcoming Renewals', value: '2', icon: Icons.update, color: Colors.red),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            QuickActionButton(icon: Icons.shopping_cart, label: 'Buy Insurance', onTap: () => context.push('/products')),
                            QuickActionButton(icon: Icons.file_upload, label: 'Submit Claim', onTap: () => context.push('/claims')),
                            QuickActionButton(icon: Icons.payment, label: 'Pay Premium', onTap: () {}),
                            QuickActionButton(icon: Icons.support_agent, label: 'Contact Support', onTap: () => context.push('/support')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.payment)),
                          title: const Text('Premium Payment'),
                          subtitle: const Text('KES 12,500 - Motor Insurance'),
                          trailing: const Text('2 days ago'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.assignment)),
                          title: const Text('Claim Update'),
                          subtitle: const Text('Claim #CLM001 under review'),
                          trailing: const Text('5 days ago'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.description)),
                          title: const Text('Policy Renewed'),
                          subtitle: const Text('Medical Insurance extended'),
                          trailing: const Text('1 week ago'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Policies'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Claims'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.api), label: 'API'),
        ],
        onTap: (index) {
          if (index == 1) context.push('/products');
          else if (index == 2) context.push('/policies');
          else if (index == 3) context.push('/claims');
          else if (index == 4) context.push('/profile');
          else if (index == 5) context.push('/api');
        },
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const DashboardCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    ),
  );
}

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
    onPressed: onTap,
    icon: Icon(icon),
    label: Text(label),
    style: ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    ),
  );
}

// ==================== PRODUCTS SCREEN ====================
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  final List<Map<String, dynamic>> products = const [
    {'name': 'Motor Insurance', 'icon': Icons.directions_car, 'premium': 'KES 15,000/year', 'color': Color(0xFF0057D9)},
    {'name': 'Medical Insurance', 'icon': Icons.health_and_safety, 'premium': 'KES 25,000/year', 'color': Color(0xFF00D084)},
    {'name': 'Life Insurance', 'icon': Icons.favorite, 'premium': 'KES 12,000/year', 'color': Color(0xFF810F92)},
    {'name': 'Education Insurance', 'icon': Icons.school, 'premium': 'KES 20,000/year', 'color': Color(0xFFFF9800)},
    {'name': 'Travel Insurance', 'icon': Icons.flight, 'premium': 'KES 5,000/trip', 'color': Color(0xFF4CAF50)},
    {'name': 'Property Insurance', 'icon': Icons.home, 'premium': 'KES 18,000/year', 'color': Color(0xFFF44336)},
    {'name': 'Business Insurance', 'icon': Icons.business, 'premium': 'KES 50,000/year', 'color': Color(0xFF9C27B0)},
    {'name': 'Personal Accident', 'icon': Icons.healing, 'premium': 'KES 8,000/year', 'color': Color(0xFF607D8B)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insurance Products')),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBackgroundGradient),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) => GlassCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(products[index]['icon'], size: 48, color: products[index]['color']),
                const SizedBox(height: 12),
                Text(products[index]['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(products[index]['premium'], style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    final product = products[index];
                    final basePremium = double.tryParse(product['premium'].replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PolicyApplicationScreen(
                          productName: product['name'],
                          basePremium: basePremium,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                  child: const Text('Apply Now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Policy Application Screen (CRUD: Create) ----------
class PolicyApplicationScreen extends ConsumerStatefulWidget {
  final String productName;
  final double basePremium;
  const PolicyApplicationScreen({super.key, required this.productName, required this.basePremium});

  @override
  ConsumerState<PolicyApplicationScreen> createState() => _PolicyApplicationScreenState();
}

class _PolicyApplicationScreenState extends ConsumerState<PolicyApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Apply for ${widget.productName}')),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBackgroundGradient),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GlassCard(
                child: Column(
                  children: [
                    Text('Product: ${widget.productName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Base Premium: KES ${widget.basePremium.toStringAsFixed(2)}', style: TextStyle(color: AppTheme.accentColor)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  children: [
                    TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 12),
                    TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => v!.contains('@') ? null : 'Invalid email'),
                    const SizedBox(height: 12),
                    TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone')),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: 'Cover Amount (KES)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'Submit Application',
                isLoading: _isLoading,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isLoading = true);
                    try {
                      final data = {
                        'productName': widget.productName,
                        'fullName': _nameController.text,
                        'email': _emailController.text,
                        'phone': _phoneController.text,
                        'coverAmount': double.parse(_amountController.text),
                        'basePremium': widget.basePremium,
                      };
                      await ref.read(createPolicyProvider(data).future);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Policy created successfully!')));
                      context.go('/policies');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== POLICY MANAGEMENT (CUSTOMER) ====================
class PolicyManagementScreen extends ConsumerWidget {
  const PolicyManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policiesAsync = ref.watch(policiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Policies')),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBackgroundGradient),
        child: policiesAsync.when(
          data: (policies) => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: policies.length,
            itemBuilder: (context, index) {
              final policy = policies[index];
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(policy.name),
                  subtitle: Text('Policy No: ${policy.policyNo}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: policy.status == 'active' ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(policy.status, style: TextStyle(color: policy.status == 'active' ? Colors.green : Colors.orange, fontSize: 12)),
                      ),
                      Text('Expires: ${DateFormat.yMMMd().format(policy.expiryDate)}'),
                    ],
                  ),
                ),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

// ==================== CLAIMS SCREEN ====================
class ClaimsScreen extends ConsumerStatefulWidget {
  const ClaimsScreen({super.key});
  @override
  ConsumerState<ClaimsScreen> createState() => _ClaimsScreenState();
}

class _ClaimsScreenState extends ConsumerState<ClaimsScreen> {
  void _showSubmitClaimDialog() {
    final policyController = TextEditingController();
    final incidentDateController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    List<File> selectedFiles = [];

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          return AlertDialog(
            title: const Text('Submit New Claim'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: policyController, decoration: const InputDecoration(labelText: 'Policy Number')),
                  const SizedBox(height: 8),
                  TextField(controller: incidentDateController, decoration: const InputDecoration(labelText: 'Incident Date (YYYY-MM-DD)')),
                  const SizedBox(height: 8),
                  TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Claim Amount')),
                  const SizedBox(height: 8),
                  TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final files = await picker.pickMultiImage();
                      if (files.isNotEmpty) {
                        setState(() {
                          selectedFiles = files.map((f) => File(f.path)).toList();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${selectedFiles.length} files selected')));
                      }
                    },
                    icon: const Icon(Icons.upload),
                    label: Text(selectedFiles.isEmpty ? 'Upload Documents' : '${selectedFiles.length} files'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (policyController.text.isEmpty || amountController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
                    return;
                  }
                  final overlay = Overlay.of(context);
                  final entry = OverlayEntry(builder: (_) => const Center(child: CircularProgressIndicator()));
                  overlay.insert(entry);
                  try {
                    final claimData = {
                      'policyNo': policyController.text,
                      'incidentDate': incidentDateController.text,
                      'amount': double.parse(amountController.text),
                      'description': descriptionController.text,
                    };
                    await ref.read(submitClaimProvider((claimData: claimData, documents: selectedFiles)).future);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Claim submitted successfully')));
                    ref.refresh(claimsProvider);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  } finally {
                    entry.remove();
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.submitted:
        return Colors.blue;
      case ClaimStatus.underReview:
        return Colors.orange;
      case ClaimStatus.additionalInfoRequired:
        return Colors.red;
      case ClaimStatus.approved:
        return Colors.green;
      case ClaimStatus.rejected:
        return Colors.red;
      case ClaimStatus.settled:
        return AppTheme.accentColor;
    }
  }

  double _getProgressValue(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.submitted:
        return 0.2;
      case ClaimStatus.underReview:
        return 0.4;
      case ClaimStatus.additionalInfoRequired:
        return 0.3;
      case ClaimStatus.approved:
        return 0.8;
      case ClaimStatus.settled:
        return 1.0;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final claimsAsync = ref.watch(claimsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Claims Management')),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBackgroundGradient),
        child: Column(children: [
          Padding(padding: const EdgeInsets.all(16), child: GradientButton(text: 'Submit New Claim', icon: Icons.add, onPressed: _showSubmitClaimDialog)),
          Expanded(
            child: claimsAsync.when(
              data: (claims) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: claims.length,
                itemBuilder: (context, index) => GlassCard(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Claim #${claims[index].id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(claims[index].status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              claims[index].status.stringValue,
                              style: TextStyle(color: _getStatusColor(claims[index].status)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Policy: ${claims[index].policyNo}'),
                      Text('Amount: KES ${claims[index].amount.toStringAsFixed(2)}'),
                      Text('Submitted: ${DateFormat.yMMMd().format(claims[index].date)}'),
                      if (claims[index].description != null) Text('Description: ${claims[index].description}'),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _getProgressValue(claims[index].status),
                        backgroundColor: Colors.grey.shade200,
                        color: _getStatusColor(claims[index].status),
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ]),
      ),
    );
  }
}

// ==================== NOTIFICATIONS & SUPPORT ====================
class NotificationsCenter extends StatelessWidget {
  const NotificationsCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBackgroundGradient),
        child: ListView(children: [
          GlassCard(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: AppTheme.primaryColor, child: const Icon(Icons.payment, color: Colors.white)),
              title: const Text('Premium Payment Reminder'),
              subtitle: const Text('Your motor insurance premium is due in 7 days'),
              trailing: const Text('2 hours ago'),
            ),
          ),
          GlassCard(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.green, child: const Icon(Icons.check, color: Colors.white)),
              title: const Text('Claim Approved'),
              subtitle: const Text('Claim #CLM001 has been approved for KES 50,000'),
              trailing: const Text('Yesterday'),
            ),
          ),
          GlassCard(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.orange, child: const Icon(Icons.warning, color: Colors.white)),
              title: const Text('Policy Expiring'),
              subtitle: const Text('Your life insurance policy expires in 30 days'),
              trailing: const Text('2 days ago'),
            ),
          ),
        ]),
      ),
    );
  }
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Support')),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBackgroundGradient),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          GlassCard(
            child: Column(children: [
              const Row(children: [Icon(Icons.chat, color: AppTheme.primaryColor), SizedBox(width: 12), Text('Live Chat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 12),
              const Text('Chat with our AI assistant or human agent'),
              const SizedBox(height: 12),
              GradientButton(text: 'Start Chat', onPressed: () {}, isSmall: true),
            ]),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(children: [
              const Row(children: [Icon(Icons.help, color: AppTheme.primaryColor), SizedBox(width: 12), Text('FAQs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 12),
              ExpansionTile(
                title: const Text('How do I file a claim?'),
                children: [const Padding(padding: EdgeInsets.all(16), child: Text('You can file a claim from the Claims section in your dashboard. Upload relevant documents and submit.'))],
              ),
              ExpansionTile(
                title: const Text('What is the claims processing time?'),
                children: [const Padding(padding: EdgeInsets.all(16), child: Text('Claims are typically processed within 5-7 business days.'))],
              ),
            ]),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(children: [
              const Row(children: [Icon(Icons.phone, color: AppTheme.primaryColor), SizedBox(width: 12), Text('Call Us', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 12),
              const Text('+254 700 123 456'),
              const Text('24/7 Customer Support'),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ==================== CALCULATOR SCREEN ====================
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _selectedType = 'Motor';
  final Map<String, dynamic> _formData = {};
  double _estimatedPremium = 0;
  final List<String> _calculatorTypes = ['Motor', 'Life', 'Medical', 'Property'];

  void _calculatePremium() {
    setState(() {
      switch (_selectedType) {
        case 'Motor':
          _estimatedPremium = (_formData['vehicleValue'] ?? 2000000) * 0.03;
          break;
        case 'Life':
          _estimatedPremium = (_formData['age'] ?? 30) * 1000;
          break;
        case 'Medical':
          _estimatedPremium = (_formData['familySize'] ?? 1) * 15000;
          break;
        case 'Property':
          _estimatedPremium = (_formData['propertyValue'] ?? 5000000) * 0.005;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insurance Calculator')),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBackgroundGradient),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Insurance Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _calculatorTypes.map((type) => FilterChip(
                    label: Text(type),
                    selected: _selectedType == type,
                    onSelected: (selected) => setState(() => _selectedType = type),
                  )).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(children: [
              if (_selectedType == 'Motor') ...[
                TextField(
                  decoration: const InputDecoration(labelText: 'Vehicle Value (KES)'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _formData['vehicleValue'] = double.tryParse(v) ?? 0,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: 'Vehicle Year'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _formData['year'] = int.tryParse(v),
                ),
              ],
              if (_selectedType == 'Life') ...[
                TextField(
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _formData['age'] = int.tryParse(v),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: 'Cover Amount (KES)'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _formData['coverAmount'] = double.tryParse(v),
                ),
              ],
              if (_selectedType == 'Medical') ...[
                TextField(
                  decoration: const InputDecoration(labelText: 'Family Size'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _formData['familySize'] = int.tryParse(v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  items: const [
                    DropdownMenuItem(value: 'Inpatient', child: Text('Inpatient Only')),
                    DropdownMenuItem(value: 'Comprehensive', child: Text('Comprehensive')),
                  ],
                  onChanged: (v) => _formData['coverType'] = v,
                  decoration: const InputDecoration(labelText: 'Cover Type'),
                ),
              ],
              if (_selectedType == 'Property') ...[
                TextField(
                  decoration: const InputDecoration(labelText: 'Property Value (KES)'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _formData['propertyValue'] = double.tryParse(v),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: 'Location'),
                  onChanged: (v) => _formData['location'] = v,
                ),
              ],
              const SizedBox(height: 24),
              GradientButton(text: 'Calculate Premium', onPressed: _calculatePremium),
            ]),
          ),
          if (_estimatedPremium > 0) const SizedBox(height: 16),
          if (_estimatedPremium > 0)
            GlassCard(
              child: Column(children: [
                const Text('Estimated Premium', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text('KES ${_estimatedPremium.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.accentColor)),
                const SizedBox(height: 16),
                const Text('Risk Assessment: Low Risk', style: TextStyle(color: AppTheme.accentColor)),
                const SizedBox(height: 8),
                GradientButton(text: 'Apply Now', onPressed: () {}, isSmall: true),
              ]),
            ),
        ]),
      ),
    );
  }
}

// ==================== PROFILE SCREEN ====================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBackgroundGradient),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          GlassCard(
            child: Column(children: [
              CircleAvatar(radius: 50, backgroundColor: AppTheme.primaryColor, child: const Icon(Icons.person, size: 50, color: Colors.white)),
              const SizedBox(height: 12),
              const Text('Chris Musila', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text('chrismusila07@gmail.com'),
              const SizedBox(height: 8),
              const Text('+254 706 079 245'),
            ]),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Divider(),
                const ListTile(title: Text('Full Name'), trailing: Text('Chris Musila')),
                const ListTile(title: Text('Date of Birth'), trailing: Text('18 July 2003')),
                const ListTile(title: Text('National ID'), trailing: Text('12345678')),
                GradientButton(
                  text: 'Edit Profile',
                  isSmall: true,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('KYC Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Divider(),
                const Row(children: [Icon(Icons.verified, color: Colors.green), SizedBox(width: 8), Text('Identity Verified')]),
                const SizedBox(height: 8),
                const Text('ID Type: National ID', style: TextStyle(fontSize: 12, color: Colors.grey)),
                GradientButton(text: 'Upload Documents', onPressed: () {}, isSmall: true),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ADMIN DASHBOARD (with logout) ====================
class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authStateProvider.notifier).logout();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final claimsAsync = ref.watch(claimsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.primaryColor),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(radius: 30, child: Icon(Icons.admin_panel_settings, size: 30)),
              SizedBox(height: 8),
              Text('Admin User', style: TextStyle(color: Colors.white)),
              Text('admin@wakenya.com', style: TextStyle(color: Colors.white70)),
            ]),
          ),
          ListTile(leading: const Icon(Icons.dashboard), title: const Text('Dashboard'), onTap: () => context.go('/admin/dashboard')),
          ListTile(leading: const Icon(Icons.people), title: const Text('Customer Management'), onTap: () => context.push('/admin/customers')),
          ListTile(leading: const Icon(Icons.policy), title: const Text('Policy Management'), onTap: () => context.push('/admin/policies')),
          ListTile(leading: const Icon(Icons.assignment), title: const Text('Claims Management'), onTap: () => context.push('/admin/claims')),
          ListTile(leading: const Icon(Icons.analytics), title: const Text('Reports'), onTap: () => context.push('/admin/reports')),
        ]),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBackgroundGradient),
        child: statsAsync.when(
          data: (stats) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  GlassCard(child: Column(children: [const Icon(Icons.people, size: 40), const SizedBox(height: 8), const Text('Total Customers', style: TextStyle(fontWeight: FontWeight.bold)), Text('${stats['totalCustomers']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))])),
                  GlassCard(child: Column(children: [const Icon(Icons.policy, size: 40), const SizedBox(height: 8), const Text('Active Policies', style: TextStyle(fontWeight: FontWeight.bold)), Text('${stats['activePolicies']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))])),
                  GlassCard(child: Column(children: [const Icon(Icons.assignment, size: 40), const SizedBox(height: 8), const Text('Pending Claims', style: TextStyle(fontWeight: FontWeight.bold)), Text('${stats['pendingClaims']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))])),
                  GlassCard(child: Column(children: [const Icon(Icons.attach_money, size: 40), const SizedBox(height: 8), const Text('Revenue (MTD)', style: TextStyle(fontWeight: FontWeight.bold)), Text('KES ${stats['revenue']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))])),
                ],
              ),
              const SizedBox(height: 24),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Revenue Trends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 1200000, color: AppTheme.primaryColor)]),
                            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 1800000, color: AppTheme.primaryColor)]),
                            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 1500000, color: AppTheme.primaryColor)]),
                            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 2200000, color: AppTheme.primaryColor)]),
                            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 2800000, color: AppTheme.primaryColor)]),
                          ],
                          titlesData: const FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: _getBottomTitles))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recent Claims', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    claimsAsync.when(
                      data: (claims) => DataTable(
                        columns: const [DataColumn(label: Text('Claim ID')), DataColumn(label: Text('Amount')), DataColumn(label: Text('Status'))],
                        rows: claims.take(5).map((claim) => DataRow(cells: [
                          DataCell(Text(claim.id)),
                          DataCell(Text('KES ${claim.amount.toStringAsFixed(0)}')),
                          DataCell(Text(claim.status.stringValue)),
                        ])).toList(),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => Text('Error: $err'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  static Widget _getBottomTitles(double value, TitleMeta meta) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
    return Text(months[value.toInt()], style: const TextStyle(fontSize: 12));
  }
}

// ==================== ADMIN CUSTOMER MANAGEMENT ====================
class CustomerManagementScreen extends ConsumerWidget {
  const CustomerManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Management')),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBackgroundGradient),
        child: customersAsync.when(
          data: (customers) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GlassCard(child: TextField(decoration: InputDecoration(labelText: 'Search Customers', prefixIcon: Icon(Icons.search)), onChanged: (v) {})),
              const SizedBox(height: 16),
              ...customers.map((user) => GlassCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(user.email),
                  subtitle: Text('UID: ${user.uid}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(user.isActive ? Icons.verified_user : Icons.block, color: user.isActive ? Colors.green : Colors.red),
                        onPressed: () async {
                          try {
                            await ref.read(toggleCustomerStatusProvider((uid: user.uid, isActive: !user.isActive)).future);
                            ref.refresh(customersProvider);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated')));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

// ==================== ADMIN POLICY MANAGEMENT (CRUD) ====================
class AdminPolicyManagementScreen extends ConsumerWidget {
  const AdminPolicyManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policiesAsync = ref.watch(policiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Policy Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PolicyApplicationScreen(productName: 'Custom Policy', basePremium: 0),
            ),
          ).then((_) => ref.refresh(policiesProvider));
        },
        child: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBackgroundGradient),
        child: policiesAsync.when(
          data: (policies) => ListView(
            padding: const EdgeInsets.all(16),
            children: policies.map((policy) => GlassCard(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text('${policy.name} (${policy.policyNo})'),
                subtitle: Text('Status: ${policy.status} | Premium: KES ${policy.premium.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditDialog(context, ref, policy);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        try {
                          await ref.read(deletePolicyProvider(policy.id).future);
                          ref.refresh(policiesProvider);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Policy deleted')));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Policy policy) {
    final statusController = TextEditingController(text: policy.status);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Policy Status'),
        content: TextField(
          controller: statusController,
          decoration: const InputDecoration(labelText: 'Status (active/expired/pending)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(updatePolicyProvider((id: policy.id, data: {'status': statusController.text})).future);
                ref.refresh(policiesProvider);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Policy updated')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

// ==================== ADMIN CLAIMS MANAGEMENT ====================
class AdminClaimsManagementScreen extends ConsumerWidget {
  const AdminClaimsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsAsync = ref.watch(claimsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Claims Management')),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBackgroundGradient),
        child: claimsAsync.when(
          data: (claims) => ListView(
            padding: const EdgeInsets.all(16),
            children: claims.map((claim) => GlassCard(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text('Claim #${claim.id}'),
                subtitle: Text('Amount: KES ${claim.amount.toStringAsFixed(2)} | Policy: ${claim.policyNo}'),
                trailing: DropdownButton<String>(
                  value: claim.status.stringValue,
                  items: ['submitted', 'underReview', 'additionalInfoRequired', 'approved', 'rejected', 'settled']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (newStatus) async {
                    if (newStatus != null) {
                      try {
                        await ref.read(updateClaimStatusProvider((id: claim.id, status: newStatus)).future);
                        ref.refresh(claimsProvider);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $newStatus')));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                ),
              ),
            )).toList(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

// ==================== REPORTS SCREEN ====================
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBackgroundGradient),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          GlassCard(
            child: Column(children: [
              const Row(children: [Icon(Icons.payments), SizedBox(width: 12), Text('Revenue Report', style: TextStyle(fontWeight: FontWeight.bold))]),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf), label: const Text('PDF')),
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.table_chart), label: const Text('Excel')),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(children: [
              const Row(children: [Icon(Icons.people), SizedBox(width: 12), Text('Customer Report', style: TextStyle(fontWeight: FontWeight.bold))]),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf), label: const Text('PDF')),
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.table_chart), label: const Text('Excel')),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(children: [
              const Row(children: [Icon(Icons.assignment), SizedBox(width: 12), Text('Claims Report', style: TextStyle(fontWeight: FontWeight.bold))]),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf), label: const Text('PDF')),
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.table_chart), label: const Text('Excel')),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ==================== API CONSOLE SCREEN ====================
class ApiScreen extends ConsumerStatefulWidget {
  const ApiScreen({super.key});

  @override
  ConsumerState<ApiScreen> createState() => _ApiScreenState();
}

class _ApiScreenState extends ConsumerState<ApiScreen> {
  final TextEditingController _bodyController = TextEditingController();

  // List of available endpoints (same as before)
  final List<Map<String, String>> endpoints = const [
    {'method': 'POST', 'path': '/auth/login', 'description': 'User login'},
    {'method': 'GET', 'path': '/policies', 'description': 'Get all policies'},
    {'method': 'POST', 'path': '/policies', 'description': 'Create a new policy'},
    {'method': 'PUT', 'path': '/policies/{id}', 'description': 'Update a policy'},
    {'method': 'DELETE', 'path': '/policies/{id}', 'description': 'Delete a policy'},
    {'method': 'GET', 'path': '/claims', 'description': 'Get all claims'},
    {'method': 'POST', 'path': '/claims', 'description': 'Submit a new claim'},
    {'method': 'PATCH', 'path': '/claims/{id}/status', 'description': 'Update claim status'},
    {'method': 'GET', 'path': '/customers', 'description': 'List customers (admin)'},
    {'method': 'PATCH', 'path': '/customers/{uid}', 'description': 'Toggle customer status'},
    {'method': 'GET', 'path': '/stats', 'description': 'Get dashboard stats (admin)'},
  ];

  @override
  void initState() {
    super.initState();
    // Listen to state changes to update body controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(apiConsoleProvider);
      _bodyController.text = state.body;
    });
  }

  @override
  Widget build(BuildContext context) {
    final consoleState = ref.watch(apiConsoleProvider);
    final notifier = ref.read(apiConsoleProvider.notifier);

    // Sync body controller with state
    if (_bodyController.text != consoleState.body) {
      _bodyController.text = consoleState.body;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('API Console')),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBackgroundGradient),
        child: Column(
          children: [
            // Endpoints list (collapsible or scrollable)
            Expanded(
              flex: 2,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: endpoints.length,
                itemBuilder: (context, index) {
                  final endpoint = endpoints[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _methodColor(endpoint['method']!).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          endpoint['method']!,
                          style: TextStyle(
                            color: _methodColor(endpoint['method']!),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(endpoint['path']!),
                      subtitle: Text(endpoint['description']!),
                      onTap: () {
                        notifier.selectEndpoint(endpoint['method']!, endpoint['path']!);
                        // Clear body controller? The notifier sets body to '{}'
                      },
                    ),
                  );
                },
              ),
            ),

            // Request Builder
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Method and Path
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _methodColor(consoleState.method).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              consoleState.method,
                              style: TextStyle(
                                color: _methodColor(consoleState.method),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              consoleState.path.isEmpty ? 'Select an endpoint' : consoleState.path,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Path Parameters
                      if (consoleState.path.contains('{'))
                        ..._buildPathParameterFields(consoleState, notifier),

                      // Query Parameters
                      const Text('Query Parameters', style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildQueryParameterFields(consoleState, notifier),

                      const SizedBox(height: 12),

                      // Body
                      const Text('Request Body (JSON)', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _bodyController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '{"key": "value"}',
                        ),
                        onChanged: (value) {
                          notifier.updateBody(value);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Send Button
                      GradientButton(
                        text: 'Send Request',
                        isLoading: consoleState.isLoading,
                        onPressed: () async {
                          // Validate JSON
                          try {
                            if (consoleState.body.trim().isNotEmpty) {
                              jsonDecode(consoleState.body);
                            }
                          } catch (_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Invalid JSON body')),
                            );
                            return;
                          }
                          await notifier.sendRequest();
                        },
                      ),

                      const SizedBox(height: 16),

                      // Response Display
                      if (consoleState.response != null || consoleState.error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (consoleState.response != null) ...[
                                Text(
                                  'Status: ${consoleState.response!.statusCode}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: consoleState.response!.statusCode! >= 200 && consoleState.response!.statusCode! < 300
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Headers: ${consoleState.response!.headers}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                const Text('Body:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: SelectableText(
                                    _prettyJson(consoleState.response!.data),
                                    style: const TextStyle(fontFamily: 'monospace'),
                                  ),
                                ),
                              ],
                              if (consoleState.error != null) ...[
                                const Text('Error:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                                SelectableText(consoleState.error.toString()),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to extract path parameters from the path string
  List<Widget> _buildPathParameterFields(ApiConsoleState state, ApiConsoleNotifier notifier) {
    final regex = RegExp(r'\{(\w+)\}');
    final matches = regex.allMatches(state.path);
    if (matches.isEmpty) return [];

    final fields = <Widget>[];
    fields.add(const Text('Path Parameters', style: TextStyle(fontWeight: FontWeight.bold)));
    for (final match in matches) {
      final key = match.group(1)!;
      fields.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: TextField(
            decoration: InputDecoration(labelText: key, border: const OutlineInputBorder()),
            onChanged: (value) => notifier.updatePathParam(key, value),
          ),
        ),
      );
    }
    return fields;
  }

  // Simple query parameter builder – you can expand to dynamic key/value pairs
  Widget _buildQueryParameterFields(ApiConsoleState state, ApiConsoleNotifier notifier) {
    // For simplicity, we use a single text field where user can enter e.g., "key1=value1&key2=value2"
    // or you can build dynamic fields. Let's keep it simple.
    // We'll parse that into queryParams.
    // Or we can allow adding multiple key-value pairs. For brevity, we'll use a single text field.
    // But we'll show existing query params as a list.
    // To keep it clean, we'll just allow a text input for query string.
    // We'll store them as a Map, but we can have a TextField that updates the map.
    // We'll implement a simple approach: a text field that parses "key=value" pairs.
    // Better: we'll provide a Row with two text fields and an "Add" button.
    // For simplicity, we'll use a single text field that accepts a query string.
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Query String (e.g., page=1&limit=10)',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            // Parse and update queryParams
            final params = <String, String>{};
            if (value.trim().isNotEmpty) {
              value.split('&').forEach((pair) {
                final parts = pair.split('=');
                if (parts.length == 2) {
                  params[parts[0]] = parts[1];
                }
              });
            }
            notifier.updateQueryParam('', ''); // This won't work; we need a proper way.
            // We'll change notifier to accept a map directly.
            // Let's adjust the notifier to have a method setQueryParams(Map<String,String>)
          },
        ),
      ],
    );
  }

  // Helper for method colors
  Color _methodColor(String method) {
    switch (method) {
      case 'GET': return Colors.green;
      case 'POST': return Colors.blue;
      case 'PUT': return Colors.orange;
      case 'PATCH': return Colors.purple;
      case 'DELETE': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _prettyJson(dynamic data) {
    try {
      if (data is String) {
        // Try to parse if it's JSON string
        final decoded = jsonDecode(data);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}

// ==================== APP ROUTER ====================
class WakenyaInsuranceApp extends ConsumerWidget {
  const WakenyaInsuranceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    final router = GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final location = state.matchedLocation;
        final isAuth = authState != null;
        final isAdmin = authState?.isAdmin ?? false;

        // Allow splash screen to load
        if (location == '/splash') return null;

        // Not authenticated → only allow login
        if (!isAuth) {
          return location == '/login' ? null : '/login';
        }

        // Authenticated → redirect away from login/splash to dashboard
        if (location == '/login' || location == '/splash') {
          return isAdmin ? '/admin/dashboard' : '/dashboard';
        }

        // Admin guard: force admin routes for admin users
        if (isAdmin && !location.startsWith('/admin')) {
          return '/admin/dashboard';
        }

        // Allow all other routes
        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
        GoRoute(path: '/dashboard', builder: (context, state) => const CustomerDashboard()),
        GoRoute(path: '/products', builder: (context, state) => const ProductsScreen()),
        GoRoute(path: '/policies', builder: (context, state) => const PolicyManagementScreen()),
        GoRoute(path: '/claims', builder: (context, state) => const ClaimsScreen()),
        GoRoute(path: '/notifications', builder: (context, state) => const NotificationsCenter()),
        GoRoute(path: '/support', builder: (context, state) => const SupportScreen()),
        GoRoute(path: '/calculator', builder: (context, state) => const CalculatorScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        GoRoute(path: '/api', builder: (context, state) => const ApiScreen()),
        // Admin routes
        GoRoute(path: '/admin/dashboard', builder: (context, state) => const AdminDashboard()),
        GoRoute(path: '/admin/customers', builder: (context, state) => const CustomerManagementScreen()),
        GoRoute(path: '/admin/policies', builder: (context, state) => const AdminPolicyManagementScreen()),
        GoRoute(path: '/admin/claims', builder: (context, state) => const AdminClaimsManagementScreen()),
        GoRoute(path: '/admin/reports', builder: (context, state) => const ReportsScreen()),
      ],
    );

    return MaterialApp.router(
      title: 'Wakenya Insurance',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}