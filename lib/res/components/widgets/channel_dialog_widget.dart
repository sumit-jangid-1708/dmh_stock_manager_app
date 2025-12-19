import 'package:dmj_stock_manager/view_models/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChannelDialogWidget extends StatelessWidget {
  final HomeController homeController = Get.find<HomeController>();
  ChannelDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Manage Channels"),
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
                      leading: Icon(Icons.circle, color:  Color(0xFF1A1A4F), size: 15,),
                      title: Text(channel.name),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: homeController.nameController,
              decoration: InputDecoration(
                hintText: "Channel Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
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
            style: TextStyle(color: Color(0xFF1A1A4F)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1A1A4F),
            fixedSize: Size(90, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () {
            homeController.addChannels();
          },
          child: const Text("Add", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
