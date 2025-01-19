cd %~dp0
zig build
move zig-out\bin\addon.dll zig-out\bin\addon.node

node test\test.mjs
