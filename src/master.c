#include <stdio.h>
#include <dlfcn.h>
#include "master.h"

typedef void (*hook_func)();

int main() {
    void *handle = dlopen("install/plugins/greeting.so", RTLD_LAZY);
    if (!handle) {
        printf("Ошибка загрузки плагина: %s\n", dlerror());
        return 1;
    }

    hook_func init = (hook_func) dlsym(handle, "init");
    hook_func fini = (hook_func) dlsym(handle, "fini");
    hook_func hook = (hook_func) dlsym(handle, "executor_start_hook");

    if (!init || !fini || !hook) {
        printf("Ошибка поиска функций в плагине: %s\n", dlerror());
        dlclose(handle);
        return 1;
    }

    init();

    if (executor_start_hook) {
        executor_start_hook();
    }

    fini();

    dlclose(handle);
    return 0;
}