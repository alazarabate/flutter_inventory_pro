// // lib/screens/auth_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
//   return AuthNotifier();
// });

// class AuthState {
//   final bool isLoading;
//   final String? error;
//   final bool isLoginMode;

//   AuthState({
//     this.isLoading = false,
//     this.error,
//     this.isLoginMode = true,
//   });

//   AuthState copyWith({
//     bool? isLoading,
//     String? error,
//     bool? isLoginMode,
//   }) {
//     return AuthState(
//       isLoading: isLoading ?? this.isLoading,
//       error: error ?? this.error,
//       isLoginMode: isLoginMode ?? this.isLoginMode,
//     );
//   }
// }

// class AuthNotifier extends StateNotifier<AuthState> {
//   AuthNotifier() : super(AuthState());

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   void toggleMode() {
//     state = state.copyWith(isLoginMode: !state.isLoginMode, error: null);
//   }

//   Future<void> submit(String email, String password) async {
//     state = state.copyWith(isLoading: true, error: null);

//     try {
//       if (state.isLoginMode) {
//         await _auth.signInWithEmailAndPassword(
//           email: email.trim(),
//           password: password.trim(),
//         );
//       } else {
//         await _auth.createUserWithEmailAndPassword(
//           email: email.trim(),
//           password: password.trim(),
//         );
//       }
//     } on FirebaseAuthException catch (e) {
//       state = state.copyWith(error: e.message, isLoading: false);
//     } catch (e) {
//       state = state.copyWith(error: 'An error occurred', isLoading: false);
//     }
//   }

//   Future<void> resetPassword(String email) async {
//     state = state.copyWith(isLoading: true, error: null);

//     try {
//       await _auth.sendPasswordResetEmail(email: email.trim());
//       state = state.copyWith(
//         isLoading: false,
//         error: 'Password reset email sent!',
//       );
//     } on FirebaseAuthException catch (e) {
//       state = state.copyWith(error: e.message, isLoading: false);
//     }
//   }
// }

// class AuthScreen extends ConsumerStatefulWidget {
//   const AuthScreen({Key? key}) : super(key: key);

//   @override
//   ConsumerState<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends ConsumerState<AuthScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _emailFocusNode = FocusNode();
//   final _passwordFocusNode = FocusNode();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _emailFocusNode.dispose();
//     _passwordFocusNode.dispose();
//     super.dispose();
//   }

//   void _submit() {
//     if (_formKey.currentState!.validate()) {
//       ref.read(authProvider.notifier).submit(
//             _emailController.text,
//             _passwordController.text,
//           );
//     }
//   }

//   void _resetPassword() {
//     final email = _emailController.text.trim();
//     if (email.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter your email first')),
//       );
//       return;
//     }
//     ref.read(authProvider.notifier).resetPassword(email);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authProvider);
//     final isLogin = authState.isLoginMode;

//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // App Logo/Title
//                   Icon(
//                     Icons.inventory_2,
//                     size: 80,
//                     color: Theme.of(context).primaryColor,
//                   ),
//                   const SizedBox(height: 32),
//                   Text(
//                     isLogin ? 'Welcome Back' : 'Create Account',
//                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     isLogin
//                         ? 'Sign in to manage your inventory'
//                         : 'Join us to start managing inventory',
//                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                           color: Colors.grey[600],
//                         ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 32),

//                   // Error Message
//                   if (authState.error != null) ...[
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.red[50],
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.error_outline, color: Colors.red[700]),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               authState.error!,
//                               style: TextStyle(color: Colors.red[700]),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                   ],

//                   // Email Field
//                   TextFormField(
//                     controller: _emailController,
//                     focusNode: _emailFocusNode,
//                     keyboardType: TextInputType.emailAddress,
//                     textInputAction: TextInputAction.next,
//                     decoration: InputDecoration(
//                       labelText: 'Email',
//                       hintText: 'Enter your email',
//                       prefixIcon: const Icon(Icons.email_outlined),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.grey[300]!),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your email';
//                       }
//                       if (!value.contains('@')) {
//                         return 'Please enter a valid email';
//                       }
//                       return null;
//                     },
//                     onFieldSubmitted: (_) {
//                       FocusScope.of(context).requestFocus(_passwordFocusNode);
//                     },
//                   ),
//                   const SizedBox(height: 16),

//                   // Password Field
//                   TextFormField(
//                     controller: _passwordController,
//                     focusNode: _passwordFocusNode,
//                     obscureText: true,
//                     textInputAction: TextInputAction.done,
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       hintText: 'Enter your password',
//                       prefixIcon: const Icon(Icons.lock_outlined),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.grey[300]!),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your password';
//                       }
//                       if (value.length < 6) {
//                         return 'Password must be at least 6 characters';
//                       }
//                       return null;
//                     },
//                     onFieldSubmitted: (_) => _submit(),
//                   ),

//                   // Forgot Password
//                   if (isLogin) ...[
//                     const SizedBox(height: 8),
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: _resetPassword,
//                         child: const Text('Forgot Password?'),
//                       ),
//                     ),
//                   ],

//                   const SizedBox(height: 24),

//                   // Submit Button
//                   ElevatedButton(
//                     onPressed: authState.isLoading ? null : _submit,
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size(double.infinity, 56),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: authState.isLoading
//                         ? const SizedBox(
//                             height: 24,
//                             width: 24,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : Text(
//                             isLogin ? 'Sign In' : 'Create Account',
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                   ),

//                   const SizedBox(height: 24),

//                   // Toggle Mode
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         isLogin
//                             ? "Don't have an account? "
//                             : 'Already have an account? ',
//                       ),
//                       TextButton(
//                         onPressed: () =>
//                             ref.read(authProvider.notifier).toggleMode(),
//                         child: Text(
//                           isLogin ? 'Sign Up' : 'Sign In',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
