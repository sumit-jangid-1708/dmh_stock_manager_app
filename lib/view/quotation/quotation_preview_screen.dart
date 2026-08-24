import 'dart:typed_data';
import 'package:dmj_stock_manager/model/quotation_models/quotation_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class QuotationPreviewScreen extends StatelessWidget {
  final QuotationDetailModel quotation;
  const QuotationPreviewScreen({super.key, required this.quotation});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Preview: ${quotation.number}'),
      backgroundColor: const Color(0xFF1A1A4F),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    body: PdfPreview(
      build: (_) => generateQuotationPdf(quotation),
      maxPageWidth: 700,
      canChangePageFormat: false,
      canChangeOrientation: false,
      canDebug: false,
      pdfFileName: "Quotation_${quotation.number}.pdf",
    ),
  );
}

Future<Uint8List> generateQuotationPdf(QuotationDetailModel quotation) async {
  final pdf = pw.Document();

  final regular = await PdfGoogleFonts.robotoCondensedRegular();
  final bold = await PdfGoogleFonts.robotoCondensedBold();

  const pageW = 612.0;
  const pageH = 792.0;
  const lineColor = PdfColors.grey700;
  const border = pw.BorderSide(color: lineColor, width: .5);

  pw.TextStyle style(double size, [bool isBold = false]) =>
      pw.TextStyle(font: isBold ? bold : regular, fontSize: size);

  final normal = style(9.3);
  final bold9 = style(9.3, true);
  final small = style(8.44);
  final smallBold = style(8.44, true);
  final company = style(9.96, true);
  final title = style(12, true);
  final total = style(12, true);

  pw.Widget text(
    String value,
    double x,
    double y,
    double w,
    double h,
    pw.TextStyle s, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    final a = align == pw.TextAlign.center
        ? pw.Alignment.topCenter
        : align == pw.TextAlign.right
        ? pw.Alignment.topRight
        : pw.Alignment.topLeft;

    return pw.Positioned(
      left: x,
      top: y,
      child: pw.Container(
        width: w,
        height: h,
        alignment: a,
        child: pw.Text(value, style: s, textAlign: align, maxLines: 20),
      ),
    );
  }

  pw.Widget line(double x, double y, double w, double h) => pw.Positioned(
    left: x,
    top: y,
    child: pw.Container(width: w, height: h, color: lineColor),
  );

  pw.Widget box(
    double x,
    double y,
    double w,
    double h, {
    pw.Border? customBorder,
  }) => pw.Positioned(
    left: x,
    top: y,
    child: pw.Container(
      width: w,
      height: h,
      decoration: pw.BoxDecoration(
        border:
            customBorder ??
            pw.Border.all(width: border.width, color: border.color),
      ),
    ),
  );

  void addText(
    List<pw.Widget> list,
    String value,
    double x,
    double y,
    double w,
    double h,
    pw.TextStyle s, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    list.add(text(value, x, y, w, h, s, align: align));
  }

  void addLines(List<pw.Widget> list, List<List<double>> values) {
    for (final v in values) {
      list.add(line(v[0], v[1], v[2], v[3]));
    }
  }

  pdf.addPage(
    pw.Page(
      pageFormat: const PdfPageFormat(pageW, pageH, marginAll: 0),
      margin: pw.EdgeInsets.zero,
      build: (_) {
        final w = <pw.Widget>[];

        addText(
          w,
          'QUOTATION',
          0,
          18.3,
          pageW,
          14,
          title,
          align: pw.TextAlign.center,
        );

        // Header.
        w.add(box(36, 44, 468, 226.68));
        addLines(w, [
          [274.1, 44, .5, 226.68],
          [36, 119.6, 238.1, .5],
          [36, 195.1, 238.1, .5],
          [388.7, 44, .5, 119.7],
          [274.1, 69.4, 229.9, .5],
          [274.1, 94.9, 229.9, .5],
          [274.1, 120.3, 229.9, .5],
        ]);

        // Seller (Hardcoded as per existing template, could be dynamic later)
        final seller = <List<Object>>[
          ['A2G Traders Private Limited', 38.7, 46.9, company],
          [
            'BASEMENT, 57 SHRI GURUKRIPA NAGAR NIGAM COLONY',
            38.7,
            57.2,
            normal,
          ],
          ['GOLIMAR GARDEN SCHEME AMER ROAD JAIPUR', 38.7, 67.3, normal],
          ['302002', 38.7, 77.4, normal],
          ['GSTIN/UIN: 08AAVCA7886Q1Z8', 38.7, 87.5, normal],
          ['State Name : Rajasthan, Code : 08', 38.7, 97.6, normal],
          ['E-Mail : ASHUTOSH.BURMAN@a2groups.org', 38.7, 107.7, normal],
        ];
        for (final e in seller) {
          addText(
            w,
            e[0] as String,
            e[1] as double,
            e[2] as double,
            233,
            11,
            e[3] as pw.TextStyle,
          );
        }

        // Consignee + Buyer.
        final people = <List<Object>>[
          ['Consignee (Ship to)', 38.7, 121.6, small],
          [quotation.consigneeName ?? '', 38.7, 131.9, company],
          [quotation.consigneeAddress ?? '', 38.7, 142.2, normal],
          ['GSTIN/UIN: ${quotation.consigneeGstin ?? ""}', 38.7, 152.3, normal],
          ['State Name : ${quotation.consigneeState ?? ""}, Code : ${quotation.consigneeStateCode ?? ""}', 38.7, 162.4, normal],
          ['Buyer (Bill to)', 38.7, 197.1, small],
          [quotation.customerName ?? '', 38.7, 207.4, company],
          [quotation.customerAddress ?? '', 38.7, 217.7, normal],
          ['GSTIN/UIN: ${quotation.customerGstin ?? ""}', 38.7, 227.8, normal],
          ['State Name : ${quotation.customerState ?? ""}, Code : ${quotation.customerStateCode ?? ""}', 38.7, 237.9, normal],
        ];
        for (final e in people) {
          addText(
            w,
            e[0] as String,
            e[1] as double,
            e[2] as double,
            233,
            22,
            e[3] as pw.TextStyle,
          );
        }

        // Right header metadata.
        final meta = <List<Object>>[
          ['Quotation No.', 276.8, 46.5, small],
          [quotation.number ?? '', 276.8, 57.1, company],
          ['Dated', 391.4, 46.5, small],
          [quotation.quoteDate ?? '', 391.4, 57.1, company],
          ['Mode/Terms of Payment', 391.4, 71.5, small],
          [quotation.paymentTerms ?? '', 391.4, 82.6, company],
          ["Buyer's Ref./Order No.", 276.8, 72.0, small],
          [quotation.buyerReference ?? '', 276.8, 82.6, company],
          ['Other References', 391.4, 97.0, small],
          [quotation.otherReferences ?? '', 391.4, 107.6, company],
          ['Dispatched through', 276.8, 97.4, small],
          [quotation.dispatchedThrough ?? '', 276.8, 107.6, company],
          ['Destination', 391.4, 122.4, small],
          [quotation.destination ?? '', 391.4, 133.0, company],
          ['Terms of Delivery', 276.8, 122.4, small],
          [quotation.deliveryTerms ?? '', 276.8, 133.0, company],
        ];
        for (final e in meta) {
          addText(
            w,
            e[0] as String,
            e[1] as double,
            e[2] as double,
            110,
            11,
            e[3] as pw.TextStyle,
          );
        }

        // Items table.
        const ty = 270.72;
        w.add(box(36, ty, 468, 226.68));
        addLines(w, [
          [49.92, ty, .5, 226.68],
          [247.20, ty, .5, 226.68],
          [288.72, ty, .5, 226.68],
          [336.48, ty, .5, 226.68],
          [383.76, ty, .5, 226.68],
          [404.28, ty, .5, 226.68],
          [435.60, ty, .5, 226.68],
          [36, ty + 22.92, 468, .5],
          [436.10, ty + 56.5, 67.4, .5],
          [36, ty + 212.28, 468, .5],
        ]);

        final headers = <List<Object>>[
          ['Sl\nNo.', 37.5, 12.0],
          ['Description of\nGoods and Services', 95.0, 105.0],
          ['Due on', 248.0, 39.0],
          ['Quantity', 289.0, 48.0],
          ['Rate', 338.0, 44.0],
          ['per', 385.0, 18.0],
          ['Disc. %', 406.0, 29.0],
          ['Amount', 436.0, 66.0],
        ];
        for (final h in headers) {
          addText(
            w,
            h[0] as String,
            h[1] as double,
            ty + 1,
            h[2] as double,
            20,
            small,
            align: pw.TextAlign.center,
          );
        }

        double currentY = 29.0;
        if (quotation.items != null) {
          for (int i = 0; i < quotation.items!.length; i++) {
            final item = quotation.items![i];
            final rows = <List<Object>>[
              ['${i + 1}', 42.0, currentY, 8.0, normal, pw.TextAlign.left],
              [item.productName ?? '', 50.0, currentY, 195.0, company, pw.TextAlign.left],
              [item.dueOn ?? '', 248.0, currentY, 39.0, normal, pw.TextAlign.center],
              ['${item.quantity} ${item.unit}', 289.0, currentY, 48.0, company, pw.TextAlign.right],
              [item.unitPrice ?? '', 338.0, currentY, 44.0, normal, pw.TextAlign.right],
              [item.unit ?? '', 385.0, currentY, 18.0, small, pw.TextAlign.center],
              [item.discountPercentage ?? '0', 406.0, currentY, 29.0, normal, pw.TextAlign.center],
              [item.totalAmount ?? '', 436.0, currentY, 66.0, company, pw.TextAlign.right],
            ];
            for (final r in rows) {
              addText(
                w,
                r[0] as String,
                r[1] as double,
                ty + (r[2] as double),
                r[3] as double,
                14,
                r[4] as pw.TextStyle,
                align: r[5] as pw.TextAlign,
              );
            }
            currentY += 14.0;
          }
        }

        // Totals
        addText(w, 'Total', 245.0, ty + 212.3, 42.0, 14, normal, align: pw.TextAlign.right);
        addText(w, '${quotation.itemCount ?? 0} Items', 289.0, ty + 212.3, 48.0, 14, company, align: pw.TextAlign.right);
        addText(w, '₹ ${quotation.grandTotal}', 426.0, ty + 211.8, 76.0, 14, total, align: pw.TextAlign.right);

        // Footer.
        w.add(
          box(
            36,
            497.4,
            468,
            188.6,
            customBorder: const pw.Border(
              left: border,
              right: border,
              bottom: border,
            ),
          ),
        );
        addText(w, 'Amount Chargeable (in words)', 38.7, 498.2, 220, 10, small);
        addText(
          w,
          'INR ${quotation.grandTotal} Only', // You might want to convert number to words here if needed
          38.7,
          511.3,
          300,
          11,
          smallBold,
        );
        addText(
          w,
          'E. & O.E',
          462,
          498.2,
          39,
          10,
          small,
          align: pw.TextAlign.right,
        );

        if (quotation.notes != null) {
          addText(w, 'Notes: ${quotation.notes}', 38.7, 530, 460, 40, small);
        }

        w.add(box(270, 643.44, 234, 42.56));
        addText(
          w,
          'for A2G Traders Private Limited',
          374,
          644.3,
          127,
          10,
          smallBold,
          align: pw.TextAlign.right,
        );
        addText(
          w,
          'Authorised Signatory',
          398,
          674.9,
          103,
          10,
          small,
          align: pw.TextAlign.right,
        );
        addText(
          w,
          'This is a Computer Generated Document',
          0,
          691.6,
          pageW,
          10,
          small,
          align: pw.TextAlign.center,
        );

        return pw.Stack(children: w);
      },
    ),
  );

  return pdf.save();
}
