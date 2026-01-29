import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:dmj_stock_manager/res/components/widgets/custom_text_field.dart';
import 'package:dmj_stock_manager/view_models/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChannelDialogWidget extends StatelessWidget {
  final HomeController homeController = Get.find<HomeController>();
  ChannelDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text(
        "Manage Channels",
        style: TextStyle(
          fontSize: 25,
          color: Color(0xFF1A1A4F),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: 300,
        height: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Obx(() {
                if (homeController.channels.isEmpty) {
                  return const Text("No channels yet");
                }
                return ListView.builder(
                  itemCount: homeController.channels.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final channel = homeController.channels[index];
                    return ListTile(
                      leading: Icon(
                        Icons.circle,
                        color: Color(0xFF1A1A4F),
                        size: 15,
                      ),
                      title: Text(channel.name),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 20),
            AppTextField(
              controller: homeController.nameController,
              hintText: "Channel Name",
              prefixIcon: Icons.store_mall_directory_outlined,
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            homeController.nameController.clear();
          },
          child: const Text(
            "Cancel",
            style: TextStyle(fontSize: 15, color: Color(0xFF1A1A4F)),
          ),
        ),
        AppGradientButton(
          onPressed: () {
            homeController.addChannels();
          },
          text: "Add",
          width: 90,
          height: 40,
        ),
      ],
    );
  }
}
