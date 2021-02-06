import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lunch_quest/src/model/record.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class WebRecordPrintPagePage extends StatefulWidget {
  final List<Record> recordItems;

  WebRecordPrintPagePage({this.recordItems});

  @override
  _WebRecordPrintPageState createState() => _WebRecordPrintPageState();
}

class _WebRecordPrintPageState extends State<WebRecordPrintPagePage> {
  List<Record> records = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      records = widget.recordItems;
    });
  }

  void _showPrintedToast(BuildContext context) {
    final scaffold = Scaffold.of(context);

    // ignore: deprecated_member_use
    scaffold.showSnackBar(
      const SnackBar(
        content: Text('Document printed successfully'),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pdf Printing'),
      ),
      body: PdfPreview(
        onPrinted: _showPrintedToast,
        build: (format) => _generatePdf(format, "식권장부"),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  pw.Widget _contentTable(pw.Context context, ByteData font) {
    final ttf = pw.Font.ttf(font);
    const tableHeaders = ['날짜', '인원수', '인원'];

    return pw.Table.fromTextArray(
      border: null,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
      ),
      headerHeight: 25,
      cellHeight: 24,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
      },
      headerStyle: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        font: ttf,
      ),
      cellStyle: pw.TextStyle(
        font: ttf,
        fontSize: 10,
      ),
      rowDecoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            width: .5,
          ),
        ),
      ),
      headers: List<String>.generate(
        tableHeaders.length,
        (col) => tableHeaders[col],
      ),
      data: List<List<String>>.generate(
        records.length,
        (row) => List<String>.generate(
          tableHeaders.length,
          (col) => records[row].getIndex(col),
        ),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
    final pdf = pw.Document(
      author: "Angel Robotics",
      creator: "Angel Robotics",
      title: "식권장부",
    );
    final font = await rootBundle.load("assets/fonts/MaruBuri-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        orientation: pw.PageOrientation.landscape,
        build: (context) {
          return _contentTable(context, font);
          // return pw.Table(
          //   children: [
          //     pw.TableRow(children: [
          //       pw.Text("날짜", style: pw.TextStyle(font: ttf, fontSize: 12)),
          //       pw.Text("인원수", style: pw.TextStyle(font: ttf, fontSize: 12)),
          //       pw.Text("인원", style: pw.TextStyle(font: ttf, fontSize: 12)),
          //     ]),
          //     ...records
          //         .map((e) => pw.TableRow(
          //                 decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 0.5)),
          //                 children: [
          //                   pw.Text("${e.date}", style: pw.TextStyle(fontSize: 12)),
          //                   pw.Text(e.total.toString(), style: pw.TextStyle(fontSize: 12)),
          //                   pw.Text(e.users.toString(), style: pw.TextStyle(font: ttf, fontSize: 12)),
          //                 ]))
          //         .toList(),
          //   ],
          // );
          // return pw.Column(
          //   children: [
          //
          //     DataTable(
          //       rows: records
          //           .map((e) => DataRow(cells: [
          //         DataCell(Text(e.date)),
          //         DataCell(Text(e.total.toString())),
          //         DataCell(Text("${e.users.toString()}")),
          //         DataCell(e.isClosed ? Text("마감완료") : Text("미완료")),
          //       ]))
          //           .toList(),
          //       columns: [
          //         DataColumn(
          //           label: Text("날짜"),
          //         ),
          //         DataColumn(
          //           label: Text("인원수"),
          //         ),
          //         DataColumn(
          //           label: Text("인원"),
          //         ),
          //         DataColumn(
          //           label: Text("마감처리 여부"),
          //         ),
          //       ],
          //     ),
          //   ],
          // );
        },
      ),
    );

    return pdf.save();
  }
}
