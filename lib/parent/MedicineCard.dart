class MedicineCard {
  String id; // medicine id
  String medicine_name;
   String dosage; // quantity and unit e.g 2 tablets / 1 teaspoon / 1 ml ...
   Map<String, List<String>> times; // all the times for this medicine we can change from string to time later
   String image; // dont know how we will store the image!

  MedicineCard({
    required this.id, 
    required this.medicine_name, 
    required this.dosage, 
    required this.times, 
    required this.image, 
  });
}
