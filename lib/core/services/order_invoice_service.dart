import 'package:shop/models/order_model.dart';

import 'order_export_saver_stub.dart'
    if (dart.library.io) 'order_export_saver_io.dart'
    if (dart.library.html) 'order_export_saver_web.dart';
import 'pdf_invoice_service.dart';

class OrderInvoiceResult {
  const OrderInvoiceResult({
    required this.fileName,
    required this.location,
  });

  final String fileName;
  final String? location;
}

class OrderInvoiceService {
  OrderInvoiceService({PdfInvoiceService? pdfInvoiceService})
    : _pdfInvoiceService = pdfInvoiceService ?? PdfInvoiceService();

  final PdfInvoiceService _pdfInvoiceService;

  Future<OrderInvoiceResult> saveInvoice(OrderModel order) async {
    final bytes = await _pdfInvoiceService.buildInvoice(order);
    final fileName = 'petsworld-invoice-${order.id}.pdf';
    final location = await saveOrderExportFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'application/pdf',
    );
    return OrderInvoiceResult(fileName: fileName, location: location);
  }
}
