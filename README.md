# Borescope camera video stream rewriter

This tool rewrites the video stream from a wi-fi borescope camera as described
in [TODO BLOG POST].

# Dependencies
## Run
This tool runs on POSIX systems.  So far, macOS is tested.

## Build
The [ragel](http://www.colm.net/open-source/ragel/) regular language parser
generator must be installed.

On macOS, install `ragel` with [Homebrew](https://brew.sh/):
```bash
brew install ragel
```

Build by running `make borescope_stream`, or just `make` to also build the test
code.

# Usage

This program is designed to be used in a pipeline.  It accepts a stream on
stdin and writes raw or transformed data to stdout.  It writes parsed headers
and image information to stderr.

The following pipeline acquires video from the camera, logs the raw stream to a
file for later playback, rewrites the stream in real time, and displays video.
A named pipe is used because `ffplay` only reads files and not accept input on
stdin.

Note that `ffplay` is only required if you want to watch the video with
`ffplay`.  Feel free to not watch the video, or to use replace `ffplay` with
your preferred tool for viewing MJPEG streams.

```bash
mkfifo vid.fifo
nc 192.168.10.123 7060 \
    | tee v.log \
    | /path/to/borescope_stream --rewrite-jpeg >vid.fifo & \
    ffplay -hide_banner -loglevel error -f mjpeg vid.fifo
```

## Command-line options
- `--jpeg` - write stripped JPEG stream to stdout.
- `--rewrite-jpeg` - rewrite each frame using `jpegtran`, then write the
  transformed fram to stdout.
- `--skip-corrupt-frames` - when `--rewrite-jpeg` is active, skip writing
  frames that `jpegtran` deems corrupt.
- `--write-files` - write stripped JPEG frames from the input stream to
  individually numbered files.
