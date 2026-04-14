# Chromarotor
An enigma-inspired cipher that uses image pixels as dynamic rotors to encrypt and scramble data.<br>
Hecho en 🇵🇷 por Radamés J. Valentín Reyes <br>
Orgullosamente Boricua<br>
## Note
- Now it works more like enigma. For every byte the rotor configuration (image) changes.
- Incompatible with previous versions
- Takes a lot more time to process
## Features
- Symmetric encryption
- No encryption overhead (file/data size is kept. not increased/bloated)
- Easy to use
- Data obfuscation - Bytes are shuffled.
- Now uses BigInt as seed instead of int
- Now uses big_dec for calculations
- Now uses big_random instead of dart's built in random which is restricted to the size of an int

# Learn the about image generation
[Check out my book on Amazon.](https://www.amazon.com/dp/B0FKB7CPWX)
## Import
~~~dart
import 'package:chromarotor/chromarotor.dart';
~~~
## Generate image
Generates a list of rgb values to be used for encryption
~~~dart
ChromaImage image = generateImage(
  seed: password,
  imageSize: 200,
);
~~~
## Encrypt
~~~dart
List<int> cipheredMessage = chromaRotorCipher(
  chromaImage: image,
  bytes: message.codeUnits,
);
~~~
## Decrypt
~~~dart
List<int> decipheredMessage = chromaRotorDecipher(
  chromaImage: image,
  cipheredBytes: cipheredMessage,
);
~~~
## Full Example
~~~dart
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
print("Deciphered: ${String.fromCharCodes(decipheredMessage)}")
print("Message CodeUnits: ${message.codeUnits}");
print("Ciphered CodeUnits: $cipheredMessage");
print("Deciphered CodeUnits: $decipheredMessage");
~~~
## Credits
- My friend Copilot
- My friend Gemini