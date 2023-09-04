#json fields


#ptTimestamp=".photoTakenTime.timestamp"
#ptFormatted=".photoTakenTime.formatted"
#gdLatitude=".geoData.latitude"
#.geoData.longitude
#.geoData.altitude
#.geoData.latitudeSpan
#.geoData.longitudeSpan
#.geoDataExif.latitude
#.geoDataExif.longitude
#.geoDataExif.altitude
#.geoDataExif.latitudeSpan
#.geoDataExif.longitudeSpan


# Counters

#Count of all types of files inside the current folder

jsonAllCount=$(find . -type f -name "*.json" | wc -l)
trimmed_string=$(echo "$jsonAllCount" | sed -e 's/  */ /g' -e 's/^ *//' -e 's/ *$//')
jsonAllCount="$trimmed_string"

mp4AllCount=$(find . -type f -name "*.mp4" | wc -l)
trimmed_string=$(echo "$mp4AllCount" | sed -e 's/  */ /g' -e 's/^ *//' -e 's/ *$//')
mp4AllCount="$trimmed_string"

movAllCount=$(find . -type f -name "*.json" | wc -l)
trimmed_string=$(echo "$movAllCount" | sed -e 's/  */ /g' -e 's/^ *//' -e 's/ *$//')
movAllCount="$trimmed_string"

jpgAllCount=$(find . -type f -name "*.json" | wc -l)
trimmed_string=$(echo "$jpgAllCount" | sed -e 's/  */ /g' -e 's/^ *//' -e 's/ *$//')
jpgAllCount="$trimmed_string"

pngAllCount=$(find . -type f -name "*.json" | wc -l)
trimmed_string=$(echo "$pngAllCount" | sed -e 's/  */ /g' -e 's/^ *//' -e 's/ *$//')
pngAllCount="$trimmed_string"

webpAllCount=$(find . -type f -name "*.json" | wc -l)
trimmed_string=$(echo "$webpAllCount" | sed -e 's/  */ /g' -e 's/^ *//' -e 's/ *$//')
webpAllCount="$trimmed_string"

tiffAllCount=$(find . -type f -name "*.json" | wc -l)
trimmed_string=$(echo "$tiffAllCount" | sed -e 's/  */ /g' -e 's/^ *//' -e 's/ *$//')
tiffAllCount="$trimmed_string"

#File types

jsonScanned=0

mp4Scanned=0
movScanned=0
jpgScanned=0
pngScanned=0
webpScanned=0
tiffScanned=0

mp4Proc=0
movProc=0
jpgProc=0
pngProc=0
webpProc=0
tiffProc=0

mp4Err=0
movErr=0
jpgErr=0
pngErr=0
webpErr=0
tiffErr=0

ffmpegErrors=()

#Fix files names
# exiftool -ext json -r -if '$Filename=~/(\.[^.]+)(\(\d+\)).json$$/i'  '-Filename<${Filename;s/(\.[^.]+)(\(\d+\)).json$/$2$1.json/}' .

#Write jpg metadata
# exiftool -d %s -tagsfromfile '%d/%F.json' '-GPSLatitude*<${GeoDataLatitude;$_ = undef if $_ eq "0.0"}' '-GPSLongitude*<${GeoDataLongitude;$_ = undef if $_ eq "0.0"}' '-Caption-Abstract<Description' '-Description<Description' '-XMP-xmp:Rating<${Favorited;$_=5 if $_=~/true/i}' '-AllDates<PhotoTakenTimeTimestamp' -execute '-FileCreateDate<ExifIFD:DateTimeOriginal' '-FileModifyDate<ExifIFD:DateTimeOriginal' -common_args -overwrite_original_in_place -ext jpg .
# exiftool -d %s -tagsfromfile '%d/%F.json' '-GPSLatitude*<${GeoDataLatitude;$_ = undef if $_ eq "0.0"}' '-GPSLongitude*<${GeoDataLongitude;$_ = undef if $_ eq "0.0"}' '-Caption-Abstract<Description' '-Description<Description' '-XMP-xmp:Rating<${Favorited;$_=5 if $_=~/true/i}' '-AllDates<PhotoTakenTimeTimestamp' -execute '-FileCreateDate<ExifIFD:DateTimeOriginal' '-FileModifyDate<ExifIFD:DateTimeOriginal' -common_args -overwrite_original_in_place -ext jpeg .



