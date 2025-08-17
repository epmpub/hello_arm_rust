# Cross-Compiling Rust for ARM64/AArch64

Cross-compiling Rust code for ARM64 (AArch64) architecture is fairly straightforward. Here's a concise guide to get you started:

## Setup

1. **Install Rust target**:
   ```
   rustup target add aarch64-unknown-linux-gnu
   ```

2. **Install cross-compiler toolchain**:
   For Debian/Ubuntu:
   ```
   apt update
   apt install -y curl build-essential gcc-aarch64-linux-gnu libssl-dev:aarch64 pkg-config
   ```

## Configuration

Create or update `.cargo/config.toml` file in your project with:

```toml
[target.aarch64-unknown-linux-gnu]
linker = "aarch64-linux-gnu-gcc"
```

## Building

Build your project with:
```
cargo build --target aarch64-unknown-linux-gnu
```

For release builds:
```
cargo build --target aarch64-unknown-linux-gnu --release
```

Fix GLIBC denpendice issue.

```code
export RUSTFLAGS="-C target-feature=+crt-static -C link-arg=-static-libgcc"

```

or use musl:
```code
rustup target add aarch64-unknown-linux-musl
sudo apt install musl-tools musl-dev

```
change Cargo.toml:

[target.aarch64-unknown-linux-musl]
linker = "aarch64-linux-gnu-gcc"

build:

```code
cargo build --release --target aarch64-unknown-linux-musl
```

USE Docker:

## Alternative: Using `cross`

For a containerized approach, you can use the `cross` tool:

1. Install Docker
2. Install Cross:
   ```
   cargo install cross
   ```
3. Build with Cross:
   ```
   cross build --target aarch64-unknown-linux-gnu
   ```

## Common Issues

- Missing linker: Ensure the cross-compiler is installed
- Library dependencies: You may need to install aarch64 versions of required libraries
- Dynamic linking: Consider static linking with `--target-dir` to avoid runtime dependency issues

Would you like more information about a specific part of this process?


# 如何在 Rust 中进行 Release 优化


在 Rust 中，Release 模式下的优化对于提升程序性能、减少二进制文件大小等方面至关重要。以下是一些在 Rust 项目中进行 Release 优化的方法：

### 1. 使用 `--release` 标志
当使用 `cargo` 构建项目时，使用 `--release` 标志可以启用编译器的优化选项。默认情况下，`cargo build` 是开发模式，不会进行大量优化，而 `cargo build --release` 会开启一系列优化，生成性能更好的代码。
```bash
cargo build --release
```

### 2. 配置 `Cargo.toml` 中的优化级别
在 `Cargo.toml` 文件中，可以通过 `[profile.release]` 部分来进一步配置 Release 模式的优化级别。常见的优化级别有 `0` 到 `3`，`0` 表示不进行优化，`3` 表示最高级别的优化。
```toml
[profile.release]
opt-level = 3
```
- `opt-level = 0`：不进行优化，编译速度最快，但生成的代码性能较差。
- `opt-level = 1`：进行基本的优化，编译速度相对较快，同时能获得一定的性能提升。
- `opt-level = 2`：进行更高级的优化，生成的代码性能较好，但编译时间会有所增加。
- `opt-level = 3`：进行最高级别的优化，能获得最佳的性能，但编译时间最长。

### 3. 启用 LTO（Link Time Optimization）
LTO 可以在链接阶段进行额外的优化，进一步提高代码性能和减少二进制文件大小。在 `Cargo.toml` 中添加以下配置：
```toml
[profile.release]
lto = true
```
不过，启用 LTO 会显著增加编译时间，尤其是在大型项目中。你也可以选择 `thin` LTO，它在性能和编译时间之间提供了一个折衷方案：
```toml
[profile.release]
lto = "thin"
```

### 4. 去除调试信息
默认情况下，Release 模式会包含一些调试信息，这些信息对于调试很有用，但会增加二进制文件的大小。可以通过在 `Cargo.toml` 中设置 `debug = false` 来去除调试信息：
```toml
[profile.release]
debug = false
```

### 5. 使用 `strip` 工具
在编译完成后，可以使用 `strip` 工具进一步去除二进制文件中的符号表和调试信息，从而减小文件大小。例如，对于 Linux 系统：
```bash
strip target/release/your_binary
```

