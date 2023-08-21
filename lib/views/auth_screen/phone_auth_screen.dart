import 'package:emart_app/views/auth_screen/provider/internet_provider.dart';
import 'package:emart_app/views/auth_screen/provider/sign_in_provider.dart';
import 'package:emart_app/views/home_screen/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../consts/consts.dart';
import '../../widgets/open_snack_bar.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final formKey = GlobalKey<FormState>();
  // controllers -> phone, email, name, otp code
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: context.screenHeight * 0.25),
                const Text(
                  'Phone Login',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                UserInput(
                  nameController: nameController,
                  errorText: "Please enter your name",
                  hintText: "Enter your name",
                  icon: const Icon(Icons.account_circle),
                ),
                const SizedBox(height: 10),
                UserInput(
                  nameController: emailController,
                  errorText: "Please enter your email",
                  hintText: "Enter your email",
                  icon: const Icon(Icons.email_rounded),
                ),
                const SizedBox(height: 10),
                UserInput(
                  nameController: phoneController,
                  errorText: "Please enter your phone number",
                  hintText: "Enter your phone number",
                  icon: const Icon(Icons.phone),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      login(context, "+91-${phoneController.text.trim()}");
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 25),
                        shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.screenHeight * 0.25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future login(BuildContext context, String mobile) async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      openSnackBar(
          context, "No internet, please check your connection", Colors.red);
    } else {
      if (formKey.currentState!.validate()) {
        FirebaseAuth.instance.verifyPhoneNumber(
            verificationCompleted: (AuthCredential credential) async {
              await FirebaseAuth.instance.signInWithCredential(credential);
            },
            verificationFailed: (FirebaseAuthException e) {
              openSnackBar(context, e.toString(), Colors.red);
            },
            codeSent: (String verificationId, int? forceResendingToken) {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('OTP sent'),
                      content:
                          Column(mainAxisSize: MainAxisSize.min, children: [
                        UserInput(
                            nameController: otpController,
                            errorText:
                                'Please enter the code sent to your mobile number',
                            hintText: 'Enter the code',
                            icon: const Icon(Icons.message)),
                        const SizedBox(height: 10),
                        ElevatedButton(
                            onPressed: () async {
                              final code = otpController.text.trim();
                              AuthCredential authCredential =
                                  PhoneAuthProvider.credential(
                                      verificationId: verificationId,
                                      smsCode: code);
                              User user = (await FirebaseAuth.instance
                                      .signInWithCredential(authCredential))
                                  .user!;

                              // save the values
                              sp.phoneNumberUser(
                                  user,
                                  emailController.text.trim(),
                                  nameController.text.trim());

                              // checking whether user exists
                              sp.checkUserExists().then((value) async {
                                if (value == true) {
                                  // user exists
                                  await sp
                                      .getUserDataFromFirestore(sp.uid)
                                      .then((value) => sp
                                          .saveDataToSharedPreferences()
                                          .then((value) =>
                                              sp.setSignIn().then((value) {
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const Home()));
                                              })));
                                } else {
                                  // user does not exist
                                  sp.saveDataToFirestore().then((value) => sp
                                      .saveDataToSharedPreferences()
                                      .then((value) =>
                                          sp.setSignIn().then((value) {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const Home()));
                                            // handleAfterSignIn
                                          })));
                                }
                              });
                            },
                            child: const Text('Confirm')),
                      ]),
                    );
                  });
            },
            codeAutoRetrievalTimeout: (String verification) {},
            phoneNumber: mobile);
      }
    }
  }
}

class UserInput extends StatelessWidget {
  const UserInput({
    super.key,
    required this.nameController,
    required this.errorText,
    required this.hintText,
    required this.icon,
  });

  final TextEditingController nameController;
  final String errorText;
  final String hintText;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: nameController,
      validator: (value) {
        if (value!.isEmpty) {
          return errorText;
        }
        return null;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: icon,
        prefixIconColor: Colors.black87,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
