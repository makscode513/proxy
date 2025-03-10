#include <stdio.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>
#include "master.h"

// Определение переменной executor_start_hook
Hook executor_start_hook = NULL;

int main() {
    // 1. Загрузка плагина
    void *handle = dlopen("install/plugins/greeting.so", RTLD_LAZY);
    if (!handle) {
        fprintf(stderr, "Ошибка загрузки плагина: %s\n", dlerror());
        return EXIT_FAILURE;
    }

    // 2. Получение обязательных функций плагина
    void (*init)(void) = dlsym(handle, "init");
    void (*fini)(void) = dlsym(handle, "fini");
    executor_start_hook = dlsym(handle, "executor_start_hook");
    const char* (*name)(void) = dlsym(handle, "name");

    // 3. Проверка наличия функций
    if (!init || !fini || !name || !executor_start_hook) {
        fprintf(stderr, "Плагин не соответствует интерфейсу\n");
        dlclose(handle);
        return EXIT_FAILURE;
    }

    // 4. Проверка имени плагина
    if (strcmp(name(), "greeting") != 0) {
        fprintf(stderr, "Неверное имя плагина\n");
        dlclose(handle);
        return EXIT_FAILURE;
    }

    // 5. Инициализация плагина
    init();

    // 6. Вызов хука, если он установлен
    if (executor_start_hook) {
        executor_start_hook();
    }

    // 7. Финализация и выгрузка
    fini();
    executor_start_hook = NULL;  // Сброс хука после выгрузки

    if (dlclose(handle) != 0) {
        fprintf(stderr, "Ошибка выгрузки плагина: %s\n", dlerror());
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}