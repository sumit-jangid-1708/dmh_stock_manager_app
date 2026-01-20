import 'package:dmj_stock_manager/res/assets/images_assets.dart';
import 'package:dmj_stock_manager/view_models/controller/auth/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final AuthController authController = Get.put(AuthController());


  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(10),
    ),
  );

  // controller to hold entered OTP


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  ImageAssets.dmhLogo,
                  height: 100,
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  "Enter Passcode",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 20),

                // Pinput field
                Pinput(
                  length: 6,
                  controller: authController.otpController,
                  defaultPinTheme: defaultPinTheme,
                  showCursor: true,
                  onCompleted: (pin) {
                    // Just storing the OTP, actual verify will happen on button click
                  },
                ),
                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: size.width,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                     authController.verifyOtp();
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(size.width, 50),
                      elevation: 0,
                      backgroundColor: const Color(0xFF1b1850),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
