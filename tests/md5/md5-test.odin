#import fmt "fmt.odin";
#import os "os.odin";
#import md5 "../md5.odin";

_md5_test :: struct {
	str, hash: string
}

main :: proc() {
	INPUT_PATH :: "md5-test.txt";
	file_cont, success := os.read_entire_file(INPUT_PATH);

	if ! success {
		fmt.printf("Can't read file %s :(\n", INPUT_PATH);
		return;
	}

	lines := 0;
	for char in file_cont {
		if char == ':' {
			lines++;
		}
	}

	tests := make([]_md5_test, lines);
	offset, index, testIndex := 0, 0, 0;
	for char in file_cont {
		//fmt.println(index);
		if char == ':' {
			word := make([]byte, index - offset);
			for b, i in file_cont[offset..<index] {
				word[i] = b;
			}
			offset = index + 1; //+1 for the :

			hash := make([]byte, 32);
			for b, i in file_cont[offset..<offset+32] {
				hash[i] = b;
			}

			offset += 32 + 1; //+1 for the \n

			tests[testIndex] = _md5_test{str = string(word), hash = string(hash)};
			testIndex++;

		}
		index++;
	}

	/*
	tests := []_md5_test{
		_md5_test{"", "d41d8cd98f00b204e9800998ecf8427e"},
		_md5_test{"a", "0cc175b9c0f1b6a831c399e269772661"},
		_md5_test{"abc", "900150983cd24fb0d6963f7d28e17f72"},
		_md5_test{"message digest", "f96b697d7cb7938d525a2f31aaf161d0"},
		_md5_test{"abcdefghijklmnopqrstuvwxyz", "c3fcd3d76192e4007dfb496cca67e13b"},
		_md5_test{"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", "d174ab98d277d9f5a5611c2c9f419d9f"},
		_md5_test{"12345678901234567890123456789012345678901234567890123456789012345678901234567890", "57edf4a22be3c955ac49da2e2107b67a"},
	};
	*/
	
	//TESTS
	for test in tests {
		h := md5.hash([]byte(test.str));
		fmt.printf("'%s' ('%s' == '%s'): %v\n", test.str, h, test.hash, h == test.hash);
		if test.hash != h {
			panic(test.str);
		}
	}
}