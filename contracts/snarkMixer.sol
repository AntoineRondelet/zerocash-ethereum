pragma solidity ^0.4.19;

contract SnarkPrecompile {
    function verify_proof(bytes, bytes, bytes) returns (bool);
}

contract Mixer {
    mapping (bytes32 => bool) public serials;
    mapping (bytes32 => bool) public roots;
    SnarkPrecompile zksnark = SnarkPrecompile(0x0000000000000000000000000000000000000005);

    struct MerkleTree {
        uint currentLeafIndex;
        bytes32[16] leaves;
    }

    MerkleTree public tree;
    bytes public verificationKey;

    function Mixer(bytes _verificationKey) {
        verificationKey = _verificationKey;
        tree.currentLeafIndex = 0;
        for (uint i = 0; i < 16; i++)
            tree.leaves[i] = 0x0;
    }

    // MerkleTree.append(commitment)
    function insert(bytes32 commitment) returns (bool res) {
        if (tree.currentLeafIndex == 16) {
            return false;
        }
        tree.leaves[tree.currentLeafIndex] = commitment;
        tree.currentLeafIndex++;
        return true;
    }

    function getLeaves() constant returns (bytes32[16]) {
        return tree.leaves;
    }

    function getTree() constant returns (bytes32[32] currentTree) {
        // bytes32[32] memory currentTree;
        uint i;
        for (i = 0; i < 16; i++) {
            currentTree[16 + i] = tree.leaves[i];
        }

        for (i = 16 - 1; i > 0; i--) {
            currentTree[i] = sha256(currentTree[i*2], currentTree[i*2+1]);
        }

        return currentTree;
    }

    // MerkleTree.root()
    function getRoot() constant returns(bytes32 root) {
        root = getTree()[1];
    }

    function deposit(bytes32 commitment) returns (bool res) {
        if (msg.value != 1 ether) {
            msg.sender.send(msg.value);
            return false;
        }
        if (!insert(commitment)) {
            msg.sender.send(msg.value);
            return false;
        }
        bytes32 rootTree = getRoot();
        roots[rootTree] = true;
        return true;
    }

    function withdraw(bytes32 serial, address addr, bytes32 rootTree, bytes32 mac, bytes proof) returns (bool success) {
        success = false;
        bytes20 addr_byte = bytes20(addr);
        bytes memory pub = new bytes(128);
        uint i;

        for (i = 0; i < 32; i++) {
            pub[i] = serial[i];
        }

        for (i = 0; i < 20; i++) {
            pub[32 + i] = addr_byte[i];
        }

        for (i = 20; i < 32; i++) {
            pub[32 + i] = 0;
        }

        for (i = 0; i < 32; i++) {
            pub[32*2 + i] = rootTree[i];
        }

        for (i = 0; i < 32; i++) {
            pub[32*3 + i] = mac[i];
        }

        if (roots[rootTree] == true) {
            if (!serials[serial]) {
                if (!zksnark.verify_proof(verificationKey, proof, pub)) {
                    return false;
                }
                serials[serial] = true;
                if (!addr.send(1 ether)) {
                    throw;
                } else {
                    success = true;
                }
            } else {
                return;
            }
        } else {
            return;
        }
    }
}
