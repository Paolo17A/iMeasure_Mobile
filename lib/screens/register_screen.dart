import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../providers/loading_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_text_field_widget.dart';
import '../widgets/text_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileNumberController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    mobileNumberController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: stackedLoadingContainer(
          context,
          ref.read(loadingProvider).isLoading,
          SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(ImagePaths.bg), fit: BoxFit.cover),
                  ),
                ),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: CustomColors.deepNavyBlue.withOpacity(0.6)),
                all20Pix(child: _registerContainer()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _registerContainer() {
    return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Gap(MediaQuery.of(context).size.height * 0.1),
            itcBaumansWhiteBold('REGISTER', fontSize: 32),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextField(
                    text: 'Email Address',
                    controller: emailController,
                    textInputType: TextInputType.emailAddress,
                    displayPrefixIcon: const Icon(Icons.email))),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextField(
                    text: 'Password',
                    controller: passwordController,
                    textInputType: TextInputType.visiblePassword,
                    displayPrefixIcon: const Icon(Icons.lock))),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextField(
                    text: 'Confirm Password',
                    controller: confirmPasswordController,
                    textInputType: TextInputType.visiblePassword,
                    displayPrefixIcon: const Icon(Icons.lock))),
            const Gap(30),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomTextField(
                  text: 'First Name',
                  controller: firstNameController,
                  textInputType: TextInputType.name,
                  displayPrefixIcon: const Icon(Icons.person)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomTextField(
                  text: 'Last Name',
                  controller: lastNameController,
                  textInputType: TextInputType.name,
                  displayPrefixIcon: const Icon(Icons.person)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomTextField(
                  text: 'Mobile Number',
                  controller: mobileNumberController,
                  textInputType: TextInputType.number,
                  displayPrefixIcon: const Icon(Icons.phone)),
            ),
            ElevatedButton(
                onPressed: () => registerNewUser(context, ref,
                    emailController: emailController,
                    passwordController: passwordController,
                    confirmPasswordController: confirmPasswordController,
                    firstNameController: firstNameController,
                    lastNameController: lastNameController,
                    mobileNumberController: mobileNumberController),
                child: montserratWhiteBold('REGISTER')),
            const Divider(color: CustomColors.deepNavyBlue),
            TextButton(
                onPressed: () => Navigator.of(context)
                    .pushNamed(NavigatorRoutes.forgotPassword),
                child: montserratWhiteBold('Forgot Password?',
                    textDecoration: TextDecoration.underline)),
            TextButton(
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(NavigatorRoutes.login),
                child: montserratWhiteBold('Already have an account?',
                    textDecoration: TextDecoration.underline))
          ],
        ));
  }
}
