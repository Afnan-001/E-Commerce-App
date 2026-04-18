import 'dart:convert';
import 'dart:typed_data';

import 'package:shop/models/order_model.dart';

import 'order_export_saver_stub.dart'
    if (dart.library.io) 'order_export_saver_io.dart'
    if (dart.library.html) 'order_export_saver_web.dart';

class OrderExportResult {
  const OrderExportResult({
    required this.fileName,
    required this.location,
  });

  final String fileName;
  final String? location;
}

class OrderExportService {
  const OrderExportService();

  Future<OrderExportResult> exportOrders(List<OrderModel> orders) async {
    final timestamp = DateTime.now();
    final fileName =
        'petsworld-orders-${timestamp.year}${_twoDigit(timestamp.month)}${_twoDigit(timestamp.day)}-${_twoDigit(timestamp.hour)}${_twoDigit(timestamp.minute)}.xls';
    final content = _buildSpreadsheetXml(orders);
    final bytes = Uint8List.fromList(utf8.encode(content));
    final location = await saveOrderExportFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'application/vnd.ms-excel',
    );
    return OrderExportResult(fileName: fileName, location: location);
  }

  String _buildSpreadsheetXml(List<OrderModel> orders) {
    final rows = <List<String>>[
      const [
        'Order ID',
        'Created At',
        'Updated At',
        'Customer Name',
        'Email',
        'Phone',
        'User ID',
        'Order Status',
        'Payment Method',
        'Payment Status',
        'Items Count',
        'Subtotal',
        'Delivery Charge',
        'Total',
        'Recipient',
        'Delivery Phone',
        'Delivery Address',
        'Razorpay Order ID',
        'Razorpay Payment ID',
      ],
      ...orders.map(
        (order) => [
          order.id,
          _formatDateTime(order.createdAt),
          _formatDateTime(order.updatedAt),
          order.customerName,
          order.userEmail,
          order.phoneNumber,
          order.userId,
          order.orderStatus.name,
          order.paymentMethod.name,
          order.paymentStatus.name,
          '${order.totalItems}',
          order.subtotal.toStringAsFixed(2),
          order.deliveryCharge.toStringAsFixed(2),
          order.totalPrice.toStringAsFixed(2),
          order.deliveryAddress.fullName,
          order.deliveryAddress.phone,
          order.deliveryAddress.fullAddress,
          order.payment.razorpayOrderId ?? '',
          order.payment.razorpayPaymentId ?? '',
        ],
      ),
    ];

    final buffer = StringBuffer()
      ..writeln('<?xml version="1.0"?>')
      ..writeln('<?mso-application progid="Excel.Sheet"?>')
      ..writeln('<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"')
      ..writeln(' xmlns:o="urn:schemas-microsoft-com:office:office"')
      ..writeln(' xmlns:x="urn:schemas-microsoft-com:office:excel"')
      ..writeln(' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">')
      ..writeln(' <Worksheet ss:Name="Orders">')
      ..writeln('  <Table>');

    for (final row in rows) {
      buffer.writeln('   <Row>');
      for (final cell in row) {
        buffer.writeln(
          '    <Cell><Data ss:Type="String">${_escapeXml(cell)}</Data></Cell>',
        );
      }
      buffer.writeln('   </Row>');
    }

    buffer
      ..writeln('  </Table>')
      ..writeln(' </Worksheet>')
      ..writeln('</Workbook>');

    return buffer.toString();
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return '';
    }
    final local = value.toLocal();
    return '${local.year}-${_twoDigit(local.month)}-${_twoDigit(local.day)} ${_twoDigit(local.hour)}:${_twoDigit(local.minute)}';
  }

  String _twoDigit(int value) => value.toString().padLeft(2, '0');

  String _escapeXml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
