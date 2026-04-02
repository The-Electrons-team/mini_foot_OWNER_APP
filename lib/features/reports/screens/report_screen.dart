import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../revenues/controllers/revenues_controller.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Screen de génération et prévisualisation du rapport PDF
// ══════════════════════════════════════════════════════════════════════════════

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isGenerating = false;
  Uint8List? _pdfBytes;

  // Données passées par Get.arguments depuis RevenuesScreen
  late final Map<String, dynamic> _args;

  @override
  void initState() {
    super.initState();
    _args = Get.arguments as Map<String, dynamic>? ?? {};
    _generatePdf();
  }

  // ── Génération du PDF ────────────────────────────────────────────────────────
  Future<void> _generatePdf() async {
    setState(() => _isGenerating = true);

    final pdf = pw.Document();
    final period      = _args['period'] as String? ?? 'Inconnu';
    final totalRevenue  = _args['totalRevenue'] as int? ?? 0;
    final totalBookings = _args['totalBookings'] as int? ?? 0;
    final occupancy     = _args['occupancy'] as String? ?? '0%';
    final entries       = _args['entries'] as List<RevenueEntry>? ?? [];

    // Couleurs PDF
    const green  = PdfColor.fromInt(0xFF006F39);
    const gold   = PdfColor.fromInt(0xFFF59E0B);
    const bgCard = PdfColor.fromInt(0xFFF8F8F8);
    const textSub = PdfColor.fromInt(0xFF6B7280);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // ── En-tête ─────────────────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: const pw.BoxDecoration(
              color: green,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(16)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MiniFoot Owner',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Rapport de revenus — $period',
                      style: const pw.TextStyle(
                        fontSize: 13,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      _formatDate(DateTime.now()),
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Propriétaire : Mamadou Sy',
                      style: const pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          // ── KPI résumé ───────────────────────────────────────────────────────
          pw.Row(
            children: [
              _pdfKpiCard('Revenus totaux', '${_formatAmountFull(totalRevenue)} F CFA', green),
              pw.SizedBox(width: 12),
              _pdfKpiCard('Réservations', '$totalBookings', PdfColor.fromInt(0xFF1565C0)),
              pw.SizedBox(width: 12),
              _pdfKpiCard('Taux moyen', occupancy, gold),
            ],
          ),

          pw.SizedBox(height: 24),

          // ── Tableau des données ──────────────────────────────────────────────
          pw.Text(
            'Détail par période',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 12),

          pw.TableHelper.fromTextArray(
            headers: ['Période', 'Revenus (F CFA)', 'Réservations', "Taux d'occupation"],
            data: entries.map((e) => [
              e.label,
              _formatAmountFull(e.amount),
              '${e.bookings}',
              '${(e.occupancy * 100).round()}%',
            ]).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 11,
            ),
            headerDecoration: const pw.BoxDecoration(color: green),
            cellStyle: const pw.TextStyle(fontSize: 11),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
            },
            rowDecoration: const pw.BoxDecoration(color: bgCard),
            oddRowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            border: pw.TableBorder.all(color: PdfColor.fromInt(0xFFE5E0D8), width: 0.5),
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),

          pw.SizedBox(height: 24),

          // ── Observations ─────────────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFE8F5E9),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
              border: pw.Border.all(color: PdfColor.fromInt(0xFFB2DFDB), width: 0.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Observations',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 13,
                    color: green,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '• Le taux d\'occupation moyen de $occupancy indique une bonne performance opérationnelle.\n'
                  '• Les revenus totaux de ${_formatAmountFull(totalRevenue)} F CFA pour la période "$period" sont en hausse de +12% vs la période précédente.\n'
                  '• Les week-ends génèrent en moyenne 40% des revenus hebdomadaires.',
                  style: const pw.TextStyle(fontSize: 11, color: textSub),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // ── Pied de page ──────────────────────────────────────────────────────
          pw.Divider(color: PdfColor.fromInt(0xFFE5E0D8)),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Généré par MiniFoot Owner App',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
              ),
              pw.Text(
                _formatDate(DateTime.now()),
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
              ),
            ],
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    if (mounted) {
      setState(() {
        _pdfBytes = bytes;
        _isGenerating = false;
      });
    }
  }

  pw.Widget _pdfKpiCard(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
          border: pw.Border.all(color: PdfColor.fromInt(0xFFE5E0D8), width: 0.5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Partager le PDF ──────────────────────────────────────────────────────────
  Future<void> _sharePdf() async {
    if (_pdfBytes == null) return;
    HapticFeedback.mediumImpact();
    final dir  = await getTemporaryDirectory();
    final file = File('${dir.path}/rapport_minifoot.pdf');
    await file.writeAsBytes(_pdfBytes!);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Rapport de revenus MiniFoot Owner',
      ),
    );
  }

  // ── Imprimer le PDF ──────────────────────────────────────────────────────────
  Future<void> _printPdf() async {
    if (_pdfBytes == null) return;
    HapticFeedback.mediumImpact();
    await Printing.layoutPdf(onLayout: (_) async => _pdfBytes!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBgCard,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextPrim, size: 18),
        ),
        title: const Text(
          'Rapport PDF',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: kTextPrim,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_pdfBytes != null) ...[
            IconButton(
              onPressed: _sharePdf,
              icon: const Icon(Icons.share_rounded, color: kGreen, size: 22),
              tooltip: 'Partager',
            ),
            IconButton(
              onPressed: _printPdf,
              icon: const Icon(Icons.print_rounded, color: kGreen, size: 22),
              tooltip: 'Imprimer',
            ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kDivider),
        ),
      ),
      body: _isGenerating
          ? _buildLoadingState()
          : _pdfBytes != null
              ? _buildPdfPreview()
              : _buildErrorState(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: kGreenLight,
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                color: kGreen,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Génération du rapport…',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kTextPrim,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Veuillez patienter',
            style: TextStyle(fontSize: 13, color: kTextSub),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfPreview() {
    return Column(
      children: [
        // Barre d'actions en bas
        Expanded(
          child: PdfPreview(
            build: (_) async => _pdfBytes!,
            allowPrinting: true,
            allowSharing: true,
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
            pdfPreviewPageDecoration: BoxDecoration(
              color: Colors.white,
              boxShadow: kCardShadow,
            ),
          ),
        ),
        // Boutons d'action bas d'écran
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: kBgCard,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _printPdf,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kBorder),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.print_rounded, color: kGreen, size: 20),
                    label: const Text(
                      'Imprimer',
                      style: TextStyle(color: kGreen, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sharePdf,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.share_rounded, size: 20),
                    label: const Text(
                      'Partager',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: kRed),
          const SizedBox(height: 16),
          const Text('Erreur de génération', style: TextStyle(fontSize: 16, color: kTextPrim)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _generatePdf,
            style: ElevatedButton.styleFrom(backgroundColor: kGreen),
            child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatAmountFull(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
