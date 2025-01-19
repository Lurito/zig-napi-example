This project is a sample implementation of a Node.js native addon (n-api) using Zig programming language, demonstrating the development process with a simple example.

Currently, the project only supports compilation on Windows systems.

## Build Instructions

### Prerequisites

- Windows 10 operating system or later
- Node.js environment and NPM (or other Node.js package managers)
- Zig language v0.14.0

Other versions of Zig might also be able to compile this project. However, due to Zig's rapid development and frequent API changes, potential issues may exist with different versions.

### Build Steps

```batch
rem Install required tools (alternatively use pnpm / yarn or other package managers)
npm install -g node-gyp
node-gyp install

rem Execute build and test
.\build_and_test.cmd
```

For custom build or test procedures, you can modify the `build_and_test.cmd` file according to your needs.

## License

This project is licensed under the terms of the GNU Lesser General Public License (LGPL) version 3. See the [LICENSE](./LICENSE) file for details.
