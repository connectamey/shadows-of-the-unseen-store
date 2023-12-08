// import 'dart:math';
//
// // Assuming MerlinTranscript class is defined elsewhere in your project
//
// class ZeroKnowledgeProof {
//   final int secret;
//   final BigInt publicValue;
//   late final BigInt blindingFactor;
//   late final BigInt commitment;
//
//   ZeroKnowledgeProof(this.secret)
//       : publicValue = BigInt.from(secret * secret);
//
//   BigInt generateCommitment() {
//     int randomNum = Random().nextInt(100);
//     blindingFactor = BigInt.from(randomNum);
//     // Commitment is calculated as blindingFactor^2 (squared)
//     commitment = blindingFactor * blindingFactor;
//     return commitment;
//   }
//
//   BigInt generateProof(BigInt challenge) {
//     // Proof combines the secret with the challenge and the blinding factor
//     // Proof = secret^2 + challenge * blindingFactor
//     return publicValue + challenge * blindingFactor;
//   }
//
//   bool verify(BigInt proof, BigInt challenge) {
//     // Verification checks if the proof is valid given the public value, commitment, and challenge
//     // Verify if proof = publicValue + challenge * blindingFactor
//     BigInt expectedProof = publicValue + challenge * blindingFactor;
//     return expectedProof == proof;
//   }
//
//   BigInt generateInvalidProof(BigInt challenge) {
//     // Generate an invalid proof by adding an arbitrary number
//     // This disrupts the expected relationship between the proof, secret, and challenge
//     return publicValue + challenge * blindingFactor + BigInt.from(1); // Adding 1 to make it invalid
//   }
//
// }
//
// void main() {
//   int secretNumber = 7; // Alice's secret
//   ZeroKnowledgeProof zkp = ZeroKnowledgeProof(secretNumber);
//
//   // Alice's part
//   BigInt commitment = zkp.generateCommitment();
//
//   // Bob's part: Generates a challenge
//   int randomChallenge = Random().nextInt(100);
//   BigInt challenge = BigInt.from(randomChallenge);
//
//   // Alice's part: Generates an INVALID proof based on the challenge
//   // BigInt invalidProof = zkp.generateInvalidProof(challenge);
//
//   BigInt invalidProof = zkp.generateProof(challenge);
//
//   // Bob's part: Verifies the proof (should fail)
//   bool isValid = zkp.verify(invalidProof, challenge);
//   print(isValid ? "Proof is valid" : "Proof is invalid"); // Should print "Proof is invalid"
// }
//
