import 'dart:developer';
import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';
import '/utils.dart';
import 'package:uuid/uuid.dart';

class AppwriteUtils {
  final Client appwriteClient = Client();

  /// for "users" collection on appwrite database
  final String _collectionUsers = "628e49f2dcab4b4a03d8";

  AppwriteUtils() {
    appwriteClient
        .setEndpoint("http://localhost/v1")
        .setProject("628688ef0d93ff255a22")
        .setKey(
            "4ae9a243c98749a41714c2dfcfc6d2947e31fdc94bfb29ba5def53cc5deb776b3340295df96d0954ec3fb5e5a2bca3d0da167e8ba333c5ab842831fd4eed72be9ea2d774e43ab7f13b86076dd32109c09722379900fd8ff7f822c8a937663aae6c94a25ff343dde27f9ef5741b541feccb8cfef0c89975f8fe67847372681711");
  }

  Future<bool> addUser({
    required String userName,
    required String tagLine,
  }) async {
    Database database = Database(appwriteClient);
    var uuid = Uuid();

    logger.i(
        "AppwriteUtils - addUser - username = $userName, tagline = $tagLine");

    try {
      Document result = await database.createDocument(
        collectionId: _collectionUsers,
        documentId: uuid.v1(),
        data: {
          "username": userName,
          "tagline": tagLine,
        },
      );

      logger.i(
          "AppwriteUtils - addUser - collection created successfully - $result");
      return true;
    } on AppwriteException catch (e) {
      logger.e("CreateDocument - error - ${e.message}");
      return false;
    }
  }

  createAttribute({required String attributeName}) async {
    Database database = Database(appwriteClient);

    /* final result =  */await database
        .createStringAttribute(
      collectionId: _collectionUsers,
      key: attributeName,
      size: 50,
      xrequired: false,
    )
        .then(
      (value) {
        logger.i(
            "AppwriteUtils - addUser - collection created successfully - $value");
      },
    ).catchError(
      (e) {
        logger.e("CreateStringAttribute - error = ${e.message}");
      },
    );
  }

  Future<bool> isUserRegistered({
    required String tagline,
  }) async {
    Database database = Database(appwriteClient);

    try {
      final result = await database.listDocuments(
        collectionId: _collectionUsers,
      );

      for (int i = 0; i != result.documents.length; i++) {
        log("$i - ${result.documents[i].data["tagline"]}");
        if (result.documents[i].data["tagline"] == tagline) {
          return true;
        }
      }
    } on AppwriteException catch (e) {
      logger.e("AppwriteUtils - getUserList - error = ${e.message}");
    }

    return false;
  }
}

final AppwriteUtils appwriteUtils = AppwriteUtils();
