// ignore_for_file: non_constant_identifier_names
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:get_driver_app/models/user_model.dart';

class UnkownFirestoreException implements Exception {
  final String message;

  UnkownFirestoreException(this.message);
}

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  User? user = _auth.currentUser;

  Future<void> uploadSignUpInfo(
    UserModel userModel,
    String id,
  ) async {
    try {
      _firestore.collection('Users').doc(id).set(userModel.toJson());
      log(userModel.toJson().toString());
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> postDetailsToFireStore(
    String fName,
    String lName,
    String id,
    String email,
    String photoUrl,
    bool firstTime,
  ) async {
    User? firebaseUser = _auth.currentUser;
    try {
      UserModel userModel = UserModel(
        firstName: fName,
        lastName: lName,
        email: email,
        id: id,
        photoUrl: photoUrl,
        firstTime: firstTime,
      );

      await _firestore.collection('Users').doc(firebaseUser?.uid).set(
            userModel.toJson(),
          );
    } catch (e) {
      log(e.toString());
    }
  }

  Future<UserModel?> getData() async {
    User? firebaseUser = _auth.currentUser;
    UserModel? myUser;
    String? id = firebaseUser?.uid;
    try {
      final data = await _firestore.collection('Users').doc(id).get();
      myUser = UserModel.fromJson(data.data()!);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      throw UnkownFirestoreException(
        "Something went wrong, ${e.message} || ${e.code}",
      );
    }
    return myUser;
  }

  Future<bool> isPresent(String id) async {
    bool isEmpty = false;
    await _firestore
        .collection('Users')
        .doc(id)
        .snapshots()
        .first
        .then((value) {
      isEmpty = false;
      isEmpty = value.exists;
    });
    return isEmpty;
  }

  Future<void> updateData(
    String photoUrl,
    String date,
    int experience,
    int cnic,
    int license,
    String phone,
  ) async {
    User? firebaseUser = _auth.currentUser;

    try {
      String? id;
      if (user == null) {
        final requestData = await FacebookAuth.instance.getUserData();
        id = requestData['id'];
      } else {
        id = firebaseUser?.uid;
      }
      var names =
          await FirebaseFirestore.instance.collection('Users').doc(id).get();
      UserModel userModel = UserModel(
        firstName: names.data()?['firstName'],
        lastName: names.data()?['lastName'],
        email: names.data()?['email'],
        id: names.data()?['userId'],
        photoUrl: names.data()?['photoUrl'],
        firstTime: false,
        cnic: cnic,
        phone: phone,
        license: license,
        experience: experience,
        date: date,
      );
      await _firestore.collection('Users').doc(id).update(
            userModel.toJson(),
          );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        e.message,
      );
      throw UnkownFirestoreException(
        'Something went wrong ${e.code} ${e.message}',
      );
    }
  }
}
