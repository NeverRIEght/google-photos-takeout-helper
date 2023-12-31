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
| webp  | &#10003;  | &#10003;  | &#10007;  | &#10003;  | &#10007;  |
| mp4  | &#10003;  | &#10003;  | &#10007;  | &#10003;  | &#10003;, via recode  |
| mov  | &#10003;  | &#10003;  | &#10007;  | &#10003;  | &#10003;  |


<b>The table does not illustrate the structure of the metadata of the file type, but whether the final file will contain the data you need.</b>

<b>Modification date is no longer supported due to innacurate data, provided by Google Photos</b>


Some commentaries to this table:
- If possible, file creation date will be written in two field: creation date and modification date. If creation date is not supported, only the modification date will be used to store this kind of data. In this case, you will see no difference between creation date and modification date inside your file manager.
- Geo coords is supported in mp4, but due to the peculiarities of ffmpeg, it is not possible to save the necessary metadata without video recoding. I assure you that the quality of the video when transcoding in this way remains approximately the same, if you look purely at the eye.

Project roadmap:
- [x] Deserialization solution for json
- [x] .mp4 support
- [x] Human-readable errors
- [x] .mov support
- [x] .jpg support
- [x] .png support
- [x] Extensions processing part
- [x] .webp support
- [x] Guide to usage
- [ ] Recursive error solver




System requirements
-------

Takeout helper is a console app, written using a bash language. 
In practice it means, that you can run this without any problem on <u>any Mac</u> or <u>Linux</u> system. 
Script is written on base of macOS, so there can be some issues using it on Linux.
What about Windows? Sorry, I do not have a solution at the moment, just try to google it. I am not an expert. 

Written and tested on Macbook Pro 2020 with M1 chip. macOS Ventura 13.5.1

Usage (and explanation)
-------
### WARNINGS

<b>I take NO responsibility for your files. Everything you do - you do at your own peril and risk. 
Please read the entire manual before doing anything. This will help you understand what's going on and what can go wrong. 


NOT RECOMMENDED TO PROCEED MORE THAN 5K FILES AT A TIME! 


Please, break your files into pieces to proceed them one by one!</b>

### Preparations

Note: All packages and utils we are going to discuss here must be installed globally (You must have access to util functions from any directories on your drive)

1. Check the WARNINGS section (above)
2. Check the system requirements section (above)
3. [Install jq](https://jqlang.github.io/jq/)
You can find the instuctions by yourself or just use [homebrew](https://brew.sh/) as I do.
To install jq with brew, use this command:

```bash
brew install jq
```

You can also remove it in future using:

```bash
brew remove jq
```

Brew will automatically provide you a way to install jq globally - follow it.

4. [Install exiftool (instructions inside)](https://exiftool.org/install.html)
5. Install ffmpeg
Using brew:

```bash
brew install ffmpeg
```

Brew will automatically provide you a way to install ffmpeg globally - follow it.

6. File management


Download you google photos library from https://takeout.google.com
Extract all the archives and place all the files you want inside one folder ("Main folder" below) 
I am so sorry, but in the current state of script there is no way to save the names of your albums.

### Script launch

Download the script itself and place it inside this main folder.


Than, open the new terminal window and type:

```bash
cd path/to/your/folder
```

You can copy the full path in Finder, for example.


Last step is to run the script:
```bash
sh gp_takeout_helper.sh 
```

Now let the script do it`s work. Take some rest, make yourself a cup of tea :)

### What`s next?

Script will provide a stats report after - you can use it to find missing data to try fix some errors itself.
Now you can see some subfolders in main folder, in which successfully processed files are grouped by extensions.
Also script removes json files, which are already used and moves successfully processed files to subfolders.
