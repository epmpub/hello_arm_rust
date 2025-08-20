# cargo build --target aarch64-unknown-linux-musl --release && echo -n build done.

# scp /home/ubuntu/rust/arm/hello_arm/target/aarch64-unknown-linux-musl/release/hello_arm openailab@192.168.3.173:~/test/hello_arm && echo -n copy done.
# echo 'begin to execute.'
# ssh openailab@192.168.3.173 './test/hello_arm'

# https://github.com/tpoechtrager/osxcross/tree/master/tools
# https://uovol.com/macos-xcode-version 
# xode download website
# github clone osxcross
# rustup target add x86_64-apple-darwin

# sudo apt-get install clang
# sudo apt install libssl-dev
# sudo apt install zlib1g-dev

#期间会从GitHub上下载一些依赖项,需要科学上网

# make macOSX SDK 

# copy SDK to tarball
# build osxcross
# setup envs
build:
	export PATH="$HOME/osxcross/target/bin:$PATH"
	export CC_x86_64_apple_darwin=x86_64-apple-darwin21.2-clang
	export CXX_x86_64_apple_darwin=x86_64-apple-darwin21.2-clang++
	export AR_x86_64_apple_darwin=x86_64-apple-darwin21.2-ar
	export CARGO_TARGET_X86_64_APPLE_DARWIN_LINKER=x86_64-apple-darwin21.2-clang

	#build
	cargo build -r --target x86_64-apple-darwin

gnu:
# 	!!! copy to terminal to run:
	export RUSTFLAGS="-C target-feature=+crt-static -C link-arg=-static-libgcc"
	cargo build --release --target aarch64-unknown-linux-gnu
	scp target/aarch64-unknown-linux-gnu/release/hello_arm openailab@192.168.3.200:~
	ssh openailab@192.168.3.200 './hello_arm'
musl:
# 	cross build --release --target aarch64-unknown-linux-musl
	cargo build --release --target aarch64-unknown-linux-musl

	scp target/aarch64-unknown-linux-musl/release/hello_arm openailab@192.168.3.200:~/hello_arm_musl
	ssh openailab@192.168.3.200 './hello_arm_musl'

musl2:
	cross build --release --target aarch64-unknown-linux-musl
	scp target/aarch64-unknown-linux-musl/release/hello_arm openailab@192.168.3.200:~/hello_arm_musl
	ssh openailab@192.168.3.200 './hello_arm_musl'