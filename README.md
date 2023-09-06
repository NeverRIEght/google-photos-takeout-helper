# google-photos-takeout-helper
Takeout photos and videos from Google Photos can be problematic, mostly because of lots of metadata, which needs to be written to a photo/video itself. But GP does not care and if you try to export your awesome multimedia library, you will get a two different types of files: multimedia file itself (jpeg, png, tiff, webp, mp4, mov, etc.) and a json file with metadata for the file mentioned previously. Now, just imagine: you have about 80000 photos and videos and also 80000 of json files! What a mess! What should you do?

I failed trying to find a perfect solution for this situation, that`s why this project appears. What is "takeout helper" and what it actually does?

What it does?
-------

1. ~~Taking your export files and place it inside generated main folder on your local drive~~
2. Going throw all of this mess, taking info from json and placing it inside your multimedia files
3. ~~Removes all json files in this main folder~~

Also, here is the list of metadata supported:

| File type | Title | Description | File modification date | File creation date  | Geographic coords |
|:-----------:|:-----------:|:-----------:|:-----------:|:-----------:|:-----------:|
| jpeg(jpg)  | &#10003;  | &#10003;  | &#10007;  | &#10003;  | &#10003;  |
| png  | &#10003;  | &#10003;  | &#10007;  | &#10003;  | &#10007;  |
| webp  | tbd  | tbd  | tbd  | tbd  | tbd  |
| tiff  | tbd  | tbd  | tbd  | tbd  | tbd  |
| mp4  | &#10003;  | &#10003;  | &#10007;  | &#10003;  | &#10003;, via recode  |
| mov  | &#10003;  | &#10003;  | &#10007;  | &#10003;  | &#10003;  |
| gif  | tbd  | tbd  | tbd  | tbd  | tbd  |


<b>The table does not illustrate the structure of the metadata of the file type, but whether the final file will contain the data you need.</b>

<b>Modification date is no longer supported due to innacurate data, provided by Google Photos</b>


Some commentaries to this table:
- Linux is unfriendly when you need to change the creation date of a file. In some cases this is possible and in some it is not. Some of the formats listed in the table do not have such a metadata field at all, and even if one is added, most applications will not recognize this date. Despite this, the script will try to record the date the file was modified and the date the file was created, if possible. In this way, you will most likely get a file whose metadata says that the file was created and edited at the same time - the time at which this video / photo was originally taken. So, you will get an accurate date in most cases.
- Geo coords is supported in mp4, but due to the peculiarities of ffmpeg, it is not possible to save the necessary metadata without video recoding. I assure you that the quality of the video when transcoding in this way remains approximately the same, if you look purely at the eye.

Project roadmap:
- [x] Deserialization solution for json
- [x] .mp4 support
- [x] Human-readable errors
- [x] .mov support
- [x] .jpg support
- [x] .png support
- [x] Extensions processing part
- [ ] Recursive error solver
- [ ] .webp support
- [ ] .tiff support
- [ ] .gif support
- [ ] Guide to usage



System requirements
-------

Takeout helper is a console app, written using a bash language.
In practice it means, that you can run this without any problem on <u>any Mac</u> or <u>Linux</u> system.
What about Windows? Sorry, I do not have a solution at the moment, just try to google it. I am not an expert.

Written and tested on Macbook Pro 2020 with M1 chip.

Usage (and explanation)
-------
### WARNINGS

<b>I take NO responsibility for your files. Everything you do - you do at your own peril and risk.
Please read the entire manual before doing anything. This will help you understand what's going on and what can go wrong.

FOR THE USERS WITH >5000 FILES:


I take NO responsibility for your hard drive state after the process. This script will check all of your photos TWICE, so
please take care of your hard drive/HDD.

I DO NOT RECOMEND TO PROCEED THE SCRIPT FOR 100.000+ FILES!


Please, break your files into pieces to proceed them one by one!</b>

### Preparations



### Script launch
### What`s next?
