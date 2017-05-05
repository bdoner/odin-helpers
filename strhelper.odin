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

indexOf :: proc(str, s: string) -> int {

	index := -1;
	firstRune, _ := utf8.decode_rune(s);
	#label outer for i, size := 0, 0; i < len(str); i += size {
		r: rune;
		r, size = utf8.decode_rune(str[i..]);
		if r == firstRune {
			index = 1;
			#label inner for j, size2 := 0, 0; j < len(s); j += size2 {
				if j == len(s)-1 {
					index = i;
					break outer;
				}

				t: rune;
				r, size = utf8.decode_rune(str[i+j..]);
				t, size2 = utf8.decode_rune(s[j..]);

				if r != t {
					break inner;
				}
			}
		}
	}
	

	
	/*
	#label outer for b, i in str {
		if b == rune(s[0]) {
			//fmt.printf("o > %d %d\n", b, s[0]);
			#label inner for sj, j in s {
				//fmt.printf("i > %d %d\n", str[i+j], s[j]);
				if j == len(s)-1 {
					index = i;
					break outer;
				}
				if str[i+j] != s[j] {
					break inner;
				}
			}
		}
	}
	*/
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

	//c := 0;
	newStr := make([]byte, 0, newLen);
	for s, i in list {
		append(newStr, ..[]byte(s));
		append(newStr, ..[]byte(d));
		/*for r in s {
			newStr[c] = byte(r);
			c++;
		}
		if i < len(list) - 1 {
			for r in d {
				newStr[c] = byte(r);
				c++;
			}
		}*/
	}
	return string(newStr);

}


main :: proc() {
	/*
	fmt.printf("%v\n", indexOf("😇abcd", '😇'));
	fmt.printf("%v\n", indexOf("😇abcd", "😇"));
	fmt.printf("%v\n", indexOf("ab", "😇"));
	fmt.printf("%v\n", indexOf("ab😇abcd", "😇ab"));
	*/
	
	/*
	fmt.printf("['a', 'b', 'c'].join(\",\") = %v\n", join([]string{"😇","b","😇"}, ","));
	fmt.printf("['a', 'b', 'c'].join(\" - \") = %v\n", join([]string{"a","b","c"}, " - "));
	fmt.printf("['a', 'b', 'c'].join(\"\") = %v\n\n", join([]string{"a","b","c"}, ""));
	*/
}

