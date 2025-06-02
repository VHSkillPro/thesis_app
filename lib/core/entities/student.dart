class Student {
  final String id;
  final String fullname;
  final String course;
  final String className;
  final bool isActive;

  Student({
    required this.id,
    required this.fullname,
    required this.course,
    required this.className,
    this.isActive = true,
  });
}
