import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'reminder.dart';

class RemindersNotifier extends StateNotifier<List<Reminder>> {
  RemindersNotifier() : super(const []);

  void add(Reminder r) => state = [...state, r];
  void addAll(List<Reminder> reminders) => state = [...state, ...reminders];
  void remove(String id) => state = state.where((e) => e.id != id).toList();
}

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, List<Reminder>>((_) => RemindersNotifier());

