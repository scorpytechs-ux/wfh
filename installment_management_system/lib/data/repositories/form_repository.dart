import 'package:cloud_firestore/cloud_firestore.dart';
import '../../presentation/files/state/form_data_model.dart';

class FormRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveForm(FormDataModel form, String userId) async {
    final map = {
      'id': form.id,
      'userId': userId,
      'serialNo': form.serialNo,
      'title': form.title,
      'firstName': form.firstName,
      'lastName': form.lastName,
      'initial': form.initial,
      'email': form.email,
      'fatherName': form.fatherName,
      'dob': form.dob,
      'gender': form.gender,
      'profession': form.profession,
      'mailingStreet': form.mailingStreet,
      'mailingCity': form.mailingCity,
      'mailingPostal': form.mailingPostal,
      'mailingCountry': form.mailingCountry,
      'serviceProvider': form.serviceProvider,
      'fileNo': form.fileNo,
      'referenceNo': form.referenceNo,
      'simNo': form.simNo,
      'imsi1': form.imsi1,
      'imsi2': form.imsi2,
      'typeOfPlan': form.typeOfPlan,
      'creditCardType': form.creditCardType,
      'contractValue': form.contractValue,
      'dateOfIssue': form.dateOfIssue,
      'dateOfRenewal': form.dateOfRenewal,
      'installment': form.installment,
      'amountInWords': form.amountInWords,
      'remarks': form.remarks,
      'score': form.score ?? 0.0,
      'mistakes': form.mistakes != null ? form.mistakes : [],
      'status': form.status ?? 'pending',
      'submittedDate': DateTime.now().toIso8601String().substring(0, 10),
    };

    await _db.collection('forms').doc(form.id).set(map);
  }

  Future<List<FormDataModel>> getFormsForUser(String userId) async {
    final result = await _db.collection('forms')
        .where('userId', isEqualTo: userId)
        .get();

    // Filter out archived forms in Dart to avoid needing a Firestore composite index
    final activeDocs = result.docs.where((doc) {
      final status = doc.data()['status'] as String? ?? 'pending';
      return status != 'archived';
    });

    return activeDocs.map((doc) {
      final data = doc.data();
      return FormDataModel(
        id: data['id'] as String,
        serialNo: data['serialNo'] as String,
        title: data['title'] as String,
        firstName: data['firstName'] as String,
        lastName: data['lastName'] as String,
        initial: data['initial'] as String,
        email: data['email'] as String,
        fatherName: data['fatherName'] as String,
        dob: data['dob'] as String,
        gender: data['gender'] as String,
        profession: data['profession'] as String,
        mailingStreet: data['mailingStreet'] as String,
        mailingCity: data['mailingCity'] as String,
        mailingPostal: data['mailingPostal'] as String,
        mailingCountry: data['mailingCountry'] as String,
        serviceProvider: data['serviceProvider'] as String,
        fileNo: data['fileNo'] as String,
        referenceNo: data['referenceNo'] as String,
        simNo: data['simNo'] as String,
        imsi1: data['imsi1'] as String,
        imsi2: data['imsi2'] as String,
        typeOfPlan: data['typeOfPlan'] as String,
        creditCardType: data['creditCardType'] as String,
        contractValue: data['contractValue'] as String,
        dateOfIssue: data['dateOfIssue'] as String,
        dateOfRenewal: data['dateOfRenewal'] as String,
        installment: data['installment'] as String,
        amountInWords: data['amountInWords'] as String,
        remarks: data['remarks'] as String,
        score: (data['score'] as num?)?.toDouble() ?? 0.0,
        mistakes: (data['mistakes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        status: data['status'] as String? ?? 'pending',
      );
    }).toList();
  }

  Future<void> deleteForm(String formId) async {
    await _db.collection('forms').doc(formId).delete();
  }
}
