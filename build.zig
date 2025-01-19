const std = @import("std");
const allocator = std.heap.page_allocator;

/// Build script for Node.js native addon
/// This script configures the build process for a Node.js native addon,
/// including setting up includes, libraries, and compilation flags
pub fn build(b: *std.Build) void {
    // Set console output to UTF-8 for proper character display
    _ = std.os.windows.kernel32.SetConsoleOutputCP(65001);

    // Setup build target and optimization options
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create shared library configuration
    const lib = b.addSharedLibrary(.{
        .name = "addon",
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Link with C standard library
    lib.linkLibC();

    // Get Node.js version with proper cleanup
    const node_version = get_node_version() catch |err| {
        switch (err) {
            NodeVersionError.SpawnError => std.debug.print("Failed to spawn Node.js process\n", .{}),
            NodeVersionError.ReadError => std.debug.print("Failed to read Node.js version\n", .{}),
            NodeVersionError.WaitError => std.debug.print("Failed to wait for Node.js process\n", .{}),
            NodeVersionError.ExecutionError => std.debug.print("Node.js version check failed\n", .{}),
            else => std.debug.print("Unexpected error occurred\n", .{}),
        }
        std.process.exit(1);
    };
    // Ensure node_version is freed
    defer allocator.free(node_version);

    // Get LOCALAPPDATA environment variable for Node.js files
    const localappdata = std.process.getEnvVarOwned(b.allocator, "LOCALAPPDATA") catch |err| {
        std.debug.print("Failed to get LOCALAPPDATA environment variable: {}\n", .{err});
        std.process.exit(1);
    };
    defer allocator.free(localappdata);

    // Create paths
    const node_path = b.pathJoin(&.{
        localappdata,
        "node-gyp",
        "Cache",
        node_version,
        "x64",
    });

    const include_path = b.pathJoin(&.{
        localappdata,
        "node-gyp",
        "Cache",
        node_version,
        "include",
        "node",
    });

    // Configure library paths and settings
    lib.addLibraryPath(.{ .cwd_relative = node_path });
    lib.linkSystemLibrary("node"); // node.lib
    lib.addIncludePath(.{ .cwd_relative = include_path });

    // Add C source file with required compilation flags
    lib.addCSourceFile(.{
        .file = .{ .cwd_relative = "src/dummy.c" },
        .flags = &[_][]const u8{
            "-DV8_DEPRECATION_WARNINGS=1",
            "-D_FILE_OFFSET_BITS=64",
        },
    });

    // Allow undefined symbols in shared library
    lib.linker_allow_shlib_undefined = true;
    b.installArtifact(lib);
}

/// Error types for Node.js version detection
const NodeVersionError = error{
    SpawnError,
    ReadError,
    WaitError,
    ExecutionError,
};

/// Get installed Node.js version by executing `node -v`
/// Returns the version string without 'v' prefix and newlines
fn get_node_version() (NodeVersionError || std.mem.Allocator.Error)![]const u8 {
    // Initialize child process for `node -v` command
    var child = std.process.Child.init(&.{ "node", "-v" }, allocator);
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;

    // Start the process
    child.spawn() catch {
        return NodeVersionError.SpawnError;
    };

    // Read command output
    const stdout = child.stdout.?.reader().readAllAlloc(allocator, 1024) catch {
        _ = child.kill() catch {};
        return NodeVersionError.ReadError;
    };

    // Wait for process completion
    const term = child.wait() catch {
        allocator.free(stdout);
        return NodeVersionError.WaitError;
    };

    // Process the command result
    switch (term) {
        .Exited => |code| {
            if (code == 0) {
                // Clean up version string by removing newlines and 'v' prefix
                var version = stdout;
                if (version.len > 0) {
                    // Remove trailing newline characters
                    if (version[version.len - 1] == '\n') {
                        version = version[0 .. version.len - 1];
                    }
                    if (version[version.len - 1] == '\r') {
                        version = version[0 .. version.len - 1];
                    }
                    // Remove 'v' prefix if present
                    if (version[0] == 'v') {
                        version = version[1..];
                    }
                }
                return version;
            } else {
                allocator.free(stdout);
                return NodeVersionError.ExecutionError;
            }
        },
        else => {
            allocator.free(stdout);
            return NodeVersionError.ExecutionError;
        },
    }
}