mkdir gphoto-output-mp4
rm -r gphoto-output-mp4/*
mkdir gphoto-output-mov
rm -r gphoto-output-mov/*
mkdir gphoto-output-jpg
rm -r gphoto-output-jpg/*
mkdir gphoto-output-png
rm -r gphoto-output-png/*
mkdir gphoto-output-webp
rm -r gphoto-output-webp/*
mkdir gphoto-output-tiff
rm -r gphoto-output-tiff/*

for json_file in *.json; do
    
    jsonScanned=$(($jsonScanned+1))

    fileName=""
    fileExtesion=""
    fileJson=""


    title=$(jq -r '.title' "$json_file")

    if [[ "$title" == *".mp4"* ]]; then
        
        fileName="${title%.mp4}"
        fileExtesion=".mp4"
        fileJson="$json_file"
        fileMp4="${json_file%.mp4.json}"
        mp4Scanned=$(($mp4Scanned+1))
        

        description=$(jq -r '.description' "$json_file")

        ctTimestamp=$(jq -r '.creationTime.timestamp' "$json_file")
        ctTimestamp=$(date -u -r "$ctTimestamp" +"%Y-%m-%d %H:%M:%S")

        ptTimestamp=$(jq -r '.photoTakenTime.timestamp' "$json_file")
        ptTimestamp=$(date -u -r "$ptTimestamp" +"%Y-%m-%d %H:%M:%S")

        latitude=$(jq -r '.geoData.latitude' "$json_file")
        longitude=$(jq -r '.geoData.longitude' "$json_file")
        altitude=$(jq -r '.geoData.altitude' "$json_file")

        if [ -f "${fileName}.mp4" ]; then
            if [[ "$latitude" == 0 ]] && [[ "$longitude" == 0 ]]; then
                output=$(ffmpeg -loglevel error -y -i "${fileName}".mp4 -metadata title="${title}" -metadata description="${description}" -c:v copy -c:a copy "gphoto-output-mp4/${fileName}".mp4 2>&1) #2>&1 >/dev/null)
                if [[ "$output" != "" ]]; then
                    ffmpegErrors+=("-------------")
                    ffmpegErrors+=("Error occurred:")
                    ffmpegErrors+=("fileName: ${fileName}${fileExtesion}")
                    ffmpegErrors+=("fileJson: $fileJson")
                fi
                ffmpegErrors+=("$output")
                touch -d "$ptTimestamp" "gphoto-output-mp4/${fileName}".mp4
                mp4Proc=$(($mp4Proc+1))
            else
                output=$(ffmpeg -loglevel error -y -i "${fileName}".mp4 -metadata title="${title}" -metadata description="${description}" -vf "geolocation=latitude=$latitude:longitude=$longitude:altitude=$altitude" -c:v libx264 -c:a copy "gphoto-output-mp4/${fileName}".mp4 2>&1) #2>&1 >/dev/null)
                if [[ "$output" != "" ]]; then
                    ffmpegErrors+=("-------------")
                    ffmpegErrors+=("Error occurred:")
                    ffmpegErrors+=("fileName: ${fileName}${fileExtesion}")
                    ffmpegErrors+=("fileJson: $fileJson")
                fi
                ffmpegErrors+=("$output")
                touch -d "$ptTimestamp" "gphoto-output-mp4/${fileName}".mp4
                mp4Proc=$(($mp4Proc+1))
            fi
        else
            ffmpegErrors+=("-------------")
            ffmpegErrors+=("Error occurred:")
            ffmpegErrors+=("fileName: ${fileName}${fileExtesion}")
            ffmpegErrors+=("fileJson: $fileJson")
            ffmpegErrors+=("updater-error: File ${fileName} is not found")
        fi

    elif [[ "$title" == *".mov"* ]]; then

        fileName="${title%.mov}"
        fileExtesion=".mov"
        fileJson="$json_file"
        movScanned=$(($movScanned+1))

        description=$(jq -r '.description' "$json_file")

        ctTimestamp=$(jq -r '.creationTime.timestamp' "$json_file")
        ctTimestamp=$(date -u -r "$ctTimestamp" +"%Y-%m-%d %H:%M:%S")

        ptTimestamp=$(jq -r '.photoTakenTime.timestamp' "$json_file")
        ptTimestamp=$(date -u -r "$ptTimestamp" +"%Y-%m-%d %H:%M:%S")

        latitude=$(jq -r '.geoData.latitude' "$json_file")

        longitude=$(jq -r '.geoData.longitude' "$json_file")

        altitude=$(jq -r '.geoData.altitude' "$json_file")

        if [ -f "${fileName}.mov" ]; then
            if [[ "$latitude" == 0 ]] && [[ "$longitude" == 0 ]]; then
                output=$(ffmpeg -loglevel error -y -i "${fileName}".mov -metadata title="${title}" -metadata description="${description}" -metadata creation_time="${ctTimestamp}" -c:v copy -c:a copy "gphoto-output-mov/${fileName}".mov 2>&1) #2>&1 >/dev/null)
                if [[ "$output" != "" ]]; then
                    ffmpegErrors+=("-------------")
                    ffmpegErrors+=("Error occurred:")
                    ffmpegErrors+=("fileName: ${fileName}${fileExtesion}")
                    ffmpegErrors+=("fileJson: $fileJson")
                fi
                ffmpegErrors+=("$output")
                touch -d "$ptTimestamp" "gphoto-output-mov/${fileName}".mov
                movProc=$(($movProc+1))
            else
                output=$(ffmpeg -loglevel error -y -i "${fileName}".mov -metadata title="${title}" -metadata description="${description}" -metadata creation_time="${ctTimestamp}" -c:v copy -c:a copy "gphoto-output-mov/${fileName}".mov 2>&1) #2>&1 >/dev/null)
                exiftool -tagsfromfile "$json_file" "-gps:all<geoData" "${fileName}.mov"
                if [[ "$output" != "" ]]; then
                    ffmpegErrors+=("-------------")
                    ffmpegErrors+=("Error occurred:")
                    ffmpegErrors+=("fileName: ${fileName}${fileExtesion}")
                    ffmpegErrors+=("fileJson: $fileJson")
                fi
                ffmpegErrors+=("$output")
                touch -d "$ptTimestamp" "gphoto-output-mov/${fileName}".mov
                movProc=$(($movProc+1))
            fi
        else
            ffmpegErrors+=("-------------")
            ffmpegErrors+=("Error occurred:")
            ffmpegErrors+=("fileName: ${fileName}${fileExtesion}")
            ffmpegErrors+=("fileJson: $fileJson")
            ffmpegErrors+=("updater-error: File ${fileName} is not found")
        fi

    
        

    elif [[ "$title" == *".jpg"* ]]; then
    
        fileName="${title%.jpg}"
        fileExtesion=".jpg"
        fileJson="$json_file"
        jpgScanned=$(($jpgScanned+1))

        description=$(jq -r '.description' "$json_file")

        ctTimestamp=$(jq -r '.creationTime.timestamp' "$json_file")
        ctTimestamp=$(date -u -r "$ctTimestamp" +"%Y-%m-%d %H:%M:%S")

        ptTimestamp=$(jq -r '.photoTakenTime.timestamp' "$json_file")
        ptTimestamp=$(date -u -r "$ptTimestamp" +"%Y-%m-%d %H:%M:%S")

        latitude=$(jq -r '.geoData.latitude' "$json_file")
        longitude=$(jq -r '.geoData.longitude' "$json_file")
        altitude=$(jq -r '.geoData.altitude' "$json_file")

        exiftool_command="exiftool -v3 -d '%Y:%m:%d %H:%M:%S' -overwrite_original \
                    '-Title=$title' \
                    '-Description=$description' \
                    '-CreateDate=$ptTimestamp' \
                    '-ModifyDate=$ptTimestamp' \
                    '-GPSLatitude=$latitude' \
                    '-GPSLongitude=$longitude' \
                    '-GPSAltitude=$altitude' \
                    '${fileName}.jpg' 2>&1 >/dev/null"
        
        exiftool_output=$(eval "$exiftool_command")

        while IFS= read -r line; do
            if [[ "$line" == *"Error"* ]]; then
                ffmpegErrors+=("-------------")
                ffmpegErrors+=("Error occurred:")
                ffmpegErrors+=("fileName: ${fileName}${fileExtesion}")
                ffmpegErrors+=("fileJson: $fileJson")
                ffmpegErrors+=("$line")
            fi
        done <<< "$exiftool_output"

        if [ -f "${fileName}.jpg" ]; then
            mv "${fileName}.jpg" "gphoto-output-jpg/"
        fi

        jpgProc=$(($jpgProc+1))
        
    elif [[ "$title" == *".png"* ]]; then
        fileName="${title%.png}"
        fileExtesion=".png"
        fileJson="$json_file"
        pngScanned=$(($pngScanned+1))
    elif [[ "$title" == *".webp"* ]]; then
        fileName="${title%.webp}"
        fileExtesion=".webp"
        fileJson="$json_file"
        webpScanned=$(($webpScanned+1))
    elif [[ "$title" == *".tiff"* ]]; then
        fileName="${title%.tiff}"
        fileExtesion=".tiff"
        fileJson="$json_file"
        tiffScanned=$(($tiffScanned+1))
    fi

    clear
    echo "Processed $jsonScanned / $jsonAllCount json files"

done

# exiftool -d '%Y:%m:%d %H:%M:%S' -overwrite_original \
#     '-Title<${Title;$_ = $val if $val}' \
#     '-Description<${Description;$_ = $val if $val}' \
#     '-CreateDate<${PhotoTakenTime.timestamp;$_ = $val if $val}' \
#     '-ModifyDate<${PhotoTakenTime.timestamp;$_ = $val if $val}' \
#     '-GPSLatitude<${GeoData.latitude;$_ = $val if $val}' \
#     '-GPSLongitude<${GeoData.longitude;$_ = $val if $val}' \
#     '-GPSAltitude<${GeoData.altitude;$_ = $val if $val}' \
#     '*.jpg'

echo "Finishing the report..."
ffmpegErrors=("${ffmpegErrors[@]//[$'\r\n']/}")
ffmpegErrors=("${ffmpegErrors[@]/$'\n'/}")

errNumber="$(grep -o 'Error occurred:' <<< "${ffmpegErrors[@]}" | wc -l)"
trimmed_string=$(echo "$errNumber" | sed -e 's/  */ /g' -e 's/^ *//' -e 's/ *$//')
errNumber="$trimmed_string"

clear
echo "All done. Statistics:"
echo "Scanned $jsonScanned json files"
echo "Found $mp4Scanned mp4 files"
echo "Processed $mp4Proc mp4 files"
echo "Found $movScanned mov files"
echo "Processed $movProc mov files"
echo "Found $jpgScanned jpg files"
echo "Processed $jpgProc jpg files"
echo "Number of occured errors: $errNumber"
for error in "${ffmpegErrors[@]}"; do
    if [[ ! -z "$error" ]]; then
        echo "$error"
    fi
done

# echo "Updated metadata in ${successCounter} mp4 files"
# echo "Recoded ${recodedCounter} mp4 files to add geo info"
# echo "Missing ${errorCounter} mp4 files"