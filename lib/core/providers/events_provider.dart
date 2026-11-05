import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ipc/ipc_client.dart';
import '../models/ipc_contract.dart';
import 'engine_provider.dart';

class EventsState {
  final bool isLoading;
  final List<SecurityEventItem> events;
  final String channelSummary;
  final String selectedChannel;
  final String selectedSeverity;
  final String searchQuery;
  final String? errorMessage;
  final DateTime lastRefreshed;

  const EventsState({
    this.isLoading = false,
    this.events = const [],
    this.channelSummary = '',
    this.selectedChannel = 'All',
    this.selectedSeverity = 'All',
    this.searchQuery = '',
    this.errorMessage,
    required this.lastRefreshed,
  });

  factory EventsState.initial() => EventsState(
        isLoading: true,
        lastRefreshed: DateTime.now(),
      );

  EventsState copyWith({
    bool? isLoading,
    List<SecurityEventItem>? events,
    String? channelSummary,
    String? selectedChannel,
    String? selectedSeverity,
    String? searchQuery,
    String? errorMessage,
    DateTime? lastRefreshed,
  }) {
    return EventsState(
      isLoading: isLoading ?? this.isLoading,
      events: events ?? this.events,
      channelSummary: channelSummary ?? this.channelSummary,
      selectedChannel: selectedChannel ?? this.selectedChannel,
      selectedSeverity: selectedSeverity ?? this.selectedSeverity,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
    );
  }

  List<SecurityEventItem> get filteredEvents {
    return events.where((e) {
      if (selectedChannel != 'All' && !e.channel.toLowerCase().contains(selectedChannel.toLowerCase())) {
        return false;
      }
      if (selectedSeverity != 'All' && e.levelDisplayName.toLowerCase() != selectedSeverity.toLowerCase()) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesMsg = e.message.toLowerCase().contains(query);
        final matchesProvider = e.providerName.toLowerCase().contains(query);
        final matchesId = e.eventId.toString().contains(query);
        if (!matchesMsg && !matchesProvider && !matchesId) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}

final eventsProvider = NotifierProvider<EventsNotifier, EventsState>(EventsNotifier.new);

class EventsNotifier extends Notifier<EventsState> {
  final IpcClient _client = IpcClient();

  @override
  EventsState build() {
    ref.listen(engineProvider, (previous, next) {
      if (next.status.name == 'connected' && (previous?.status.name != 'connected' || state.events.isEmpty)) {
        refresh();
      }
    });

    Future.microtask(() => refresh());
    return EventsState.initial();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final resp = await _client.sendRequest<SecurityEventsSnapshot>(
        'get_security_events',
        {'maxPerChannel': 40},
        fromData: (json) => SecurityEventsSnapshot.fromJson(Map<String, dynamic>.from(json as Map)),
      );

      state = state.copyWith(
        isLoading: false,
        events: resp.data?.events ?? [],
        channelSummary: resp.data?.channelSummary ?? '',
        errorMessage: null,
        lastRefreshed: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to retrieve security event logs: $e',
        lastRefreshed: DateTime.now(),
      );
    }
  }

  void setChannelFilter(String channel) {
    state = state.copyWith(selectedChannel: channel);
  }

  void setSeverityFilter(String severity) {
    state = state.copyWith(selectedSeverity: severity);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }
}

