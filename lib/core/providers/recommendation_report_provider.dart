import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ipc/ipc_client.dart';
import '../models/ipc_contract.dart';
import 'engine_provider.dart';

class RecommendationReportState {
  final bool isLoading;
  final bool isExporting;
  final List<SecurityRecommendationItem> recommendations;
  final SystemReportData? lastGeneratedReport;
  final String? lastExportedPath;
  final String? errorMessage;
  final String? successMessage;
  final DateTime lastRefreshed;

  const RecommendationReportState({
    this.isLoading = false,
    this.isExporting = false,
    this.recommendations = const [],
    this.lastGeneratedReport,
    this.lastExportedPath,
    this.errorMessage,
    this.successMessage,
    required this.lastRefreshed,
  });

  factory RecommendationReportState.initial() => RecommendationReportState(
        isLoading: true,
        lastRefreshed: DateTime.now(),
      );

  RecommendationReportState copyWith({
    bool? isLoading,
    bool? isExporting,
    List<SecurityRecommendationItem>? recommendations,
    SystemReportData? lastGeneratedReport,
    String? lastExportedPath,
    String? errorMessage,
    String? successMessage,
    DateTime? lastRefreshed,
  }) {
    return RecommendationReportState(
      isLoading: isLoading ?? this.isLoading,
      isExporting: isExporting ?? this.isExporting,
      recommendations: recommendations ?? this.recommendations,
      lastGeneratedReport: lastGeneratedReport ?? this.lastGeneratedReport,
      lastExportedPath: lastExportedPath ?? this.lastExportedPath,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
    );
  }
}

final recommendationReportProvider = NotifierProvider<RecommendationReportNotifier, RecommendationReportState>(
  RecommendationReportNotifier.new,
);

class RecommendationReportNotifier extends Notifier<RecommendationReportState> {
  final IpcClient _client = IpcClient();

  @override
  RecommendationReportState build() {
    ref.listen(engineProvider, (previous, next) {
      if (next.status.name == 'connected' && (previous?.status.name != 'connected' || state.recommendations.isEmpty)) {
        refreshAll();
      }
    });

    Future.microtask(() => refreshAll());
    return RecommendationReportState.initial();
  }

  Future<void> refreshAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);

    try {
      final recResp = await _client.sendRequest<List<SecurityRecommendationItem>>(
        'get_recommendations',
        {},
        fromData: (json) => (json as List)
            .map((e) => SecurityRecommendationItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

      state = state.copyWith(
        isLoading: false,
        recommendations: recResp.data ?? [],
        errorMessage: null,
        lastRefreshed: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to evaluate recommendations: $e',
        lastRefreshed: DateTime.now(),
      );
    }
  }

  Future<void> generateReport() async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);

    try {
      final repResp = await _client.sendRequest<SystemReportData>(
        'generate_system_report',
        {},
        fromData: (json) => SystemReportData.fromJson(Map<String, dynamic>.from(json as Map)),
      );

      state = state.copyWith(
        isLoading: false,
        lastGeneratedReport: repResp.data,
        successMessage: 'System posture audit report generated successfully.',
        lastRefreshed: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to build system report: $e',
        lastRefreshed: DateTime.now(),
      );
    }
  }

  Future<String?> exportReport(String format) async {
    state = state.copyWith(isExporting: true, errorMessage: null, successMessage: null);

    try {
      final exportResp = await _client.sendRequest<Map<String, dynamic>>(
        'export_report',
        {'format': format},
      );

      final path = exportResp.data?['filePath']?.toString();
      state = state.copyWith(
        isExporting: false,
        lastExportedPath: path,
        successMessage: 'Report exported to $path',
        lastRefreshed: DateTime.now(),
      );
      return path;
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        errorMessage: 'Export failed: $e',
        lastRefreshed: DateTime.now(),
      );
      return null;
    }
  }
}

