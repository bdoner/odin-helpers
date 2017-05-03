#import fmt "fmt.odin";
DEBUG :: false;
DEBUG_VERBOSE :: false;
/*

	Let the symbol "+" denote addition of words (i.e., modulo-2^32
	addition). Let X <<< s denote the 32-bit value obtained by circularly
	shifting (rotating) X left by s bit positions. Let not(X) denote the
	bit-wise complement of X, and let X v Y denote the bit-wise OR of X
	and Y. Let X xor Y denote the bit-wise XOR of X and Y, and let XY
	denote the bit-wise AND of X and Y.

*/

immutable _T : [64]u32 = [64]u32 { 
		0xD76AA478,   0xE8C7B756,   0x242070DB,   0xC1BDCEEE,
		0xF57C0FAF,   0x4787C62A,   0xA8304613,   0xFD469501,
		0x698098D8,   0x8B44F7AF,   0xFFFF5BB1,   0x895CD7BE,
		0x6B901122,   0xFD987193,   0xA679438E,   0x49B40821,
		0xF61E2562,   0xC040B340,   0x265E5A51,   0xE9B6C7AA,
		0xD62F105D,   0x02441453,   0xD8A1E681,   0xE7D3FBC8,
		0x21E1CDE6,   0xC33707D6,   0xF4D50D87,   0x455A14ED,
		0xA9E3E905,   0xFCEFA3F8,   0x676F02D9,   0x8D2A4C8A,
		0xFFFA3942,   0x8771F681,   0x6D9D6122,   0xFDE5380C,
		0xA4BEEA44,   0x4BDECFA9,   0xF6BB4B60,   0xBEBFBC70,
		0x289B7EC6,   0xEAA127FA,   0xD4EF3085,   0x04881D05,
		0xD9D4D039,   0xE6DB99E5,   0x1FA27CF8,   0xC4AC5665,
		0xF4292244,   0x432AFF97,   0xAB9423A7,   0xFC93A039,
		0x655B59C3,   0x8F0CCC92,   0xFFEFF47D,   0x85845DD1,
		0x6FA87E4F,   0xFE2CE6E0,   0xA3014314,   0x4E0811A1,
		0xF7537E82,   0xBD3AF235,   0x2AD7D2BB,   0xEB86D391 };

__F :: proc(X, Y, Z: u32) -> u32 {
	return (X & Y) | (~X) & Z;
}

__G :: proc(X, Y, Z: u32) -> u32 { 
	return (X & Z) | Y & (~Z);
}

__H :: proc(X, Y, Z: u32) -> u32 { 
	return (X ~ Y) ~ Z;
}

__I :: proc(X, Y, Z: u32) -> u32 { 
	return (Y ~ (X | (~Z))); 
}


__rol :: proc(val, shifts: u32) -> u32 {
	bits : u32 = size_of_val(val) * 8;
	a := val >> (bits - (shifts % bits));
	b := val << shifts;

	when DEBUG && DEBUG_VERBOSE {
		fmt.printf("__rol\n");
		fmt.printf(" i %b\n", val);
		fmt.printf(" s %d\n", shifts);
		fmt.printf("ls %d\n", (bits - (shifts % bits)));
		fmt.printf(" a %b\n", a);
		fmt.printf(" b %b\n", b);
		fmt.printf("ab %b\n", a | b);
	}
	return a | b;
}

__cpy :: proc(src: ^[]byte, dst: ^[]byte, offset, count: int) {
	for i := offset; i < count; i++ {
		dst[i] = src[i];
	}
}
__xprntl :: proc(list: []byte) {
	fmt.printf("[ ");
	for c, i in list {
		fmt.printf("%X", c);
		if i != len(list)-1 {
			fmt.printf(", ");
		}
		else {
			fmt.printf(" ");
		}
	}
	fmt.printf("]");
}

__xprntl :: proc(list: []u32) {
	fmt.printf("[ ");
	for c, i in list {
		fmt.printf("%X", c);
		if i != len(list)-1 {
			fmt.printf(", ");
		}
		else {
			fmt.printf(" ");
		}
	}
	fmt.printf("]");
}

__flip :: proc(i: u32) -> u32 {
	return (i & 0x000000FF) << ((size_of_val(i) - 1) * 8) | (i & 0x0000FF00) << 8 | (i & 0x00FF0000) >> 8 | (i & 0xFF000000) >> ((size_of_val(i) - 1) * 8);
}

