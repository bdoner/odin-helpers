#import file "../../file.odin";
#import fmt "fmt.odin";

run :: proc(testFile: string) {
	lines, s := file.read_lines(testFile);

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


	fmt.printf("Same length: %v\n", len(lines) == len(expected));

	for line, i in lines {
		fmt.printf("#%d '%s' == '%s' = %v\n", i, line, expected[i], line == expected[i]);
	}
}

main :: proc() {
	run("file-test.txt");
}