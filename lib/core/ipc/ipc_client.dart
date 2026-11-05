import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/ipc_contract.dart';

class IpcClient {
  static final IpcClient _instance = IpcClient._internal();
  factory IpcClient() => _instance;
  IpcClient._internal();

  final HttpClient _httpClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 3);

  final Uuid _uuid = const Uuid();
  SessionMetadata? _cachedSession;
  Process? engineProcess;

  Future<SessionMetadata?> loadSession() async {
    try {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData == null) return null;

      final sessionFile = File('$localAppData\\SentinelX\\session.json');
      if (await sessionFile.exists()) {
        final content = await sessionFile.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        _cachedSession = SessionMetadata.fromJson(json);
        return _cachedSession;
      }
    } catch (e) {
      debugPrint('[IpcClient] Failed to load session metadata: $e');
    }
    return null;
  }

  Future<bool> ensureEngineRunning() async {
    final session = await loadSession();
    if (session != null) {
      // Test if active
      final pingOk = await ping();
      if (pingOk) return true;
    }

    // Try starting engine if binary exists locally
    try {
      final exeCandidates = [
        'SentinelX.Engine\\bin\\Release\\SentinelX.Engine.exe',
        'SentinelX.Engine\\bin\\Debug\\SentinelX.Engine.exe',
        'engine\\SentinelX.Engine.exe',
      ];

      for (final relPath in exeCandidates) {
        final file = File(relPath);
        if (await file.exists()) {
          debugPrint('[IpcClient] Launching native engine: ${file.absolute.path}');
          engineProcess = await Process.start(
            file.absolute.path,
            [],
            mode: ProcessStartMode.detached,
          );
          // Wait for session.json to be created
          for (int i = 0; i < 15; i++) {
            await Future.delayed(const Duration(milliseconds: 300));
            final s = await loadSession();
            if (s != null) {
              final ok = await ping();
              if (ok) return true;
            }
          }
          break;
        }
      }
    } catch (e) {
      debugPrint('[IpcClient] Could not spawn engine automatically: $e');
    }

    return false;
  }

  Future<bool> ping() async {
    try {
      final resp = await sendRequest<Map<String, dynamic>>('ping', {});
      return resp.isSuccess;
    } catch (_) {
      return false;
    }
  }

  Future<EngineHealthData> getHealth() async {
    final resp = await sendRequest<EngineHealthData>(
      'health',
      {},
      fromData: (json) => EngineHealthData.fromJson(Map<String, dynamic>.from(json as Map)),
    );

    if (resp.isSuccess && resp.data != null) {
      return resp.data!;
    }

    if (resp.error != null) {
      throw Exception('${resp.error!.errorCode}: ${resp.error!.safeMessage}');
    }

    throw Exception('Engine did not return health data.');
  }

  Future<IpcResponse<T>> sendRequest<T>(
    String action,
    Map<String, dynamic> parameters, {
    T Function(dynamic)? fromData,
    Duration timeout = const Duration(seconds: 4),
  }) async {
    var session = _cachedSession;
    if (session == null) {
      session = await loadSession();
      if (session == null) {
        throw Exception('ENGINE_OFFLINE: No active engine session found.');
      }
    }

    final requestId = _uuid.v4();
    final request = IpcRequest(
      contractVersion: IpcContractConstants.version,
      requestId: requestId,
      action: action,
      timestampUtc: DateTime.now().toUtc().toIso8601String(),
      parameters: parameters,
    );

    final uri = Uri.parse('http://127.0.0.1:${session.port}/');

    try {
      final httpRequest = await _httpClient.postUrl(uri).timeout(timeout);
      httpRequest.headers.set('Content-Type', 'application/json; charset=utf-8');
      httpRequest.headers.set('X-SentinelX-Token', session.token);

      final payload = jsonEncode(request.toJson());
      httpRequest.write(payload);

      final httpResponse = await httpRequest.close().timeout(timeout);
      final responseBody = await utf8.decodeStream(httpResponse).timeout(timeout);

      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      final parsed = IpcResponse.fromJson(json, fromData);

      // Verify contract version
      if (parsed.contractVersion != IpcContractConstants.version) {
        throw Exception('CONTRACT_MISMATCH: Engine version ${parsed.contractVersion} differs from UI ${IpcContractConstants.version}');
      }

      return parsed;
    } on TimeoutException {
      throw Exception('TIMEOUT: Engine request timed out after ${timeout.inSeconds}s.');
    } on SocketException catch (e) {
      _cachedSession = null; // Invalidate cached session
      throw Exception('SOCKET_ERROR: Unable to connect to engine at 127.0.0.1:${session.port} (${e.message})');
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
