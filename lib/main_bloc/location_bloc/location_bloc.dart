import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:location/location.dart';
import 'package:map_flutter/repo/map_api.dart';
import 'package:map_flutter/l10n/generated/l10n.dart';

part 'location_bloc.freezed.dart';

part 'parts/init_location.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc({required this.api}) : super(const LocationState.init()) {
    on<_InitLocation>(_initLocation);
  }

  final MapApi api;
}

@freezed
class LocationEvent with _$LocationEvent {
  const factory LocationEvent.initLocation({
    @Default(false) bool moveToCurrentLocation,
  }) = _InitLocation;
}

@freezed
class LocationState with _$LocationState {
  const LocationState._();

  const factory LocationState.init() = _Init;

  const factory LocationState.error({
    required String? error,
  }) = _Error;

  const factory LocationState.loading() = _Loading;

  const factory LocationState.map({
    @Default(false) bool moveToCurrentLocation,
    double? latitude,
    double? longitude,
    UniqueKey? key,
  }) = _Map;

  T? maybeCurrentLat<T extends double>() => maybeWhen(
        map: (_, lat, lng,__) {
          if (lat is T) {
            return lat;
          }

          return null;
        },
        orElse: () => null,
      );

  T? maybeCurrentLng<T extends double>() => maybeWhen(
        map: (_, lat, lng,__) {
          if (lng is T) {
            return lng;
          }

          return null;
        },
        orElse: () => null,
      );

}
