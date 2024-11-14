import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imeasure_mobile/providers/loading_provider.dart';
import 'package:imeasure_mobile/utils/firebase_util.dart';
import 'package:imeasure_mobile/utils/string_util.dart';
import 'package:imeasure_mobile/widgets/app_bar_widget.dart';
import 'package:imeasure_mobile/widgets/custom_miscellaneous_widgets.dart';
import 'package:imeasure_mobile/widgets/custom_padding_widgets.dart';
import 'package:imeasure_mobile/widgets/text_widgets.dart';

class TestimoniesScreen extends ConsumerStatefulWidget {
  const TestimoniesScreen({super.key});

  @override
  ConsumerState<TestimoniesScreen> createState() => _TestimoniesScreenState();
}

class _TestimoniesScreenState extends ConsumerState<TestimoniesScreen> {
  List<DocumentSnapshot> galleryDocs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        galleryDocs = await getAllTestimonialGalleryDocs();
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        ref.read(loadingProvider).toggleLoading(false);
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting gallery docs: $error')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return Scaffold(
      appBar: appBarWidget(),
      body: switchedLoadingContainer(
          ref.read(loadingProvider).isLoading,
          Column(
            children: [
              quicksandBlackBold('CLIENT TESTIMONIALS', fontSize: 28),
              all10Pix(
                  child: Wrap(
                      children: galleryDocs.map((gallery) {
                final galleryData = gallery.data() as Map<dynamic, dynamic>;
                return GestureDetector(
                  onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                          content: square80PercentNetworkImage(
                              context, galleryData[GalleryFields.imageURL]))),
                  child: all10Pix(
                      child: Image.network(galleryData[GalleryFields.imageURL],
                          width: 160, height: 160, fit: BoxFit.cover)),
                );
              }).toList())),
            ],
          )),
    );
  }
}
