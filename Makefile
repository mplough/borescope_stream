CXXFLAGS=-funsigned-char --std=c++17 -O3

.PHONY: all
all: boundary
	@echo "DONE."

boundary: boundary.o
	$(CXX) $(CXXFLAGS) $(LIBS) $^ -o $@

.PHONY: clean
clean:
	-rm -rf *.o
	-rm -rf boundary

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDE) -c $< -o $@

%.cpp: %.rl
	ragel -G2 -C $< -o $@
