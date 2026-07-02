import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'publisher.g.dart';

@HiveType(typeId: 5)
class Publisher extends Equatable {
  const Publisher({
    required this.id,
    required this.name,
    this.address,
    this.website,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? address;
  @HiveField(3)
  final String? website;

  @override
  List<Object?> get props => [id, name, address, website];
}
