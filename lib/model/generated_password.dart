class GeneratedPassword {
  final String generatedPass;

  GeneratedPassword({required this.generatedPass});

  factory GeneratedPassword.fromJson(Map<String, dynamic> json) {
   return GeneratedPassword(
     generatedPass: json['password'],
   );
  } 
}