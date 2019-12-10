#ifndef __BOUNDARY_PIPE_H
#define __BOUNDARY_PIPE_H

#include <string>

class Process {
    public:
        Process(const std::string &filename);
        ~Process();

        int wait();

        FILE *child_stdin() const {return m_child_stdin;}
        FILE *child_stdout() const {return m_child_stdout;}
        FILE *child_stderr() const {return m_child_stderr;}

    private:
        enum PipeNames {READ = 0, WRITE = 1};

        FILE *m_child_stdin;
        FILE *m_child_stdout;
        FILE *m_child_stderr;
};

#endif
