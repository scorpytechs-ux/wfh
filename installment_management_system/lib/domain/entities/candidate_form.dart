class CandidateForm {
  final String id;
  final String userId;
  final String serialNo;
  final String title;
  final String firstName;
  final String lastName;
  final String initial;
  final String email;
  final String fatherName;
  final String dob;
  final String gender;
  final String profession;
  final String mailingStreet;
  final String mailingCity;
  final String mailingPostal;
  final String mailingCountry;
  final String serviceProvider;
  final String fileNo;
  final String referenceNo;
  final String simNo;
  final String imsi1;
  final String imsi2;
  final String typeOfPlan;
  final String creditCardType;
  final String contractValue;
  final String dateOfIssue;
  final String dateOfRenewal;
  final String installment;
  final String amountInWords;
  final String remarks;
  
  // New scoring fields
  final double score;
  final String mistakes;
  final String status;

  CandidateForm({
    required this.id,
    required this.userId,
    required this.serialNo,
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.initial,
    required this.email,
    required this.fatherName,
    required this.dob,
    required this.gender,
    required this.profession,
    required this.mailingStreet,
    required this.mailingCity,
    required this.mailingPostal,
    required this.mailingCountry,
    required this.serviceProvider,
    required this.fileNo,
    required this.referenceNo,
    required this.simNo,
    required this.imsi1,
    required this.imsi2,
    required this.typeOfPlan,
    required this.creditCardType,
    required this.contractValue,
    required this.dateOfIssue,
    required this.dateOfRenewal,
    required this.installment,
    required this.amountInWords,
    required this.remarks,
    this.score = 0.0,
    this.mistakes = '[]',
    this.status = 'pending',
  });
}
