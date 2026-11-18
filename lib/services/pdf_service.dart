import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/user.dart';
import '../models/achievement.dart';
import '../providers/energy_provider.dart';
import '../providers/water_provider.dart';
import '../providers/gamification_provider.dart';

class PdfService {
  PdfService._({required pw.Font regular, required pw.Font bold})
      : _r = regular,
        _b = bold;

  final pw.Font _r;
  final pw.Font _b;

  static const double _kWhRate   = 2.5;
  static const double _literRate = 0.05;

  // WattBeaver palette
  static final _darkGreen = PdfColor(49 / 255, 114 / 255, 86 / 255);
  static final _green     = PdfColor(82 / 255, 191 / 255, 144 / 255);
  static final _blue      = PdfColor(74 / 255, 184 / 255, 224 / 255);
  static final _purple    = PdfColor(155 / 255, 121 / 255, 255 / 255);
  static final _orange    = PdfColor(255 / 255, 143 / 255, 94 / 255);
  static final _cream     = PdfColor(236 / 255, 224 / 255, 209 / 255);
  static final _brown     = PdfColor(56 / 255, 34 / 255, 15 / 255);
  static final _grey      = PdfColor(150 / 255, 114 / 255, 89 / 255);

  // ── Public entry point ──────────────────────────────────────────────────────

  static Future<Uint8List> generateAccountStatement({
    required User user,
    required EnergyProvider energy,
    required WaterProvider water,
    required GamificationProvider gamification,
  }) async {
    final regular = await PdfGoogleFonts.notoSansRegular();
    final bold    = await PdfGoogleFonts.notoSansBold();
    final svc     = PdfService._(regular: regular, bold: bold);
    return svc._build(user: user, energy: energy, water: water, gamification: gamification);
  }

  // ── Private builder ─────────────────────────────────────────────────────────

