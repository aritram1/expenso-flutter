import 'package:expenso/helper/salesforce_oauth2_controller.dart';
import 'package:expenso/widgets/wavy_clipper_widget.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LoginViaOTPPage extends StatefulWidget {
  const LoginViaOTPPage({super.key});

  @override
  State<LoginViaOTPPage> createState() => _LoginViaOTPPageState();
}

class _LoginViaOTPPageState extends State<LoginViaOTPPage> {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false; // To track the loading state
  bool isButtonEnabled = false; // To track if the button is enabled

  @override
  void initState() {
    super.initState();
    phoneController.addListener(_validateInput);
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      // Enable the button only if phoneController text is not empty
      isButtonEnabled = phoneController.text.trim().isNotEmpty;
    });
  }

  Future<void> handleLoginViaOTP(String phone) async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      final result = await SalesforceAuth2Controller.loginViaOTP();
      Logger().d('inside handleLoginViaOTP method, result => $result');
      // Handle success or navigation here if needed
    } catch (error) {
      Logger().e('Error during login via OTP: $error');
      // Optionally show an error message
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Blue Background
          Container(
            color: Colors.blue,
            child: Column(
              children: [
                // Wavy Clip Path
                ClipPath(
                  clipper: WavyClipperWidget(),
                  child: Container(
                    height: 300,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
          // Content Section (Positioned over the purple part)
          Positioned.fill(
            top: 200, // Adjust to align below the wavy curve
            child: Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Phone Input Field
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      hintText: "Enter your phone number",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16.0),
                  // Submit Button
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(), // Show loading indicator
                        )
                      : ElevatedButton(
                          onPressed: isButtonEnabled
                              ? () async {
                                  Logger().d('Phone: ${phoneController.text}');
                                  await handleLoginViaOTP(phoneController.text);
                                }
                              : null, // Disable button if not enabled
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isButtonEnabled
                                ? Colors.blueAccent
                                : Colors.grey, // Gray color when disabled
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                            "Submit",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                  const SizedBox(height: 24.0),
                  // Terms and Conditions
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // Handle terms and conditions navigation
                        print("Terms and Conditions clicked");
                      },
                      child: const Text(
                        "Terms and Conditions",
                        style: TextStyle(
                          color: Color.fromRGBO(177, 196, 253, 1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
