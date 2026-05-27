// lib/services/thermal_print_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

import '../../../model/order_models/order_detail_model.dart';
import '../../../model/product_models/product_model.dart';

// ─────────────────────────────────────────────────────────────
// UNIFIED PRINT ENTRY — sabke liye ek model
// ─────────────────────────────────────────────────────────────
class PrintEntry {
  final String qrData; // QR mein encode hone wala data
  final String displayName; // Right side mein dikhne wala name

  const PrintEntry({required this.qrData, required this.displayName});

  // ── Order serial se ──
  factory PrintEntry.fromSerial({
    required String serialNumber,
    required String productName,
  }) => PrintEntry(qrData: serialNumber, displayName: productName);

  // ── Product SKU se ──
  factory PrintEntry.fromProduct(ProductModel p) =>
      PrintEntry(qrData: p.sku, displayName: p.name);

  // ── Single SKU + qty se (qty copies banata hai) ──
  static List<PrintEntry> fromSkuWithQty(String sku, String name, int qty) =>
      List.generate(qty, (_) => PrintEntry(qrData: sku, displayName: name));
}

// ─────────────────────────────────────────────────────────────
// UNIFIED THERMAL PRINT SERVICE
// ─────────────────────────────────────────────────────────────
class ThermalPrintService {
  ThermalPrintService._();

  /// ── Label dimensions (58mm printer @ 203 DPI) ──
  /// 50mm wide  → 384 dots  (printable area of 58mm roll)
  /// 25mm tall  → 200 dots
  static const double _labelW = 384.0;
  static const double _labelH = 200.0;
  static const double _qrPx =
      170.0; // QR fixed size — label height se thoda chota
  static const double _padH = 6.0;
  static const double _padV = 12.0;
  static const double _gap = 8.0;

  // ── State ──
  static final _plugin = FlutterThermalPrinter.instance;
  static StreamSubscription<List<Printer>>? _scanSub;
  static Printer? _connected;

  static bool get isConnected =>
      _connected != null && (_connected!.isConnected ?? false);

  // ─────────────────────────────────────────────────────────────
  // PUBLIC API — 3 entry points
  // ─────────────────────────────────────────────────────────────

  /// 1. Order ke serials print karo
  static Future<void> printOrderLabels(
    BuildContext context,
    OrderDetailsModel order,
  ) async {
    final entries = <PrintEntry>[];
    for (final item in order.items) {
      for (final serial in item.serials) {
        entries.add(
          PrintEntry.fromSerial(
            serialNumber: serial.serialNumber,
            productName: item.productName,
          ),
        );
      }
    }
    await _start(context, entries, "Order_${order.orderId}");
  }

  /// 2. Product list print karo (ek ek label)
  static Future<void> printProductLabels(
    BuildContext context,
    List<ProductModel> products,
  ) async {
    final entries = products.map(PrintEntry.fromProduct).toList();
    await _start(context, entries, "Products_${products.length}");
  }

  /// 3. Single SKU — qty copies print karo
  static Future<void> printSkuLabels(
    BuildContext context,
    String sku,
    String productName,
    int qty,
  ) async {
    final entries = PrintEntry.fromSkuWithQty(sku, productName, qty);
    await _start(context, entries, "SKU_$sku");
  }

