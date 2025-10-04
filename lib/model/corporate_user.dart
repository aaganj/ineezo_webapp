class CorporateUser{
   final String companyName;
   final String companyEmail;
   final String password;
   final String profileUrl;
   final String contactNumber;
   final String address;
   final String role;

  CorporateUser({
      required this.companyName,
      required this.companyEmail,
      required this.password,
      required this.profileUrl,
      required this.contactNumber,
      required this.address,
      required this.role,
    });

// Factory constructor instead of static
  factory CorporateUser.fromJson(Map<String, dynamic> json) {
    return CorporateUser(
      companyName: json['companyName'] ?? '',
      companyEmail: json['companyEmail'] ?? '',
      password: json['password'] ?? '',
      profileUrl: json['profileUrl'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      address: json['address'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'companyEmail': companyEmail,
      'password': password,
      'profileUrl': profileUrl,
      'contactNumber': contactNumber,
      'address': address,
      'role': role,
    };
  }
}