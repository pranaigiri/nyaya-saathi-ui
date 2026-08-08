import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/draft_application_model.dart';

class PdfGeneratorService {
  static Future<Uint8List> generateA4FormPdf(DraftApplicationModel draft) async {
    final pdf = pw.Document();

    final formCode = _determineFormCode(draft.categoryCode, draft.caseTypeCode);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text("SIKKIM STATE LEGAL SERVICES AUTHORITY (SLSA)", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text("FORM $formCode — APPLICATION FOR FREE LEGAL AID", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.SizedBox(height: 2),
                    pw.Text("[Under Regulation 3 of Sikkim State Legal Services Regulations]", style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
                    pw.Divider(thickness: 1.5, color: PdfColors.blue900),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),

              // Section 1: Application & Category
              _buildSectionTitle("1. ELIGIBILITY & CATEGORY"),
              _buildRow("Category Selected:", draft.categoryName ?? 'General'),
              _buildRow("Applying For:", draft.appliedFor == 'self' ? 'Self' : 'Other (${draft.relationRemark ?? ''})'),
              pw.SizedBox(height: 10),

              // Section 2: Personal Details
              _buildSectionTitle("2. APPLICANT PERSONAL INFORMATION"),
              _buildRow("Full Name:", draft.fullName),
              _buildRow("Gender:", draft.gender),
              _buildRow("Date of Birth:", draft.dob ?? 'N/A'),
              _buildRow("Address / Town:", draft.villageTown),
              _buildRow("District:", draft.districtName),
              _buildRow("Phone Number:", draft.phone),
              _buildRow("Email Address:", draft.email.isNotEmpty ? draft.email : 'N/A'),
              pw.SizedBox(height: 10),

              // Section 3: Case & Grievance
              _buildSectionTitle("3. CASE & GRIEVANCE DETAILS"),
              _buildRow("Case Type:", draft.caseTypeName ?? 'N/A'),
              _buildRow("Summary of Case:", draft.summaryOfGrievance),
              if (draft.reliefSought.isNotEmpty) _buildRow("Relief Sought:", draft.reliefSought),
              pw.SizedBox(height: 10),

              // Section 4: Witnesses
              _buildSectionTitle("4. WITNESSES"),
              _buildRow("Witness 1:", "${draft.witness1Name} (${draft.witness1Relation})"),
              _buildRow("Witness 2:", "${draft.witness2Name} (${draft.witness2Relation})"),
              pw.SizedBox(height: 10),

              // Section 5: Documents Attached
              _buildSectionTitle("5. ATTACHED DOCUMENTS"),
              ...draft.documentStoragePaths.keys.map((code) => pw.Bullet(text: "Verified Document Upload: $code")),
              pw.SizedBox(height: 20),

              // Declaration & Signature Box
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("DECLARATION", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "I hereby declare that all particulars stated above are true to the best of my knowledge and belief. I agree to abide by the provisions of the Legal Services Authorities Act, 1987.",
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 24),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("Date: ${DateTime.now().toString().split(' ')[0]}", style: const pw.TextStyle(fontSize: 9)),
                        pw.Text("Signature / Thumb Impression of Applicant", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static String _determineFormCode(String? catCode, String? caseCode) {
    if (catCode == 'CAT_WOMEN') return 'A';
    if (catCode == 'CAT_SC_ST') return 'B';
    if (caseCode == 'CT_CRIMINAL_DEFENSE') return 'C';
    return 'D'; // Generic Form
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(title, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
    );
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 140, child: pw.Text(label, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
          pw.Expanded(child: pw.Text(value.isNotEmpty ? value : 'N/A', style: const pw.TextStyle(fontSize: 9))),
        ],
      ),
    );
  }
}
