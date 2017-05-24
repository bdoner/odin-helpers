#import "fmt.odin";
#import "utf8.odin";

startsWith :: proc(str, s: string) -> bool {
	if len(s) > len(str) {
		return false;
	}

	if str == s {
		return true;
	}

	found := true;
	for i1, i2, size1, size2 := 0, 0, 0, 0; i1 < len(str); {
		if i1 == len(s) {
			break;
		}
		rstr, rs: rune;
		rstr, size1 = utf8.decode_rune(str[i1..]);
		rs, size2 = utf8.decode_rune(s[i2..]);
		if rstr != rs {
			found = false;
		}

		i1 += size1;
		i2 += size2;
	}

	return found;
}

startsWith :: proc(str: string, s: rune) -> bool {
	r, size := utf8.decode_rune(str); //decode rune takes the first rune in a string
	return r == s;
}

startsWith :: proc(str: string, s: byte) -> bool {
	return startsWith(str, rune(s));
}


indexOf :: proc(str: string, s: rune) -> int {
	for b, i in str {
		if b == s {
			return i;
		}
	}
	return -1;
}

indexOf :: proc(str: string, s: byte) -> int {
	return indexOf(str, rune(s));;
}

indexOf :: proc(str, pattern: string) -> int {

	index := -1;
	firstRuneInPattern, _ := utf8.decode_rune(pattern);
	#label outer for i, size := 0, 0; i < len(str)-len(pattern)+1; i += size {
		r: rune;
		r, size = utf8.decode_rune(str[i..]);
		if r == firstRuneInPattern {
			index = i;
			//fmt.printf("First match at %d\n", i);
			#label inner for j, size2 := 0, 0; j < len(pattern); j += size2 {
				if j == len(pattern) {
					//fmt.printf("j == len(pattern)-1 j: %d, len(pattern): %d\n", j, len(pattern));
					index = i;
					break outer;
				}

				t: rune;
				r, size = utf8.decode_rune(str[i+j..]);
				t, size2 = utf8.decode_rune(pattern[j..]);

				//fmt.printf("r: %d, t: %d\n", r, t);
				if r != t {
					index = -1;
					break inner;
				}
			}
		}
	}
	
	return index;
}

join :: proc(list: []string, d: string) -> string {
	if len(list) == 0 {
		return "";
	}
	newLen := 0;
	for s in list {
		newLen = newLen + len(s);
	}
	newLen += (len(list) - 1) * len(d);

	newStr := make([]byte, 0, newLen);
	for s, i in list {
		append(newStr, ..[]byte(s));
		append(newStr, ..[]byte(d));
	}
	return string(newStr);

}

join :: proc(list: []string, d: byte) -> string { 
	return join(list, string([]byte{d}));
}

join :: proc(list: []string, d: rune) -> string {
	str, size := utf8.encode_rune(d);
	return join(list, string(str[..]));
}

split :: proc(input: string, d: rune) -> []string {
	delCount := 1;
	inputLen := len(input);
	for b in input {
		if b == d {
			delCount++;
		}
	}

	lines := make([]string, delCount);
	foundLines := 0;
	for offset, i, size := 0, 0, 0; i < inputLen; i += size {
		r: rune;
		r, size = utf8.decode_rune(input[i..]);

		if r == d {
			lines[foundLines] = string(input[offset..<i]);
			

			foundLines++;
			//i += 1;
			offset = i+1;
		}

		eof := i >= inputLen-1;
		if eof {
			lines[foundLines] = string(input[offset..<inputLen]);
			break;
		}	
	}

	return lines;
}

/*

main :: proc() {
	/*
	fmt.printf("%v\n", indexOf("😇abcd", '😇'));
	fmt.printf("%v\n", indexOf("😇abcd", "😇"));
	fmt.printf("%v\n", indexOf("ab", "😇"));
	fmt.printf("%v\n", indexOf("ab😇abcd", "😇ab"));
	*/

	fmt.printf("'ugknbfddgicrmopn'.indexOf(\"cd\") = %v\n\n", indexOf("ugknbfddgicrmopn", "cd"));
	fmt.printf("'ugknbfddgicrmopn'.indexOf(\"cr\") = %v\n\n", indexOf("ugknbfddgicrmopn", "cr"));
	
	/*
	fmt.printf("['a', 'b', 'c'].join(\",\") = %v\n", join([]string{"a","b","c"}, '😇'));
	fmt.printf("['a', 'b', 'c'].join(\" - \") = %v\n", join([]string{"a","b","c"}, " 😇 "));
	fmt.printf("['a', 'b', 'c'].join(\"\") = %v\n\n", join([]string{"a","b","c"}, byte(',')));
	*/
}

*/