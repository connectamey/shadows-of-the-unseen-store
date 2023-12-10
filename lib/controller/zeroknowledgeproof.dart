import 'dart:typed_data';
import 'dart:convert';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:crypto/crypto.dart'; // For hashing

class ZeroKnowledgeProof {
  String secret;
  late final BigInt publicValue;
  late final BigInt blindingFactor;
  late final MerlinTranscript transcript;
  late final BigInt commitment;

  ZeroKnowledgeProof._(this.secret);

  factory ZeroKnowledgeProof(String secret) {
    final proof = ZeroKnowledgeProof._(secret);
    proof.publicValue = BigInt.parse(proof.hashString(secret), radix: 16);
    proof.transcript = MerlinTranscript("ZeroKnowledgeProof");
    // Add publicValue to the transcript
    proof.transcript.additionalData("public-value".codeUnits, proof.bigIntToBytes(proof.publicValue));
    return proof;
  }

  BigInt generateCommitment() {
    blindingFactor = BigInt.from(99);
    commitment = blindingFactor * blindingFactor;
    transcript.additionalData("commitment".codeUnits, bigIntToBytes(commitment));
    return commitment;
  }

  // BigInt generateChallenge() {
  //   List<int> challengeBytes = transcript.toBytes("challenge".codeUnits, 16);
  //   return bytesToBigInt(Uint8List.fromList(challengeBytes));
  // }

  BigInt generateProof(BigInt challenge) {
    return publicValue + challenge * blindingFactor;
  }

  bool verify(BigInt proof, BigInt challenge) {
    BigInt expectedProof = publicValue + challenge * blindingFactor;
    return proof == expectedProof;
  }

  String hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Uint8List bigIntToBytes(BigInt bigInt) {
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

