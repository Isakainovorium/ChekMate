import 'package:flutter_chekmate/core/domain/entities/location_entity.dart';
import 'package:flutter_chekmate/core/services/location_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocationService', () {
    group('LocationServiceException', () {
      test('creates exception with message', () {
        const exception = LocationServiceException('Test error');
        expect(exception.message, 'Test error');
        expect(exception.toString(), 'LocationServiceException: Test error');
      });

      test('exception message is accessible', () {
        const exception = LocationServiceException('Location services disabled');
        expect(exception.message, 'Location services disabled');
      });

      test('exception toString includes message', () {
        const exception = LocationServiceException('Permission denied');
        expect(exception.toString(), contains('Permission denied'));
      });
    });

    group('Service Structure', () {
      test('LocationService has required static methods', () {
        expect(LocationService.getCurrentLocation, isA<Function>());
        expect(LocationService.getAddressFromCoordinates, isA<Function>());
        expect(LocationService.getCoordinatesFromAddress, isA<Function>());
        expect(LocationService.checkPermission, isA<Function>());
        expect(LocationService.requestPermission, isA<Function>());
        expect(LocationService.openLocationSettings, isA<Function>());
        expect(LocationService.isLocationServiceEnabled, isA<Function>());
        expect(LocationService.calculateDistance, isA<Function>());
        expect(LocationService.getLastKnownLocation, isA<Function>());
        expect(LocationService.openAppSettings, isA<Function>());
      });
    });

    group('Distance Calculation', () {
      test('calculateDistance returns distance in kilometers', () {
        final distance = LocationService.calculateDistance(
          startLatitude: 37.7749,
          startLongitude: -122.4194,
          endLatitude: 34.0522,
          endLongitude: -118.2437,
        );
        expect(distance, isA<double>());
        expect(distance, greaterThan(500));
        expect(distance, lessThan(600));
      });

      test('calculateDistance returns zero for same location', () {
        final distance = LocationService.calculateDistance(
          startLatitude: 37.7749,
          startLongitude: -122.4194,
          endLatitude: 37.7749,
          endLongitude: -122.4194,
        );
        expect(distance, equals(0.0));
      });

      test('calculateDistance handles negative coordinates', () {
        final distance = LocationService.calculateDistance(
          startLatitude: -33.8688,
          startLongitude: 151.2093,
          endLatitude: -37.8136,
          endLongitude: 144.9631,
        );
        expect(distance, isA<double>());
        expect(distance, greaterThan(0));
      });
    });

    group('Method Return Types', () {
      test('getCurrentLocation returns Future<LocationEntity>', () {
        expect(LocationService.getCurrentLocation(), isA<Future<LocationEntity>>());
      });

      test('getAddressFromCoordinates returns Future<LocationEntity>', () {
        expect(
          LocationService.getAddressFromCoordinates(latitude: 37.7749, longitude: -122.4194),
          isA<Future<LocationEntity>>(),
        );
      });

      test('getCoordinatesFromAddress returns Future<List<LocationEntity>>', () {
        expect(
          LocationService.getCoordinatesFromAddress(address: 'San Francisco, CA'),
          isA<Future<List<LocationEntity>>>(),
        );
      });

      test('checkPermission returns Future', () {
        expect(LocationService.checkPermission(), isA<Future<dynamic>>());
      });

      test('requestPermission returns Future', () {
        expect(LocationService.requestPermission(), isA<Future<dynamic>>());
      });

      test('isLocationServiceEnabled returns Future<bool>', () {
        expect(LocationService.isLocationServiceEnabled(), isA<Future<bool>>());
      });

      test('getLastKnownLocation returns Future<LocationEntity?>', () {
        expect(LocationService.getLastKnownLocation(), isA<Future<LocationEntity?>>());
      });

      test('openAppSettings returns Future<bool>', () {
        expect(LocationService.openAppSettings(), isA<Future<bool>>());
      });

      test('openLocationSettings returns Future<bool>', () {
        expect(LocationService.openLocationSettings(), isA<Future<bool>>());
      });
    });

    group('API Validation', () {
      test('getCurrentLocation accepts includeAddress parameter', () {
        expect(() => LocationService.getCurrentLocation(includeAddress: false), returnsNormally);
      });

      test('getAddressFromCoordinates requires latitude and longitude', () {
        expect(
          () => LocationService.getAddressFromCoordinates(latitude: 37.7749, longitude: -122.4194),
          returnsNormally,
        );
      });

      test('getCoordinatesFromAddress requires address parameter', () {
        expect(
          () => LocationService.getCoordinatesFromAddress(address: 'San Francisco, CA'),
          returnsNormally,
        );
      });

      test('calculateDistance requires all coordinate parameters', () {
        expect(
          () => LocationService.calculateDistance(
            startLatitude: 37.7749,
            startLongitude: -122.4194,
            endLatitude: 34.0522,
            endLongitude: -118.2437,
          ),
          returnsNormally,
        );
      });
    });
  });
}
