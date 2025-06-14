class AppointmentCard {
  String id;
  String description;
  String doctor_name;
  String hospital_name;
  DateTime time;
  DateTime alert_time;

  AppointmentCard({required this.id, required this.description, required this.doctor_name, required this.hospital_name, required this.time, required this.alert_time});
}