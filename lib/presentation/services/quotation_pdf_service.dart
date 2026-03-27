import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const PdfColor _ink = PdfColor(0.12, 0.12, 0.12);
const PdfColor _muted = PdfColor(0.35, 0.35, 0.35);
const PdfColor _line = PdfColor(0.75, 0.75, 0.75);
const PdfColor _soft = PdfColor(0.96, 0.96, 0.96);
const PdfColor _accent = PdfColor(0.10, 0.22, 0.45);

class QuotationModel {
  const QuotationModel({
    required this.quotationNo,
    required this.date,
    required this.validityDate,
    required this.customer,
    required this.contact,
    required this.pickup,
    required this.delivery,
    required this.route,
    required this.cargoType,
    required this.weight,
    required this.vehicle,
    required this.dispatchDate,
    required this.notes,
    required this.rate,
    required this.costSummary,
    required this.paymentTerms,
    required this.remarks,
  });

  final String quotationNo;
  final String date;
  final String validityDate;
  final String customer;
  final String contact;
  final String pickup;
  final String delivery;
  final String route;
  final String cargoType;
  final String weight;
  final String vehicle;
  final String dispatchDate;
  final String notes;
  final String rate;
  final String costSummary;
  final String paymentTerms;
  final String remarks;
}

pw.Widget buildSection(String title, pw.Widget child) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _line),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          color: _soft,
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11.5,
              fontWeight: pw.FontWeight.bold,
              color: _accent,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: child,
        ),
      ],
    ),
  );
}

Future<Uint8List> generateQuotationPdf(QuotationModel data) async {
  final doc = pw.Document();
  final logo = await _tryLoadLogo();
  final rateValue = _toDouble(data.rate);
  final vatValue = rateValue * 0.05;
  final grandTotal = rateValue + vatValue;

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(30, 24, 30, 24),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _letterHeader(data, logo),
            pw.SizedBox(height: 12),
            _recipientBlock(data),
            pw.SizedBox(height: 10),
            _subjectLine(),
            pw.SizedBox(height: 10),
            _bodyIntro(data),
            pw.SizedBox(height: 10),
            _quotationTable(data, rateValue, vatValue, grandTotal),
            pw.SizedBox(height: 8),
            _amountInWords(grandTotal),
            pw.SizedBox(height: 12),
            _footerColumns(data),
          ],
        );
      },
    ),
  );

  return doc.save();
}

pw.Widget _letterHeader(QuotationModel data, pw.MemoryImage? logo) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              if (logo != null)
                pw.SizedBox(
                  width: 145,
                  height: 44,
                  child: pw.Image(logo, fit: pw.BoxFit.contain),
                ),
              if (logo == null)
                pw.Text(
                  'Greenfield Logistics Services LLC',
                  style: pw.TextStyle(
                    color: _accent,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              pw.Text(
                'Greenfield Logistics Services LLC',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: _muted,
                ),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _smallPair('Ref No', data.quotationNo),
          _smallPair('Date', _formatDate(data.date)),
        ],
      ),
    ],
  );
}

pw.Widget _recipientBlock(QuotationModel data) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('To', style: pw.TextStyle(fontSize: 10, color: _ink)),
      pw.SizedBox(height: 4),
      pw.Text(
        data.customer,
        style: pw.TextStyle(fontSize: 10, color: _ink, fontWeight: pw.FontWeight.bold),
      ),
      pw.Text('Contact: ${_safe(data.contact)}', style: pw.TextStyle(fontSize: 10, color: _ink)),
      pw.Text('Route: ${_safe(data.route)}', style: pw.TextStyle(fontSize: 10, color: _ink)),
      pw.Text('Pickup: ${_safe(data.pickup)}', style: pw.TextStyle(fontSize: 10, color: _ink)),
      pw.Text('Delivery: ${_safe(data.delivery)}', style: pw.TextStyle(fontSize: 10, color: _ink)),
    ],
  );
}

