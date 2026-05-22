import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

// ── EVENTS ────────────────────────────────────────────────────
abstract class ThemeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ThemeLoadEvent extends ThemeEvent {}

class ThemeToggleEvent extends ThemeEvent {
  final ThemeMode themeMode;
  ThemeToggleEvent(this.themeMode);
  @override
  List<Object> get props => [themeMode];
}

// ── STATE ─────────────────────────────────────────────────────
class ThemeState extends Equatable {
  final ThemeMode themeMode;
  const ThemeState({this.themeMode = ThemeMode.system});

  @override
  List<Object> get props => [themeMode];
}

// ── BLOC ──────────────────────────────────────────────────────
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences prefs;

  ThemeBloc({required this.prefs}) : super(const ThemeState()) {
    on<ThemeLoadEvent>(_onLoad);
    on<ThemeToggleEvent>(_onToggle);
  }

  Future<void> _onLoad(ThemeLoadEvent event, Emitter<ThemeState> emit) async {
    final savedMode = prefs.getString(AppConstants.themeModeKey);
    final themeMode = switch (savedMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    emit(ThemeState(themeMode: themeMode));
  }

  Future<void> _onToggle(
    ThemeToggleEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await prefs.setString(
      AppConstants.themeModeKey,
      event.themeMode.name,
    );
    emit(ThemeState(themeMode: event.themeMode));
  }
}

// ── SETTINGS BLOC ─────────────────────────────────────────────
abstract class SettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {}

class ChangeFontSizeEvent extends SettingsEvent {
  final double fontSize;
  ChangeFontSizeEvent(this.fontSize);
  @override
  List<Object> get props => [fontSize];
}

class ClearCacheEvent extends SettingsEvent {}

class SettingsState extends Equatable {
  final double fontSize;
  final bool isClearingCache;
  final bool cacheClearedSuccess;

  const SettingsState({
    this.fontSize = 16.0,
    this.isClearingCache = false,
    this.cacheClearedSuccess = false,
  });

  SettingsState copyWith({
    double? fontSize,
    bool? isClearingCache,
    bool? cacheClearedSuccess,
  }) {
    return SettingsState(
      fontSize: fontSize ?? this.fontSize,
      isClearingCache: isClearingCache ?? this.isClearingCache,
      cacheClearedSuccess: cacheClearedSuccess ?? this.cacheClearedSuccess,
    );
  }

  @override
  List<Object> get props => [fontSize, isClearingCache, cacheClearedSuccess];
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences prefs;

  SettingsBloc({required this.prefs}) : super(const SettingsState()) {
    on<LoadSettingsEvent>(_onLoad);
    on<ChangeFontSizeEvent>(_onFontSize);
    on<ClearCacheEvent>(_onClearCache);
  }

  Future<void> _onLoad(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final fontSize = prefs.getDouble(AppConstants.fontSizeKey) ?? 16.0;
    emit(state.copyWith(fontSize: fontSize));
  }

  Future<void> _onFontSize(
    ChangeFontSizeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await prefs.setDouble(AppConstants.fontSizeKey, event.fontSize);
    emit(state.copyWith(fontSize: event.fontSize));
  }

  Future<void> _onClearCache(
    ClearCacheEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isClearingCache: true));
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate clearing cache
      emit(state.copyWith(
        isClearingCache: false,
        cacheClearedSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(isClearingCache: false));
    }
  }
}
