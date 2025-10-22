import 'package:flutter_riverpod/flutter_riverpod.dart';

class Profile {
  final String name;
  final double height; // m
  final double weight; // kg
  const Profile({this.name = 'Người dùng', this.height = 1.7, this.weight = 65});
  double get bmi => weight / (height * height);
}

class ProfileNotifier extends StateNotifier<Profile> {
  ProfileNotifier() : super(const Profile());
  void update({String? name, double? height, double? weight}) =>
      state = Profile(name: name ?? state.name, height: height ?? state.height, weight: weight ?? state.weight);
}

final profileProvider = StateNotifierProvider<ProfileNotifier, Profile>((_) => ProfileNotifier());
