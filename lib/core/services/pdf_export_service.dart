import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/tasks/models/task_model.dart';
import '../../features/tasks/models/task_category.dart';

class PdfExportService {
  static Future<void> exportProgressReport({
    required String userName,
    required int currentStreak,
    required int longestStreak,
    required int totalXp,
    required int level,
    required List<TaskModel> allTasks,
  }) async {
    final pdf = pw.Document();

    final completedTasks = allTasks.where((t) => t.isCompleted).toList();
    final completionRate = allTasks.isEmpty
        ? 0
        : ((completedTasks.length / allTasks.length) * 100).round();

    final dateFormat = DateFormat('MMMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    // Category breakdown
    final categoryStats = <TaskCategory, int>{};
    for (final cat in TaskCategory.values) {
      categoryStats[cat] = completedTasks.where((t) => t.category == cat).length;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Discipline Tracker',
                      style: const pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green700,
                      ),
                    ),
                    pw.Text(
                      'Personal Consistency & Progress Report',
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Date: ${dateFormat.format(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                    ),
                    pw.Text(
                      'User: $userName',
                      style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1.5, color: PdfColors.green600),
            pw.SizedBox(height: 16),

            // Performance KPI Cards
            pw.Text(
              'Performance Summary',
              style: const pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              children: [
                _buildKpiBox('Current Streak', '$currentStreak Days', PdfColors.orange700),
                pw.SizedBox(width: 12),
                _buildKpiBox('Longest Streak', '$longestStreak Days', PdfColors.amber800),
                pw.SizedBox(width: 12),
                _buildKpiBox('Completion Rate', '$completionRate%', PdfColors.green800),
                pw.SizedBox(width: 12),
                _buildKpiBox('Discipline Level', 'Lvl $level ($totalXp XP)', PdfColors.indigo700),
              ],
            ),
            pw.SizedBox(height: 20),

            // Category Breakdown Table
            pw.Text(
              'Category Breakdown (Completed Tasks)',
              style: const pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableCell('Category', isHeader: true),
                    _tableCell('Completed Tasks', isHeader: true),
                    _tableCell('Share of Total', isHeader: true),
                  ],
                ),
                ...categoryStats.entries.map((entry) {
                  final share = completedTasks.isEmpty
                      ? '0%'
                      : '${((entry.value / completedTasks.length) * 100).toStringAsFixed(1)}%';
                  return pw.TableRow(
                    children: [
                      _tableCell(entry.key.displayName),
                      _tableCell('${entry.value}'),
                      _tableCell(share),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 24),

            // Recent Completed Tasks
            pw.Text(
              'Recent Completed Accomplishments (Top 20)',
              style: const pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableCell('Task Title', isHeader: true),
                    _tableCell('Category', isHeader: true),
                    _tableCell('Priority', isHeader: true),
                    _tableCell('Completed On', isHeader: true),
                  ],
                ),
                ...completedTasks.take(20).map((task) {
                  final completedStr = task.completedAt != null
                      ? '${dateFormat.format(task.completedAt!)} ${timeFormat.format(task.completedAt!)}'
                      : 'Completed';
                  return pw.TableRow(
                    children: [
                      _tableCell(task.title),
                      _tableCell(task.category.displayName),
                      _tableCell(task.priority.displayName),
                      _tableCell(completedStr),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 20),

            // Footer
            pw.Center(
              child: pw.Text(
                '“Small disciplines repeated with consistency every day lead to great achievements.”',
                style: const pw.TextStyle(
                  fontSize: 10,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.grey700,
                ),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Discipline_Tracker_Report_${userName.replaceAll(' ', '_')}.pdf',
    );
  }

  static pw.Widget _buildKpiBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color, width: 1.5),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
