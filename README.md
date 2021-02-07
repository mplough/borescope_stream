# Borescope camera video stream rewriter

This tool rewrites the video stream from a wi-fi borescope camera as described
in my blog post [Rewriting the video stream from a wi-fi borescope camera](https://mplough.github.io/2019/12/14/borescope.html).

It fixes the borescope's intentional stream corruption and produces output
suitable for use in standard video tools such as `ffmpeg` that read MJPEG
streams.  Credit for [identifying the method of intentional
corruption](https://mkarr.github.io/20200616_boroscope) goes to Michael Karr et
al.

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

Build by running `make borescope_stream`.

# Usage

This program is designed to be used in a pipeline.  It accepts a stream on
stdin and writes raw or transformed data to stdout.  It writes parsed headers
and image information to stderr.

The following pipeline acquires video from the camera, logs the raw stream to a
file for later playback, rewrites the stream in real time, and displays video.
A named pipe is used because `ffplay` only reads files and does not accept input
on stdin.

Note that `ffplay` is only required if you want to watch the video with
`ffplay`.  Feel free to not watch the video, or to use replace `ffplay` with
your preferred tool for viewing MJPEG streams.

```bash
mkfifo vid.fifo
nc 192.168.10.123 7060 \
    | tee v.log \
    | /path/to/borescope_stream --jpeg >vid.fifo & \
    ffplay -hide_banner -loglevel error -f mjpeg vid.fifo
```

## Command-line options
- `--jpeg` - write stripped JPEG stream to stdout.
- `--write-files` - write stripped JPEG frames from the input stream to
  individually numbered files.
