import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class IdCardPdfService {
  IdCardPdfService._();

  /// Captures the RepaintBoundary widget into high-res PNG bytes (3.0 pixel ratio for 300+ DPI print)
  static Future<Uint8List?> captureWidgetToImage(GlobalKey boundaryKey) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("Error capturing widget to image: $e");
      return null;
    }
  }

  /// Generates a PDF containing ONLY the ID Card widget UI (1:1 exact card proportions, 0 margins/clutter)
  static Future<Uint8List> generateIdCardPdf({
    required Uint8List cardImageBytes,
    String? employeeName,
    String? empId,
    String? designation,
    String? joiningDate,
    String? bloodGroup,
  }) async {
    final pdf = pw.Document(
      title: "Durvasa Ayurved ID Card - ${employeeName ?? 'Employee'}",
      author: "Durvasa Ayurved Pvt. Ltd.",
      creator: "Durvasa Digital ID System",
    );
    final cardImage = pw.MemoryImage(cardImageBytes);

    // Exact ID Card Page Dimensions (380 x 590 pt @ standard ID card ratio, 0 margins)
    const cardFormat = PdfPageFormat(380, 590, marginAll: 0);

    pdf.addPage(
      pw.Page(
        pageFormat: cardFormat,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.FullPage(
            ignoreMargins: true,
            child: pw.Image(
              cardImage,
              fit: pw.BoxFit.fill,
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Saves PDF bytes to a temporary file for sharing
  static Future<File> savePdfToTempFile(Uint8List pdfBytes, {required String empId}) async {
    final tempDir = await getTemporaryDirectory();
    final cleanId = empId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final filePath = "${tempDir.path}/Durvasa_ID_Card_$cleanId.pdf";
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes, flush: true);
    return file;
  }

  /// Shares the PDF via standard Share sheet (WhatsApp, Drive, Email, etc.)
  static Future<void> shareIdCardPdf({
    required File pdfFile,
    required String employeeName,
    required String empId,
    String? joiningDate,
    String? bloodGroup,
  }) async {
    final cleanName = employeeName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final xFile = XFile(
      pdfFile.path,
      mimeType: 'application/pdf',
      name: "Durvasa_ID_Card_$cleanName.pdf",
    );

    final dateLine = (joiningDate != null && joiningDate.trim().isNotEmpty) ? "\n📅 Date of Joining: $joiningDate" : "";
    final bloodLine = (bloodGroup != null && bloodGroup.trim().isNotEmpty) ? "\n🩸 Blood Group: $bloodGroup" : "";

    await Share.shareXFiles(
      [xFile],
      text: "🌿 Durvasa Ayurved Employee ID Card\n👤 Employee: $employeeName\n🆔 ID: $empId$dateLine$bloodLine\n📍 Office: A 61, Noida Sector 16, Gautam Buddha Nagar, U.P. 201301\n🌐 Website: www.durvasaayurved.com",
      subject: "Durvasa Ayurved ID Card - $employeeName",
    );
  }

  /// Direct WhatsApp share with prefilled text and attached ID Card PDF
  static Future<void> shareToWhatsApp({
    required File pdfFile,
    required String employeeName,
    required String empId,
    String? joiningDate,
    String? bloodGroup,
    String? phoneNumber,
  }) async {
    final cleanName = employeeName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final xFile = XFile(
      pdfFile.path,
      mimeType: 'application/pdf',
      name: "Durvasa_ID_Card_$cleanName.pdf",
    );

    final dateLine = (joiningDate != null && joiningDate.trim().isNotEmpty) ? "\n📅 *Joining Date:* $joiningDate" : "";
    final bloodLine = (bloodGroup != null && bloodGroup.trim().isNotEmpty) ? "\n🩸 *Blood Group:* $bloodGroup" : "";

    try {
      await Share.shareXFiles(
        [xFile],
        text: "🌿 *Durvasa Ayurved Pvt. Ltd.* 🌿\n\nOfficial Employee ID Card\n*Name:* $employeeName\n*ID:* $empId$dateLine$bloodLine\n*Office:* A 61, Noida Sector 16, Gautam Buddha Nagar, U.P. 201301\n*Helpline:* 1800 123 4500\n*Website:* www.durvasaayurved.com",
      );
    } catch (e) {
      debugPrint("Share sheet error: $e");
      final textMsg = Uri.encodeComponent(
        "🌿 *Durvasa Ayurved Pvt. Ltd.* 🌿\n\nOfficial Employee ID Card\n*Name:* $employeeName\n*ID:* $empId$dateLine$bloodLine\n*Office:* A 61, Noida Sector 16, Gautam Buddha Nagar, U.P. 201301\n*Website:* www.durvasaayurved.com",
      );
      final phone = phoneNumber != null && phoneNumber.isNotEmpty ? phoneNumber : "";
      final waUri = Uri.parse("whatsapp://send?phone=$phone&text=$textMsg");
      if (await canLaunchUrl(waUri)) {
        await launchUrl(waUri);
      }
    }
  }

  /// Direct print or preview with default or custom title
  static Future<void> printOrPreviewPdf(Uint8List pdfBytes, {String title = 'Durvasa_ID_Card.pdf'}) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: title,
    );
  }
}
