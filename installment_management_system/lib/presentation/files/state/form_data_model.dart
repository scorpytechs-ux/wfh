class FormDataModel {
  final String id;
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
  final String typeOfNetwork;
  final String cellModelNo;
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
  final double? score;
  final List<String>? mistakes;
  final String status;
  final String? submittedDate;

  FormDataModel({
    required this.id,
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
    required this.typeOfNetwork,
    required this.cellModelNo,
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
    this.score,
    this.mistakes,
    this.status = 'pending',
    String? submittedDate,
  }) : this.submittedDate = submittedDate ?? DateTime.now().toIso8601String().substring(0, 10);

  bool get isComplete {
    return serialNo.trim().isNotEmpty &&
        title.trim().isNotEmpty &&
        firstName.trim().isNotEmpty &&
        lastName.trim().isNotEmpty &&
        initial.trim().isNotEmpty &&
        email.trim().isNotEmpty &&
        fatherName.trim().isNotEmpty &&
        dob.trim().isNotEmpty &&
        gender.trim().isNotEmpty &&
        profession.trim().isNotEmpty &&
        mailingStreet.trim().isNotEmpty &&
        mailingCity.trim().isNotEmpty &&
        mailingPostal.trim().isNotEmpty &&
        mailingCountry.trim().isNotEmpty &&
        serviceProvider.trim().isNotEmpty &&
        fileNo.trim().isNotEmpty &&
        referenceNo.trim().isNotEmpty &&
        simNo.trim().isNotEmpty &&
        typeOfNetwork.trim().isNotEmpty &&
        cellModelNo.trim().isNotEmpty &&
        imsi1.trim().isNotEmpty &&
        imsi2.trim().isNotEmpty &&
        typeOfPlan.trim().isNotEmpty &&
        creditCardType.trim().isNotEmpty &&
        contractValue.trim().isNotEmpty &&
        dateOfIssue.trim().isNotEmpty &&
        dateOfRenewal.trim().isNotEmpty &&
        installment.trim().isNotEmpty &&
        amountInWords.trim().isNotEmpty &&
        remarks.trim().isNotEmpty;
  }

  FormDataModel copyWith({
    String? id,
    String? serialNo,
    String? title,
    String? firstName,
    String? lastName,
    String? initial,
    String? email,
    String? fatherName,
    String? dob,
    String? gender,
    String? profession,
    String? mailingStreet,
    String? mailingCity,
    String? mailingPostal,
    String? mailingCountry,
    String? serviceProvider,
    String? fileNo,
    String? referenceNo,
    String? simNo,
    String? typeOfNetwork,
    String? cellModelNo,
    String? imsi1,
    String? imsi2,
    String? typeOfPlan,
    String? creditCardType,
    String? contractValue,
    String? dateOfIssue,
    String? dateOfRenewal,
    String? installment,
    String? amountInWords,
    String? remarks,
    double? score,
    List<String>? mistakes,
    String? status,
    String? submittedDate,
  }) {
    return FormDataModel(
      id: id ?? this.id,
      serialNo: serialNo ?? this.serialNo,
      title: title ?? this.title,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      initial: initial ?? this.initial,
      email: email ?? this.email,
      fatherName: fatherName ?? this.fatherName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      profession: profession ?? this.profession,
      mailingStreet: mailingStreet ?? this.mailingStreet,
      mailingCity: mailingCity ?? this.mailingCity,
      mailingPostal: mailingPostal ?? this.mailingPostal,
      mailingCountry: mailingCountry ?? this.mailingCountry,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      fileNo: fileNo ?? this.fileNo,
      referenceNo: referenceNo ?? this.referenceNo,
      simNo: simNo ?? this.simNo,
      typeOfNetwork: typeOfNetwork ?? this.typeOfNetwork,
      cellModelNo: cellModelNo ?? this.cellModelNo,
      imsi1: imsi1 ?? this.imsi1,
      imsi2: imsi2 ?? this.imsi2,
      typeOfPlan: typeOfPlan ?? this.typeOfPlan,
      creditCardType: creditCardType ?? this.creditCardType,
      contractValue: contractValue ?? this.contractValue,
      dateOfIssue: dateOfIssue ?? this.dateOfIssue,
      dateOfRenewal: dateOfRenewal ?? this.dateOfRenewal,
      installment: installment ?? this.installment,
      amountInWords: amountInWords ?? this.amountInWords,
      remarks: remarks ?? this.remarks,
      score: score ?? this.score,
      mistakes: mistakes ?? this.mistakes,
      status: status ?? this.status,
      submittedDate: submittedDate ?? this.submittedDate,
    );
  }
}
