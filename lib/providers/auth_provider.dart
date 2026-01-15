// // lib/providers/auth_provider.dart
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // Stream provider for Firebase auth state
// final authStateProvider = StreamProvider<User?>((ref) {
//   return FirebaseAuth.instance.authStateChanges();
// });

// // Simple logged-in check
// final isLoggedInProvider = Provider<bool>((ref) {
//   final authState = ref.watch(authStateProvider);
//   return authState.when(
//     data: (user) => user != null,
//     loading: () => false,
//     error: (_, __) => false,
//   );
// });
