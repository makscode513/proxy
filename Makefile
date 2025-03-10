# Компилятор и флаги
CC      = gcc
CFLAGS  += -Wall -Wpedantic -Wpointer-arith -Wendif-labels -Wmissing-format-attribute \
           -Wimplicit-fallthrough=3 -Wcast-function-type -Wshadow=compatible-local -Wformat-security \
           -fPIC -rdynamic # Для создания позиционно-независимого кода (необходимо для .so)
LDFLAGS += -ldl # Подключение библиотеки dlopen

# Директории
BUILD_DIR = install
PLUGIN_DIR = $(BUILD_DIR)/plugins
SRC_DIR = src
INCLUDE_DIR = $(SRC_DIR)/include

# Исходники
SRC = $(wildcard $(SRC_DIR)/*.c)
OBJ = $(SRC:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)

# Файлы
PROXY_BIN = $(BUILD_DIR)/proxy
STATIC_LIB = $(BUILD_DIR)/libconfig.a
DYNAMIC_LIB = $(BUILD_DIR)/liblogger.so
PLUGIN_SO = $(PLUGIN_DIR)/greeting.so

# Создание папок
$(BUILD_DIR) $(PLUGIN_DIR):
	mkdir -p $@

# Сборка исполняемого файла (поддержка dlopen)
$(PROXY_BIN): $(OBJ) $(DYNAMIC_LIB) $(STATIC_LIB) | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(OBJ) -o $@ $(LDFLAGS)

# Компиляция объектов
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -I$(INCLUDE_DIR) -c $< -o $@

# Статическая библиотека
$(STATIC_LIB): $(BUILD_DIR)/config.o
	ar rcs $@ $^

# Динамическая библиотека (необходима для логирования)
$(DYNAMIC_LIB): $(BUILD_DIR)/logger.o
	$(CC) -shared -fPIC $^ -o $@

# Компиляция плагина (используется dlopen, поэтому создаём .so)
$(PLUGIN_SO): plugins/greeting/greeting.c | $(PLUGIN_DIR)
	$(CC) -shared -fPIC $< -o $@

# Очистка
clean:
	rm -rf $(BUILD_DIR)

# Сборка всего проекта
all: $(PROXY_BIN) $(PLUGIN_SO)