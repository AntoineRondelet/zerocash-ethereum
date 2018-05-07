pragma solidity ^0.4.19;

library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() internal returns (G1Point) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() internal returns (G2Point) {
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
    }
    /// @return the negation of p, i.e. p.add(p.negate()) should be zero.
    function negate(G1Point p) internal returns (G1Point) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return the sum of two points of G1
    function add(G1Point p1, G1Point p2) internal returns (G1Point r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 6, 0, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid }
        }
        require(success);
    }
    /// @return the product of a point on G1 and a scalar, i.e.
    /// p == p.mul(1) and p.add(p) == p.mul(2) for all points p.
    function mul(G1Point p, uint s) internal returns (G1Point r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 7, 0, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] p1, G2Point[] p2) internal returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 8, 0, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point a1, G2Point a2, G1Point b1, G2Point b2) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point a1, G2Point a2,
            G1Point b1, G2Point b2,
            G1Point c1, G2Point c2
    ) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point a1, G2Point a2,
            G1Point b1, G2Point b2,
            G1Point c1, G2Point c2,
            G1Point d1, G2Point d2
    ) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}

contract SumsToFifteenDebug {
    // Verifier code - Beginning
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G2Point A;
        Pairing.G1Point B;
        Pairing.G2Point C;
        Pairing.G2Point gamma;
        Pairing.G1Point gammaBeta1;
        Pairing.G2Point gammaBeta2;
        Pairing.G2Point Z;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G1Point A_p;
        Pairing.G2Point B;
        Pairing.G1Point B_p;
        Pairing.G1Point C;
        Pairing.G1Point C_p;
        Pairing.G1Point K;
        Pairing.G1Point H;
    }
    function verifyingKey() internal returns (VerifyingKey vk) {
        vk.A = Pairing.G2Point([0x9bf0304747059207191e39d47679755d774ee1a3ef62b7f286bad4b448e9651, 0xf26e39cc03e7d5d7908cea272613cd624efacbb8b5cb0641307acb15dfc06eb], [0x1d3517ab48a2c914b2778eae9ca2dc73474c82baa7852a21abb6c2b356a4d0d7, 0x4e289d0df15d64a1b69b09eff13706d9522cc96c7978e10af65ccd1bfce8b54]);
        vk.B = Pairing.G1Point(0xc368888d6c5c3cbb058e77eb7c03903d12a3c96dc330368230ecb2309ac4b76, 0x1b81a7f32beca5fab7848acfa504fe60576fe38195cd33e7dd55ecd1186a6775);
        vk.C = Pairing.G2Point([0x2d4b534fdc59468b41ea75bae75a12ac4dfa3ffb05ab9a414a673f546bb0f092, 0x8e93dd601fa15ee8a9c676576be4409432940cf94f9b534a17c71f7e365376e], [0xa394985f7ad2e7c23ac4310f0d574c6ae725c5de71228cad4442bf8d71e601c, 0x11baf5fdf558a34042647f0282e89a75eadae268f13a9ecab2122030749c355b]);
        vk.gamma = Pairing.G2Point([0x2cd9c74970e3cd16be65d4c3916a91f22b60953a851a583541652e53f3989823, 0x17fd297424ab663c866153747f9d2dcf53c5506dfae5f98361b79acdda712ac9], [0x1238d2e623b5d05d62f65136be8010eca5ccd3acb5166118564b52e48be2caf2, 0x2c042ef137a67532cbbdc419a8fdee54e34f9f90a009766fdf3f24743f9b0d56]);
        vk.gammaBeta1 = Pairing.G1Point(0xf05be661e3b449c81b4414bec8be0f7bb305e110d625b809742b542182222ce, 0xa7a385621ba50b9f2ba0da6e87a98df5f836571def5303bc34c836e94d5b8ca);
        vk.gammaBeta2 = Pairing.G2Point([0x17154526b9463f66917b5ec96f3f699b5b51282679aa64338ed1462ef921eb99, 0x113735be3fef27dec034b6d687be7cb9da1dce84e098a101f031dfbd3be622f7], [0x17d5b5fd9f5904a4df8090c9b598f3476f947e4dd918ed322b3027256a1a8b8c, 0x23de5bb5da6d552701bd66179d6d56176370d485b98ec7734ea08b4ac8af237a]);
        vk.Z = Pairing.G2Point([0x2be14b1647f761e062c3bfa7102326b2d8357126e4a4f985c85944a475b39e64, 0x28effb771d807bd0b931c6a472bd7c2d336c426f23006a217269f23c057b2824], [0xf8a1442bc3db68b8758e88fd3d9304db58641aa0c198e8fce28383f20fdd2d3, 0x151215b72293c38a7670481e550fd60436f0ba20ba3beeef46a1ce90c2e550b4]);
        vk.IC = new Pairing.G1Point[](3);
        vk.IC[0] = Pairing.G1Point(0x25bc36673baf3610d2136eefdf2232df484857651f5b6831e8941afc61da50a7, 0x1f617b060288e5586bc91875f4dba4c76f84777c6a4ab1b8a9abd34d1aeacc0c);
        vk.IC[1] = Pairing.G1Point(0x15867047835f84d9a8b919b6d8aa1c64a67aa9377213ca700df2e983a7b34645, 0x15950be0161185c50deadca4d4cf216ca69488d57743f0f4ceeb5fcbb9a5452e);
        vk.IC[2] = Pairing.G1Point(0x2bbea1686ed80de3b39ad635857d7a5f9cabf4670d199380bae8d27f49aee6c, 0x10fd117330abf09ef89f61540ccc8148ec4508811becb0c2f14e263e8ea58ff2);
    }
    function verify(uint[] input, Proof proof) internal returns (uint) {
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++)
            vk_x = Pairing.add(vk_x, Pairing.mul(vk.IC[i + 1], input[i]));
        vk_x = Pairing.add(vk_x, vk.IC[0]);
        if (!Pairing.pairingProd2(proof.A, vk.A, Pairing.negate(proof.A_p), Pairing.P2())) return 1;
        if (!Pairing.pairingProd2(vk.B, proof.B, Pairing.negate(proof.B_p), Pairing.P2())) return 2;
        if (!Pairing.pairingProd2(proof.C, vk.C, Pairing.negate(proof.C_p), Pairing.P2())) return 3;
        if (!Pairing.pairingProd3(
            proof.K, vk.gamma,
            Pairing.negate(Pairing.add(vk_x, Pairing.add(proof.A, proof.C))), vk.gammaBeta2,
            Pairing.negate(vk.gammaBeta1), proof.B
        )) return 4;
        if (!Pairing.pairingProd3(
                Pairing.add(vk_x, proof.A), proof.B,
                Pairing.negate(proof.H), vk.Z,
                Pairing.negate(proof.C), Pairing.P2()
        )) return 5;
        return 0;
    }
    event Verified(string);
    function verifyTx(
            uint[2] a,
            uint[2] a_p,
            uint[2][2] b,
            uint[2] b_p,
            uint[2] c,
            uint[2] c_p,
            uint[2] h,
            uint[2] k,
            uint[2] input
        ) returns (bool) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.A_p = Pairing.G1Point(a_p[0], a_p[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.B_p = Pairing.G1Point(b_p[0], b_p[1]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        proof.C_p = Pairing.G1Point(c_p[0], c_p[1]);
        proof.H = Pairing.G1Point(h[0], h[1]);
        proof.K = Pairing.G1Point(k[0], k[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            Verified("Transaction successfully verified.");
            return true;
        } else {
            return false;
        }
    }
    // Verifier code - End

    event LogResult (
        bool res
    );

    bool result;

    bool public success = false;
    function verifyFifteenProofHardcoded() public {
        uint[2] memory a = [0x10c00a39dc7747d769eb81232974ce9a229d110c7987a54c07c034c2c6af8350, 0x2a980770191a8331dbf00379797b63d27c1150dbe47bfc69f998e4c005794a4d];
        uint[2] memory a_p = [0x1623c7fb2136e586f0ef7591b216ea9586ce2cee5a4831147bbbf6f623e9047a, 0x1254c7fb542bd85906eeb8510c4fa5e7f40f88b2bb6fe7127e051eb1e7d6590f];
        uint[2][2] memory b = [[0x2b9b93b9e3833c6279a46894f7cb950f9570888776f8125c912b3515294babe, 0x1922b132a198d5e63f106d04f25a626ea351f9c9baba49e9bf4040098d7d61bd], [0x1f70c44cd6414f96fd2ee08fd7ca409ae0ccf53137ba5a3bc93ffdecd51eb35a, 0x1643d2db0ab4d405f6888bd96ae1fa7cb03ac4771e3da173ad43bdca0df85df6]];
        uint[2] memory b_p = [0x22d92a36476e28555486d2944a4fc1b1e8c36c336b3d0709b9741a5f38e00de3, 0x2c7f1663e80b8c2e3b76a60fcd7c09c72a30c6ce7fc0e347eecc3f5301c6769a];
        uint[2] memory c = [0x1a7872b0ce466bf4a2240f33baabbe8e73c804861b82c72a7aa654f6a9396f86, 0x2f9e2ebc2c99a0b6ef34c7a113bf285dca62d6b938fe4fde6ff9d40539efd0c7];
        uint[2] memory c_p = [0x1d275412b73f78096921ccdc423c4a358faa04b9c55195744eae910275006378, 0x2877b1027b093423c7f8a9e670968112d3c33a39960c5a64e9fd75f1672d51b9];
        uint[2] memory h = [0x142d590c4dc59c9c67104e386f72dcb5660021cdc875e4ca87ce91354cd76d7e, 0xe040b4c5adb5982c32b5917bd9d1a67cf53c0021d10cb13ce0d728d6473b53f];
        uint[2] memory k = [0xba173680de64db289c41b3e4e9523e543a474fcd5e4af6173fe8373b97afc12, 0x221c658314cf8cafb1e9e148c973637e603571833e5e1c6624992109710f1d0];
        uint[2] memory input = [uint256(5), uint256(1)];
        // Verifiy the proof
        success = verifyTx(a, a_p, b, b_p, c, c_p, h, k, input);
        if (success) {
            // Proof verified
            result = true;
            LogResult(result);
        } else {
            // Sorry, bad proof!
            result = false;
            LogResult(result);
        }
    }

    function verifyFifteen(
        uint[2] a,
        uint[2] a_p,
        uint[2][2] b,
        uint[2] b_p,
        uint[2] c,
        uint[2] c_p,
        uint[2] h,
        uint[2] k,
        uint[2] input) public {
        // Verifiy the proof
        success = verifyTx(a, a_p, b, b_p, c, c_p, h, k, input);
        if (success) {
            // Proof verified
            result = true;
            LogResult(result);
        } else {
            // Sorry, bad proof!
            result = false;
            LogResult(result);
        }
    }
}
