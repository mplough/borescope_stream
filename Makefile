CXXFLAGS=-funsigned-char --std=c++17 -O3

.PHONY: all
all: borescope_stream testpipe
	@echo "DONE."

borescope_stream: borescope_stream.o pipe.o
	$(CXX) $(CXXFLAGS) $(LIBS) $^ -o $@

testpipe: testpipe.o pipe.o
	$(CXX) $(CXXFLAGS) $(LIBS) $^ -o $@

borescope_stream.cpp: pipe.h
testpipe.cpp: pipe.h
pipe.cpp: pipe.h

.PHONY: clean
clean:
	-rm -rf borescope_stream.cpp
	-rm -rf *.o
	-rm -rf borescope_stream
	-rm -rf testpipe

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDE) -c $< -o $@

%.cpp: %.rl
	ragel -G2 -C $< -o $@
