import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imeasure_mobile/utils/color_util.dart';

import '../providers/loading_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_text_field_widget.dart';
import '../widgets/text_widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          //appBar: appBarWidget(),
          body: stackedLoadingContainer(
        context,
        ref.read(loadingProvider).isLoading,
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
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
              all20Pix(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    vertical20Pix(
                        child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: montserratWhiteBold('BACK'))),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: CustomColors.lavenderMist, width: 3)),
                      child: Column(
                        children: [
                          vertical20Pix(
                              child: montserratWhiteBold('RESET PASSWORD',
                                  fontSize: 26)),
                          all20Pix(
                              child: Column(
                            children: [
                              CustomTextField(
                                  text: 'Email',
                                  controller: emailController,
                                  textInputType: TextInputType.emailAddress,
                                  displayPrefixIcon: Icon(Icons.email)),
                              vertical20Pix(
                                child: ElevatedButton(
                                    onPressed: () => sendResetPasswordEmail(
                                        context, ref,
                                        emailController: emailController),
                                    child: montserratWhiteBold(
                                        'SEND PASSWORD RESET EMAIL',
                                        fontSize: 16)),
                              )
                            ],
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
        ),
      )),
    );
  }
}
