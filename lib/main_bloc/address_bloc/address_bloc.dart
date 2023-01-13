import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_flutter/models/location.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:map_flutter/main_bloc/address_bloc/parts/google_markers.dart';
import 'package:map_flutter/main_bloc/address_bloc/parts/yandex_markers.dart';
import 'package:geolocator/geolocator.dart';

part 'address_bloc.freezed.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc() : super(const AddressState.address()) {
    on<_InitAddress>((event, emit) async {
      double? distanceInMeters;
      double? bearing;
      emit(state.copyWith(loadingAddress: true));
      List<Placemark> placeMarks = await placemarkFromCoordinates(
        event.lat,
        event.lng,
        localeIdentifier: 'en_US',
      );
      final address =
          '${placeMarks.first.street}, ${placeMarks.first.administrativeArea}, ${placeMarks.first.subAdministrativeArea}, ${placeMarks.first.country}';
      if (event.selectionObject) {
        emit(state.copyWith(selectedAddress: address));
      } else {
        emit(state.copyWith(
          currentAddress: address,
          selectedAddress: '',
        ));
      }
      if (event.currentLat != null && event.currentLng != null) {
        distanceInMeters = Geolocator.distanceBetween(
          event.currentLat!,
          event.currentLng!,
          event.lat,
          event.lng,
        );

        bearing = Geolocator.bearingBetween(
          event.currentLat!,
          event.currentLng!,
          event.lat,
          event.lng,
        );
      }
      emit(
        state.copyWith(
          loadingAddress: false,
          bearing: bearing,
          distanceInMeters: distanceInMeters,
          setMarkersOsm: event.selectionObject,
          changeMarkersOsm: event.changeMarkersOsm,
          markersGoogle: await googleMarkers(event, emit),
          markersYandex: await yandexMarkers(event, emit),
          location: LocationMap(lat: event.lat, lng: event.lng),
        ),
      );
    });
  }
}

@freezed
class AddressEvent with _$AddressEvent {
  const factory AddressEvent.initAddress({
    required double lat,
    required double lng,
    double? currentLat,
    double? currentLng,
    @Default(false) bool selectionObject,
    @Default(false) bool changeMarkersOsm,
  }) = _InitAddress;
}

@freezed
class AddressState with _$AddressState {
  const factory AddressState.address({
    @Default(false) bool loadingAddress,
    @Default(false) bool setMarkersOsm,
    @Default(false) bool changeMarkersOsm,
    LocationMap? location,
    Set<Marker>? markersGoogle,
    List<PlacemarkMapObject>? markersYandex,
    String? currentAddress,
    String? selectedAddress,
    double? distanceInMeters,
    double? bearing,
    String? error,
  }) = _Address;
}
