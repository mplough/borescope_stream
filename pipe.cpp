#include "pipe.h"

#include <stdio.h>
#include <string>
#include <unistd.h>

Process::Process(const std::string &filename)
{
    int stdin_pipe[2];
    int stdout_pipe[2];
    int stderr_pipe[2];

    if (pipe(stdin_pipe) == -1 ||
            pipe(stdout_pipe) == -1 ||
            pipe(stderr_pipe) == -1) {
        perror("Process: pipe failed");
        exit(1);
    }

    int pid = fork();

    if (pid < 0) {
        perror("Process: fork failed");
        exit(1);
    }
    else if (pid == 0) {
        // child
        if (dup2(stdin_pipe[READ], STDIN_FILENO) == -1 ||
                dup2(stdout_pipe[WRITE], STDOUT_FILENO) == -1 ||
                dup2(stderr_pipe[WRITE], STDERR_FILENO) == -1) {
            perror("child Process: dup2 failed");
            exit(1);
        }

        if (close(stdin_pipe[READ]) == -1 ||
                close(stdin_pipe[WRITE]) == -1 ||
                close(stdout_pipe[READ]) == -1 ||
                close(stdout_pipe[WRITE]) == -1 ||
                close(stderr_pipe[READ]) == -1 ||
                close(stderr_pipe[WRITE]) == -1) {
            perror("child Process: close failed");
            exit(1);
        }

        execlp(filename.c_str(), filename.c_str(), nullptr);
        perror("child Process: exec failed");
        exit(1);
    }
    else {
        // parent
        if (close(stdin_pipe[READ]) == -1 ||
                close(stdout_pipe[WRITE]) == -1 ||
                close(stderr_pipe[WRITE]) == -1) {
            perror("parent Process: close failed");
            exit(1);
        }

        m_child_stdin = fdopen(stdin_pipe[WRITE], "wb");
        m_child_stdout = fdopen(stdout_pipe[READ], "rb");
        m_child_stderr = fdopen(stderr_pipe[READ], "rb");
    }
}

Process::~Process() {
    // Note: the caller must call fclose(m_child_stdin);
    fclose(m_child_stdout);
    fclose(m_child_stderr);
}

void Process::wait() {
    ::wait(nullptr);
}