### 6. 优化依赖库
- **减少不必要的依赖**：检查项目的 `Cargo.toml` 文件，移除不必要的依赖库，避免引入过多的代码和潜在的性能开销。
- **选择高性能的依赖库**：在选择依赖库时，优先选择性能优化较好的库。可以参考社区的评价和性能测试结果。

### 7. 代码层面的优化
- **避免不必要的内存分配**：尽量减少堆内存的分配和释放，使用栈上分配的数据结构（如 `Vec::with_capacity` 预分配内存），避免频繁的 `String` 拼接等操作。
- **使用高效的数据结构和算法**：根据具体的业务需求，选择合适的数据结构和算法。例如，使用 `HashMap` 而不是线性搜索来提高查找效率。
- **减少函数调用开销**：对于一些简单的函数，可以考虑使用内联（`#[inline]` 或 `#[inline(always)]`）来减少函数调用的开销。
```rust
#[inline(always)]
fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

通过以上这些方法，可以在 Rust 项目的 Release 模式下获得更好的性能和更小的二进制文件大小。

## 参考资料
资料
- [Rust 官方文档 - Release Profiles](URL_ADDRESS- [Rust 官方文档 - Release Profiles](https://doc.rust-lang.org/cargo/reference/profiles.html)
- cross工具 https://github.com/cross-rs/cross


Openssl issue fix:

The issue is with OpenSSL when cross-compiling to `aarch64-unknown-linux-musl`. OpenSSL is a native C library that needs to be compiled for the target architecture. Here are several solutions:

## Solution 1: Use rustls instead of OpenSSL (Recommended)

Modify your `Cargo.toml` to use `rustls` instead of OpenSSL:

```toml
[dependencies]
reqwest = { version = "0.11", default-features = false, features = ["rustls-tls", "json"] }
tokio = { version = "1.0", features = ["full"] }
# Remove the openssl dependency
```

Then build with:
```bash
cargo build --release --target aarch64-unknown-linux-musl
```

## Solution 2: Use the `cross` tool

Install and use `cross` which handles cross-compilation dependencies:

```bash
cargo install cross
cross build --release --target aarch64-unknown-linux-musl
```

## Solution 3: Install OpenSSL for aarch64-musl

If you must use OpenSSL, you'll need to cross-compile it:

```bash
# Install musl-dev for aarch64
sudo apt-get install musl-dev musl-tools

# Set environment variables for OpenSSL cross-compilation
export CC=aarch64-linux-gnu-gcc
export AR=aarch64-linux-gnu-ar
export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_LINKER=aarch64-linux-gnu-gcc

# Install openssl for the target
export OPENSSL_STATIC=1
export OPENSSL_DIR=/usr/aarch64-linux-gnu/
```

## Solution 4: Use a pre-compiled OpenSSL

Create a `.cargo/config.toml` file:

```toml
[target.aarch64-unknown-linux-musl]
linker = "aarch64-linux-gnu-gcc"

[env]
OPENSSL_STATIC = "1"
OPENSSL_DIR = "/usr/aarch64-linux-gnu/"
```

## Solution 5: Docker approach

Use a Docker container with pre-configured cross-compilation environment:

Create a `Dockerfile`:
```dockerfile
FROM messense/rust-musl-cross:aarch64-musl
WORKDIR /app
COPY . .
RUN cargo build --release --target aarch64-unknown-linux-musl
```

Then build:
```bash
docker build -t my-rust-app .
docker run --rm -v $(pwd)/target:/app/target my-rust-app
```

## Recommended Quick Fix

The easiest solution is to switch to `rustls`. Update your `Cargo.toml`:

```toml
[package]
name = "hello_arm"
version = "0.1.0"
edition = "2021"

[dependencies]
reqwest = { version = "0.11", default-features = false, features = ["rustls-tls", "json"] }
tokio = { version = "1.0", features = ["full"] }
```

And if you have any explicit OpenSSL usage in your code, you might need to adjust it, but `reqwest` with `rustls-tls` should work as a drop-in replacement for most use cases.

Try the rustls approach first - it's the most straightforward solution for cross-compilation scenarios.