pw.Widget _subjectLine() {
  return pw.RichText(
    text: pw.TextSpan(
      style: pw.TextStyle(fontSize: 10, color: _ink),
      children: [
        pw.TextSpan(
          text: 'Subject: ',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        const pw.TextSpan(
          text: 'Quotation for Logistics Transportation and Fleet Support Services',
        ),
      ],
    ),
  );
}

pw.Widget _bodyIntro(QuotationModel data) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('Dear ${_safe(data.customer)},', style: const pw.TextStyle(fontSize: 10)),
      pw.SizedBox(height: 6),
      pw.Text(
        'Greetings from Greenfield Logistics Services LLC.',
        style: const pw.TextStyle(fontSize: 10, lineSpacing: 2),
      ),
      pw.SizedBox(height: 8),
      pw.Text(
        'We are pleased to submit our quotation for the requested logistics transportation scope, '
        'including vehicle deployment, route execution, and cargo movement support. '
        'Please review the commercial details below for your approval.',
        style: const pw.TextStyle(fontSize: 10, lineSpacing: 2),
      ),
      if (data.notes.trim().isNotEmpty) ...[
        pw.SizedBox(height: 4),
        pw.Text(
          'Notes: ${data.notes}',
          style: pw.TextStyle(fontSize: 9.5, color: _muted),
        ),
      ],
    ],
  );
}

pw.Widget _quotationTable(
  QuotationModel data,
  double rate,
  double vat,
  double total,
) {
  final rows = <List<String>>[
    [
      '1',
      'Transport service from ${_safe(data.pickup)} to ${_safe(data.delivery)}\nCargo: ${_safe(data.cargoType)} | Vehicle: ${_safe(data.vehicle)}\nDispatch: ${_formatDate(data.dispatchDate)} | Weight/Volume: ${_safe(data.weight)}',
      _money(rate),
      _money(rate),
    ],
  ];

  return pw.Column(
    children: [
      pw.Table(
        border: pw.TableBorder.all(color: _ink, width: 0.7),
        columnWidths: const {
          0: pw.FlexColumnWidth(0.7),
          1: pw.FlexColumnWidth(5.0),
          2: pw.FlexColumnWidth(1.4),
          3: pw.FlexColumnWidth(1.5),
        },
        children: [
          _head(['Sl. No', 'Items', 'Unit Price', 'Total Price']),
          ...rows.map(_dataRow),
          _sumRow('SUB TOTAL', _money(rate)),
          _sumRow('VAT (5%)', _money(vat)),
          _sumRow('TOTAL', _money(total), bold: true),
        ],
      ),
    ],
  );
}

pw.TableRow _head(List<String> cells) {
  return pw.TableRow(
    decoration: const pw.BoxDecoration(color: _soft),
    children: [
      for (final cell in cells)
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            cell,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _ink),
          ),
        ),
    ],
  );
}

pw.TableRow _dataRow(List<String> cells) {
  return pw.TableRow(
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(cells[0], textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 9)),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(cells[1], style: const pw.TextStyle(fontSize: 9, lineSpacing: 2)),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(cells[2], textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 9)),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(cells[3], textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 9)),
      ),
    ],
  );
}

pw.TableRow _sumRow(String label, String amount, {bool bold = false}) {
  final weight = bold ? pw.FontWeight.bold : pw.FontWeight.normal;
  return pw.TableRow(
    decoration: bold ? const pw.BoxDecoration(color: _soft) : null,
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(''),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(''),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(
          label,
          textAlign: pw.TextAlign.right,
          style: pw.TextStyle(fontSize: 9, fontWeight: weight),
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(
          amount,
          textAlign: pw.TextAlign.right,
          style: pw.TextStyle(fontSize: 9, fontWeight: weight),
        ),
      ),
    ],
  );
}

pw.Widget _amountInWords(double total) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _line, width: 0.7),
      color: _soft,
    ),
    child: pw.Text(
      'Amount in words: OMR ${_amountWords(total)} only',
      style: pw.TextStyle(fontSize: 9, color: _ink),
    ),
  );
}

