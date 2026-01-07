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

            TextField(
              controller: homeController.nameController,
              decoration: InputDecoration(
                hintText: "Channel Name",
                // prefixIcon: Icon(Icons.),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1A1A4F),
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
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
        Container(
          width: 90,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF1A1A4F).withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
            borderRadius: BorderRadius.circular(15),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {
              homeController.addChannels();
            },
            child: const Text(
              "Add",
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
