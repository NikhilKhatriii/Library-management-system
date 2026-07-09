import 'package:equatable/equatable.dart';

class SystemHealth extends Equatable {
  final double cpuUsage;
  final double memoryUsage;
  final double storageUsage;
  final String serverStatus;
  final int uptimeMinutes;

  const SystemHealth({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.storageUsage,
    required this.serverStatus,
    required this.uptimeMinutes,
  });

  @override
  List<Object?> get props => [cpuUsage, memoryUsage, storageUsage, serverStatus, uptimeMinutes];
}
