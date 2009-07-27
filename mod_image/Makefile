CXX           = g++
DEFINES       = -DDARWIN -DSIGPROCMASK_SETS_THREAD_MASK
CXXFLAGS      = -no-cpp-precomp -fPIC
INCPATH       = -I/usr/include/apr-1.0 -I/usr/include/apache2 -I`pkg-config --variable=includedir GraphicsMagick++` -I`pkg-config --variable=includedir libcurl` -I`pkg-config --cflags QtCore` -I. -I.
LIBS          = -F/opt/local/libexec/qt4-mac/lib -L/opt/local/libexec/qt4-mac/lib -framework QtCore `pkg-config --libs libcurl` `pkg-config --libs GraphicsMagick++`

all: mod_image.os UrlLibrary.os md5.os md5wrapper.os
	g++ -o mod_image.so -undefined dynamic_lookup -bundle mod_image.os UrlLibrary.os md5.os md5wrapper.os $(LIBS)

mod_image.os: mod_image.cpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o mod_image.os mod_image.cpp

UrlLibrary.os: UrlLibrary.cpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o UrlLibrary.os UrlLibrary.cpp

md5.os: md5.cpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o md5.os md5.cpp

md5wrapper.os: md5wrapper.cpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o md5wrapper.os md5wrapper.cpp

clean:
	rm -f *.so *.os