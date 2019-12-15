#include <stdio.h>
#include "pipe.h"

int main(int argc, char **argv)
{
    // Ensure that the pipe is intact and that we don't have any leaking file
    // descriptors.  Set a low ulimit -n and run.
    for (int i=0; i<1000; i++) {
        Process p("cat");
        printf("%d\n", i);
        fprintf(p.child_stdin(), "line 1\n");
        fprintf(p.child_stdin(), "line 2\n");
        fclose(p.child_stdin());

        char buf[1024];
        while (true) {
            auto len = fread(buf, 1, 1024, p.child_stdout());
            fwrite(buf, len, 1, stdout);
            if (len != 1024) break;
        }
        while (true) {
            auto len = fread(buf, 1, 1024, p.child_stderr());
            fwrite(buf, len, 1, stdout);
            if (len != 1024) break;
        }
        p.wait();
    }
}
