import 'dart:io';
import 'package:flutter/material.dart';

/// Singleton class to manage attendance state without SharedPreferences
class AttendanceManager {
  static final AttendanceManager _instance = AttendanceManager._internal();
  factory AttendanceManager() => _instance;
  AttendanceManager._internal();

  // Attendance state
  bool _isCheckedIn = false;
  DateTime? _checkInTime;
  double? _checkInLatitude;
  double? _checkInLongitude;
  File? _checkInImage;
  String _locationName = "Capital Icon";

  // Getters
  bool get isCheckedIn => _isCheckedIn;
  DateTime? get checkInTime => _checkInTime;
  double? get checkInLatitude => _checkInLatitude;
  double? get checkInLongitude => _checkInLongitude;
  File? get checkInImage => _checkInImage;
  String get locationName => _locationName;

  // Calculate work duration
  Duration get workDuration {
    if (_checkInTime == null) return Duration.zero;
    return DateTime.now().difference(_checkInTime!);
  }

  // Check-in method
  void checkIn({
    required DateTime checkInTime,
    required double latitude,
    required double longitude,
    required File checkInImage,
    String locationName = "Capital Icon",
  }) {
    _isCheckedIn = true;
    _checkInTime = checkInTime;
    _checkInLatitude = latitude;
    _checkInLongitude = longitude;
    _checkInImage = checkInImage;
    _locationName = locationName;
    
    print('✅ AttendanceManager: Check-in successful');
    print('   Time: $checkInTime');
    print('   Location: $latitude, $longitude');
  }

  // Check-out method
  void checkOut() {
    _isCheckedIn = false;
    _checkInTime = null;
    _checkInLatitude = null;
    _checkInLongitude = null;
    _checkInImage = null;
    _locationName = "Capital Icon";
    
    print('✅ AttendanceManager: Check-out successful');
  }

  // Reset method (for testing or manual reset)
  void reset() {
    checkOut();
  }

  // Get formatted work duration
  String getFormattedWorkDuration() {
    final duration = workDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return "$hours h $minutes m";
  }

  // Get formatted check-in time
  String getFormattedCheckInTime() {
    if (_checkInTime == null) return "Not checked in";
    
    final hour = _checkInTime!.hour % 12;
    final minute = _checkInTime!.minute.toString().padLeft(2, '0');
    final period = _checkInTime!.hour >= 12 ? 'PM' : 'AM';
    return "${hour == 0 ? 12 : hour}:$minute $period";
  }
}

