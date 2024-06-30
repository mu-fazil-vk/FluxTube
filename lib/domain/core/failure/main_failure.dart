import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_failure.freezed.dart';

@freezed
class MainFailure with _$MainFailure {
  //client error
  const factory MainFailure.clientFailure() = _ClientFailure;
  //server error
  const factory MainFailure.serverFailure() = _ServerFailure;
}
