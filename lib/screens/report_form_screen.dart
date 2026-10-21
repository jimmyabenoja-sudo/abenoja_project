import 'package:flutter/material.dart';

import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

/// The four essential asynchronous UI responses required by Activity 9,
/// plus the initial [idle] state before anything is submitted.
enum ReportUiState { idle, loading, success, empty, error }

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  static const Color _teal = Color(0xFF00897B);
  static const Color _tealDark = Color(0xFF00695C);
  static const Color _tealTint = Color(0xFFE0F2F1);

  static const List<String> _categories = <String>[
    'Incident Report',
    'Travel Event',
    'Document Problem',
    'Other',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  /// Records created during this session. Starts empty, which is how the
  /// EMPTY state is reproduced before any report is filed.
  final List<_SubmittedReport> _reports = <_SubmittedReport>[];

  ReportUiState _uiState = ReportUiState.idle;
  String? _category;
  String _errorMessage = '';

  /// Demo switch: when on, the simulated submission fails so the ERROR
  /// state and its Retry action can be demonstrated on demand.
  bool _simulateFailure = false;

  bool get _submitting => _uiState == ReportUiState.loading;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Simulated asynchronous submission. A [Future.delayed] stands in for the
  /// future REST API call until the backend is connected in later activities.
  Future<void> submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _uiState = ReportUiState.loading);

    try {
      await Future<void>.delayed(const Duration(seconds: 3));
      if (_simulateFailure) {
        throw Exception('Simulated network failure. Please try again.');
      }
      if (!mounted) return;
      setState(() {
        _reports.insert(
          0,
          _SubmittedReport(
            title: _titleController.text.trim(),
            category: _category ?? 'Other',
            location: _locationController.text.trim(),
            description: _descriptionController.text.trim(),
          ),
        );
        _uiState = ReportUiState.success;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _uiState = ReportUiState.error;
      });
    }
  }

  void _resetToForm() {
    setState(() {
      _formKey.currentState?.reset();
      _titleController.clear();
      _locationController.clear();
      _descriptionController.clear();
      _category = null;
      _uiState = ReportUiState.idle;
    });
  }

  void _previewReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _reports.isEmpty
              ? 'No reports yet — file your first report above.'
              : '${_reports.length} report(s) available below.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      appBar: AppBar(
        title: const Text(
          'Report Form',
          style: TextStyle(color: _tealDark, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _tealDark,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildFormCard(),
                const SizedBox(height: 16),
                _buildReportsPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _tealTint,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit an OIGE Report',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _tealDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Report a recent travel event, document problem, or incident '
              'related to international movement monitoring.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      );

  Widget _buildFormCard() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: switch (_uiState) {
          ReportUiState.idle ||
          ReportUiState.loading ||
          ReportUiState.empty =>
            _buildForm(),
          ReportUiState.success => _buildSuccessView(),
          ReportUiState.error => _buildErrorView(),
        },
      );

  Widget _buildForm() => Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Report Details',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Report Title',
              hint: 'e.g. Lost baggage at the airport',
              controller: _titleController,
              prefixIcon: Icons.title,
              enabled: !_submitting,
              validator: (String? value) {
                final String text = value?.trim() ?? '';
                if (text.isEmpty) return 'Report title is required.';
                if (text.length < 5) return 'Use at least 5 characters.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(
                labelText: 'Category',
                hintText: 'Incident Report',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.category_outlined),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              items: _categories
                  .map((String c) => DropdownMenuItem<String>(
                        value: c,
                        child: Text(c, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged:
                  _submitting ? null : (String? value) => setState(() => _category = value),
              validator: (String? value) =>
                  value == null ? 'Please select a category.' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Destination / Location',
              hint: 'e.g. Narita International Airport, Japan',
              controller: _locationController,
              prefixIcon: Icons.public,
              enabled: !_submitting,
              validator: (String? value) {
                final String text = value?.trim() ?? '';
                if (text.isEmpty) return 'Destination is required.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Description',
              hint: 'Describe the event, problem, or incident...',
              controller: _descriptionController,
              prefixIcon: Icons.description_outlined,
              maxLines: 4,
              enabled: !_submitting,
              validator: (String? value) {
                final String text = value?.trim() ?? '';
                if (text.isEmpty) return 'Description is required.';
                if (text.length < 10) return 'Provide at least 10 characters.';
                return null;
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: _submitting ? 'Submitting...' : 'Submit Report',
                    icon: _submitting ? null : Icons.send_outlined,
                    busy: _submitting,
                    colors: const <Color>[Color(0xFF26A69A), _teal],
                    onPressed: _submitting ? null : submitReport,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _submitting ? null : _previewReports,
                    icon: const Icon(Icons.list_alt_outlined, size: 18),
                    label: const Text('Preview Reports'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _tealDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: _teal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_submitting) ...[
              const SizedBox(height: 16),
              _buildSubmittingPanel(),
            ],
            const Divider(height: 32),
            Material(
              color: Colors.white,
              child: SwitchListTile.adaptive(
                value: _simulateFailure,
                onChanged: _submitting
                    ? null
                    : (bool value) => setState(() => _simulateFailure = value),
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Simulate failure (demo)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Turn on to demonstrate the Error state, then use Retry.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildSubmittingPanel() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: _teal,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Submitting report',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sending your report to the OIGE office...',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Please wait — duplicate submissions are disabled.',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildSuccessView() {
    final _SubmittedReport report = _reports.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Color(0xFF2E7D32), size: 40),
              const SizedBox(height: 8),
              const Text(
                'Report Submitted Successfully',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Your report has been recorded (simulated). '
                'Reference #: RPT-${_reports.length.toString().padLeft(4, '0')}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _detailRow('Title', report.title),
        _detailRow('Category', report.category),
        _detailRow('Destination', report.location),
        _detailRow('Description', report.description),
        const SizedBox(height: 20),
        AppButton(
          label: 'File Another Report',
          icon: Icons.add,
          colors: const <Color>[Color(0xFF26A69A), _teal],
          onPressed: _resetToForm,
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _previewReports,
          icon: const Icon(Icons.list_alt_outlined, size: 18),
          label: const Text('Preview Reports'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _tealDark,
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: _teal),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 95,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600)),
            ),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
          ],
        ),
      );

  Widget _buildErrorView() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFC62828).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFC62828).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline,
                    color: Color(0xFFC62828), size: 40),
                const SizedBox(height: 8),
                const Text(
                  'Submission Failed',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your report was NOT saved. Check your connection '
                  'or correct the form, then try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Retry',
            icon: Icons.refresh,
            colors: const <Color>[Color(0xFF26A69A), _teal],
            onPressed: submitReport,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _resetToForm,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit Report'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _tealDark,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: _teal),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      );

  Widget _buildReportsPanel() {
    final bool isEmpty = _reports.isEmpty;

    return Container(
      key: const Key('reportsPanel'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isEmpty ? _buildEmptyView() : _buildReportList(),
    );
  }

  Widget _buildEmptyView() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Submitted Reports',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.inbox_outlined, size: 44, color: Colors.grey),
          const SizedBox(height: 10),
          const Text(
            'No reports yet',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          const Text(
            'You have not submitted any reports in this session. '
            'Fill out the form above to file your first report.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _resetToForm,
            icon: const Icon(Icons.edit_note, size: 18),
            label: const Text('File Your First Report'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _tealDark,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: _teal),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      );

  Widget _buildReportList() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Submitted Reports',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Text('${_reports.length} record(s)',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          for (final _SubmittedReport report in _reports)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.description_outlined,
                      size: 18, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(report.title,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('${report.category} • ${report.location}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
}

class _SubmittedReport {
  const _SubmittedReport({
    required this.title,
    required this.category,
    required this.location,
    required this.description,
  });

  final String title;
  final String category;
  final String location;
  final String description;
}
