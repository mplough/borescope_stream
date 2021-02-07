#include <stdio.h>
#include <string>
#include <vector>

struct State {
    int cs;
    std::vector<char> header;
    std::vector<char> image;
    bool output_jpeg = false;
    bool write_files = false;
    size_t image_size = 0;
    uint32_t frame_number = 0;
    int n = 0;
};

/*
The header is 41 bytes.

9 bytes - "BoundaryS"
4 bytes - always 00 00 01 00
4 bytes - length of image (FFD8 to FFD9, inclusive)
4 bytes - ?
4 bytes - frame number
4 bytes - frame number again?
4 bytes - always 01 00 01 00
4 bytes - always 00 05 00 00
4 bytes - always d0 02 00 00

All 4-byte values are sent in little-endian byte order.
This bothers me because NETWORK BYTE ORDER IS BIG ENDIAN.
*/


%%{
    machine borescope;
    access fsm->;

    action done_begin {
        fsm->header.clear();
        fsm->image.clear();
        fsm->image_size = 0;
        fsm->frame_number = 0;
    }

    action done_end {
        // first, remove the characters accepted while writing the jpeg
        // but while we were really in end (yay nondeterminism)
        fsm->n++;
        for (int i=0; i<8; i++)
            fsm->image.pop_back();
        fprintf(stderr, "%08zx ", fsm->image_size);
        fprintf(stderr, "%08lx ", fsm->image.size());
        fprintf(stderr, "%8d ", fsm->frame_number);
        fprintf(stderr, "%8d ", fsm->n);

        // undo the borescope's intentional image corruption as described at
        // https://mkarr.github.io/20200616_boroscope
        fsm->image[fsm->image.size() / 2] = ~fsm->image[fsm->image.size() / 2];

        if (fsm->output_jpeg) {
            // write jpeg data with depstech header and footer stripped
            fwrite(fsm->image.data(), fsm->image.size(), 1, stdout);
        }

        if (fsm->write_files) {
            char name_buf[50];
            sprintf(name_buf, "frame_%06d.log", fsm->n);
            FILE *fp = fopen(name_buf, "wb");
            fwrite(fsm->image.data(), fsm->image.size(), 1, fp);
            fclose(fp);
        }

        fprintf(stderr, "\n");

    }

    action byte_header {
        fsm->header.push_back(fc);
    }
    action done_header {
        for(auto c : fsm->header)
            fprintf(stderr, "%02x ", c);
    }

    action byte_jpeg {
        fsm->image.push_back(fc);
    }

    action byte_image_size {
        fsm->image_size >>= 8;
        fsm->image_size |= (uint32_t) fc << 24;
    }
    image_size = any{4} $byte_image_size;

    action byte_frame_number {
        fsm->frame_number >>= 8;
        fsm->frame_number |= (uint32_t) fc << 24;
    }
    frame_number = any{4} $byte_frame_number;

    begin = ('BoundaryS') @done_begin;
    end = ('BoundaryE') @done_end;
    header = (
        any{4}  # always 00 00 01 00
        image_size
        any{4}
        frame_number
        any{4}
        any{4}
        any{4}
        any{4}
    ) $byte_header @done_header;
    jpeg = (any* -- end) $byte_jpeg;

    main := (begin header jpeg end)*;
}%%

%% write data;

void boundary_init(State *fsm) {
    %% write init;
}

void boundary_execute(State *fsm, char c) {
    const char *p = &c;
    const char *pe = p + 1;

    %% write exec;
}


int main(int argc, char **argv)
{
    State fsm;

    for (int i=1; i<argc; i++) {
        if (std::string(argv[i]) == "--jpeg") {
            fsm.output_jpeg = true;
        }
        else if (std::string(argv[i]) == "--write-files") {
            fsm.write_files = true;
        }
        else {
            printf("The option '%s' is not valid\n", argv[i]);
            return 1;
        }
    }

    boundary_init(&fsm);

    for (;;) {
        int c = getchar();
        if (c == EOF) {
            printf("got eof\n");
            break;
        }
        boundary_execute(&fsm, (char)c);
    }

    return 0;
}
