import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() async {
  final document = pw.Document(title: 'PetsWorld Firebase Cost Guide');
  final generatedOn = DateTime.now();
  final logoBytes = await File(
    'assets/logo/petsworld_logo.png',
  ).readAsBytes();
  final logo = pw.MemoryImage(logoBytes);

  const ink = PdfColor.fromInt(0xFF203036);
  const muted = PdfColor.fromInt(0xFF66757D);
  const accent = PdfColor.fromInt(0xFF1F8C72);
  const accentDark = PdfColor.fromInt(0xFF155846);
  const warm = PdfColor.fromInt(0xFFF7F5EF);
  const border = PdfColor.fromInt(0xFFD9E3DE);
  const white = PdfColors.white;

  String formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day/$month/$year';
  }

  pw.Widget bodyText(String text, {double size = 11.2, PdfColor color = ink}) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: size, color: color, lineSpacing: 3),
    );
  }

  pw.Widget sectionHeading(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 12, bottom: 10),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          color: ink,
        ),
      ),
    );
  }

  pw.Widget bullet(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 6,
            height: 6,
            margin: const pw.EdgeInsets.only(top: 5, right: 8),
            decoration: const pw.BoxDecoration(
              color: accent,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.Expanded(child: bodyText(text)),
        ],
      ),
    );
  }

  pw.Widget infoCard({
    required String title,
    required List<String> paragraphs,
    PdfColor background = warm,
  }) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: background,
        border: pw.Border.all(color: border),
        borderRadius: pw.BorderRadius.circular(16),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 13.5,
              fontWeight: pw.FontWeight.bold,
              color: ink,
            ),
          ),
          pw.SizedBox(height: 8),
          ...paragraphs.map(
            (paragraph) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: bodyText(paragraph),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget smallPill(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: white,
        borderRadius: pw.BorderRadius.circular(20),
        border: pw.Border.all(color: border),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: accentDark,
          fontSize: 9.5,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget summaryTable() {
    final rows = <List<String>>[
      ['Area', 'What it means for PetsWorld', 'Main cost risk'],
      [
        'Authentication',
        'User login, signup, Google sign-in, phone OTP, email verification',
        'Phone OTP and SMS-based login can become expensive much faster than email login.',
      ],
      [
        'Firestore',
        'Products, categories, orders, users, home banner',
        'Large repeated reads, especially when the app loads full product lists often.',
      ],
      [
        'Storage',
        'Product images and category images',
        'Large image files and repeated downloads increase cost over time.',
      ],
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: border, width: 0.8),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.1),
        1: pw.FlexColumnWidth(2.2),
        2: pw.FlexColumnWidth(2.2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: warm),
          children: rows.first
              .map(
                (cell) => pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    cell,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: ink,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        ...rows.skip(1).map(
          (row) => pw.TableRow(
            children: row
                .map(
                  (cell) => pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: bodyText(cell, size: 10.3),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  pw.Widget exampleCard({
    required String title,
    required String scenario,
    required String takeaway,
  }) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF3F7F5),
        borderRadius: pw.BorderRadius.circular(16),
        border: pw.Border.all(color: border),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12.5,
              fontWeight: pw.FontWeight.bold,
              color: ink,
            ),
          ),
          pw.SizedBox(height: 7),
          bodyText(scenario),
          pw.SizedBox(height: 7),
          pw.Text(
            takeaway,
            style: pw.TextStyle(
              fontSize: 11,
              color: accentDark,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  document.addPage(
    pw.MultiPage(
      margin: const pw.EdgeInsets.all(30),
      pageTheme: const pw.PageTheme(pageFormat: PdfPageFormat.a4),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 12),
        child: pw.Text(
          'PetsWorld • Firebase Cost Guide • ${context.pageNumber}/${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: muted),
        ),
      ),
      build: (context) => [
        pw.Container(
          padding: const pw.EdgeInsets.all(24),
          decoration: pw.BoxDecoration(
            gradient: const pw.LinearGradient(
              colors: [accentDark, accent],
              begin: pw.Alignment.topLeft,
              end: pw.Alignment.bottomRight,
            ),
            borderRadius: pw.BorderRadius.circular(22),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(
                        width: 56,
                        height: 56,
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: white,
                          borderRadius: pw.BorderRadius.circular(16),
                        ),
                        child: pw.Image(logo, fit: pw.BoxFit.contain),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'PetsWorld',
                            style: pw.TextStyle(
                              fontSize: 24,
                              color: white,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Client Brief',
                            style: pw.TextStyle(
                              fontSize: 11,
                              color: white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  smallPill('Prepared on ${formatDate(generatedOn)}'),
                ],
              ),
              pw.SizedBox(height: 26),
              pw.Text(
                'Firebase Pricing Explained for PetsWorld',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: white,
                  lineSpacing: 2,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'A simple business-focused explanation of how Firebase pricing works, where costs come from in this app, and how to keep long-term costs under control as the platform grows.',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.white,
                  lineSpacing: 3,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 18),
        infoCard(
          title: 'Executive summary',
          paragraphs: [
            'Firebase is not a fixed monthly package. It is a set of cloud services, and the final cost depends on how much the app actually uses them.',
            'For PetsWorld, the most important cost areas are database usage, image storage and image downloads, and user authentication.',
            'The good news is that Firebase can remain cost-efficient for this app if product loading, image handling, and user authentication are structured properly.',
          ],
        ),
        sectionHeading('1. What the client should know first'),
        bullet(
          'There is a free plan for starting out, but larger usage moves the project to a pay-as-you-go model.',
        ),
        bullet(
          'The app does not get charged simply because users install it. Costs increase when users read data, save data, upload files, and download files.',
        ),
        bullet(
          'The app can scale safely if the technical setup is optimized for efficient reads, smaller images, and controlled admin uploads.',
        ),
        sectionHeading('2. How Firebase is used in PetsWorld'),
        summaryTable(),
        pw.SizedBox(height: 10),
        sectionHeading('3. Where costs can grow in this app'),
        bodyText(
          'In the current PetsWorld structure, the biggest long-term cost risk is not sign-up or login. It is product browsing. That is because the app currently reads large sets of product and category data during startup and browsing.',
        ),
        pw.SizedBox(height: 8),
        bullet(
          'If the product catalog becomes large, repeated reads will grow each time users open the app or browse categories.',
        ),
        bullet(
          'If large images are uploaded and shown often, download bandwidth and storage usage will rise steadily.',
        ),
        bullet(
          'If phone-based authentication becomes the main login method, authentication costs can increase faster than expected.',
        ),
        sectionHeading('4. Simple examples the client can understand'),
        exampleCard(
          title: 'Example 1: Home page traffic',
          scenario:
              'Imagine PetsWorld has 120 active products, several featured products, and category data. If every home-page load reads large product lists, then thousands of daily visitors can quickly turn into hundreds of thousands or even millions of database reads.',
          takeaway:
              'Business meaning: growth is good, but the home page should load smarter, not heavier.',
        ),
        exampleCard(
          title: 'Example 2: Product images',
          scenario:
              'If a product image is large and the same image is viewed thousands of times, the app pays more in storage and image delivery than it would with compressed images and thumbnails.',
          takeaway:
              'Business meaning: smaller images can reduce cost without hurting the customer experience.',
        ),
        exampleCard(
          title: 'Example 3: Authentication choice',
          scenario:
              'Email login and Google login are usually more cost-friendly. Phone OTP is useful, but SMS-related usage can become more expensive when the user base becomes large.',
          takeaway:
              'Business meaning: keep phone login optional unless it is a business requirement.',
        ),
        sectionHeading('5. Recommended strategy for keeping Firebase cost-efficient'),
        bullet(
          'Load products in pages instead of reading the full catalog in one go.',
        ),
        bullet(
          'Cache home-page data like banners, categories, and featured products so they are not fetched repeatedly.',
        ),
        bullet(
          'Use thumbnail images in lists and full-size images only on product detail pages.',
        ),
        bullet(
          'Compress images before upload and keep clear size limits for admin uploads.',
        ),
        bullet(
          'Use email/password and Google sign-in as the main login methods, with phone OTP only where needed.',
        ),
        bullet(
          'Set billing alerts early so spending can be monitored as the business grows.',
        ),
        sectionHeading('6. What has already been improved in the app'),
        bullet(
          'Image uploads have been moved from Cloudinary to Firebase Storage so the app stays within one Firebase-based backend flow.',
        ),
        bullet(
          'Storage rules now restrict uploads to admin users and only allow image files within a fixed size limit.',
        ),
        bullet(
          'The project is now ready for a more cost-aware image strategy using Firebase Storage.',
        ),
        infoCard(
          title: 'Recommended business conclusion',
          paragraphs: [
            'Firebase is a suitable choice for PetsWorld, but the pricing model should be understood as usage-based rather than fixed-price.',
            'The platform can remain cost-efficient if the app avoids unnecessary database reads and uses optimized images.',
            'In short: Firebase is not the problem. Inefficient usage is the problem. With the right structure, Firebase can scale well for this business.',
          ],
          background: const PdfColor.fromInt(0xFFEAF4F0),
        ),
        sectionHeading('7. Official reference sources'),
        bodyText('1. Firebase Pricing: https://firebase.google.com/pricing'),
        bodyText(
          '2. Firebase Billing Plans: https://firebase.google.com/docs/projects/billing',
        ),
        bodyText(
          '3. Firestore Pricing: https://firebase.google.com/docs/firestore/pricing',
        ),
        bodyText(
          '4. Firestore Billing Example: https://firebase.google.com/docs/firestore/billing-example',
        ),
        bodyText(
          '5. Firebase Authentication Limits: https://firebase.google.com/docs/auth/limits',
        ),
        bodyText(
          '6. Cloud Storage for Firebase FAQ: https://firebase.google.com/docs/storage/faqs-storage-changes-announced-sept-2024',
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Note: exact pricing depends on region, actual traffic, storage volume, and authentication usage. This document is meant to explain the pricing model clearly for business discussion and planning.',
          style: const pw.TextStyle(fontSize: 10, color: muted),
        ),
      ],
    ),
  );

  final outputDir = Directory('docs');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  final outputFile = File('docs/petsworld_client_firebase_pricing_guide.pdf');
  await outputFile.writeAsBytes(await document.save());
  stdout.writeln(outputFile.path);
}
