##
##  Makefile -- Build procedure for fast3lpoad Apache module
##
##  This is a C++ module so things have to be handled a little differently.

#   the used tools
APXS=/opt/local/apache2/bin/apxs
APACHECTL=/opt/local/apache2/binapachectl

# Get all of apxs's internal values.
APXS_CC=`$(APXS) -q CC`   
APXS_TARGET=`$(APXS) -q TARGET`   
APXS_CFLAGS=`$(APXS) -q CFLAGS`   
APXS_SBINDIR=`$(APXS) -q SBINDIR`   
APXS_CFLAGS_SHLIB=`$(APXS) -q CFLAGS_SHLIB`   
APXS_INCLUDEDIR=`$(APXS) -q INCLUDEDIR`   
APXS_LD_SHLIB=`$(APXS) -q LD_SHLIB`
APXS_LIBEXECDIR=`$(APXS) -q LIBEXECDIR`
APXS_LDFLAGS_SHLIB=`$(APXS) -q LDFLAGS_SHLIB`
APXS_SYSCONFDIR=`$(APXS) -q SYSCONFDIR`
APXS_LIBS_SHLIB=`$(APXS) -q LIBS_SHLIB`
APP_INCLUDES = `pkg-config --cflags GraphicsMagick++` `pkg-config --cflags libcurl` `pkg-config --cflags QtCore`
APP_LIBS = `pkg-config --libs GraphicsMagick++` `pkg-config --libs libcurl` `pkg-config --libs QtCore`
OBJECTS = mod_image.o

# the default target
all:
	$(APXS) -S CC=g++ $(APP_INCLUDES) -c mod_image.c $(APP_LIBS)

# install the shared object file into Apache 
install: all
	sudo $(APXS) -i -n 'image' -a .libs/mod_image.so

#   cleanup
clean:
	-rm -rf *.so *.o *~ ._* *.la *.lo *.slo .libs

#   install and activate shared object by reloading Apache to
#   force a reload of the shared object file
reload: install restart

#   the general Apache start/restart/stop
#   procedures
start:
	$(APACHECTL) start
restart:
	$(APACHECTL) restart
stop:
	$(APACHECTL) stop

