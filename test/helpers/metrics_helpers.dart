import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellbeing/features/account/profile_services.dart';

/// Wraps the app with fake gallery and ringtone pickers for [appTest].
Widget Function(Widget) withPickers({
  FakeRingtonePicker? ringtone,
  FakeProfilePhotoStore? photo,
}) =>
    (app) => ProviderScope(
      overrides: [
        if (ringtone != null)
          ringtonePickerProvider.overrideWithValue(ringtone),
        if (photo != null) profilePhotoStoreProvider.overrideWithValue(photo),
      ],
      child: app,
    );
