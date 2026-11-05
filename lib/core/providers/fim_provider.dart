import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ipc/ipc_client.dart';
import '../models/ipc_contract.dart';
import 'engine_provider.dart';

class FimState {
  final bool isLoading;
  final List<FimTargetItem> targets;
  final List<FimChangeEvent> recentChanges;
  final bool isMonitoring;
  final String? errorMessage;
  final DateTime lastRefreshed;

  const FimState({
    this.isLoading = false,
    this.targets = const [],
    this.recentChanges = const [],
    this.isMonitoring = true,
    this.errorMessage,
    required this.lastRefreshed,
  });

  factory FimState.initial() => FimState(
        isLoading: true,
        lastRefreshed: DateTime.now(),
      );

  FimState copyWith({
    bool? isLoading,
    List<FimTargetItem>? targets,
    List<FimChangeEvent>? recentChanges,
    bool? isMonitoring,
    String? errorMessage,
    DateTime? lastRefreshed,
  }) {
    return FimState(
      isLoading: isLoading ?? this.isLoading,
      targets: targets ?? this.targets,
      recentChanges: recentChanges ?? this.recentChanges,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      errorMessage: errorMessage ?? this.errorMessage,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
    );
  }
}

final fimProvider = NotifierProvider<FimNotifier, FimState>(FimNotifier.new);

class FimNotifier extends Notifier<FimState> {
  final IpcClient _client = IpcClient();

  @override
  FimState build() {
    ref.listen(engineProvider, (previous, next) {
      if (next.status.name == 'connected' && (previous?.status.name != 'connected' || state.targets.isEmpty)) {
        refresh();
      }
    });

    Future.microtask(() => refresh());
    return FimState.initial();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final resp = await _client.sendRequest<FimSnapshot>(
        'get_fim_snapshot',
        {},
        fromData: (json) => FimSnapshot.fromJson(Map<String, dynamic>.from(json as Map)),
      );

      state = state.copyWith(
        isLoading: false,
        targets: resp.data?.targets ?? [],
        recentChanges: resp.data?.recentChanges ?? [],
        isMonitoring: resp.data?.isMonitoring ?? true,
        errorMessage: null,
        lastRefreshed: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to retrieve FIM snapshot: $e',
        lastRefreshed: DateTime.now(),
      );
    }
  }

  Future<bool> addTarget(String filePath, String label) async {
    try {
      await _client.sendRequest<Map<String, dynamic>>(
        'add_fim_target',
        {'filePath': filePath, 'label': label},
      );
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to add FIM target: $e');
      return false;
    }
  }

  Future<void> removeTarget(String targetId) async {
    try {
      await _client.sendRequest<Map<String, dynamic>>(
        'remove_fim_target',
        {'targetId': targetId},
      );
      await refresh();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to remove target: $e');
    }
  }

  Future<void> verifyTarget(String targetId) async {
    try {
      await _client.sendRequest<Map<String, dynamic>>(
        'verify_fim_target',
        {'targetId': targetId},
      );
      await refresh();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Target verification failed: $e');
    }
  }

  Future<void> verifyAll() async {
    state = state.copyWith(isLoading: true);
    try {
      await _client.sendRequest<List<dynamic>>(
        'verify_all_fim_targets',
        {},
      );
      await refresh();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Verification scan failed: $e');
    }
  }

  Future<void> resetBaseline(String targetId) async {
    try {
      await _client.sendRequest<Map<String, dynamic>>(
        'reset_fim_baseline',
        {'targetId': targetId},
      );
      await refresh();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Baseline reset failed: $e');
    }
  }
}

