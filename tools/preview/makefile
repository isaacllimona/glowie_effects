BUILD_DIR := build

.PHONY: all build_lua clean

all: build_lua $(BUILD_DIR)/previewlib.so

build_lua:
	$(MAKE) -C third_party/lua-5.5.1 all local

$(BUILD_DIR)/previewlib.so: $(BUILD_DIR)/previewlib.o $(BUILD_DIR)/tigr.o
	clang $(BUILD_DIR)/previewlib.o $(BUILD_DIR)/tigr.o -lGLU -lGL -lX11 -shared -o $(BUILD_DIR)/previewlib.so

$(BUILD_DIR)/previewlib.o: previewlib.c | $(BUILD_DIR)
	clang -c -fPIC previewlib.c -I./third_party/lua-5.5.1/install/include -o $(BUILD_DIR)/previewlib.o

$(BUILD_DIR)/tigr.o: third_party/tigr/tigr.c | $(BUILD_DIR)
	clang -c -fPIC third_party/tigr/tigr.c -o $(BUILD_DIR)/tigr.o

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

clean:
	rm -rf build
