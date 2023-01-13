# 2048 Game
This is an implementation of the [2048 Game](https://2048game.com) in the [Zig](https://ziglang.org) programming language.

---
__From the website__:

2048 is an easy and fun puzzle game...It is played on a 4x4 grid... Every time you press a key - all tiles slide. Tiles with the same value that bump into one-another are merged...

---
## Usage
Development was done using a nightly build from the Zig website, using an Apple MacBook Air (M2).
```shell
$ zig version
0.11.0-dev.824+b3f4e0d09
```
Windows support has not been added yet, though I intend to work on that in the future.

### Building and running
Run the command `zig build` from the root directory. The executable file will be created in `./zig-out/bin`.
```shell
$ zig build
$ ./zig-out/bin/2048-game
```
This will generate a debug build. The following options are also available for smaller and/or faster executables:
* `-Drelease-safe`
* `-Drelease-small`
* `-Drelease-fast`

Cross-platform builds need the `target` parameter. For example, to target x64 Linux and GNU ABI:
```shell
$ zig build -Dtarget=x86_64-linux-gnu
```

### Running from source
Zig provides a `run` command to build and execute the source file directly, without an intervening build step.
```shell
$ zig run ./src/main.zig
```

### Testing
(WIP) Tests have not been added yet.
