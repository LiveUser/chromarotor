import 'dart:math';
import 'package:big_random/big_random.dart';

const _maxInt = 999999999999999999;

class ChromaImage{
  ChromaImage({
    required this.seed,
    required this.image,
  });
  final BigInt seed;
  final List<int> image;
}

// And ensure _shuffleBytes correctly handles the last element:
List<int> _reorderBytes({
  required int seed,
  required List<int> bytes,
}){
  Random random = Random(seed);
  List<int> indicies = List<int>.generate(bytes.length, (i) => i);
  indicies.shuffle(random);

  // Create the inverse permutation map in O(M) time
  List<int> inverseIndicies = List<int>.filled(bytes.length, 0);
  for (int i = 0; i < indicies.length; i++) {
    inverseIndicies[indicies[i]] = i;
  }

  // Apply the inverse permutation in O(M) time
  List<int> orderedBytes = List<int>.filled(bytes.length, 0);
  for (int i = 0; i < bytes.length; i++) {
    orderedBytes[i] = bytes[inverseIndicies[i]];
  }
  return orderedBytes;
}
//Enigma inspired cipher
//------------------------------------------------------------------------------
ChromaImage generateImage({
  required BigInt seed,
  ///Width and height in pixels
  int imageSize = 100,
}){
  List<int> rgb = [];
  int amountOfPixels = imageSize * imageSize;
  BigRandom bigRandom = BigRandom(seed);
  //Solved the multiplication issue with big_dart library
  String maxHexValue = List.filled(amountOfPixels, "FFFFFF").join();
  //print(maxHexValue);
  BigInt maxSeed = BigInt.parse(maxHexValue, radix: 16);
  BigInt operationResult = bigRandom.nextBigInt(maxSeed);
  String seedHex = operationResult.toRadixString(16);
  while(seedHex.length < maxHexValue.length){
    seedHex = "0$seedHex";
  }
  for (int i = 0; i < seedHex.length; i += 6) {
    int index = i.toInt();
    int red = int.parse(seedHex.substring(index, index + 2), radix: 16);
    int green = int.parse(seedHex.substring(index + 2, index + 4), radix: 16);
    int blue = int.parse(seedHex.substring(index + 4, index + 6), radix: 16);
    rgb.addAll([
      red,
      green, 
      blue, 
    ]);
  }
  return ChromaImage(
    seed: seed, 
    image: rgb,
  );
}
//This function is courtessy of Copilot. I don't understand how it works.
int getKeyFromImage({
  required List<int> image,
}){
  int key = 0;

  for (int i = 0; i < image.length; i += 3) {
    int r = image[i];
    int g = image[i + 1];
    int b = image[i + 2];

    // Mix bits with shifting and XOR
    key ^= ((r << 16) | (g << 8) | b);    // Combine RGB into a 24-bit chunk
    key = ((key << 5) | (key >> 27)) & 0xFFFFFFFF; // Rotate key bits to diffuse
  }

  return key;
}
List<int> chromaRotorCipher({
  required ChromaImage chromaImage,
  required List<int> bytes,
}){
  //print("Bytes length: ${bytes.length}");
  BigRandom bigRandom = BigRandom(chromaImage.seed);
  List<int> mutableImage = List.from(chromaImage.image);
  List<int> cipheredBytes = [];
  for(int byteIndex = 0; byteIndex < bytes.length; byteIndex++){
    int byte = bytes[byteIndex];
    for(int index = 0; index < mutableImage.length; index += 3){
      int r = mutableImage[index];
      int g = mutableImage[index + 1];
      int b = mutableImage[index + 2];
      //Perform the rotor shift operations. Made with the Help of Copilot.
      int substituted = (byte + r) % 256;
      int shifted = (substituted + g) % 256;
      int outputByte = shifted ^ b;
      //Store the output byte for the next calculation
      byte = outputByte;
    }
    cipheredBytes.add(byte);
    BigInt bigRandomNumber = bigRandom.nextBigInt(BigInt.from(_maxInt));
    mutableImage.shuffle(Random(bigRandomNumber.toInt()));
  }
  //Suffle bytes
  Random random = Random(getKeyFromImage(
    image: mutableImage,
  ));
  cipheredBytes.shuffle(random);
  return cipheredBytes;
}
List<int> chromaRotorDecipher({
  required ChromaImage chromaImage,
  required List<int> cipheredBytes,
}) {
  // We need to re-run the cipher's state changes to get to the final state
  // This is a necessary step to get the correct keys for the last shuffles
  BigRandom bigRandom = BigRandom(chromaImage.seed);
  List<int> mutableImage = List.from(chromaImage.image);
  List<int> shuffleSeedHistory = [];
  for(int i = 0; i < cipheredBytes.length; i++){
    BigInt bigRandomNumber = bigRandom.nextBigInt(BigInt.from(_maxInt));
    int shuffleSeed = bigRandomNumber.toInt();
    shuffleSeedHistory.add(shuffleSeed);
    mutableImage.shuffle(Random(shuffleSeed));
  }
  
  // Now, `mutableImage` is in the final state from the cipher.
  // We use this final state to reverse the final shuffle on the bytes.
  List<int> reorderedBytes = _reorderBytes(
    seed: getKeyFromImage(image: mutableImage),
    bytes: List.from(cipheredBytes), // Work with a copy to prevent mutation
  );
  
  List<int> decipheredBytes = [];
  
  // Decrypt in a backward loop, reversing the state at each step
  for (int byteIndex = reorderedBytes.length - 1; byteIndex >= 0; byteIndex--) {
    int byte = reorderedBytes[byteIndex];
    
    // Reverse the shuffle on the mutableImage to get to the state before this byte's encryption
    int lastShuffleSeed = shuffleSeedHistory.removeLast();
    mutableImage = _reorderBytes(
      seed: lastShuffleSeed, 
      bytes: List.from(mutableImage), // Work with a copy to prevent side effects
    );

    // Reverse the pixel transformation loop
    for (int index = mutableImage.length - 3; index >= 0; index -= 3) {
      int r = mutableImage[index];
      int g = mutableImage[index + 1];
      int b = mutableImage[index + 2];

      // Reverse operations: XOR, subtract g, subtract r
      int unxor = byte ^ b;
      int unshifted = (unxor - g);
      if (unshifted < 0) unshifted += 256;
      int originalByte = (unshifted - r);
      if (originalByte < 0) originalByte += 256;

      byte = originalByte;
    }
    
    decipheredBytes.insert(0, byte); // Insert at the beginning to reverse the order
  }
  
  return decipheredBytes;
}