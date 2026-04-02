class DashboardViewState {
  final bool isLoading;
  final Map<String, dynamic> deviceData;
  final Map<String, dynamic> systemData;

  const DashboardViewState({
    required this.isLoading,
    required this.deviceData,
    required this.systemData,
  });

  factory DashboardViewState.initial() {
    return const DashboardViewState(
      isLoading: true,
      deviceData: {},
      systemData: {},
    );
  }

  DashboardViewState copyWith({
    bool? isLoading,
    Map<String, dynamic>? deviceData,
    Map<String, dynamic>? systemData,
  }) {
    return DashboardViewState(
      isLoading: isLoading ?? this.isLoading,
      deviceData: deviceData ?? this.deviceData,
      systemData: systemData ?? this.systemData,
    );
  }
}
