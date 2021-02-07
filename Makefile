CXXFLAGS=-funsigned-char --std=c++17 -O3

.PHONY: all
all: borescope_stream
	@echo "DONE."

borescope_stream: borescope_stream.o
	$(CXX) $(CXXFLAGS) $(LIBS) $^ -o $@

.PHONY: clean
clean:
	-rm -rf borescope_stream.cpp
	-rm -rf *.o
	-rm -rf borescope_stream

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDE) -c $< -o $@

%.cpp: %.rl
	ragel -G2 -C $< -o $@
