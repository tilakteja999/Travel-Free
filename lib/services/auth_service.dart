import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum OtpVerificationResult { success, incorrect, expired }

class UserAccount {
  final String id;
  final String fullName;
  final String email;
  final String mobile;
  final String passwordHash;
  final DateTime createdAt;

  UserAccount({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.passwordHash,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get displayName {
    final name = fullName.trim();
    if (name.isNotEmpty) return name;
    if (email.trim().isNotEmpty) return email.split('@').first;
    return 'Traveller';
  }

  String get firstName {
    final name = displayName.trim();
    if (name.isEmpty) return 'Traveller';
    return name.split(RegExp(r'\s+')).first;
  }

  String get initials {
    final words = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((item) => item.isNotEmpty)
        .toList();

    if (words.isEmpty) return 'T';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();

    return '${words.first.substring(0, 1)}${words.last.substring(0, 1)}'.toUpperCase();
  }

  // Legacy compatibility getters
  String get identifier => id.isNotEmpty ? id : (email.isNotEmpty ? email : mobile);
  String get isEmail => email.isNotEmpty ? 'true' : 'false';

  UserAccount copyWith({
    String? id,
    String? fullName,
    String? email,
    String? mobile,
    String? passwordHash,
    DateTime? createdAt,
  }) {
    return UserAccount(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'mobile': mobile,
        'passwordHash': passwordHash,
        'createdAt': createdAt.toIso8601String(),
        // Legacy keys for backwards compatibility
        'identifier': identifier,
        'isEmail': isEmail,
      };

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    final rawId = json['id']?.toString() ?? json['identifier']?.toString() ?? '';
    final isEmailStr = json['isEmail']?.toString() ?? 'true';
    final rawEmail = json['email']?.toString() ?? (isEmailStr == 'true' ? json['identifier']?.toString() ?? '' : '');
    final rawMobile = json['mobile']?.toString() ?? (isEmailStr == 'false' ? json['identifier']?.toString() ?? '' : '');

    var name = json['fullName']?.toString() ?? json['name']?.toString() ?? '';
    if (name.isEmpty || name == rawMobile) {
      if (rawEmail == 'user@travel.com' || rawMobile == '9876543210') {
        name = 'Travel Demo User';
      }
    }

    return UserAccount(
      id: rawId.isNotEmpty ? rawId : (rawEmail.isNotEmpty ? rawEmail : rawMobile),
      fullName: name,
      email: rawEmail,
      mobile: rawMobile,
      passwordHash: json['passwordHash']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class PendingOtp {
  final String identifier;
  final String code;
  final DateTime expiresAt;

  PendingOtp({
    required this.identifier,
    required this.code,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _keyUsers = 'travel_auth_users_v1';
  static const String _keyActiveSession = 'travel_auth_active_session';
  static const String _keyLastAccount = 'travel_auth_last_account';

  SharedPreferences? _prefs;
  final Map<String, UserAccount> _users = {};
  PendingOtp? _currentOtp;

  static final ValueNotifier<UserAccount?> activeUserNotifier = ValueNotifier<UserAccount?>(null);

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _loadUsersFromPrefs();

    final demoHash = _hashPassword('Travel123!');
    final demoUser = UserAccount(
      id: 'usr_demo_1',
      fullName: 'Travel Demo User',
      email: 'user@travel.com',
      mobile: '9876543210',
      passwordHash: demoHash,
      createdAt: DateTime.now(),
    );

    if (_users.isEmpty) {
      _saveAccountToMap(demoUser);
      await _saveUsersToPrefs();
    } else {
      // Clean up legacy accounts without names or where fullName == mobile
      bool needsSave = false;
      for (var u in _users.values.toList()) {
        if (u.fullName.isEmpty || u.fullName == u.mobile) {
          final updatedName = u.email == 'user@travel.com' || u.mobile == '9876543210'
              ? 'Travel Demo User'
              : (u.email.isNotEmpty ? u.email.split('@').first : 'Traveller');
          final updated = u.copyWith(fullName: updatedName);
          _saveAccountToMap(updated);
          needsSave = true;
        }
      }
      if (needsSave) {
        await _saveUsersToPrefs();
      }
    }

    _restoreSession();
  }

  void _restoreSession() {
    final activeId = _prefs?.getString(_keyActiveSession);
    if (activeId != null && activeId.isNotEmpty) {
      final account = findAccountByEmailOrMobile(activeId);
      activeUserNotifier.value = account;
    } else {
      activeUserNotifier.value = null;
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode('salt_travel_2026_$password');
    return sha256.convert(bytes).toString();
  }

  void _loadUsersFromPrefs() {
    final rawJson = _prefs?.getString(_keyUsers);
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(rawJson);
        for (var item in decoded) {
          final account = UserAccount.fromJson(Map<String, dynamic>.from(item));
          _saveAccountToMap(account);
        }
      } catch (e) {
        // Fallback if parsing fails
      }
    }
  }

  void _saveAccountToMap(UserAccount account) {
    if (account.id.isNotEmpty) _users[account.id.toLowerCase()] = account;
    if (account.email.isNotEmpty) _users[account.email.toLowerCase()] = account;
    if (account.mobile.isNotEmpty) _users[account.mobile.toLowerCase()] = account;
  }

  Future<void> _saveUsersToPrefs() async {
    final uniqueAccounts = _users.values.toSet().toList();
    final list = uniqueAccounts.map((u) => u.toJson()).toList();
    await _prefs?.setString(_keyUsers, jsonEncode(list));
  }

  // Active Session & Remember Account
  bool isLoggedIn() {
    final session = _prefs?.getString(_keyActiveSession);
    return session != null && session.isNotEmpty;
  }

  String? getActiveUserIdentifier() {
    final active = activeUserNotifier.value;
    if (active != null) return active.id;
    return _prefs?.getString(_keyActiveSession);
  }

  UserAccount? getCurrentUser() {
    if (activeUserNotifier.value != null) return activeUserNotifier.value;
    final activeId = _prefs?.getString(_keyActiveSession);
    if (activeId != null && activeId.isNotEmpty) {
      final account = findAccountByEmailOrMobile(activeId);
      activeUserNotifier.value = account;
      return account;
    }
    return null;
  }

  String? getLastAccountIdentifier() {
    return _prefs?.getString(_keyLastAccount);
  }

  // Determine if input is Email or Mobile
  static bool isEmailIdentifier(String input) {
    return input.contains('@');
  }

  // Find Account
  UserAccount? findAccountByEmailOrMobile(String input) {
    final clean = input.trim().toLowerCase();
    if (_users.containsKey(clean)) return _users[clean];

    for (var u in _users.values) {
      if (u.id.toLowerCase() == clean ||
          (u.email.isNotEmpty && u.email.toLowerCase() == clean) ||
          (u.mobile.isNotEmpty && u.mobile.toLowerCase() == clean)) {
        return u;
      }
    }
    return null;
  }

  // User Lookup
  bool userExists(String identifier) {
    return findAccountByEmailOrMobile(identifier) != null;
  }

  // Authentication: Login
  Future<bool> login(String identifier, String password) async {
    await init();
    final account = findAccountByEmailOrMobile(identifier);
    if (account == null) return false;

    final hash = _hashPassword(password);
    if (account.passwordHash == hash) {
      await _prefs?.setString(_keyActiveSession, account.id);
      await _prefs?.setString(_keyLastAccount, account.id);
      activeUserNotifier.value = account;
      return true;
    }
    return false;
  }

  // Create User Account
  Future<bool> registerUser({
    required String fullName,
    required String identifier,
    required String password,
  }) async {
    await init();
    final cleanId = identifier.trim();
    final isEmail = isEmailIdentifier(cleanId);

    final newId = 'usr_${DateTime.now().millisecondsSinceEpoch}';
    final account = UserAccount(
      id: newId,
      fullName: fullName.trim(),
      email: isEmail ? cleanId : '',
      mobile: isEmail ? '' : cleanId,
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
    );

    _saveAccountToMap(account);
    await _saveUsersToPrefs();

    // Auto log in after registration
    await _prefs?.setString(_keyActiveSession, account.id);
    await _prefs?.setString(_keyLastAccount, account.id);
    activeUserNotifier.value = account;
    return true;
  }

  // Update Profile Name
  Future<void> updateProfileName(String newFullName) async {
    await init();
    final currentUser = getCurrentUser();
    if (currentUser == null) return;

    final updated = currentUser.copyWith(fullName: newFullName.trim());
    _saveAccountToMap(updated);
    await _saveUsersToPrefs();
    activeUserNotifier.value = updated;
  }

  // Reset Password
  Future<bool> resetPassword(String identifier, String newPassword) async {
    await init();
    final account = findAccountByEmailOrMobile(identifier);
    if (account == null) return false;

    final updated = account.copyWith(passwordHash: _hashPassword(newPassword));
    _saveAccountToMap(updated);
    await _saveUsersToPrefs();

    if (activeUserNotifier.value?.id == account.id) {
      activeUserNotifier.value = updated;
    }
    return true;
  }

  // Change Password
  Future<bool> changePassword({
    required String identifier,
    required String currentPassword,
    required String newPassword,
  }) async {
    await init();
    final account = findAccountByEmailOrMobile(identifier);
    if (account == null) return false;

    if (account.passwordHash != _hashPassword(currentPassword)) {
      return false;
    }

    final updated = account.copyWith(passwordHash: _hashPassword(newPassword));
    _saveAccountToMap(updated);
    await _saveUsersToPrefs();

    if (activeUserNotifier.value?.id == account.id) {
      activeUserNotifier.value = updated;
    }
    return true;
  }

  // OTP Generation
  String generateOtp(String identifier) {
    final random = Random();
    final code = (100000 + random.nextInt(900000)).toString();
    _currentOtp = PendingOtp(
      identifier: identifier.trim().toLowerCase(),
      code: code,
      expiresAt: DateTime.now().add(const Duration(seconds: 120)),
    );
    return code;
  }

  PendingOtp? get currentOtp => _currentOtp;

  // OTP Verification
  OtpVerificationResult verifyOtp(String identifier, String enteredCode) {
    if (_currentOtp == null ||
        _currentOtp!.identifier != identifier.trim().toLowerCase()) {
      return OtpVerificationResult.incorrect;
    }

    if (_currentOtp!.isExpired) {
      return OtpVerificationResult.expired;
    }

    if (_currentOtp!.code == enteredCode.trim()) {
      _currentOtp = null; // Clear OTP after success
      return OtpVerificationResult.success;
    }

    return OtpVerificationResult.incorrect;
  }

  // Logout
  Future<void> logout() async {
    await _prefs?.remove(_keyActiveSession);
    activeUserNotifier.value = null;
  }

  // Switch Account
  Future<void> switchAccount() async {
    await _prefs?.remove(_keyActiveSession);
    await _prefs?.remove(_keyLastAccount);
    activeUserNotifier.value = null;
  }

  // Password Requirements Validation
  static Map<String, bool> validatePasswordRequirements(String password) {
    return {
      'Min 8 characters': password.length >= 8,
      'At least one uppercase letter (A-Z)': password.contains(RegExp(r'[A-Z]')),
      'At least one lowercase letter (a-z)': password.contains(RegExp(r'[a-z]')),
      'At least one number (0-9)': password.contains(RegExp(r'[0-9]')),
    };
  }

  static bool isPasswordValid(String password) {
    final reqs = validatePasswordRequirements(password);
    return !reqs.values.contains(false);
  }
}
