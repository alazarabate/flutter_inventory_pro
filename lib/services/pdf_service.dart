import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/product.dart';

/// Generates A4 invoice with 15 % VAT (Ethiopia) and shares via native sheet.
class PdfService {

  /// Creates a PDF invoice file with itemized list, subtotal, tax, and grand total.
  Future<File> generateInvoice(List<Product> products) async {
    final pdf = pw.Document();
    final total = products.fold<double>(
      0,
      (sum, p) => sum + (p.price * p.stock),
    );
    final tax = total * 0.15; // 15% VAT (Ethiopia)
    final grandTotal = total + tax;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'INVOICE',
              style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Item', 'Qty', 'Unit Price', 'Total'],
            data: products
                .map(
                  (p) => [
                    p.name,
                    p.stock.toString(),
                    '${p.price} ETB',
                    '${(p.price * p.stock).toStringAsFixed(2)} ETB',
                  ],
                )
                .toList(),
          ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Subtotal: ${total.toStringAsFixed(2)} ETB'),
                  pw.Text('Tax (15%): ${tax.toStringAsFixed(2)} ETB'),
                  pw.Text(
                    'Grand Total: ${grandTotal.toStringAsFixed(2)} ETB',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

/// Generates an invoice PDF and shares it via the platform's native share dialog.
  Future<void> shareInvoice(List<Product> products) async {
    final file = await generateInvoice(products);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Invoice from Inventory Pro',
      text: 'Please find the attached invoice.',
    );
  }
}

