import 'package:dmj_stock_manager/res/assets/images_assets.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:dmj_stock_manager/view_models/controller/auth/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: size.height - MediaQuery.of(context).padding.top,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Logo Section (Bigger Circle for Logo) ---
                Container(
                  height: 160, // Container ka fixed height
                  width: 160, // Container ka fixed width
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 30,
                          spreadRadius: 2),
                    ],
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Image.asset(
                        ImageAssets.dmhLogo,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),

                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1b1850),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Use the username and password created in admin panel",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 30),

                TextField(
                  controller: authController.usernameController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    icon: Icons.person_outline,
                    hint: "Username",
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: authController.passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => authController.loginWithPassword(),
                  decoration: _inputDecoration(
                    icon: Icons.lock_outline,
                    hint: "Password",
                  ),
                ),
                const SizedBox(height: 30),

                Obx(
                  () => authController.isLoading.value
                      ? const CircularProgressIndicator(
                          color: Color(0xFF1b1850))
                      : AppGradientButton(
                          onPressed: () => authController.loginWithPassword(),
                          text: "Login",
                          width: size.width,
                          height: 55,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required IconData icon,
    required String hint,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF1b1850)),
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1b1850), width: 1.5),
      ),
    );
  }
}

// import 'package:dmj_stock_manager/res/assets/images_assets.dart';
// import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
// import 'package:dmj_stock_manager/view_models/controller/auth/auth_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pinput/pinput.dart';
//
// class AuthScreen extends StatelessWidget {
//   AuthScreen({super.key});
//
//   final AuthController authController = Get.put(AuthController());
//
//
//   final defaultPinTheme = PinTheme(
//     width: 56,
//     height: 56,
//     textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       border: Border.all(color: Colors.grey),
//       borderRadius: BorderRadius.circular(10),
//     ),
//   );
//
//   // controller to hold entered OTP
//
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Logo
//                 Image.asset(
//                   ImageAssets.dmhLogo,
//                   height: 100,
//                 ),
//                 const SizedBox(height: 20),
//
//                 // Title
//                 const Text(
//                   "Enter Passcode",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//
//                 // Pinput field
//                 Pinput(
//                   keyboardType: TextInputType.number,
//                   length: 6,
//                   controller: authController.otpController,
//                   defaultPinTheme: defaultPinTheme,
//                   showCursor: true,
//                   onCompleted: (pin) {
//                     // Just storing the OTP, actual verify will happen on button click
//                   },
//                 ),
//                 const SizedBox(height: 30),
//
//                 // Submit Button
//                 AppGradientButton(onPressed: (){authController.verifyOtp();}, text: "submit", width: size.width, height: 50,),
//                 // SizedBox(
//                 //   width: size.width,
//                 //   height: 50,   authController.verifyOtp();
//                 //   child: ElevatedButton(
//                 //     onPressed: () {
//                 //      authController.verifyOtp();
//                 //     },
//                 //     style: ElevatedButton.styleFrom(
//                 //       fixedSize: Size(size.width, 50),
//                 //       elevation: 0,
//                 //       backgroundColor: const Color(0xFF1b1850),
//                 //       shape: RoundedRectangleBorder(
//                 //         borderRadius: BorderRadius.circular(15),
//                 //       ),
//                 //     ),
//                 //     child: const Text(
//                 //       "Submit",
//                 //       style: TextStyle(
//                 //         fontSize: 16,
//                 //         fontWeight: FontWeight.w600,
//                 //         color: Colors.white,
//                 //       ),
//                 //     ),
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
