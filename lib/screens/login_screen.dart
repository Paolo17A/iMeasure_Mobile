import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/loading_provider.dart';
import '../providers/profile_image_url_provider.dart';
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
  void initState() {
    super.initState();
    if (!hasLoggedInUser()) return;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(loadingProvider).toggleLoading(true);
      final user = await getCurrentUserDoc();
      final userData = user.data() as Map<dynamic, dynamic>;
      ref
          .read(profileImageURLProvider)
          .setImageURL(userData[UserFields.profileImageURL]);
      ref.read(profileImageURLProvider).setFormattedName(
          '${userData[UserFields.firstName]} ${userData[UserFields.lastName]}');
      ref.read(loadingProvider).toggleLoading(false);
      Navigator.of(context).pushNamed(NavigatorRoutes.home);
    });
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
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(children: [
        Gap(MediaQuery.of(context).size.height * 0.2),
        vertical20Pix(child: Image.asset(ImagePaths.heritageIcon, scale: 2)),
        montserratWhiteBold('iMeasure', fontSize: 40),
        //itcBaumansWhiteBold('• LOS BAÑOS •', fontSize: 16),
        Gap(40),
        roundedWhiteContainer(
          context,
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: CustomTextField(
                    text: 'Email Address',
                    controller: emailController,
                    textInputType: TextInputType.emailAddress,
                    fillColor: CustomColors.deepCharcoal,
                    textColor: Colors.white,
                    displayPrefixIcon:
                        const Icon(Icons.email, color: Colors.white)),
              ),
              const Gap(16),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: CustomTextField(
                  text: 'Password',
                  controller: passwordController,
                  textInputType: TextInputType.visiblePassword,
                  fillColor: CustomColors.deepCharcoal,
                  textColor: Colors.white,
                  displayPrefixIcon:
                      const Icon(Icons.lock, color: Colors.white),
                  onSearchPress: () => logInUser(context, ref,
                      emailController: emailController,
                      passwordController: passwordController),
                ),
              ),
              vertical20Pix(
                child: Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                      border: Border.all(width: 2),
                      borderRadius: BorderRadius.circular(30)),
                  child: ElevatedButton(
                      onPressed: () => logInUser(context, ref,
                          emailController: emailController,
                          passwordController: passwordController),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      child: quicksandBlackBold('LOG-IN')),
                ),
              ),
              quicksandBlackBold('Don\'t have an account?', fontSize: 16),
              TextButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(NavigatorRoutes.register),
                  child: quicksandBlackBold('Create an account',
                      fontSize: 16, textDecoration: TextDecoration.underline)),
              TextButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamed(NavigatorRoutes.forgotPassword),
                  child: quicksandDeepCharcoalBold('Forgot Password?',
                      fontSize: 12, textDecoration: TextDecoration.underline)),
            ],
          ),
        )
      ]),
    );
  }
}