pw.Widget _footerColumns(QuotationModel data) {
  final terms = data.paymentTerms.trim().isEmpty
      ? 'Payment: As per agreed terms\nDelivery: Based on dispatch schedule\nValidity: Quotation valid till the date mentioned above'
      : data.paymentTerms;

  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Sincerely,', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 20),
            pw.Container(width: 110, height: 1, color: _line),
            pw.SizedBox(height: 4),
            pw.Text(
              'Authorized Signatory',
              style: pw.TextStyle(fontSize: 9, color: _muted),
            ),
            pw.Text(
              'Greenfield Logistics Services LLC',
              style: pw.TextStyle(fontSize: 9, color: _ink),
            ),
            if (data.remarks.trim().isNotEmpty) ...[
              pw.SizedBox(height: 8),
              pw.Text('Remarks: ${data.remarks}', style: pw.TextStyle(fontSize: 8.8, color: _muted)),
            ],
          ],
        ),
      ),
      pw.SizedBox(width: 16),
      pw.Expanded(
        child: buildSection(
          'Terms',
          pw.Text(
            terms,
            style: const pw.TextStyle(fontSize: 8.8, lineSpacing: 1.8),
          ),
        ),
      ),
    ],
  );
}

pw.Widget _smallPair(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 2),
    child: pw.RichText(
      text: pw.TextSpan(
        style: pw.TextStyle(fontSize: 9, color: _ink),
        children: [
          pw.TextSpan(text: '$label : ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.TextSpan(text: _safe(value)),
        ],
      ),
    ),
  );
}

String _safe(String value) {
  final v = value.trim();
  return v.isEmpty ? '-' : v;
}

double _toDouble(String value) {
  return double.tryParse(value.replaceAll(',', '').trim()) ?? 0;
}

String _money(double value) => value.toStringAsFixed(3);

String _formatDate(String input) {
  final value = input.trim();
  if (value.isEmpty) return '-';
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match != null) {
    final year = match.group(1)!;
    final month = match.group(2)!;
    final day = match.group(3)!;
    return '$day-$month-$year';
  }
  return value;
}

String _amountWords(double value) {
  final whole = value.floor();
  final fraction = ((value - whole) * 1000).round();
  return '${_intWords(whole)} and ${fraction.toString().padLeft(3, '0')} baisa';
}

String _intWords(int n) {
  if (n == 0) return 'zero';
  final units = [
    '',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
    'ten',
    'eleven',
    'twelve',
    'thirteen',
    'fourteen',
    'fifteen',
    'sixteen',
    'seventeen',
    'eighteen',
    'nineteen'
  ];
  final tens = ['', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'];

  String twoDigits(int x) {
    if (x < 20) return units[x];
    final t = x ~/ 10;
    final u = x % 10;
    return u == 0 ? tens[t] : '${tens[t]} ${units[u]}';
  }

  String threeDigits(int x) {
    if (x < 100) return twoDigits(x);
    final h = x ~/ 100;
    final r = x % 100;
    if (r == 0) return '${units[h]} hundred';
    return '${units[h]} hundred ${twoDigits(r)}';
  }

  final parts = <String>[];
  var num = n;

  final millions = num ~/ 1000000;
  if (millions > 0) {
    parts.add('${threeDigits(millions)} million');
    num %= 1000000;
  }

  final thousands = num ~/ 1000;
  if (thousands > 0) {
    parts.add('${threeDigits(thousands)} thousand');
    num %= 1000;
  }

  if (num > 0) {
    parts.add(threeDigits(num));
  }

  return parts.join(' ');
}

Future<pw.MemoryImage?> _tryLoadLogo() async {
  try {
    final data = await rootBundle.load('assets/images/gls_logo.jpg');
    return pw.MemoryImage(data.buffer.asUint8List());
  } catch (_) {
    return null;
  }
}
