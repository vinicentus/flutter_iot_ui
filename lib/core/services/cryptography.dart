import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt/encrypt_io.dart' as encryptio;
import 'package:pointycastle/asymmetric/api.dart' as pointycastle;

class EncryptorDecryptor {
  Future<pointycastle.RSAPublicKey> loadRsaPublicKey() => encryptio
      .parseKeyFromFile<pointycastle.RSAPublicKey>('resources/public_key.pem');

  Future<pointycastle.RSAPrivateKey> _loadRsaPrivateKey() =>
      encryptio.parseKeyFromFile<pointycastle.RSAPrivateKey>(
          'resources/private_key.pem');

  /// This is temporary, TODO: remove
  loadKeysAndDecrypt() async {
    var privateKey = await _loadRsaPrivateKey();

    // TODO
    var encryptedData =
        'gAAAAABhrytJOQg5vprILyPZYnlh_LMQUBPQjamIwtMoiv0ZipUzRY_iluhN5WthRrjXlMr1z85iyrtZIEAI-1MXeRChoVyF5Q==';
    final encryptedSymmetricKey = encrypt.Encrypted.fromBase64(
        r"cL3Q5VGs/4BbTWDMkF1uOrBhUZliehxkzVl3wYKPFZ8gagoHXtxe+jCSBPWJxEGWeYiRLo6mWwtaZl63voMrSLQ9MHO/DtI0rEElUmCVGJl0WactS2XZ0CVCF08LCHBscyFp5fRgX9KkCG6qmnXnSSQN1/4Wl3fg5f+zbFwoft04nLeAJS94yFAZ+ugXBHfe+8rnMQs/JP7DxQL5NhKwLrEZcMlwt2KOmW8vunLa57dUQuD56TRB7C82GZoOMPd5ujeceA9aq2x5aZ6sH2G2mcBRVn8yorvVmcNYpCOezf7zWGZndKRLvQRY8BGx6Jh+ap0Li+dIX29v5us8IK4/Eg==");

    return decryptBoth(privateKey, encryptedSymmetricKey, encryptedData);
  }

  Future<String> decryptBoth(pointycastle.RSAPrivateKey privateRsaKey,
      encrypt.Encrypted encryptedFernetKey, String encryptedData) async {
    var symmetricKey =
        await _decryptKeyAsymmetric(privateRsaKey, encryptedFernetKey);

    var decryptedData =
        await _decryptDataSymmetric(symmetricKey, encryptedData);

    print(decryptedData);

    return decryptedData;
  }

  Future<String> _decryptKeyAsymmetric(pointycastle.RSAPrivateKey rsaPrivateKey,
      encrypt.Encrypted encryptedSymmetricKey) async {
    final privKey = rsaPrivateKey;

    final encrypter = encrypt.Encrypter(
        encrypt.RSA(privateKey: privKey, encoding: encrypt.RSAEncoding.OAEP));

    final decrypted = encrypter.decrypt(encryptedSymmetricKey);

    print(decrypted);
    return decrypted;
  }

  Future<String> _decryptDataSymmetric(
      String symmetricKey, String encryptedData) async {
    var encrypted = encrypt.Encrypted.fromBase64(encryptedData);

    final b64key = encrypt.Key.fromBase64(symmetricKey);
    final fernet = encrypt.Fernet(b64key);
    final encrypter = encrypt.Encrypter(fernet);

    final decrypted = encrypter.decrypt(encrypted);

    print(decrypted);
    print(encrypted.base64); // random cipher text
    print(fernet.extractTimestamp(encrypted.bytes)); // unix timestamp

    return decrypted;
  }
}
