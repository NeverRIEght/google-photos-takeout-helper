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

#File types

jsonScanned=0

mp4Found=0
movFound=0
jpgFound=0
pngFound=0
webpFound=0
tiffFound=0

mp4Suc=0
movSuc=0
jpgSuc=0
pngSuc=0
webpSuc=0
tiffSuc=0

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

jsonAllCount=$(find . -type f -name "*.json" | wc -l)
trimmed_string=$(echo "$jsonAllCount" | sed -e 's/  */ /g' -e 's/^ *//' -e 's/ *$//')
jsonAllCount="$trimmed_string"

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
        mp4Found=$(($mp4Found+1))
        

        description=$(jq -r '.description' "$json_file")

        ctTimestamp=$(jq -r '.creationTime.timestamp' "$json_file")
        ctTimestamp=$(date -u -r "$ctTimestamp" +"%Y-%m-%d %H:%M:%S")

        ptTimestamp=$(jq -r '.photoTakenTime.timestamp' "$json_file")
        ptTimestamp=$(date -u -r "$ptTimestamp" +"%Y-%m-%d %H:%M:%S")

        latitude=$(jq -r '.geoData.latitude' "$json_file")

        longitude=$(jq -r '.geoData.longitude' "$json_file")

        altitude=$(jq -r '.geoData.altitude' "$json_file")

        if [[ "$latitude" == 0 ]] && [[ "$longitude" == 0 ]]; then
            output=$(ffmpeg -loglevel error -y -i "${fileName}".mp4 -metadata title="${title}" -metadata description="${description}" -c:v copy -c:a copy "gphoto-output-mp4/${fileName}".mp4 2>&1) #2>&1 >/dev/null)
            if [[ "$output" != "" ]]; then
                ffmpegErrors+=("-------------")
                ffmpegErrors+=("Error occurred:")
                ffmpegErrors+=("fileName: ${fileName}${fileExtesion}")
                ffmpegErrors+=("fileJson: $fileJson")
            fi
            ffmpegErrors+=("$output")
            
        else
            output=$(ffmpeg -loglevel error -y -i "${fileName}".mp4 -metadata title="${title}" -metadata description="${description}" -vf "geolocation=latitude=$latitude:longitude=$longitude:altitude=$altitude" -c:v libx264 -c:a copy "gphoto-output-mp4/${fileName}".mp4 2>&1) #2>&1 >/dev/null)
            if [[ "$output" != "" ]]; then
                ffmpegErrors+=("-------------")
                ffmpegErrors+=("Error occurred:")
                ffmpegErrors+=("fileName: ${fileName}${fileExtesion}")
                ffmpegErrors+=("fileJson: $fileJson")
            fi
            ffmpegErrors+=("$output")
        fi

        touch -d "$ctTimestamp" "gphoto-output-mp4/${fileName}".mp4



        mp4Suc=$(($mp4Suc+1))

    elif [[ "$title" == *".mov"* ]]; then
        fileName="${title%.mov}"
        fileExtesion=".mov"
        fileJson="$json_file"
        movFound=$(($movFound+1))

        description=$(jq -r '.description' "$json_file")

        ctTimestamp=$(jq -r '.creationTime.timestamp' "$json_file")
        ctTimestamp=$(date -u -r "$ctTimestamp" +"%Y-%m-%d %H:%M:%S")

        ptTimestamp=$(jq -r '.photoTakenTime.timestamp' "$json_file")
        ptTimestamp=$(date -u -r "$ptTimestamp" +"%Y-%m-%d %H:%M:%S")

        latitude=$(jq -r '.geoData.latitude' "$json_file")

        longitude=$(jq -r '.geoData.longitude' "$json_file")

        altitude=$(jq -r '.geoData.altitude' "$json_file")

        if [[ "$latitude" == 0 ]] && [[ "$longitude" == 0 ]]; then
            output=$(ffmpeg -loglevel error -y -i "${fileName}".mov -metadata title="${title}" -metadata description="${description}" -metadata creation_time="${ctTimestamp}" -c:v copy -c:a copy "gphoto-output-mov/${fileName}".mov 2>&1) #2>&1 >/dev/null)
            if [[ "$output" != "" ]]; then
                ffmpegErrors+=("-------------")
                ffmpegErrors+=("Error occurred:")
                ffmpegErrors+=("fileName: ${fileName}${fileExtesion}")
                ffmpegErrors+=("fileJson: $fileJson")
            fi
            ffmpegErrors+=("$output")
            
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
        fi

        touch -d "$ctTimestamp" "gphoto-output-mov/${fileName}".mov



        movSuc=$(($movSuc+1))

    elif [[ "$title" == *".jpg"* ]]; then
        fileName="${title%.jpg}"
        fileExtesion=".jpg"
        fileJson="$json_file"
        jpgFound=$(($jpgFound+1))
    elif [[ "$title" == *".jpeg"* ]]; then
        fileName="${title%.jpeg}"
        fileExtesion=".jpeg"
        fileJson="$json_file"
        jpgFound=$(($jpgFound+1))
    elif [[ "$title" == *".png"* ]]; then
        fileName="${title%.png}"
        fileExtesion=".png"
        fileJson="$json_file"
        pngFound=$(($pngFound+1))
    elif [[ "$title" == *".webp"* ]]; then
        fileName="${title%.webp}"
        fileExtesion=".webp"
        fileJson="$json_file"
        webpFound=$(($webpFound+1))
    elif [[ "$title" == *".tiff"* ]]; then
        fileName="${title%.tiff}"
        fileExtesion=".tiff"
        fileJson="$json_file"
        tiffFound=$(($tiffFound+1))
    fi

    clear
    echo "Processed $jsonScanned / $jsonAllCount json files"

done

echo "Finishing the report..."
ffmpegErrors=("${ffmpegErrors[@]//[$'\r\n']/}")
ffmpegErrors=("${ffmpegErrors[@]/$'\n'/}")

errNumber="$(grep -o 'Error occurred:' <<< "${ffmpegErrors[@]}" | wc -l)"
trimmed_string=$(echo "$errNumber" | sed -e 's/  */ /g' -e 's/^ *//' -e 's/ *$//')
errNumber="$trimmed_string"

clear
echo "All done. Statistics:"
echo "Scanned $jsonScanned json files"
echo "Found $mp4Found mp4 files"
echo "Changed $mp4Suc mp4 files"
echo "Found $movFound mov files"
echo "Changed $movSuc mov files"
echo "Number of occured errors: $errNumber"
for error in "${ffmpegErrors[@]}"; do
    if [[ ! -z "$error" ]]; then
        echo "$error"
    fi
done

# echo "Updated metadata in ${successCounter} mp4 files"
# echo "Recoded ${recodedCounter} mp4 files to add geo info"
# echo "Missing ${errorCounter} mp4 files"