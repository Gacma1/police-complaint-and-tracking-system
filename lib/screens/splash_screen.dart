import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        // Add a timeout to prevent hanging forever
        await authProvider.tryAutoLogin().timeout(
            const Duration(seconds: 3),
            onTimeout: () {
                // If it times out, we assume no user is logged in
                return;
            },
        );

        if (mounted) {
            final targetRoute = authProvider.isAuthenticated
                ? (authProvider.isAdmin ? '/admin' : '/home')
                : '/login';
                
            Navigator.of(context).pushReplacementNamed(targetRoute);
        }
    } catch (e) {
        // Fallback to login on any error
        if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_police, size: 80, color: Colors.indigo),
            SizedBox(height: 20),
            Text(
              'Police Complaint System',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
