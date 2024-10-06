class JoinTraderModel {
  String fName;
  String lName;
  String store;
  String phone;
  String full_address;
  List<String> master;
  List<String> parts_type;
  List<String> activity_type;

  JoinTraderModel({
    required this.fName,
    required this.lName,
    required this.store,
    required this.phone,
    required this.full_address,
    required this.master,
    required this.parts_type,
    required this.activity_type,
  });

  void printDetails() {
    print("First Name: $fName");
    print("Last Name: $lName");
    print("Store Name: $store");
    print("Phone: $phone");
    print("Full Address: $full_address");
    print("Master: $master");
    print("Parts Type: $parts_type");
    print("Activity Type: $activity_type");
  }
}
