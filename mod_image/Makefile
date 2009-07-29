##
##  Makefile -- Build procedure for fast3lpoad Apache module
##
##  This is a C++ module so things have to be handled a little differently.

#   the used tools
APXS=apxs2
APACHECTL=apache2ctl

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
OBJECTS = mod_image.o md5.o md5wrapper.o UrlLibrary.o

# the default target
all: mod_image.so

# link
mod_image.so: $(OBJECTS)
	g++ -fPIC -shared -o $@ $(OBJECTS) $(APXS_LIBS_SHLIB) $(APP_LIBS)

# compile
%.o:%.cpp
	g++ -c -fPIC $(APP_INCLUDES) -I$(APXS_INCLUDEDIR) -I. $(APXS_CFLAGS) $(APXS_CFLAGS_SHLIB) -Wall -o $@ $<

# install the shared object file into Apache 
install: all
	$(APXS) -i -n 'image' mod_image.so

# display the apxs variables
check_apxs_vars:
	@echo APXS_CC $(APXS_CC);\
	echo APXS_TARGET $(APXS_TARGET);\
	echo APXS_CFLAGS $(APXS_CFLAGS);\
	echo APXS_SBINDIR $(APXS_SBINDIR);\
	echo APXS_CFLAGS_SHLIB $(APXS_CFLAGS_SHLIB);\
	echo APXS_INCLUDEDIR $(APXS_INCLUDEDIR);\
	echo APXS_LD_SHLIB $(APXS_LD_SHLIB);\
	echo APXS_LIBEXECDIR $(APXS_LIBEXECDIR);\
	echo APXS_LDFLAGS_SHLIB $(APXS_LDFLAGS_SHLIB);\
	echo APXS_SYSCONFDIR $(APXS_SYSCONFDIR);\
	echo APXS_LIBS_SHLIB $(APXS_LIBS_SHLIB)

#   cleanup
clean:
	-rm -f *.so *.o *~ ._*

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

