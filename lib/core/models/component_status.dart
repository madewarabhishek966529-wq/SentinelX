import 'package:flutter/material.dart';
import '../theme/sentinel_colors.dart';

/// The 7 honest, mutually exclusive status values mandated by SentinelX PRD.
/// Missing data is NEVER mapped to "Safe" or "Enabled".
enum ComponentStatus {
  enabled,
  disabled,
  unknown,
  unsupported,
  accessDenied,
  error,
  stale;

  static ComponentStatus fromString(String? value) {
    if (value == null) return ComponentStatus.unknown;
    switch (value.toLowerCase().replaceAll('_', '')) {
      case 'enabled':
      case 'active':
      case 'running':
      case 'true':
        return ComponentStatus.enabled;
      case 'disabled':
      case 'inactive':
      case 'stopped':
      case 'false':
        return ComponentStatus.disabled;
      case 'unsupported':
      case 'notapplicable':
        return ComponentStatus.unsupported;
      case 'accessdenied':
      case 'permissiondenied':
        return ComponentStatus.accessDenied;
      case 'error':
      case 'failed':
        return ComponentStatus.error;
      case 'stale':
      case 'expired':
        return ComponentStatus.stale;
      case 'unknown':
      default:
        return ComponentStatus.unknown;
    }
  }

  String get label {
    switch (this) {
      case ComponentStatus.enabled:
        return 'Enabled';
      case ComponentStatus.disabled:
        return 'Disabled';
      case ComponentStatus.unknown:
        return 'Unknown';
      case ComponentStatus.unsupported:
        return 'Unsupported';
      case ComponentStatus.accessDenied:
        return 'Access Denied';
      case ComponentStatus.error:
        return 'Error';
      case ComponentStatus.stale:
        return 'Stale';
    }
  }

  Color get color {
    switch (this) {
      case ComponentStatus.enabled:
        return SentinelColors.statusEnabled;
      case ComponentStatus.disabled:
        return SentinelColors.statusDisabled;
      case ComponentStatus.unknown:
        return SentinelColors.statusUnknown;
      case ComponentStatus.unsupported:
        return SentinelColors.statusUnsupported;
      case ComponentStatus.accessDenied:
        return SentinelColors.statusAccessDenied;
      case ComponentStatus.error:
        return SentinelColors.statusError;
      case ComponentStatus.stale:
        return SentinelColors.statusStale;
    }
  }

  IconData get icon {
    switch (this) {
      case ComponentStatus.enabled:
        return Icons.check_circle_outline;
      case ComponentStatus.disabled:
        return Icons.remove_circle_outline;
      case ComponentStatus.unknown:
        return Icons.help_outline;
      case ComponentStatus.unsupported:
        return Icons.block;
      case ComponentStatus.accessDenied:
        return Icons.lock_outline;
      case ComponentStatus.error:
        return Icons.error_outline;
      case ComponentStatus.stale:
        return Icons.access_time;
    }
  }

  String get description {
    switch (this) {
      case ComponentStatus.enabled:
        return 'Protection is active and reporting normally.';
      case ComponentStatus.disabled:
        return 'Protection is explicitly disabled.';
      case ComponentStatus.unknown:
        return 'Status cannot be verified from available sources. Does not imply malware or safety.';
      case ComponentStatus.unsupported:
        return 'This check is not supported by your current Windows build or hardware.';
      case ComponentStatus.accessDenied:
        return 'Elevated permissions or Administrator access is required to read this status.';
      case ComponentStatus.error:
        return 'An error occurred while communicating with the data source.';
      case ComponentStatus.stale:
        return 'The recorded status is older than expected freshness interval.';
    }
  }
}

