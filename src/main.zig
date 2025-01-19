const std = @import("std");
const c = @cImport({
    @cInclude("node_api.h");
});

// Export multiplication function
pub export fn multiply(env: c.napi_env, info: c.napi_callback_info) callconv(.C) c.napi_value {
    std.debug.print("Zig: multiply function called\n", .{});

    var argc: usize = 2;
    var argv: [2]c.napi_value = undefined;
    var this_arg: c.napi_value = undefined;

    const status = c.napi_get_cb_info(env, info, &argc, &argv, &this_arg, null);
    if (status != c.napi_ok) {
        std.debug.print("Zig: napi_get_cb_info failed: {d}\n", .{status});
        return null;
    }

    if (argc < 2) {
        // Not enough arguments, throw error
        var err: c.napi_value = undefined;
        _ = c.napi_create_string_utf8(env, "Expected two arguments", 0, &err);
        _ = c.napi_throw(env, err);
        std.debug.print("Zig: Not enough arguments, throwing error\n", .{});
        return null;
    }

    var num1: i32 = 0;
    var num2: i32 = 0;

    const status1 = c.napi_get_value_int32(env, argv[0], &num1);
    const status2 = c.napi_get_value_int32(env, argv[1], &num2);
    if (status1 != c.napi_ok or status2 != c.napi_ok) {
        // Invalid argument type, throw error
        var err: c.napi_value = undefined;
        _ = c.napi_create_string_utf8(env, "Zig: Invalid argument type", 0, &err);
        _ = c.napi_throw(env, err);
        std.debug.print("Zig: Invalid argument type, throwing error\n", .{});
        return null;
    }

    var result: c.napi_value = undefined;
    const status3 = c.napi_create_int32(env, num1 * num2, &result);
    if (status3 != c.napi_ok) {
        std.debug.print("Zig: napi_create_int32 failed: {d}\n", .{status3});
        return null;
    }

    std.debug.print("Zig: Calculation result: {d} * {d} = {d}\n", .{ num1, num2, num1 * num2 });
    return result;
}

// Initialization function to register exported functions
pub export fn napi_register_module_v1(env: c.napi_env, exports: c.napi_value) callconv(.C) c.napi_value {
    // Set console encoding for Windows platform
    if (@import("builtin").os.tag == .windows) {
        _ = std.os.windows.kernel32.SetConsoleOutputCP(65001);
    }

    std.debug.print("Zig: Initializing Zig addon\n", .{});

    var fn_multiply: c.napi_value = undefined;
    var status: c.napi_status = c.napi_create_function(env, null, 0, multiply, null, &fn_multiply);
    if (status != c.napi_ok) {
        std.debug.print("Zig: Failed to create function: {d}\n", .{status});
        return null;
    }

    status = c.napi_set_named_property(env, exports, "multiply", fn_multiply);
    if (status != c.napi_ok) {
        std.debug.print("Zig: Failed to set property: {d}\n", .{status});
        return null;
    }
    std.debug.print("Zig: Zig addon initialization completed\n", .{});
    return exports;
}
