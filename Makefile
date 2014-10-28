# Makefile for State Controller Library
# This makefile is an example only, and is intended for demonstrating compilation on Linux
# systems. The state controller code is however completely platform-independent and can easily
# be built on Windows systems. Ideally this library should either be used by directly including
# the two library source files (state_controller.h/cpp) in your project and compiling, or by
# building a static library and linking your project to it. It is also possible to build a
# dynamic library of state_controller, but due to the library's very small size and low resource
# requirements, this is not necessary and can possibly introduce unnecessary complications.
#
# All three building possibilities are demonstrated below (directly include source, build static
# library, build dynamic library).
#
# It is assumed that gtest/gtest.h is on a global include path, and the pthread, gtest and
# gtest_main libraries can be found. It is also assumed that the following Boost Libraries
# are installed and can be found: Smart Ptr, Static Assert, Type Traits
#
# Get started by executing 'make list'.
# Executing 'make' attempts to build all targets.

MAJOR_VERSION = 1
MINOR_VERSION = 2
PATCH_VERSION = 1

SRCDIR = src
TESTDIR = test
INCLUDEDIR = include
BUILDDIR = build
LIBDIR = lib
BINDIR = bin
DYNDIR = $(BUILDDIR)/for_dyn_lib

ENSURE_DIR = @mkdir -p $(@D)

INCLUDES = -I$(INCLUDEDIR)
LDFLAGS = -lpthread -lgtest -lgtest_main -L../../gtest

DLIB_OBJS = $(DYNDIR)/state_controller.o
LIB_OBJS = $(BUILDDIR)/state_controller.o
TEST_OBJS = $(BUILDDIR)/test_state_controller.o $(BUILDDIR)/test_utilities.o
DLIB_BASENAME = $(LIBDIR)/libstate_controller.so
SLIB_TARGET = $(LIBDIR)/libstate_controller.a
DLIB_TARGET = $(DLIB_BASENAME).$(MAJOR_VERSION).$(MINOR_VERSION).$(PATCH_VERSION)
TEST_TARGET = $(BINDIR)/test_state_controller

CXX = g++
AR = ar
CXXFLAGS = -Wall -g

#
# Meta rules
#

all: libs tests

libs: lib-static lib-dynamic

#
# Static library rules
#

lib-static: $(SLIB_TARGET)

$(SLIB_TARGET): $(LIB_OBJS)
	@echo "Building static library..."
	$(ENSURE_DIR)
	$(AR) -rcs $@ $^

#
# Dynamic library rules
#

lib-dynamic: $(DLIB_TARGET)

$(DLIB_TARGET): $(DLIB_OBJS)
	@echo "Building dynamic library..."
	$(ENSURE_DIR)
	$(CXX) $(CXXFLAGS) -shared -o $@ $^ $(LDFLAGS)
	ln -sf $(DLIB_TARGET) $(DLIB_BASENAME).$(MAJOR_VERSION).$(MINOR_VERSION)
	ln -sf $(DLIB_TARGET) $(DLIB_BASENAME).$(MAJOR_VERSION)
	ln -sf $(DLIB_TARGET) $(DLIB_BASENAME)

$(DYNDIR)/%.o: $(SRCDIR)/%.cpp
	$(ENSURE_DIR)
	$(CXX) $(CXXFLAGS) -fPIC -o $@ -c $< $(INCLUDES)

$(DYNDIR)/%.o: $(TESTDIR)/%.cpp
	$(ENSURE_DIR)
	$(CXX) $(CXXFLAGS) -fPIC -o $@ -c $< $(INCLUDES)

#
# Unit test rules
#

run-tests: tests
	@echo "Running $(TEST_TARGET)..."
	@./$(TEST_TARGET)

tests: $(TEST_TARGET)

$(TEST_TARGET): $(LIB_OBJS) $(TEST_OBJS)
	@echo "Building $(TEST_TARGET)..."
	$(ENSURE_DIR)
	$(CXX) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)

$(BUILDDIR)/%.o: $(SRCDIR)/%.cpp
	$(ENSURE_DIR)
	$(CXX) $(CXXFLAGS) -o $@ -c $< $(INCLUDES)

$(BUILDDIR)/%.o: $(TESTDIR)/%.cpp
	$(ENSURE_DIR)
	$(CXX) $(CXXFLAGS) -o $@ -c $< $(INCLUDES)

#
# Dependency rules
#

$(BUILDDIR)/test_utilities.o: $(TESTDIR)/test_utilities.h
$(BUILDDIR)/state_controller.o: $(INCLUDEDIR)/state_controller/state_controller.h
$(BUILDDIR)/test_state_controller.o: $(INCLUDEDIR)/state_controller/state_controller.h $(TESTDIR)/test_state_controller.h $(TESTDIR)/test_utilities.h
$(DYNDIR)/state_controller.o: $(INCLUDEDIR)/state_controller/state_controller.h

#
# Clean rules
#

clean:
	rm -f $(BUILDDIR)/*.o $(DYNDIR)/*.o
	rm -f $(SLIB_TARGET)
	rm -f $(DLIB_TARGET) $(DLIB_BASENAME).$(MAJOR_VERSION).$(MINOR_VERSION) $(DLIB_BASENAME).$(MAJOR_VERSION) $(DLIB_BASENAME)
	rm -f $(TEST_TARGET)
	rm -f *~

clean-hard:
	rm -rf $(BUILDDIR)
	rm -rf $(LIBDIR)
	rm -rf $(BINDIR)
	rm -f *~

clean-doc:
	rm -rf doc/out

#
# Help
#

.PHONY: no_targets__ list doc

doc:
	@doc/generate_doc.sh | grep warning || true

doc-verbose:
	@doc/generate_doc.sh

no_targets__:
list:
	@sh -c "$(MAKE) -p no_targets__ | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | sort"
# EOF