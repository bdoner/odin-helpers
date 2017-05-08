#import file "../../file.odin";
#import fmt "fmt.odin";

run :: proc(testFile: string) {
	lines: []string;
	s: bool;
	lines, s = file.read_lines(testFile);

	if !s {
		fmt.println(" :( ");
	}

	expected := []string{
		"a",
		"b",
		" ",
		"c",
		"d",
		""
	};


	fmt.printf("-----\nSame length (%d == %d): %v\n", len(lines), len(expected), len(lines) == len(expected));	
	for i := 0; i < len(lines); i++ {
		fmt.printf("#%d '%s' == '%s' = %v\n", i, lines[i], expected[i], lines[i] == expected[i]);
	}
	
}

main :: proc() {
	run("file-test.txt");
}