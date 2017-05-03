# odin-helpers

This is a small collection of code snippets for the [Odin programming language](https://github.com/gingerBill/Odin).

This is made by a very inexperience (when it comes to C) programmer, so there will be bugs!

In each of the folders in `tests` is a folder with the code and resources needed to test each helper. Go there for examples on how to use the procedures.

### Following is done:
* `md5.odin` - Implementation of the MD5 hashing algorithm in pure Odin.
    * `hash([]byte): string` Takes a single messages and return it's hash.
* `strhelpers.odin` - String helper functions.
    * `indexOf(string, string): int` takes a `string` to search in, and a `string` to search for. Can also search for `rune`s and `byte`s.
    * `startsWith(string, string): bool` takes a `string` to search in, and a `string` to search for. Can also search for `rune`s and `byte`s.



###  My wishlist
* Possibly other, newer hashing functions (that are not already in [hash.odin](https://github.com/gingerBill/Odin/blob/master/core/hash.odin)).
* Reading files, line by line - not caring about Unix or Windows line endings.