  Future<Uint8List> _build({
    required User user,
    required EnergyProvider energy,
    required WaterProvider water,
    required GamificationProvider gamification,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    final totalKwh    = energy.history?.weekTotal ?? 0;
    final totalLiters = water.history?.weekTotal ?? 0;
    final energyCost  = totalKwh * _kWhRate;
    final waterCost   = totalLiters * _literRate;
    final totalCost   = energyCost + waterCost;

    final completedAchievements =
        gamification.achievements.where((a) => a.isCompleted).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          _header(),
          pw.SizedBox(height: 20),
          _userInfo(user, now),
          pw.SizedBox(height: 16),
          _section(
            title: 'ENERGÍA — Últimos 30 días',
            color: _green,
            rows: [
              _row('Consumo acumulado', '${totalKwh.toStringAsFixed(3)} kWh'),
              _row('Potencia promedio', '${(energy.history?.weekAvg ?? 0).toStringAsFixed(1)} W'),
              _row('Costo estimado', '\$${energyCost.toStringAsFixed(2)} MXN'),
              _row('Tarifa aplicada', '\$${_kWhRate.toStringAsFixed(2)}/kWh'),
              _row('Dispositivos', '${energy.summary?.deviceCount ?? 0} (${energy.summary?.onlineDevices ?? 0} en línea)'),
            ],
          ),
          pw.SizedBox(height: 10),
          _section(
            title: 'AGUA — Últimos 30 días',
            color: _blue,
            rows: [
              _row('Consumo acumulado', '${totalLiters.toStringAsFixed(2)} L'),
              _row('Flujo promedio', '${(water.history?.weekAvg ?? 0).toStringAsFixed(2)} L/min'),
              _row('Costo estimado', '\$${waterCost.toStringAsFixed(2)} MXN'),
              _row('Tarifa aplicada', '\$${_literRate.toStringAsFixed(2)}/L'),
              _row('Sensores', '${water.summary?.sensorCount ?? 0} (${water.summary?.onlineSensors ?? 0} en línea)'),
            ],
          ),
          pw.SizedBox(height: 14),
          _totalBox(totalCost),
          pw.SizedBox(height: 20),
          if (gamification.profile != null)
            _section(
              title: 'GAMIFICACIÓN',
              color: _purple,
              rows: [
                _row('Nivel actual', 'Nivel ${gamification.profile!.currentLevel}'),
                _row('Puntos totales', '${gamification.profile!.totalPoints} pts'),
                _row('Racha actual', '${gamification.profile!.currentStreak} días'),
                _row('Mejor racha', '${gamification.profile!.bestStreak} días'),
                _row('Ranking global', gamification.profile!.rank > 0 ? '#${gamification.profile!.rank}' : 'Sin ranking'),
              ],
            ),
          if (completedAchievements.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            _achievementsTable(completedAchievements),
          ],
          pw.SizedBox(height: 28),
          _footer(now),
        ],
      ),
    );

    return pdf.save();
  }

  // ── Widget builders ─────────────────────────────────────────────────────────

  pw.Widget _header() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: pw.BoxDecoration(
        color: _darkGreen,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('WattBeaver',
              style: pw.TextStyle(font: _b, color: PdfColors.white, fontSize: 26)),
          pw.SizedBox(height: 4),
          pw.Text('Estado de Cuenta',
              style: pw.TextStyle(font: _r, color: _cream, fontSize: 12)),
        ],
      ),
    );
  }

  pw.Widget _userInfo(User user, DateTime now) {
    final date =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _cream, width: 1.5),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('DATOS DEL TITULAR',
              style: pw.TextStyle(
                  font: _b, fontSize: 9, color: _grey, letterSpacing: 0.8)),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _labelValue('Nombre', user.name),
                  pw.SizedBox(height: 4),
                  _labelValue('Correo', user.email),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  _labelValue('Fecha de emisión', date),
                  pw.SizedBox(height: 4),
                  _labelValue('Período', 'Últimos 30 días'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _labelValue(String label, String value) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(text: '$label: ',
              style: pw.TextStyle(font: _r, fontSize: 10, color: _grey)),
          pw.TextSpan(text: value,
              style: pw.TextStyle(font: _b, fontSize: 10, color: _brown)),
        ],
      ),
    );
  }

  pw.Widget _section({
    required String title,
    required PdfColor color,
    required List<pw.TableRow> rows,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(6),
              topRight: pw.Radius.circular(6),
            ),
          ),
          child: pw.Text(title,
              style: pw.TextStyle(
                  font: _b, color: PdfColors.white, fontSize: 10, letterSpacing: 0.5)),
        ),
        pw.Table(
          border: pw.TableBorder.all(color: _cream, width: 1),
          columnWidths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(1),
          },
          children: rows,
        ),
      ],
    );
  }

  pw.TableRow _row(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label,
              style: pw.TextStyle(font: _r, fontSize: 10, color: _brown)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value,
              style: pw.TextStyle(font: _b, fontSize: 10, color: _brown),
              textAlign: pw.TextAlign.right),
        ),
      ],
    );
  }

  pw.Widget _totalBox(double total) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: pw.BoxDecoration(
        color: _darkGreen,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('TOTAL ESTIMADO',
              style: pw.TextStyle(
                  font: _b, color: PdfColors.white, fontSize: 13, letterSpacing: 0.6)),
          pw.Text('\$${total.toStringAsFixed(2)} MXN',
              style: pw.TextStyle(font: _b, color: PdfColors.white, fontSize: 18)),
        ],
      ),
    );
  }

  pw.Widget _achievementsTable(List<Achievement> achievements) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: pw.BoxDecoration(
            color: _orange,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(6),
              topRight: pw.Radius.circular(6),
            ),
          ),
          child: pw.Text('LOGROS COMPLETADOS (${achievements.length})',
              style: pw.TextStyle(
                  font: _b, color: PdfColors.white, fontSize: 10, letterSpacing: 0.5)),
        ),
        pw.Table(
          border: pw.TableBorder.all(color: _cream, width: 1),
          columnWidths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(3),
            2: pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: _cream),
              children: [
                _headerCell('Logro'),
                _headerCell('Descripción'),
                _headerCell('Pts', align: pw.TextAlign.right),
              ],
            ),
            ...achievements.map((a) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(7),
                  child: pw.Text(a.name,
                      style: pw.TextStyle(font: _r, fontSize: 9, color: _brown)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(7),
                  child: pw.Text(a.description,
                      style: pw.TextStyle(font: _r, fontSize: 9, color: _grey)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(7),
                  child: pw.Text('${a.points}',
                      style: pw.TextStyle(font: _b, fontSize: 9, color: _purple),
                      textAlign: pw.TextAlign.right),
                ),
              ],
            )),
          ],
        ),
      ],
    );
  }

  pw.Widget _headerCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(7),
      child: pw.Text(text,
          style: pw.TextStyle(font: _b, fontSize: 9, color: _brown),
          textAlign: align),
    );
  }

  pw.Widget _footer(DateTime now) {
    final date =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    return pw.Center(
      child: pw.Text('Generado por WattBeaver · $date',
          style: pw.TextStyle(font: _r, fontSize: 9, color: _grey)),
    );
  }
}
