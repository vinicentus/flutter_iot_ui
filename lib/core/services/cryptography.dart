import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt/encrypt_io.dart' as encryptio;
import 'package:flutter/services.dart';
import 'package:pointycastle/asymmetric/api.dart' as pointycastle;

class EncryptorDecryptor {
  Future<pointycastle.RSAPublicKey> rsaPublicKey() => encryptio
      .parseKeyFromFile<pointycastle.RSAPublicKey>('resources/public_key.pem');

  Future<String> rsaPublicKeyBase64() async {
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
}
