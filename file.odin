#import os "os.odin";
#import utf8 "utf8.odin";
#import fmt "fmt.odin";

read_lines :: proc(path: string) -> ([]string, bool) {

	is_newline :: proc(i: int, arr: []byte) -> (bool, int) {
		if ((len(arr)-1 > i && arr[i] == '\r' && arr[i+1] == '\n') && arr[i] != '\n' && arr[i] != '\r') ||
			(arr[i] == '\n' && arr[i] != '\r' && !(len(arr)-1 > i && arr[i] == '\r' && arr[i+1] == '\n')) || 
			(arr[i] == '\r' && arr[i] != '\n' && !(len(arr)-1 > i && arr[i] == '\r' && arr[i+1] == '\n')) {
	//			fmt.printf("%v ", arr[i]);
	//			if len(arr)-1 > i {
	//				fmt.printf("%v", arr[i+1]);
	//			}
	//			fmt.println();

				if (len(arr)-1 > i && arr[i] == '\r' && arr[i+1] == '\n') {
					return true, 2;
				}
				return true, 1;
			}

		return false, 0;
	}

	fileCont, success := os.read_entire_file(path);
	//fmt.printf("%v\n------\n", fileCont);
	if !success {
		return []string{}, success;
	}

	fileLength := len(fileCont);
	lineCount := 0;
	lastNewline := 0;
	for c, i in fileCont {
		nl, _ := is_newline(i, fileCont);
		if nl {
			lineCount++;
			lastNewline = i;
		}
	}
	if fileLength-1 > lastNewline {
		lineCount++;
	}
	//fmt.println("------");
	foundLines := 0;
	lines := make([]string, lineCount);	
	for offset, i, size := 0, 0, 0; i < fileLength; i += size {
		r: rune;
		r, size = utf8.decode_rune(fileCont[i..]);

		eof := i == fileLength - 1;
		nl, nll := is_newline(i, fileCont);
		if nl || eof {
	//		fmt.printf("%d\n", nll);
			end := nll == 2 ? i-nll-1 : i;
			lines[foundLines] = string(fileCont[offset..<end]);
			foundLines++;
			offset = i + nll;
			i += nll-1;
			
		} 
	}

	return lines, true;
}

/*
run :: proc(testFile: string) {
	lines, s := read_lines(testFile);

	if !s {
		fmt.println(" :( ");
	}

	expected := []string{
		"a",
		"bb",
		"",
		"ccc",
		"1"
	};


	fmt.printf("Same length (%d == %d): %v\n", len(lines), len(expected), len(lines) == len(expected));

	for line, i in lines {
		fmt.printf("#%d '%s' == '%s' = %v\n", i, line, expected[i], line == expected[i]);
	}
}

main :: proc() {
	run("tests/file/file-test.txt");
}
*/