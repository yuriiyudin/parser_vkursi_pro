class Company {
  final String shortName;
  final String firstPhones;
  final String email;
  final String website;
  final String status;
  final String bankrot;
  final String stoped;
  final String codeEdrpoy;
  final String fullName;
  final String type;
  final String dateRegistered;
  final String dataZapisu;
  final String numberZapisu;
  final String adress;
  final List<String?>? secondPhones;
  final String owner;
  final String kvedMain;
  final String kvedDop;
  final String taxesData;

  Company(
      {required this.shortName,
      required  this.firstPhones,
      required this.email,
      required this.website,
      required this.status,
      required this.bankrot,
      required this.stoped,
      required this.codeEdrpoy,
      required this.fullName,
      required this.type,
      required this.dateRegistered,
      required this.dataZapisu,
      required this.numberZapisu,
      required this.adress,
      required this.secondPhones,
      required this.owner,
      required this.kvedMain,
      required this.kvedDop,
      required this.taxesData});
}