__trn1 :: proc(a, b, c, d: ^u32, k, s, i: u32, X: ^[16]u32) {
	a^ = b^ + __rol(((a^ + __F(b^, c^, d^)) + X^[k]) + _T[i-1], s);
}


__trn2 :: proc(a, b, c, d: ^u32, k, s, i: u32, X: ^[16]u32) {
	a^ = b^ + __rol(a^ + __G(b^, c^, d^) + X^[k] + _T[i-1], s);
}


__trn3 :: proc(a, b, c, d: ^u32, k, s, i: u32, X: ^[16]u32) {
	a^ = b^ + __rol(a^ + __H(b^, c^, d^) + X^[k] + _T[i-1], s);
}


__trn4 :: proc(a, b, c, d: ^u32, k, s, i: u32, X: ^[16]u32) {
	a^ = b^ + __rol(a^ + __I(b^, c^, d^) + X^[k] + _T[i-1], s);
}

BIT_RATIO :: size_of(byte) * 8;
hash :: proc(data_in: []byte) -> string {
	// https://www.ietf.org/rfc/rfc1321.txt
	// http://motp.sourceforge.net/MD5.java
	// https://rosettacode.org/wiki/MD5/Implementation_Debug

	dataLen := len(data_in);
	when DEBUG {
		fmt.println();
		fmt.printf("Input length is %d bytes: ", dataLen);
		__xprntl(data_in);
		//fmt.printf("%v\n", data_in);
	}
	paddingLength := 0;
	lenMod := dataLen % 64;
	if lenMod >= 56 {
		paddingLength = (64 - lenMod) + 56;
	}
	else {
		paddingLength = 56 - lenMod;
	}

	newLen : int = dataLen + paddingLength + 8; //plus 8 bytes (64 bits) for the length
	padded := make([]byte, newLen);
	defer free(padded);

	__cpy(&data_in, &padded, 0, int(dataLen));
	padded[dataLen] = 0x80;

	when DEBUG {
		fmt.println();
		fmt.println();
		fmt.printf("Padding length is %d bytes.\nPadding is: ", paddingLength);
		__xprntl(padded[dataLen..<dataLen+paddingLength]);
	}

	for i := 8; i > 0; i-- {
		padded[newLen-i] = byte((dataLen*8) >> uint(((8 - i) * 8)) & 0x00000000000000ff);
	}


	when DEBUG {
		fmt.println();
		fmt.println();
		fmt.printf("Appending input length: ");
		__xprntl(padded[newLen-8..<newLen]);
		fmt.println();
		fmt.println();
		fmt.printf("Padded input is: ");
		__xprntl(padded);
		//fmt.printf("%v\n", padded2);
		fmt.println();
		fmt.println();
		fmt.printf("Array is now %d bits\n", len(padded) * BIT_RATIO);
		fmt.printf("%d %% 512 == %d\n", len(padded) * BIT_RATIO, (len(padded) * BIT_RATIO) % 512);

		fmt.printf("Total number of 512-bit (16 word) blocks: %d\n", (len(padded) / 4) / 16);
	}

	paddedWord := make([]u32, len(padded) / size_of(u32));
	defer free(paddedWord);
	for i := 0; i < len(paddedWord); i++ {
		a := u32(u32(padded[(i * 4) + 0]) << (8 * 0));
		b := u32(u32(padded[(i * 4) + 1]) << (8 * 1));
		c := u32(u32(padded[(i * 4) + 2]) << (8 * 2));
		d := u32(u32(padded[(i * 4) + 3]) << (8 * 3));
		paddedWord[i] = a | b | c | d;
	}

	A : u32 = 0x67452301;
	B : u32 = 0xefcdab89;
	C : u32 = 0x98badcfe;
	D : u32 = 0x10325476;

	
	 for i in 0..<len(paddedWord)/16 {
		X: [16]u32;

		for j in 0..<16 {
			//fmt.printf("%d of %d\n", i*16+j, len(paddedWord));
			X[j] = u32(paddedWord[i * 16 + j]);
		}

		when DEBUG {
			fmt.println();
			fmt.printf("Starting processing on block #%d: ", i);
			__xprntl(X[..]);
			fmt.printf("\n\n");
		}

		when DEBUG {
			fmt.println();
			fmt.printf("Before all rounds: ");
			fmt.printf("A=%X\t", A);
			fmt.printf("B=%X\t", B);
			fmt.printf("C=%X\t", C);
			fmt.printf("D=%X; ", D);
			fmt.printf("saving as AA/BB/CC/DD");
		}

		AA: u32 = A;
		BB: u32 = B;
		CC: u32 = C;
		DD: u32 = D;

		when DEBUG {
			fmt.println("Round 1, using __F()");
		}		

		__trn1(&A, &B, &C, &D,  0,  7,  1, &X);
		when DEBUG {
			fmt.printf("\tApplying [ABCD %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  0,  7,  1, A, B, C, D,  1-1, _T[ 1-1]);
		}
		__trn1(&D, &A, &B, &C,  1, 12,  2, &X);
		when DEBUG {
			fmt.printf("\tApplying [DABC %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  1, 12,  2, A, B, C, D,  2-1, _T[ 2-1]);
		}
		__trn1(&C, &D, &A, &B,  2, 17,  3, &X);
		when DEBUG {
			fmt.printf("\tApplying [CDAB %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  2, 17,  3, A, B, C, D,  3-1, _T[ 3-1]);
		}
		__trn1(&B, &C, &D, &A,  3, 22,  4, &X);
		when DEBUG {
			fmt.printf("\tApplying [BCDA %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  3, 22,  4, A, B, C, D,  4-1, _T[ 4-1]);
			fmt.println();
		}
		__trn1(&A, &B, &C, &D,  4,  7,  5, &X);
		when DEBUG {
			fmt.printf("\tApplying [ABCD %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  4,  7,  5, A, B, C, D,  5-1, _T[ 5-1]);
		}
		__trn1(&D, &A, &B, &C,  5, 12,  6, &X);
		when DEBUG {
			fmt.printf("\tApplying [DABC %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  5, 12,  6, A, B, C, D,  6-1, _T[ 6-1]);
		}
		__trn1(&C, &D, &A, &B,  6, 17,  7, &X);
		when DEBUG {
			fmt.printf("\tApplying [CDAB %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  6, 17,  7, A, B, C, D,  7-1, _T[ 7-1]);
		}
		__trn1(&B, &C, &D, &A,  7, 22,  8, &X);
		when DEBUG {
			fmt.printf("\tApplying [BCDA %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  7, 22,  8, A, B, C, D,  8-1, _T[ 8-1]);
			fmt.println();
		}
		__trn1(&A, &B, &C, &D,  8,  7,  9, &X);
		when DEBUG {
			fmt.printf("\tApplying [ABCD %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  8,  7,  9, A, B, C, D,  9-1, _T[ 9-1]);
		}
		__trn1(&D, &A, &B, &C,  9, 12, 10, &X);
		when DEBUG {
			fmt.printf("\tApplying [DABC %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  9, 12, 10, A, B, C, D, 10-1, _T[10-1]);
		}
		__trn1(&C, &D, &A, &B, 10, 17, 11, &X);
		when DEBUG {
			fmt.printf("\tApplying [CDAB %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 10, 17, 11, A, B, C, D, 11-1, _T[11-1]);
		}
		__trn1(&B, &C, &D, &A, 11, 22, 12, &X);
		when DEBUG {
			fmt.printf("\tApplying [BCDA %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 11, 22, 12, A, B, C, D, 12-1, _T[12-1]);
			fmt.println();
		}
		__trn1(&A, &B, &C, &D, 12,  7, 13, &X);
		when DEBUG {
			fmt.printf("\tApplying [ABCD %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 12,  7, 13, A, B, C, D, 13-1, _T[13-1]);
		}
		__trn1(&D, &A, &B, &C, 13, 12, 14, &X);
		when DEBUG {
			fmt.printf("\tApplying [DABC %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 13, 12, 14, A, B, C, D, 14-1, _T[14-1]);
		}
		__trn1(&C, &D, &A, &B, 14, 17, 15, &X);
		when DEBUG {
			fmt.printf("\tApplying [CDAB %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 14, 17, 15, A, B, C, D, 15-1, _T[15-1]);
		}
		__trn1(&B, &C, &D, &A, 15, 22, 16, &X);
		when DEBUG {
			fmt.printf("\tApplying [BCDA %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 15, 22, 16, A, B, C, D, 16-1, _T[16-1]);
			fmt.println();
		}


		when DEBUG {
			fmt.println("Round 2, using __G()");
		}

		__trn2(&A, &B, &C, &D,  1,  5, 17, &X);
		when DEBUG {
			fmt.printf("\tApplying [ABCD %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  1,  5, 17, A, B, C, D, 17-1, _T[17-1]);
		}
		__trn2(&D, &A, &B, &C,  6,  9, 18, &X);
		when DEBUG {
			fmt.printf("\tApplying [DABC %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  6,  9, 18, A, B, C, D, 18-1, _T[18-1]);
		}
		__trn2(&C, &D, &A, &B, 11, 14, 19, &X);
		when DEBUG {
			fmt.printf("\tApplying [CDAB %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 11, 14, 19, A, B, C, D, 19-1, _T[19-1]);
		}
		__trn2(&B, &C, &D, &A,  0, 20, 20, &X);
		when DEBUG {
			fmt.printf("\tApplying [BCDA %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  0, 20, 20, A, B, C, D, 20-1, _T[20-1]);
			fmt.println();
		}
		__trn2(&A, &B, &C, &D,  5,  5, 21, &X);
		when DEBUG {
			fmt.printf("\tApplying [ABCD %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  5,  5, 21, A, B, C, D, 21-1, _T[21-1]);
		}
		__trn2(&D, &A, &B, &C, 10,  9, 22, &X);
		when DEBUG {
			fmt.printf("\tApplying [DABC %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 10,  9, 22, A, B, C, D, 22-1, _T[22-1]);
		}
		__trn2(&C, &D, &A, &B, 15, 14, 23, &X);
		when DEBUG {
			fmt.printf("\tApplying [CDAB %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 15, 14, 23, A, B, C, D, 23-1, _T[23-1]);
		}
		__trn2(&B, &C, &D, &A,  4, 20, 24, &X);
		when DEBUG {
			fmt.printf("\tApplying [BCDA %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  4, 20, 24, A, B, C, D, 24-1, _T[24-1]);
			fmt.println();
		}
		__trn2(&A, &B, &C, &D,  9,  5, 25, &X);
		when DEBUG {
			fmt.printf("\tApplying [ABCD %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  9,  5, 25, A, B, C, D, 25-1, _T[25-1]);
		}
		__trn2(&D, &A, &B, &C, 14,  9, 26, &X);
		when DEBUG {
			fmt.printf("\tApplying [DABC %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 14,  9, 26, A, B, C, D, 26-1, _T[26-1]);
		}
		__trn2(&C, &D, &A, &B,  3, 14, 27, &X);
		when DEBUG {
			fmt.printf("\tApplying [CDAB %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  3, 14, 27, A, B, C, D, 27-1, _T[27-1]);
		}
		__trn2(&B, &C, &D, &A,  8, 20, 28, &X);
		when DEBUG {
			fmt.printf("\tApplying [BCDA %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  8, 20, 28, A, B, C, D, 28-1, _T[28-1]);
			fmt.println();
		}
		__trn2(&A, &B, &C, &D, 13,  5, 29, &X);
		when DEBUG {
			fmt.printf("\tApplying [ABCD %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 13,  5, 29, A, B, C, D, 29-1, _T[29-1]);
		}
		__trn2(&D, &A, &B, &C,  2,  9, 30, &X);
		when DEBUG {
			fmt.printf("\tApplying [DABC %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  2,  9, 30, A, B, C, D, 30-1, _T[30-1]);
		}
		__trn2(&C, &D, &A, &B,  7, 14, 31, &X);
		when DEBUG {
			fmt.printf("\tApplying [CDAB %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  7, 14, 31, A, B, C, D, 31-1, _T[31-1]);
		}
		__trn2(&B, &C, &D, &A, 12, 20, 32, &X);
		when DEBUG {
			fmt.printf("\tApplying [BCDA %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 12, 20, 32, A, B, C, D, 32-1, _T[32-1]);
			fmt.println();
		}


		when DEBUG {
			fmt.println("Round 3, using __H()");
		}

		__trn3(&A, &B, &C, &D,  5,  4, 33, &X);
		when DEBUG {
			fmt.printf("\tApplying [ABCD %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  5,  4, 33, A, B, C, D, 33-1, _T[33-1]);
		}
		__trn3(&D, &A, &B, &C,  8, 11, 34, &X);
		when DEBUG {
			fmt.printf("\tApplying [DABC %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  8, 11, 34, A, B, C, D, 34-1, _T[34-1]);
		}
		__trn3(&C, &D, &A, &B, 11, 16, 35, &X);
		when DEBUG {
			fmt.printf("\tApplying [CDAB %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 11, 16, 35, A, B, C, D, 35-1, _T[35-1]);
		}
		__trn3(&B, &C, &D, &A, 14, 23, 36, &X);
		when DEBUG {
			fmt.printf("\tApplying [BCDA %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 14, 23, 36, A, B, C, D, 36-1, _T[36-1]);
			fmt.println();
		}
		__trn3(&A, &B, &C, &D,  1,  4, 37, &X);
		when DEBUG {
			fmt.printf("\tApplying [ABCD %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  1,  4, 37, A, B, C, D, 37-1, _T[37-1]);
		}
		__trn3(&D, &A, &B, &C,  4, 11, 38, &X);
		when DEBUG {
			fmt.printf("\tApplying [DABC %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  4, 11, 38, A, B, C, D, 38-1, _T[38-1]);
		}
		__trn3(&C, &D, &A, &B,  7, 16, 39, &X);
		when DEBUG {
			fmt.printf("\tApplying [CDAB %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  7, 16, 39, A, B, C, D, 39-1, _T[39-1]);
		}
		__trn3(&B, &C, &D, &A, 10, 23, 40, &X);
		when DEBUG {
			fmt.printf("\tApplying [BCDA %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 10, 23, 40, A, B, C, D, 40-1, _T[40-1]);
			fmt.println();
		}
		__trn3(&A, &B, &C, &D, 13,  4, 41, &X);
		when DEBUG {
			fmt.printf("\tApplying [ABCD %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 13,  4, 41, A, B, C, D, 41-1, _T[41-1]);
		}
		__trn3(&D, &A, &B, &C,  0, 11, 42, &X);
		when DEBUG {
			fmt.printf("\tApplying [DABC %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  0, 11, 42, A, B, C, D, 42-1, _T[42-1]);
		}
		__trn3(&C, &D, &A, &B,  3, 16, 43, &X);
		when DEBUG {
			fmt.printf("\tApplying [CDAB %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  3, 16, 43, A, B, C, D, 43-1, _T[43-1]);
		}
		__trn3(&B, &C, &D, &A,  6, 23, 44, &X);
		when DEBUG {
			fmt.printf("\tApplying [BCDA %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  6, 23, 44, A, B, C, D, 44-1, _T[44-1]);
			fmt.println();
		}
		__trn3(&A, &B, &C, &D,  9,  4, 45, &X);
		when DEBUG {
			fmt.printf("\tApplying [ABCD %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  9,  4, 45, A, B, C, D, 45-1, _T[45-1]);
		}
		__trn3(&D, &A, &B, &C, 12, 11, 46, &X);
		when DEBUG {
			fmt.printf("\tApplying [DABC %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 12, 11, 46, A, B, C, D, 46-1, _T[46-1]);
		}
		__trn3(&C, &D, &A, &B, 15, 16, 47, &X);
		when DEBUG {
			fmt.printf("\tApplying [CDAB %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 15, 16, 47, A, B, C, D, 47-1, _T[47-1]);
		}
		__trn3(&B, &C, &D, &A,  2, 23, 48, &X);
		when DEBUG {
			fmt.printf("\tApplying [BCDA %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  2, 23, 48, A, B, C, D, 48-1, _T[48-1]);
			fmt.println();
		}


		when DEBUG {
			fmt.println("Round 4, using __I()");
		}

		__trn4(&A, &B, &C, &D,  0,  6, 49, &X);
		when DEBUG {
			fmt.printf("\tApplying [ABCD %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  0,  6, 49, A, B, C, D, 49-1, _T[49-1]);
		}
		__trn4(&D, &A, &B, &C,  7, 10, 50, &X);
		when DEBUG {
			fmt.printf("\tApplying [DABC %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  7, 10, 50, A, B, C, D, 50-1, _T[50-1]);
		}
		__trn4(&C, &D, &A, &B, 14, 15, 51, &X);
		when DEBUG {
			fmt.printf("\tApplying [CDAB %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 14, 15, 51, A, B, C, D, 51-1, _T[51-1]);
		}
		__trn4(&B, &C, &D, &A,  5, 21, 52, &X);
		when DEBUG {
			fmt.printf("\tApplying [BCDA %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  5, 21, 52, A, B, C, D, 52-1, _T[52-1]);
			fmt.println();
		}
		__trn4(&A, &B, &C, &D, 12,  6, 53, &X);
		when DEBUG {
			fmt.printf("\tApplying [ABCD %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 12,  6, 53, A, B, C, D, 53-1, _T[53-1]);
		}
		__trn4(&D, &A, &B, &C,  3, 10, 54, &X);
		when DEBUG {
			fmt.printf("\tApplying [DABC %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  3, 10, 54, A, B, C, D, 54-1, _T[54-1]);
		}
		__trn4(&C, &D, &A, &B, 10, 15, 55, &X);
		when DEBUG {
			fmt.printf("\tApplying [CDAB %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 10, 15, 55, A, B, C, D, 55-1, _T[55-1]);
		}
		__trn4(&B, &C, &D, &A,  1, 21, 56, &X);
		when DEBUG {
			fmt.printf("\tApplying [BCDA %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  1, 21, 56, A, B, C, D, 56-1, _T[56-1]);
			fmt.println();
		}
		__trn4(&A, &B, &C, &D,  8,  6, 57, &X);
		when DEBUG {
			fmt.printf("\tApplying [ABCD %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  8,  6, 57, A, B, C, D, 57-1, _T[57-1]);
		}
		__trn4(&D, &A, &B, &C, 15, 10, 58, &X);
		when DEBUG {
			fmt.printf("\tApplying [DABC %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 15, 10, 58, A, B, C, D, 58-1, _T[58-1]);
		}
		__trn4(&C, &D, &A, &B,  6, 15, 59, &X);
		when DEBUG {
			fmt.printf("\tApplying [CDAB %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  6, 15, 59, A, B, C, D, 59-1, _T[59-1]);
		}
		__trn4(&B, &C, &D, &A, 13, 21, 60, &X);
		when DEBUG {
			fmt.printf("\tApplying [BCDA %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 13, 21, 60, A, B, C, D, 60-1, _T[60-1]);
			fmt.println();
		}
		__trn4(&A, &B, &C, &D,  4,  6, 61, &X);
		when DEBUG {
			fmt.printf("\tApplying [ABCD %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  4,  6, 61, A, B, C, D, 61-1, _T[61-1]);
		}
		__trn4(&D, &A, &B, &C, 11, 10, 62, &X);
		when DEBUG {
			fmt.printf("\tApplying [DABC %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n", 11, 10, 62, A, B, C, D, 62-1, _T[62-1]);
		}
		__trn4(&C, &D, &A, &B,  2, 15, 63, &X);
		when DEBUG {
			fmt.printf("\tApplying [CDAB %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  2, 15, 63, A, B, C, D, 63-1, _T[63-1]);
		}
		__trn4(&B, &C, &D, &A,  9, 21, 64, &X);
		when DEBUG {
			fmt.printf("\tApplying [BCDA %d %d %d]:\tA=%X B=%X C=%X D=%X T[%d]=%X\n",  9, 21, 64, A, B, C, D, 64-1, _T[64-1]);
			fmt.println();
		}

		
		A = A + AA;
		B = B + BB;
		C = C + CC;
		D = D + DD;

		when DEBUG {
			fmt.println();
			fmt.printf("After adding original values (AA/BB/CC/DD): A=%X B=%X C=%X D=%X\n", A, B, C, D);
		}
	}


	outp := make([]byte, 16);
	defer free(outp);
	for i in 0..<4 {
		outp[i + 0] = byte(A >> u8(i * 8));
	}
	for i in 0..<4{
		outp[i + 4] = byte(B >> u8(i * 8));
	}
	for i in 0..<4 {
		outp[i + 8] = byte(C >> u8(i * 8));
	}
	for i in 0..<4 {
		outp[i +12] = byte(D >> u8(i * 8));
	}

	outps := make([]byte, 32);
	defer free(outps);
	hexChars := "0123456789abcdef";
	for b, i in outp {
		// 0x0C
		bh, bl: =
			(b << 0) >> 4,
			(b << 4) >> 4;
		outps[i * 2] = hexChars[bh];
		outps[i * 2 + 1] = hexChars[bl];
	}

	when DEBUG {
		fmt.printf("output is: ");
		__xprntl(outps);
		fmt.println();
	}

	return string(outps);
	
}


