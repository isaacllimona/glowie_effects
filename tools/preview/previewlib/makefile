BUILD_DIR := build

$(BUILD_DIR)/previewlib.so: $(BUILD_DIR)/previewlib.o $(BUILD_DIR)/tigr.o
	clang $(BUILD_DIR)/previewlib.o $(BUILD_DIR)/tigr.o -lGLU -lGL -lX11 -shared -o $(BUILD_DIR)/previewlib.so

$(BUILD_DIR)/previewlib.o: previewlib.c | $(BUILD_DIR)
	clang -c -fPIC previewlib.c -I../lua-5.5.1/install/include -o $(BUILD_DIR)/previewlib.o

$(BUILD_DIR)/tigr.o: tigr/tigr.c | $(BUILD_DIR)
	clang -c -fPIC tigr/tigr.c -o $(BUILD_DIR)/tigr.o

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

clean:
	rm -r build
