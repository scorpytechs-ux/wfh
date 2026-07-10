import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
      'typeOfNetwork': form.typeOfNetwork,
      'cellModelNo': form.cellModelNo,
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
      'submittedDate': form.submittedDate ?? DateTime.now().toIso8601String().substring(0, 10),
    };

    await _db.collection('forms').doc(form.id).set(map);
  }

  Future<int> getFormsCountForUser(String userId, {String? monthStr}) async {
    try {
      final querySnapshot = await _db.collection('forms')
          .where('userId', isEqualTo: userId)
          .get();
          
      int count = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (monthStr != null) {
          final date = data['submittedDate'] as String?;
          if (date != null && date.startsWith(monthStr)) {
            count++;
          }
        } else {
          count++;
        }
      }
      return count;
    } catch (e) {
      print('Error fetching forms count: $e');
    }
    return 0;
  }

  Future<List<FormDataModel>> getFormsForUser(String userId, {int page = 1, int limit = 50}) async {
    try {
      final querySnapshot = await _db.collection('forms')
          .where('userId', isEqualTo: userId)
          .get();
      
      List<FormDataModel> parsedForms = [];
      for (var doc in querySnapshot.docs) {
        final docData = doc.data();
        final status = docData['status'] as String? ?? 'pending';
        if (status == 'archived') continue;

        List<dynamic> parsedMistakes = [];
        if (docData['mistakes'] is String) {
          try { parsedMistakes = jsonDecode(docData['mistakes']); } catch (_) {}
        } else if (docData['mistakes'] is List) {
          parsedMistakes = docData['mistakes'];
        }

        parsedForms.add(FormDataModel(
          id: docData['id'] as String? ?? '',
          serialNo: docData['serialNo']?.toString() ?? '',
          title: docData['title'] as String? ?? '',
          firstName: docData['firstName'] as String? ?? '',
          lastName: docData['lastName'] as String? ?? '',
          initial: docData['initial'] as String? ?? '',
          email: docData['email'] as String? ?? '',
          fatherName: docData['fatherName'] as String? ?? '',
          dob: docData['dob'] as String? ?? '',
          gender: docData['gender'] as String? ?? '',
          profession: docData['profession'] as String? ?? '',
          mailingStreet: docData['mailingStreet'] as String? ?? '',
          mailingCity: docData['mailingCity'] as String? ?? '',
          mailingPostal: docData['mailingPostal']?.toString() ?? '',
          mailingCountry: docData['mailingCountry'] as String? ?? '',
          serviceProvider: docData['serviceProvider'] as String? ?? '',
          fileNo: docData['fileNo'] as String? ?? '',
          referenceNo: docData['referenceNo'] as String? ?? '',
          simNo: docData['simNo'] as String? ?? '',
          typeOfNetwork: docData['typeOfNetwork'] as String? ?? '',
          cellModelNo: docData['cellModelNo'] as String? ?? '',
          imsi1: docData['imsi1'] as String? ?? '',
          imsi2: docData['imsi2'] as String? ?? '',
          typeOfPlan: docData['typeOfPlan'] as String? ?? '',
          creditCardType: docData['creditCardType'] as String? ?? '',
          contractValue: docData['contractValue']?.toString() ?? '',
          dateOfIssue: docData['dateOfIssue'] as String? ?? '',
          dateOfRenewal: docData['dateOfRenewal'] as String? ?? '',
          installment: docData['installment']?.toString() ?? '',
          amountInWords: docData['amountInWords'] as String? ?? '',
          remarks: docData['remarks'] as String? ?? '',
          score: (docData['score'] as num?)?.toDouble() ?? 0.0,
          mistakes: parsedMistakes.map((e) => e.toString()).toList(),
          status: status,
          submittedDate: docData['submittedDate'] as String?,
        ));
      }
      
      final startIndex = (page - 1) * limit;
      if (startIndex >= parsedForms.length) return [];
      final endIndex = startIndex + limit;
      return parsedForms.sublist(startIndex, endIndex > parsedForms.length ? parsedForms.length : endIndex);
    } catch (e) {
      print('Error fetching forms from Firestore: $e');
    }
    return [];
  }

  Future<void> deleteForm(String formId) async {
    await _db.collection('forms').doc(formId).delete();
  }

  Future<List<FormDataModel>> getSentFormsForUser(String userId) async {
    try {
      final querySnapshot = await _db.collection('forms')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'sent')
          .get();
      
      List<FormDataModel> parsedForms = [];
      for (var doc in querySnapshot.docs) {
        final docData = doc.data();
        final status = docData['status'] as String? ?? 'pending';

        List<dynamic> parsedMistakes = [];
        if (docData['mistakes'] is String) {
          try { parsedMistakes = jsonDecode(docData['mistakes']); } catch (_) {}
        } else if (docData['mistakes'] is List) {
          parsedMistakes = docData['mistakes'];
        }

        parsedForms.add(FormDataModel(
          id: docData['id'] as String? ?? '',
          serialNo: docData['serialNo']?.toString() ?? '',
          title: docData['title'] as String? ?? '',
          firstName: docData['firstName'] as String? ?? '',
          lastName: docData['lastName'] as String? ?? '',
          initial: docData['initial'] as String? ?? '',
          email: docData['email'] as String? ?? '',
          fatherName: docData['fatherName'] as String? ?? '',
          dob: docData['dob'] as String? ?? '',
          gender: docData['gender'] as String? ?? '',
          profession: docData['profession'] as String? ?? '',
          mailingStreet: docData['mailingStreet'] as String? ?? '',
          mailingCity: docData['mailingCity'] as String? ?? '',
          mailingPostal: docData['mailingPostal']?.toString() ?? '',
          mailingCountry: docData['mailingCountry'] as String? ?? '',
          serviceProvider: docData['serviceProvider'] as String? ?? '',
          fileNo: docData['fileNo'] as String? ?? '',
          referenceNo: docData['referenceNo'] as String? ?? '',
          simNo: docData['simNo'] as String? ?? '',
          typeOfNetwork: docData['typeOfNetwork'] as String? ?? '',
          cellModelNo: docData['cellModelNo'] as String? ?? '',
          imsi1: docData['imsi1'] as String? ?? '',
          imsi2: docData['imsi2'] as String? ?? '',
          typeOfPlan: docData['typeOfPlan'] as String? ?? '',
          creditCardType: docData['creditCardType'] as String? ?? '',
          contractValue: docData['contractValue']?.toString() ?? '',
          dateOfIssue: docData['dateOfIssue'] as String? ?? '',
          dateOfRenewal: docData['dateOfRenewal'] as String? ?? '',
          installment: docData['installment']?.toString() ?? '',
          amountInWords: docData['amountInWords'] as String? ?? '',
          remarks: docData['remarks'] as String? ?? '',
          score: (docData['score'] as num?)?.toDouble() ?? 0.0,
          mistakes: parsedMistakes.map((e) => e.toString()).toList(),
          status: status,
          submittedDate: docData['submittedDate'] as String?,
        ));
      }
      return parsedForms;
    } catch (e) {
      print('Error fetching sent forms from Firestore: $e');
    }
    return [];
  }
}
