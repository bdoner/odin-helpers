#import "fmt.odin";

startsWith :: proc(str, s: string) -> bool {
	if len(s) > len(str) {
		return false;
	}

	found := true;
	for b, i in str {
		if i == len(s) {
			break;
		}
		if b != rune(s[i]) {
			found = false;
		}
	}

	return found;
}

startsWith :: proc(str: string, s: rune) -> bool {
	return rune(str[0]) == s;
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

	c := 0;
	newStr := make([]byte, newLen);
	for s, i in list {
		for r in s {
			newStr[c] = byte(r);
			c++;
		}
		if i < len(list) - 1 {
			for r in d {
				newStr[c] = byte(r);
				c++;
			}
		}
	}
	return string(newStr);

}

/*
main :: proc() {
	fmt.printf("%s\n", join([]string{"ab"}, ""));
	fmt.printf("['a', 'b', 'c'].join(\",\") = %v\n", join([]string{"a","b","c"}, ","));
	fmt.printf("['a', 'b', 'c'].join(\" - \") = %v\n", join([]string{"a","b","c"}, " - "));
	fmt.printf("['a', 'b', 'c'].join(\"\") = %v\n\n", join([]string{"a","b","c"}, ""));
}
*/
