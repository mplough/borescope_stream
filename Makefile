CXXFLAGS=-funsigned-char --std=c++17 -O3

.PHONY: all
all: boundary testpipe
	@echo "DONE."

boundary: boundary.o pipe.o
	$(CXX) $(CXXFLAGS) $(LIBS) $^ -o $@

testpipe: testpipe.o pipe.o
	$(CXX) $(CXXFLAGS) $(LIBS) $^ -o $@

boundary.cpp: pipe.h
testpipe.cpp: pipe.h
pipe.cpp: pipe.h

.PHONY: clean
clean:
	-rm -rf boundary.cpp
	-rm -rf *.o
	-rm -rf boundary
	-rm -rf testpipe

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDE) -c $< -o $@

%.cpp: %.rl
	ragel -G2 -C $< -o $@
