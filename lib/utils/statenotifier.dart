import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a model for firstName and lastName
class LeadState {
  final String firstName;
  final String lastName;

  LeadState({this.firstName = '', this.lastName = ''});

  LeadState copyWith({String? firstName, String? lastName}) {
    return LeadState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }
}

// Create a StateNotifier to manage the lead state
class LeadNotifier extends StateNotifier<LeadState> {
  LeadNotifier() : super(LeadState());

  void updateFirstName(String firstName) {
    state = state.copyWith(firstName: firstName);
  }

  void updateLastName(String lastName) {
    state = state.copyWith(lastName: lastName);
  }
}

// Create a provider for LeadNotifier
final leadProvider = StateNotifierProvider<LeadNotifier, LeadState>((ref) {
  return LeadNotifier();
});