  /// Printer disconnect karo
  static Future<void> disconnect() async {
    if (_connected != null) {
      await _plugin.disconnect(_connected!);
      _connected = null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // INTERNAL — connect + print flow
  // ─────────────────────────────────────────────────────────────

  static Future<void> _start(
    BuildContext context,
    List<PrintEntry> entries,
    String jobName,
  ) async {
    if (entries.isEmpty) {
      _snack("Nothing to print", Colors.orange);
      return;
    }

    if (!isConnected) {
      final ok = await _pickAndConnect(context);
      if (!ok) return;
    }

    await _printAll(context, entries, jobName);
  }

  // ─────────────────────────────────────────────────────────────
  // BLUETOOTH PICKER + CONNECT
  // ─────────────────────────────────────────────────────────────

  static Future<bool> _pickAndConnect(BuildContext context) async {
    final printers = <Printer>[].obs;
    final isScanning = true.obs;

    _scanSub?.cancel();
    await _plugin.getPrinters(connectionTypes: [ConnectionType.BLE]);
    _scanSub = _plugin.devicesStream.listen((list) {
      printers.value = list.where((p) => p.name?.isNotEmpty == true).toList();
      isScanning.value = false;
    });

    final picked = await showModalBottomSheet<Printer>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          _PrinterPickerSheet(printers: printers, isScanning: isScanning),
    );

    _scanSub?.cancel();
    _plugin.stopScan();
    if (picked == null) return false;

    try {
      await _plugin.connect(picked);
      _connected = picked;
      _snack("✅ Connected: ${picked.name}", Colors.green);
      return true;
    } catch (e) {
      _snack("❌ Connection failed: $e", Colors.red);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // PRINT ALL — single BLE job
  // ─────────────────────────────────────────────────────────────

  static Future<void> _printAll(
    BuildContext context,
    List<PrintEntry> entries,
    String jobName,
  ) async {
    _showLoading(context, "Printing ${entries.length} label(s)...");

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      final sc = ScreenshotController();
      final List<int> allBytes = [];

      for (int i = 0; i < entries.length; i++) {
        // Widget → PNG bytes @ pixelRatio 1.0 (1 logical px = 1 printer dot)
        final captured = await sc.captureFromWidget(
          _buildLabel(entries[i]),
          pixelRatio: 1.0,
          context: context,
        );

        final decoded = img.decodeImage(captured);
        if (decoded == null) {
          debugPrint("❌ Decode failed label $i");
          continue;
        }

        // Exact 384×200 dots — safe guard
        final resized = img.copyResize(
          decoded,
          width: 384,
          height: 200,
          interpolation: img.Interpolation.linear,
        );

        allBytes.addAll(generator.imageRaster(resized, align: PosAlign.left));

        // GAP sensor ke liye feed — sticker boundary pe rukne ke liye
        allBytes.addAll(generator.feed(1));

        debugPrint("✅ $jobName — label ${i + 1}/${entries.length} buffered");
      }

      // Single BLE call — longData: true = auto chunking
      await _plugin.printData(_connected!, allBytes, longData: true);

      Get.back(); // loading hatao
      _snack("✅ ${entries.length} label(s) printed!", Colors.green);
    } catch (e) {
      Get.back();
      debugPrint("❌ Print error: $e");
      _snack("Print failed: $e", Colors.red);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LABEL WIDGET — 384×200 px
  // QR (fixed 176px) LEFT | product name RIGHT
  // SKU text hataya — thermal pe clear nahi aata
  // ─────────────────────────────────────────────────────────────

  static Widget _buildLabel(PrintEntry entry) {
    return SizedBox(
      width: _labelW,
      height: _labelH,
      child: Material(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _padH, vertical: _padV),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── QR CODE — fixed size, always inside label ──
              SizedBox(
                width: _qrPx,
                height: _qrPx,
                child: QrImageView(
                  data: entry.qrData,
                  version: QrVersions.auto,
                  size: _qrPx,
                  gapless: true,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  // Quiet zone — scanner ke liye zaruri white border
                  padding: const EdgeInsets.all(4),
                ),
              ),

              SizedBox(width: _gap),

              // ── PRODUCT NAME — bold, no SKU ──
              Expanded(
                child: Center(
                  child: Text(
                    entry.displayName,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.25,
                      // Monospace — thermal pe consistent width
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────

  static void _showLoading(BuildContext ctx, String msg) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const CircularProgressIndicator(color: Color(0xFF1A1A4F)),
            const SizedBox(width: 16),
            Expanded(child: Text(msg)),
          ],
        ),
      ),
    );
  }

  static void _snack(String msg, Color color) {
    Get.snackbar(
      '',
      msg,
      backgroundColor: color,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(12),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PRINTER PICKER BOTTOM SHEET
// ─────────────────────────────────────────────────────────────
class _PrinterPickerSheet extends StatelessWidget {
  final RxList<Printer> printers;
  final RxBool isScanning;

  const _PrinterPickerSheet({required this.printers, required this.isScanning});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Select Printer",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A4F),
            ),
          ),
          const SizedBox(height: 12),

          if (isScanning.value)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  CircularProgressIndicator(color: Color(0xFF1A1A4F)),
                  SizedBox(height: 12),
                  Text("Scanning...", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          else if (printers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.print_disabled,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "No printers found.\nBluetooth ON karein aur\nprinter pairing mode mein rakhen.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: printers.length,
                separatorBuilder: (_, __) =>
                    Divider(color: Colors.grey.shade100, height: 1),
                itemBuilder: (ctx, i) {
                  final p = printers[i];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A4F).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.print_outlined,
                        color: Color(0xFF1A1A4F),
                      ),
                    ),
                    title: Text(
                      p.name ?? "Unknown",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      p.address ?? "",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey,
                    ),
                    onTap: () => Navigator.pop(ctx, p),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
