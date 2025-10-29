class Reminder {
  final String id;
  final String medicine;
  final int pills; // số viên mỗi lần
  final List<String> times; // danh sách giờ dạng HH:mm

  Reminder({
    required this.id,
    required this.medicine,
    required this.pills,
    required this.times,
  });
}
