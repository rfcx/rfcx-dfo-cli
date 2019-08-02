# Guardian Command Line Interface

This set of scripts mimics the checkin of a guardian in order to manually ingest audio files
into the RFCx platform.

A *checkin* is the upload of a single audio file together with some meta data including the timestamp of when the audio is recorded. Therefore these scripts require you to provide a timestamp for each file, which must be given in the filename.

The format of the filename is configurable. For example, if you have a set of files `2019-06-01-14:05:30.opus` then you must specify the input format as `%YYY-%m-%d-%H:%M:%S` (note that the year must span 4 characters `%YYY`).

If the filename is prefixed with information before the timestamp then it must be the same for every file. This must be included in the filename format/pattern. The string at the end of the filename (between the timestamp and the extension) is ignored. For example, if you have a set of files `MyStream-2019-06-01-14:05:30-XYZ.opus` then the input format is `MyStream-%YYY-%m-%d-%H:%M:%S` and `-XYZ` is ignored.

## Requirements

Operating systems supported: Ubuntu, macOS

The shell (bash) scripts require the following commands to be installed:

- `ffmpeg` and `sox` for audio processing/conversion
- `base64`, `sed`, `hexdump` and `gzip` for preparing checkin json, 
- `date` (or `gdate` on macOS) for parsing/preparing filenames
- `openssl` for preparing SHA1 values of the audio file
- `curl` for performing the checkin request
- `wget` for upgrading the files (e.g.  downloading an updated version of the project) in setup.sh and upgrade.sh
- `inotify` for queue processing? (not fully understood!) and `sqlite3` for handling the queue as a database of requests
- `stat` for file inspection

To install dependencies for running locally on Mac:
```
brew install wget ffmpeg sox gzip base64 sqlite3 coreutils
```

To install dependencies on a Ubuntu/Debian-based system: // untested
```
apt-get ffmpeg sox inotify openssl stat gzip base64 wget curl hexdump sed sqlite3 
```

## Getting started

*(First time setup -- short version)*

1. In a terminal, either create a new empty directory or change into a directory where there are audio files to be uploaded.

2. Grab and run setup:

   `wget -q -O setup.sh https://rf.cx/guardian-cli && chmod a+x setup.sh && ./setup.sh;`

   This will:
   - download the latest scripts from the repo (using update.sh and utils/upgrade.sh)
   - authenticate with the API
   - register a guardian with the API (by prompting for a registration code)
   - create local sqlite databases (ready for queuing checkins)
   - setup cron jobs (if neccessary - probably not for local running)

   Note: alternatively, you can manually download the git repository (not cloned!), unzip it and run `sh setup.sh`.

*(Every time you want to upload audio)*

3. Arrange the audio files in a folder where each file is of the format: `someprefix_yyyyMMdd_hhmmss` with extension `.opus` or `.wav`

4. Queue up the files using either of the 2 options:
   
   a) Single file is added to the queue by `./queue.sh batch/someprefix_20190123_123456.opus` 
   b) Multiple files are added by `./trigger_queue_from_directory.sh batch opus` where the first arg is the directory and the second arg is the file type (if the directory and file type was set during `setup.sh` then it is not required)

5. Run a batch of uploads:

   `./trigger_checkin_from_queue.sh someprefix_%YYY%m%d_%H%M%S`

    (if the file name pattern was set during `setup.sh` then it is not required)

   This will upload a batch of audio files (checkins), 3 at one time, with 5 sec gap between calls. Re-run this again until there are not remaining files in the queue.

6. Open the dashboard and check that the audio is available from this guardian. 

## Additional options

### Upload an individual file

Step 5 above pulls checkins from the queue and calls the `checkin.sh` script. If you don't need queuing (e.g. for uploading an individual file) then simply call the script with 2 arguments: the filename and the date format of the filename.

`./checkin.sh batch/20190123_123456.opus someprefix_%YYY%m%d%_H%M%S`

### Change the API

The default server for uploading audio files is `api.rfcx.org`. To change to the staging server, edit the file `.private/api_hostname` to point to `https://api-staging.rfcx.org` (or another test server).

### Multiple guardians

This repository is designed to be downloaded as a zip and extracted into a directory of files that correspond to *one* guardian.

However, it is possible to support more than one guardian by changing the `.private/api_token` and `.private/guardian_guid`.

To reset change guardians, simplest way is to remove guardian keys created on setup:
`rm .private/guardian_guid .private/api_token .private/api_registered`

Then rerun the setup script:
`./setup.sh`

### Clean up

To remove all the files created by these scripts:

`rm -f *.sh; rm -rf logs tmp databases utils .private;`
