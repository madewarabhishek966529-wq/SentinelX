import 'package:flutter/material.dart';
import '../../../core/models/component_status.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/status_badge.dart';

class ProcessesScreen extends StatefulWidget {
  const ProcessesScreen({super.key});

  @override
  State<ProcessesScreen> createState() => _ProcessesScreenState();
}

class _ProcessesScreenState extends State<ProcessesScreen> {
  String _searchQuery = '';

  final List<Map<String, dynamic>> _sampleProcesses = [
    {
      'name': 'sentinelx.exe',
      'pid': 14820,
      'publisher': 'SentinelX Desktop App',
      'publisherStatus': ComponentStatus.enabled,
      'cpu': '0.4%',
      'memory': '68 MB',
      'path': r'C:\Users\madew\Desktop\Git Project\Flutter Projects git\sentinelx\build\sentinelx.exe',
    },
    {
      'name': 'SentinelX.Engine.exe',
      'pid': 8392,
      'publisher': 'SentinelX Native Service',
      'publisherStatus': ComponentStatus.enabled,
      'cpu': '0.1%',
      'memory': '24 MB',
      'path': r'C:\Users\madew\Desktop\Git Project\Flutter Projects git\sentinelx\SentinelX.Engine\bin\Release\SentinelX.Engine.exe',
    },
    {
      'name': 'explorer.exe',
      'pid': 5210,
      'publisher': 'Microsoft Windows Publisher',
      'publisherStatus': ComponentStatus.enabled,
      'cpu': '0.8%',
      'memory': '142 MB',
      'path': r'C:\Windows\explorer.exe',
    },
    {
      'name': 'custom_script_runner.exe',
      'pid': 11408,
      'publisher': 'Unsigned / Self-Signed',
      'publisherStatus': ComponentStatus.unknown,
      'cpu': '0.0%',
      'memory': '12 MB',
      'path': r'C:\Tools\custom_script_runner.exe',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _sampleProcesses.where((p) {
      final name = p['name'].toString().toLowerCase();
      final publisher = p['publisher'].toString().toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || publisher.contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Process Visibility', style: SentinelTypography.display),
          const SizedBox(height: 8),
          const Text(
            'Read-only process inspector. Unverified publisher indicates the binary has no valid digital signature, not that it is malicious. Automatic process termination is disabled by design.',
            style: SentinelTypography.bodySecondary,
          ),
          const SizedBox(height: 20),

          // Search & Filter Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search process by name or publisher...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: SentinelColors.textSecondary),
                    filled: true,
                    fillColor: SentinelColors.surfaceCard,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: SentinelColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: SentinelColors.border),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: SentinelColors.surfaceCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SentinelColors.border),
                ),
                child: Text('Total Processes: ${_sampleProcesses.length}', style: SentinelTypography.caption),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Process Table Card
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) {
                final p = filtered[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  leading: const Icon(Icons.apps_outlined, color: SentinelColors.primary, size: 22),
                  title: Row(
                    children: [
                      Text(p['name'], style: SentinelTypography.titleMedium),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: SentinelColors.surfaceHighlight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('PID: ${p['pid']}', style: SentinelTypography.code),
                      ),
                      const Spacer(),
                      StatusBadge(status: p['publisherStatus'] as ComponentStatus),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Publisher: ${p['publisher']}', style: SentinelTypography.bodySecondary),
                      const SizedBox(height: 2),
                      Text('Path: ${p['path']}', style: SentinelTypography.caption, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('CPU: ${p['cpu']}', style: SentinelTypography.caption),
                      const SizedBox(width: 16),
                      Text('RAM: ${p['memory']}', style: SentinelTypography.caption),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
