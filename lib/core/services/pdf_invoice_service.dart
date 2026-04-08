import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:shop/models/order_model.dart';

class PdfInvoiceService {
  Future<Uint8List> buildInvoice(OrderModel order) async {
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text(
            'PawCare Invoice',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Order ID: ${order.id}'),
          pw.Text('Date: ${_formatDate(order.createdAt)}'),
          pw.SizedBox(height: 16),
          pw.Text(
            'Customer Details',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(order.customerName),
          pw.Text(order.phoneNumber),
          pw.Text(order.address),
          pw.SizedBox(height: 16),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: const <int, pw.TableColumnWidth>{
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(),
              2: pw.FlexColumnWidth(),
              3: pw.FlexColumnWidth(),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: _tableCells(
                  <String>['Item', 'Qty', 'Price', 'Total'],
                  isHeader: true,
                ),
              ),
              ...order.items.map(
                (item) => pw.TableRow(
                  children: _tableCells(
                    <String>[
                      item.name,
                      item.quantity.toString(),
                      'Rs ${item.unitPrice.toStringAsFixed(0)}',
                      'Rs ${item.lineTotal.toStringAsFixed(0)}',
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Subtotal: Rs ${order.subtotal.toStringAsFixed(0)}'),
                pw.Text('Delivery: Rs ${order.deliveryCharge.toStringAsFixed(0)}'),
                pw.Text(
                  'Total: Rs ${order.totalPrice.toStringAsFixed(0)}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Payment: ${order.paymentStatus}'),
              ],
            ),
          ),
        ],
      ),
    );

    return document.save();
  }

  List<pw.Widget> _tableCells(List<String> values, {bool isHeader = false}) {
    return values
        .map(
          (value) => pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        )
        .toList();
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A';
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    return '$day/$month/$year';
  }
}
