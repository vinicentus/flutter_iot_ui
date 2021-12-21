import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt/encrypt_io.dart' as encryptio;
import 'package:flutter/services.dart';
import 'package:pointycastle/asymmetric/api.dart' as pointycastle;

class EncryptorDecryptor {
  Future<pointycastle.RSAPublicKey> rsaPublicKey() => encryptio
      .parseKeyFromFile<pointycastle.RSAPublicKey>('resources/public_key.pem');

  Future<String> rsaPublicKeyString() async {
    var file = await rootBundle.loadString('resources/public_key.pem');
    return file;
  }

  Future<pointycastle.RSAPrivateKey> _rsaPrivateKey() =>
      encryptio.parseKeyFromFile<pointycastle.RSAPrivateKey>(
          'resources/private_key.pem');

  Future<String> decryptBoth(
      String encryptedFernetKey, String encryptedData) async {
    var privateRsaKey = await _rsaPrivateKey();

    var fernet2 = encrypt.Encrypted.fromBase64(encryptedFernetKey);

    var symmetricKey = _decryptKeyAsymmetric(privateRsaKey, fernet2);
    var decryptedData = _decryptDataSymmetric(symmetricKey, encryptedData);

    return decryptedData;
  }

  String _decryptKeyAsymmetric(pointycastle.RSAPrivateKey rsaPrivateKey,
      encrypt.Encrypted encryptedSymmetricKey) {
    final encrypter = encrypt.Encrypter(encrypt.RSA(
        privateKey: rsaPrivateKey, encoding: encrypt.RSAEncoding.OAEP));

    final decrypted = encrypter.decrypt(encryptedSymmetricKey);

    return decrypted;
  }

  String _decryptDataSymmetric(String symmetricKey, String encryptedData) {
    var encrypted = encrypt.Encrypted.fromBase64(encryptedData);

    final b64key = encrypt.Key.fromBase64(symmetricKey);
    final fernet = encrypt.Fernet(b64key);
    final encrypter = encrypt.Encrypter(fernet);

    final decrypted = encrypter.decrypt(encrypted);

    return decrypted;
  }

  /// Returns a list containing first the assymetrically encrypted symmetric key as base64,
  /// then as second element the symmetically encrypted data as base64.
  List<String> encryptBoth(String data, String rsaPublicKey) {
    var list = _encryptSymmetric(data);
    var symmetricKey = list[0];
    var encryptedData = list[1];
    var encryptedSymmetricKey = _encryptAsymmetric(symmetricKey, rsaPublicKey);

    return <String>[encryptedSymmetricKey, encryptedData];
  }

  /// Encrypts and converts to base64.
  String _encryptAsymmetric(String symmetricKey, String rsaPublicKey) {
    final parsedKey =
        encrypt.RSAKeyParser().parse(rsaPublicKey) as pointycastle.RSAPublicKey;

    final encrypter = encrypt.Encrypter(
        encrypt.RSA(publicKey: parsedKey, encoding: encrypt.RSAEncoding.OAEP));

    return encrypter.encrypt(symmetricKey).base64;
  }

  /// Returns base64 key and data.
  List<String> _encryptSymmetric(String data) {
    final newKey = encrypt.Key.fromSecureRandom(32);
    final fernet = encrypt.Fernet(newKey);
    final encrypter = encrypt.Encrypter(fernet);

    final encryptedData = encrypter.encrypt(data);

    final symmetricKey = newKey.base64;
    return [symmetricKey, encryptedData.base64];
  }

  /// Requires asymetrically encrypted symmetric key (base64 encoded),
  /// and encrypted data (base4 encoded).
  String encodeBase64KeyAndData(String key, String data) {
    var map = {'key': key, 'data': data};

    return base64.encode(utf8.encode(json.encode(map)));
  }
}
