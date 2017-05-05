#import fmt "fmt.odin";
#import str "../../strhelper.odin";

run :: proc() {
	using fmt;

	printf("'abc'.startsWith(byte('a')) = %v\n", str.startsWith("abc", byte('a')));
	printf("'abc'.startsWith(byte('b')) = %v\n\n", str.startsWith("abc", byte('b')));
	
	printf("'abc'.startsWith(\"ab\") = %v\n", str.startsWith("abc", "ab"));
	printf("'abc'.startsWith(\"bc\") = %v\n\n", str.startsWith("abc", "bc"));
	

	printf("'abc'.indexOf(byte('a')) = %v\n", str.indexOf("abc", byte('a')));
	printf("'abc'.indexOf(byte('b')) = %v\n", str.indexOf("abc", byte('b')));
	printf("'abc'.indexOf(byte('d')) = %v\n\n", str.indexOf("abc", byte('d')));
	
	printf("'abc'.indexOf(\"ab\") = %v\n", str.indexOf("abc", "ab"));
	printf("'abc'.indexOf(\"bc\") = %v\n", str.indexOf("abc", "bc"));
	printf("'abc'.indexOf(\"de\") = %v\n", str.indexOf("abc", "de"));
	printf("'abc'.indexOf(\"defdhfdg\") = %v\n\n", str.indexOf("abc", "defdhfdg"));

	printf("[\"a\", \"b\", \"c\"].join(\",\") = '%v'\n", str.join([]string{"a","b","c"}, ","));
	printf("[\"a\", \"b\", \"c\"].join(\" - \") = '%v'\n", str.join([]string{"a","b","c"}, " - "));
	printf("[\"a\", \"b\", \"c\"].join(\"\") = '%v'\n\n", str.join([]string{"a","b","c"}, ""));

	printf("[\"a\"].join(\",\") = '%v'\n", str.join([]string{"a"}, ","));
	printf("[\"a\"].join(\" - \") = '%v'\n", str.join([]string{"a"}, " - "));
	printf("[\"a\"].join(\"\") = '%v'\n\n", str.join([]string{"a"}, ""));

	printf("[\"\"].join(\",\") = '%v'\n", str.join([]string{""}, ","));
	printf("[\"\"].join(\" - \") = '%v'\n", str.join([]string{""}, " - "));
	printf("[\"\"].join(\"\") = '%v'\n\n", str.join([]string{""}, ""));

	printf("[].join(\",\") = '%v'\n", str.join([]string{}, ","));
	printf("[].join(\" - \") = '%v'\n", str.join([]string{}, " - "));
	printf("[].join(\"\") = '%v'\n\n", str.join([]string{}, ""));

}

main :: proc() {
	run();
};
