import 'package:chromarotor/chromarotor.dart';
import 'package:test/test.dart';

void main() {
  test("Chromarotor Cipher", (){
    BigInt password = BigInt.parse("9684615468496727262");
    ChromaImage image = generateImage(
      seed: password,
      imageSize: 200,
    );
    String message = "Yo soy boricua pa que tu lo sepas.";
    print("Message: $message");
    List<int> cipheredMessage = chromaRotorCipher(
      chromaImage: image,
      bytes: message.codeUnits,
    );
    print("Ciphered: ${String.fromCharCodes(cipheredMessage)}");
    List<int> decipheredMessage = chromaRotorDecipher(
      chromaImage: image,
      cipheredBytes: cipheredMessage,
    );
    print("Deciphered: ${String.fromCharCodes(decipheredMessage)}");

    //print("Message CodeUnits: ${message.codeUnits}");
    //print("Ciphered CodeUnits: $cipheredMessage");
    //print("Deciphered CodeUnits: $decipheredMessage");
  });
}
