import (
    md5test "md5/md5-test.odin";
    strtest "str/str-test.odin";
    filetest "file/file-test.odin";
);

main :: proc() {
    md5test.run("md5/md5-test.txt");
    strtest.run();
    filetest.run("file/file-test.txt");
}
