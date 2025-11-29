import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationState {
  final String? address;
  final Placemark? placemark;
  final bool isLoading;
  final String? error;

  LocationState({this.address, this.placemark, this.isLoading = false, this.error});

  LocationState copyWith({String? address, Placemark? placemark, bool? isLoading, String? error}) {
    return LocationState(
      address: address ?? this.address,
      placemark: placemark ?? this.placemark,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Allow setting error to null
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState());

  Future<void> fetchLocation() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final fullAddress = "${p.name}, ${p.street}, ${p.locality}, ${p.postalCode}, ${p.country}";
        state = state.copyWith(address: fullAddress, placemark: p, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) => LocationNotifier());