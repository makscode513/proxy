CC = gcc
CFLAGS = -I./src/include -fPIC
LDFLAGS = -ldl

all: create_dirs proxy greeting.so libconfig.a liblogger.so

create_dirs:
	mkdir -p install/plugins

proxy: src/master.c libconfig.a
	$(CC) $(CFLAGS) $< -L./install -lconfig -o $@ $(LDFLAGS)
	mv proxy install/

greeting.so: plugins/greeting/greeting.c
	$(CC) $(CFLAGS) -shared $< -o $@
	mv greeting.so install/plugins/

libconfig.a: src/config.c
	$(CC) $(CFLAGS) -c $< -o config.o
	ar rcs $@ config.o
	mv $@ install/

liblogger.so: src/logger.c
	$(CC) $(CFLAGS) -shared $< -o $@
	mv $@ install/

clean:
	rm -rf install/*.so install/*.a install/proxy install/plugins/*.so