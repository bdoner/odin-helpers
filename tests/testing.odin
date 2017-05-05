#import md5test "md5/md5-test.odin";
#import strhelpertest "strhelper/strhelper-test.odin";

main :: proc() {
    md5test.run("md5/md5-test.txt");
    strhelpertest.main();
}
