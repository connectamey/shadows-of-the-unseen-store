import 'dart:typed_data';
import 'dart:math';
import 'package:blockchain_utils/blockchain_utils.dart';
class ZeroKnowledgeProof {
   int secret;
  final BigInt publicValue;
  late final BigInt blindingFactor;
  late final MerlinTranscript transcript;
  late final BigInt commitment;

  ZeroKnowledgeProof(this.secret)
      : publicValue = BigInt.from(secret * secret) {
    transcript = MerlinTranscript("ZeroKnowledgeProof");
    // Add publicValue to the transcript
    transcript.additionalData("public-value".codeUnits, bigIntToBytes(publicValue));
  }

  BigInt generateCommitment() {
    int randomNum = Random().nextInt(100);
    blindingFactor = BigInt.from(randomNum);
    commitment = blindingFactor * blindingFactor;

    transcript.additionalData("commitment".codeUnits, bigIntToBytes(commitment));
    return commitment;
  }

  BigInt generateChallenge() {
    // Generate a pseudo-random challenge using the transcript
    List<int> challengeBytes = transcript.toBytes("challenge".codeUnits, 16);
    return bytesToBigInt(Uint8List.fromList(challengeBytes));
  }

  BigInt generateProof(BigInt challenge) {
    return publicValue + challenge * blindingFactor;
  }

  bool verify(BigInt proof, BigInt challenge) {
    BigInt expectedProof = publicValue + challenge * blindingFactor;
    if (secret >= 18) {
      return proof == expectedProof; // Ensure the proof is equal to expectedProof for secret >= 18
    } else {
      return proof != expectedProof; // Ensure the proof is not equal to expectedProof for secret < 18
    }
  }

  Uint8List bigIntToBytes(BigInt bigInt) {
    // Getting the byte representation of the BigInt
    var bytes = (bigInt.bitLength + 7) >> 3;
    var b256 = BigInt.from(256);
    var result = Uint8List(bytes);
    for (int i = 0; i < bytes; i++) {
      result[bytes - i - 1] = (bigInt.remainder(b256)).toInt();
      bigInt = bigInt ~/ b256;
    }
    return result;
  }

  BigInt bytesToBigInt(Uint8List bytes) {
    BigInt result = BigInt.from(0);
    for (int i = 0; i < bytes.length; i++) {
      result += BigInt.from(bytes[i]) << (8 * (bytes.length - i - 1));
    }
    return result;
  }
}