import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../res/routes/routes_names.dart';
import '../../../view_models/controller/auth/auth_controller.dart';
import '../../orders/return_order_screen.dart';
import '../../orders/shipping_screen.dart';
import '../../purchase_screen/purchase_screen.dart';
import '../../quotation/quotation_screen.dart';

class HomeServiceShortcuts extends StatelessWidget {
  HomeServiceShortcuts({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final services = [
      if (authController.canView('inventory'))
        _HomeService(
          title: 'Inventory',
          icon: Icons.inventory_2_outlined,
          color: const Color(0xFF4A4ABF),
          onTap: () => Get.toNamed(RouteName.stockScreen),
        ),
      if (authController.canView('orders'))
        _HomeService(
          title: 'Returns',
          icon: Icons.assignment_return_outlined,
          color: const Color(0xFFE05B67),
          onTap: () => Get.to(() => ReturnOrderHistoryScreen()),
        ),
      if (authController.canView('purchase'))
        _HomeService(
          title: 'Purchase',
          icon: Icons.shopping_bag_outlined,
          color: const Color(0xFFDD8A35),
          onTap: () => Get.to(() => PurchaseScreen()),
        ),
      if (authController.canView('orders'))
        _HomeService(
          title: 'Shipping',
          icon: Icons.local_shipping_outlined,
          color: const Color(0xFF3486C7),
          onTap: () => Get.to(() => ShippingScreen()),
        ),
      if (authController.canView('leads'))
        _HomeService(
          title: 'Leads',
          icon: Icons.support_agent_outlined,
          color: const Color(0xFF2A9D78),
          onTap: () => Get.toNamed(RouteName.leadScreen),
        ),
      _HomeService(
        title: 'Quotation',
        icon: Icons.request_quote_outlined,
        color: const Color(0xFF8A57B5),
        onTap: () => Get.to(() => const QuotationScreen()),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (_, index) => _ServiceTile(service: services[index]),
    );
  }
}

class _HomeService {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeService({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _ServiceTile extends StatelessWidget {
  final _HomeService service;

  const _ServiceTile({required this.service});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: service.onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFE8E8F2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: service.color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(service.icon, color: service.color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                service.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A4F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
