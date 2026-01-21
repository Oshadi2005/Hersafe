class TrustedContact {
  String name;
  String phone;

  TrustedContact({required this.name, required this.phone});

  factory TrustedContact.fromJson(Map<String, dynamic> json) {
    return TrustedContact(name: json['name'], phone: json['phone']);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
      };
}
