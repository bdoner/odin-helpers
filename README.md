# odin-helpers

This is a small collection of code snippets for the [Odin programming language](https://github.com/gingerBill/Odin).

This is made by a very inexperience (when it comes to C) programmer, so there will be bugs!

In each of the folders in `tests` is a folder with the code and resources needed to test each helper. Go there for examples on how to use the procedures.

### Following is done:
* `md5.odin` - Implementation of the MD5 hashing algorithm in pure Odin.
    * `hash([]byte): string` Takes a single messages and return it's hash.
* `str.odin` - String helper procedures.
    * `indexOf(string, string): int` Takes a `string` to search in, and a `string` to search for. Can also search for `rune`s and `byte`s.
    * `startsWith(string, string): bool` Takes a `string` to search in, and a `string` to search for. Can also search for `rune`s and `byte`s.
    * `join([]string, string): string` Takes a `[]string` to join with the separator. Separator can also be a `rune` or a `byte`.
    * `split(string, rune): []string` Takes a ´string´ and split it into a list of `string`s using a single separator. 
* `file.odin` - File helper procedures
    * `read_lines(string): []string` A procedure that takes a string which is a path to a file. The file will be read in it's full length and returned as a `[]string` where each entry in the list represents a line in the file. The file will be split on `\n`, `\r` and `\r\n` which is Unix, Mac and Windows line endings.



###  My wishlist
* Possibly other, newer hashing functions (that are not already in [hash.odin](https://github.com/gingerBill/Odin/blob/master/core/hash.odin)).
* ~~Reading files, line by line - not caring about Unix or Windows line endings.~~
