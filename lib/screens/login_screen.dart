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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        //appBar: appBarWidget(mayPop: true),
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
                            image: AssetImage(ImagePaths.bg),
                            fit: BoxFit.cover)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: CustomColors.deepCharcoal.withOpacity(0.6),
                  ),
                  _logInContainer(),
                ],
              ),
            )),
      ),
    );
  }

  Widget _logInContainer() {
    return Column(children: [
      Gap(MediaQuery.of(context).size.height * 0.2),
      itcBaumansDeepSkyBlueBold('iMeasure'),
      Gap(40),
      vertical20Pix(child: Image.asset(ImagePaths.heritageIcon, scale: 2)),
      itcBaumansWhiteBold('HERITAGE ALUMINUM SALES CORPORATION', fontSize: 20),
      itcBaumansWhiteBold('• LOS BAÑOS •', fontSize: 16),
      Gap(40),
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: CustomTextField(
            text: 'Email Address',
            controller: emailController,
            textInputType: TextInputType.emailAddress,
            displayPrefixIcon: const Icon(Icons.email)),
      ),
      const Gap(16),
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: CustomTextField(
          text: 'Password',
          controller: passwordController,
          textInputType: TextInputType.visiblePassword,
          displayPrefixIcon: const Icon(Icons.lock),
          onSearchPress: () => logInUser(context, ref,
              emailController: emailController,
              passwordController: passwordController),
        ),
      ),
      TextButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(NavigatorRoutes.forgotPassword),
          child: quicksandWhiteBold('Forgot Password?',
              fontSize: 16, textDecoration: TextDecoration.underline)),
      ElevatedButton(
          onPressed: () => logInUser(context, ref,
              emailController: emailController,
              passwordController: passwordController),
          child: quicksandWhiteBold('LOG-IN')),
      const Divider(),
      TextButton(
          onPressed: () => Navigator.of(context)
              .pushReplacementNamed(NavigatorRoutes.register),
          child: quicksandWhiteBold('Don\'t have an account?',
              fontSize: 16, textDecoration: TextDecoration.underline))
    ]);
  }
}
