import 'dart:typed_data';
import 'dart:math';
import 'package:blockchain_utils/blockchain_utils.dart';

class ZeroKnowledgeProof {
  final int secret;
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
    BigInt proof;
    if (secret >= 18) {
      proof = publicValue + challenge * blindingFactor; // Valid proof for secret >= 18
    } else {
      proof = challenge * blindingFactor; // Invalid proof for secret < 18
    }
    return proof;
  }

  bool verify(BigInt proof, BigInt challenge) {
    BigInt expectedProof = publicValue + challenge * blindingFactor;
    return expectedProof == proof;
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

void main() {
  int secretNumber = 19; // Alice's secret
  ZeroKnowledgeProof zkp = ZeroKnowledgeProof(secretNumber);

  // Alice's part
  BigInt commitment = zkp.generateCommitment();

  // Generate challenge using the transcript
  BigInt challenge = zkp.generateChallenge();

  // Alice's part: Generates a proof based on the challenge
  BigInt proof = zkp.generateProof(challenge);

  // Bob's part: Verifies the proof
  bool isValid = zkp.verify(proof, challenge);
  print(isValid ? "Proof is valid" : "Proof is invalid");
}
