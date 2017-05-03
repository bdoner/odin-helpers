#import fmt "fmt.odin";
#import strhelper "../../strhelper.odin";

main :: proc() {
	using fmt;

	printf("'abc'.startsWith(byte('a')) = %v\n", strhelper.startsWith("abc", byte('a')));
	printf("'abc'.startsWith(byte('b')) = %v\n\n", strhelper.startsWith("abc", byte('b')));
	
	printf("'abc'.startsWith(\"ab\") = %v\n", strhelper.startsWith("abc", "ab"));
	printf("'abc'.startsWith(\"bc\") = %v\n\n", strhelper.startsWith("abc", "bc"));
	

	printf("'abc'.indexOf(byte('a')) = %v\n", strhelper.indexOf("abc", byte('a')));
	printf("'abc'.indexOf(byte('b')) = %v\n", strhelper.indexOf("abc", byte('b')));
	printf("'abc'.indexOf(byte('d')) = %v\n\n", strhelper.indexOf("abc", byte('d')));
	
	printf("'abc'.indexOf(\"ab\") = %v\n", strhelper.indexOf("abc", "ab"));
	printf("'abc'.indexOf(\"bc\") = %v\n", strhelper.indexOf("abc", "bc"));
	printf("'abc'.indexOf(\"de\") = %v\n", strhelper.indexOf("abc", "de"));
	printf("'abc'.indexOf(\"defdhfdg\") = %v\n\n", strhelper.indexOf("abc", "defdhfdg"));



}