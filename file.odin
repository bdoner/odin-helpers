#import os "os.odin";
#import utf8 "utf8.odin";
//#import fmt "fmt.odin";

read_lines :: proc(path: string) -> ([]string, bool) {

	is_newline :: proc(i: int, arr: []byte) -> (bool, int) {
		if arr[i] == '\n' || arr[i] == '\r' {
				if len(arr)-1 > i && arr[i] == '\r' && arr[i+1] == '\n' {
					//fmt.printf("CR NL\n");
					return true, 2;
				}
				//fmt.printf("%s\n", arr[i] == 0x0D ? "CR" : "NL");
				return true, 1;
			}

		return false, 0;
	}

	fileCont, success := os.read_entire_file(path);
	//fmt.printf("%v\n------\n", fileCont);
	if !success {
		//empty := make([]string, 0);
		return []string{}, success;
	}

	fileLength := len(fileCont);
	lineCount := 1;
	lastNewline := 0;
	for i := 0; i < fileLength; i++ {
		nl, nll := is_newline(i, fileCont);
		if nl {
			lineCount++;
			lastNewline = i;
			i += nll-1;
		}
	}
	//endsWithLF, _ := is_newline(fileLength-1, fileCont);
	//if endsWithLF {
		//lineCount++;
	//}

	//fmt.printf("------\nlnl: %d\n", lastNewline);
	//fmt.printf("------\nfl: %d\n", fileLength);
	//fmt.printf("------\nlines: %d\n", lineCount);
	//fmt.println("------");
	foundLines := 0;
	lines := make([]string, lineCount);	
	for offset, i, size := 0, 0, 0; i < fileLength; i += size {
		r: rune;
		r, size = utf8.decode_rune(fileCont[i..]);

		nl, nll := is_newline(i, fileCont);
		if nl {
			
			//fmt.printf("nll: %d\n", nll);
			//fmt.printf("offset: %v\n", offset);
			//fmt.printf("i: %v\n", i);

			lines[foundLines] = string(fileCont[offset..<i]);			
			
			//fmt.printf("line: '%s'\n", lines[foundLines]);
			//fmt.printf("line #: %d\n", foundLines);
			//fmt.printf("-\n");
			foundLines++;
			i += nll;
			offset = i;
		} 

		eof := i >= fileLength-1;
		if eof {
			//fmt.printf("nll: %d\n", nll);
			//fmt.printf("eof: %v\n", eof);
			//fmt.printf("offset: %v\n", offset);
			//fmt.printf("i: %v\n", fileLength);
			lines[foundLines] = string(fileCont[offset..<fileLength]);
			//fmt.printf("line: '%s'\n", lines[foundLines]);
			//fmt.printf("line #: %d\n", foundLines);


			i += nll;
			offset = i;
		}
		
	}

	return lines, true;
}



