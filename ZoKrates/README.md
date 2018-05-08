# Using ZoKrates

## Step 1: "Trusted setup" - Done only once by a trusted third party
1. Write the code of the program you want to use, in a file (eg: `factorize.code`):
```bash
def main(c, private a, private b):
  	c == a * b
	return 1
```
2. Compile the program down to an arithmetic circuit:
```bash
zokrates compile -i factorize.code
```
3. Compute the setup:
```bash
zokrates setup
```
The output of this serie of commands contain the files `verifiation.key` and `proving.key`.
These two files are made public for anyone to generate proofs for the program defined earlier.
4. The trusted party, then generates a solidity contract (`verifier.sol`) containing the hardcoded verification key.
```bash
zokrates export-verifier
```
5. The trusted third party deploy the `verifier.sol` contract on the blockchain for anyone to use it.

## Step 2: User of the network using the output of the setup to generate proofs
1. Compute the witness
```bash
zokrates compute-witness -a 21 --interactive
```
This command allow a member of the network to generate a proof of knowledge satisfying the program of the trusted party. In the case of the "factorization" problem (`factorize.code`), `21` represents the number we want to prove we know a factorization for, and the `--interactive` flag allows to provide the private arguments interactively via the command line (these private arguments are the solution to the problem, so they should be kept secret !). In ur example, these private arguments would be `3` and `7` for instance.
2. Generate a proof
```bash
zokrates generate-proof > proof
```
