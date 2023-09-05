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

dot="."

for ext in jpg jpeg png heic tiff mp4 mov webp; do
    clear
    echo "Fixing multimedia files extensions$dot"
    dot=".."
  for file in *."$ext" *."$(echo "$ext" | tr '[:lower:]' '[:upper:]')"; do
    mv "$file" "${file%.*}.$(echo "${file##*.}" | tr '[:upper:]' '[:lower:]')"
    clear
    echo "Fixing multimedia files extensions$dot"
    dot="."
  done
done

clear
    echo "Multimedia files extensions fixed"
    dot="."

for file in *.JPG.* *.JPEG.* *.PNG.* *.TIFF.* *.WEBP.* *.MP4.* *.MOV.*; do
    clear
    echo "Fixing json files extensions$dot"
    dot=".."
    part1=$(echo "$file" | sed 's/\(.*\)\(\.[^.]*\)\(\.[^.]*\)$/\1/')
    part2=$(echo "$file" | sed 's/\(.*\)\(\.[^.]*\)\(\.[^.]*\)$/\2/')
    part3=$(echo "$file" | sed 's/\(.*\)\(\.[^.]*\)\(\.[^.]*\)$/\3/')
    newpart2=$(echo "$part2" | tr '[:upper:]' '[:lower:]')
    mv "$file" "${part1}${newpart2}${part3}"  # Изменение регистра имени и расширения
    clear
    echo "Fixing json files extensions$dot"
    dot="."
done

clear
echo "Multimedia files extensions fixed"
echo "Json files extensions fixed"



# Counters

#Count of all types of files inside the current folder

jsonAllCount=$(find . -type f -name "*.json" | wc -l)
trimmed_string=$(echo "$jsonAllCount" | sed -e 's/  */ /g' -e 's/^ *//' -e 's/ *$//')
jsonAllCount="$trimmed_string"

mp4AllCount=0
movAllCount=0
jpgAllCount=0
pngAllCount=0
webpAllCount=0
tiffAllCount=0

for file in *.mp4; do
    mp4AllCount=$(($mp4AllCount+1))
done
for file in *.mov; do
    movAllCount=$(($movAllCount+1))
done
for file in *.jpg; do
    jpgAllCount=$(($jpgAllCount+1))
done
for file in *.png; do
    pngAllCount=$(($pngAllCount+1))
done
for file in *.webp; do
    webpAllCount=$(($webpAllCount+1))
done
for file in *.tiff; do
    tiffAllCount=$(($tiffAllCount+1))
done

#File types

jsonScanned=0

mp4Found=0
movFound=0
jpgFound=0
pngFound=0
webpFound=0
tiffFound=0

mp4Proc=0
movProc=0
jpgProc=0
pngProc=0
webpProc=0
tiffProc=0

mp4Succ=0
movSucc=0
jpgSucc=0
pngSucc=0
webpSucc=0
tiffSucc=0

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
    title=$(jq -r '.title' "$json_file")

    part1=$(echo "$title" | sed 's/\(.*\)\(\.[^.]*\)$/\1/')
    part2=$(echo "$title" | sed 's/\(.*\)\(\.[^.]*\)$/\2/')
    newpart2=$(echo "$part2" | tr '[:upper:]' '[:lower:]')
    title="${part1}${newpart2}"

    echo "$title"

    fileName=""
    fileExtesion=""
    fileJson=""


    if [[ "$title" == *".mp4"* ]]; then
        
        fileName="${title%.mp4}"
        fileExtesion=".mp4"
        fileJson="$json_file"
        

        description=$(jq -r '.description' "$json_file")
        ctTimestamp=$(jq -r '.creationTime.timestamp' "$json_file")
        ctTimestamp=$(date -u -r "$ctTimestamp" +"%Y-%m-%d %H:%M:%S")
        ptTimestamp=$(jq -r '.photoTakenTime.timestamp' "$json_file")
        ptTimestamp=$(date -u -r "$ptTimestamp" +"%Y-%m-%d %H:%M:%S")
        latitude=$(jq -r '.geoData.latitude' "$json_file")
        longitude=$(jq -r '.geoData.longitude' "$json_file")
        altitude=$(jq -r '.geoData.altitude' "$json_file")


        if [ -f "${fileName}.mp4" ]; then
            mp4Found=$(($mp4Found+1))
            if [[ "$latitude" == 0 ]] && [[ "$longitude" == 0 ]]; then
                output=$(ffmpeg -loglevel error -y -i "${fileName}".mp4 -metadata title="${title}" -metadata description="${description}" -c:v copy -c:a copy "gphoto-output-mp4/${fileName}".mp4 2>&1) #2>&1 >/dev/null)
                if [[ "$output" != "" ]]; then
                    ffmpegErrors+=("-------------")
                    ffmpegErrors+=("Error occurred:")
                    ffmpegErrors+=("fileName: ${fileName}${fileExtesion}")
                    ffmpegErrors+=("fileJson: $fileJson")
                    ffmpegErrors+=("$output")
                    mp4Err=$(($mp4Err+1))
                else
                    touch -d "$ptTimestamp" "gphoto-output-mp4/${fileName}".mp4
                    rm "${fileName}.mp4"
                    rm "${json_file}"
                    mp4Succ=$(($mp4Succ+1))
                fi
                mp4Proc=$(($mp4Proc+1))
            else
                output=$(ffmpeg -loglevel error -y -i "${fileName}".mp4 -metadata title="${title}" -metadata description="${description}" -vf "geolocation=latitude=$latitude:longitude=$longitude:altitude=$altitude" -c:v libx264 -c:a copy "gphoto-output-mp4/${fileName}".mp4 2>&1) #2>&1 >/dev/null)
                if [[ "$output" != "" ]]; then
                    ffmpegErrors+=("-------------")
                    ffmpegErrors+=("Error occurred:")
                    ffmpegErrors+=("fileName: ${fileName}${fileExtesion}")
                    ffmpegErrors+=("fileJson: $fileJson")
                    ffmpegErrors+=("$output")
                    mp4Err=$(($mp4Err+1))
                else
                    touch -d "$ptTimestamp" "gphoto-output-mp4/${fileName}".mp4
                    rm "${fileName}.mp4"
                    rm "${json_file}"
                    mp4Succ=$(($mp4Succ+1))
                fi
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


        description=$(jq -r '.description' "$json_file")
        ctTimestamp=$(jq -r '.creationTime.timestamp' "$json_file")
        ctTimestamp=$(date -u -r "$ctTimestamp" +"%Y-%m-%d %H:%M:%S")
        ptTimestamp=$(jq -r '.photoTakenTime.timestamp' "$json_file")
        ptTimestamp=$(date -u -r "$ptTimestamp" +"%Y-%m-%d %H:%M:%S")
        latitude=$(jq -r '.geoData.latitude' "$json_file")
        longitude=$(jq -r '.geoData.longitude' "$json_file")
        altitude=$(jq -r '.geoData.altitude' "$json_file")


        if [ -f "${fileName}.mov" ]; then
            movFound=$(($movFound+1))
            if [[ "$latitude" == 0 ]] && [[ "$longitude" == 0 ]]; then
                output=$(ffmpeg -loglevel error -y -i "${fileName}".mov -metadata title="${title}" -metadata description="${description}" -metadata creation_time="${ctTimestamp}" -c:v copy -c:a copy "gphoto-output-mov/${fileName}".mov 2>&1) #2>&1 >/dev/null)
                if [[ "$output" != "" ]]; then
                    ffmpegErrors+=("-------------")
                    ffmpegErrors+=("Error occurred:")
                    ffmpegErrors+=("fileName: ${fileName}${fileExtesion}")
                    ffmpegErrors+=("fileJson: $fileJson")
                    ffmpegErrors+=("$output")
                    movErr=$(($movErr+1))
                else
                    touch -d "$ptTimestamp" "gphoto-output-mov/${fileName}".mov
                    rm "${fileName}.mov"
                    rm "${json_file}"
                    movSucc=$(($movSucc+1))
                fi
                movProc=$(($movProc+1))
            else
                output=$(ffmpeg -loglevel error -y -i "${fileName}".mov -metadata title="${title}" -metadata description="${description}" -metadata creation_time="${ctTimestamp}" -c:v copy -c:a copy "gphoto-output-mov/${fileName}".mov 2>&1) #2>&1 >/dev/null)
                exiftool -tagsfromfile "$json_file" "-gps:all<geoData" "${fileName}.mov"
                if [[ "$output" != "" ]]; then
                    ffmpegErrors+=("-------------")
                    ffmpegErrors+=("Error occurred:")
                    ffmpegErrors+=("fileName: ${fileName}${fileExtesion}")
                    ffmpegErrors+=("fileJson: $fileJson")
                    ffmpegErrors+=("$output")
                    movErr=$(($movErr+1))
                else
                    touch -d "$ptTimestamp" "gphoto-output-mov/${fileName}".mov
                    rm "${fileName}.mov"
                    rm "${json_file}"
                    movSucc=$(($movSucc+1))
                fi
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


        description=$(jq -r '.description' "$json_file")
        ctTimestamp=$(jq -r '.creationTime.timestamp' "$json_file")
        ctTimestamp=$(date -u -r "$ctTimestamp" +"%Y-%m-%d %H:%M:%S")
        ptTimestamp=$(jq -r '.photoTakenTime.timestamp' "$json_file")
        ptTimestamp=$(date -u -r "$ptTimestamp" +"%Y-%m-%d %H:%M:%S")
        latitude=$(jq -r '.geoData.latitude' "$json_file")
        longitude=$(jq -r '.geoData.longitude' "$json_file")
        altitude=$(jq -r '.geoData.altitude' "$json_file")

        if [ -f "${fileName}.jpg" ]; then
            jpgFound=$(($jpgFound+1))
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


            mv "${fileName}.jpg" "gphoto-output-jpg/"
            rm "${json_file}"
            touch -d "$ptTimestamp" "gphoto-output-jpg/${fileName}.jpg"
            jpgProc=$(($jpgProc+1))

            while IFS= read -r line; do
                if [[ "$line" == *"Error"* ]]; then
                    ffmpegErrors+=("-------------")
                    ffmpegErrors+=("Error occurred:")
                    ffmpegErrors+=("fileName: ${fileName}${fileExtesion}")
                    ffmpegErrors+=("fileJson: $fileJson")
                    ffmpegErrors+=("$line")
                    jpgErr=$(($jpgErr+1))
                else
                    jpgSucc=$(($jpgSucc+1))
                fi
            done <<< "$exiftool_output"

        fi        
        
    elif [[ "$title" == *".png"* ]]; then

        fileName="${title%.png}"
        fileExtesion=".png"
        fileJson="$json_file"


        description=$(jq -r '.description' "$json_file")
        ptTimestamp=$(jq -r '.photoTakenTime.timestamp' "$json_file")
        ptTimestamp=$(date -u -r "$ptTimestamp" +"%Y-%m-%d %H:%M:%S")

        if [ -f "${fileName}.png" ]; then
            pngFound=$(($pngFound+1))
            exiftool_command="exiftool -v3 -Title='Заголовок'
                                           -Description='Описание'
                                           -CreationTime='2023:08:23 07:47:42'
                                           'IMG_4573.png' 2>&1 >/dev/null"
        
            exiftool_output=$(eval "$exiftool_command")


            mv "${fileName}.png" "gphoto-output-png/"
            rm "${json_file}"
            touch -d "$ptTimestamp" "gphoto-output-png/${fileName}.png"
            pngProc=$(($pngProc+1))

            while IFS= read -r line; do
                if [[ "$line" == *"Error"* ]]; then
                    ffmpegErrors+=("-------------")
                    ffmpegErrors+=("Error occurred:")
                    ffmpegErrors+=("fileName: ${fileName}${fileExtesion}")
                    ffmpegErrors+=("fileJson: $fileJson")
                    ffmpegErrors+=("$line")
                    pngErr=$(($pngErr+1))
                else
                    pngSucc=$(($pngSucc+1))
                fi
            done <<< "$exiftool_output"
        fi


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
    echo "Multimedia files extensions fixed"
    echo "Json files extensions fixed"
    echo "Processed $jsonScanned / $jsonAllCount json files"
    echo ""
    echo "Total in folder: $jpgAllCount jpg"
    echo "Found metadata / Processed / Success / Error (jpg): $jpgFound / $jpgProc / $jpgSucc / $jpgErr"
    echo ""
    echo "Total in folder: $pngAllCount png"
    echo "Found metadata / Processed / Success / Error (png): $pngFound / $pngProc / $pngSucc / $pngErr"
    echo ""
    echo "Total in folder: $webpAllCount webp"
    echo "Found metadata / Processed / Success / Error (webp): $webpFound / $webpProc / $webpSucc / $webpErr"
    echo ""
    echo "Total in folder: $tiffAllCount tiff"
    echo "Found metadata / Processed / Success / Error (tiff): $tiffFound / $tiffProc / $tiffSucc / $tiffErr"
    echo ""
    echo "Total in folder: $mp4AllCount mp4"
    echo "Found metadata / Processed / Success / Error (mp4): $mp4Found / $mp4Proc / $mp4Succ / $mp4Err"
    echo ""
    echo "Total in folder: $movAllCount mov"
    echo "Found metadata / Processed / Success / Error (mov): $movFound / $movProc / $movSucc / $movErr"
    echo ""

done

for mp4_file in *.mp4; do
    fileName="${title%.mp4}"
    fileExtesion=".mp4"
    fileJson="${mp4_file}.json"
done

echo "Finishing the report..."
ffmpegErrors=("${ffmpegErrors[@]//[$'\r\n']/}")
ffmpegErrors=("${ffmpegErrors[@]/$'\n'/}")

errNumber="$(grep -o 'Error occurred:' <<< "${ffmpegErrors[@]}" | wc -l)"
trimmed_string=$(echo "$errNumber" | sed -e 's/  */ /g' -e 's/^ *//' -e 's/ *$//')
errNumber="$trimmed_string"

clear

for error in "${ffmpegErrors[@]}"; do
    if [[ ! -z "$error" ]]; then
        echo "$error"
    fi
done
echo ""
echo ""
echo ""
echo ""
echo ""
echo "All done. Statistics:"
echo ""
echo "Total in folder: $jpgAllCount jpg"
echo "Found metadata / Processed / Success / Error (jpg): $jpgFound / $jpgProc / $jpgSucc / $jpgErr"
echo ""
echo "Total in folder: $pngAllCount png"
echo "Found metadata / Processed / Success / Error (png): $pngFound / $pngProc / $pngSucc / $pngErr"
echo ""
echo "Total in folder: $webpAllCount webp"
echo "Found metadata / Processed / Success / Error (webp): $webpFound / $webpProc / $webpSucc / $webpErr"
echo ""
echo "Total in folder: $tiffAllCount tiff"
echo "Found metadata / Processed / Success / Error (tiff): $tiffFound / $tiffProc / $tiffSucc / $tiffErr"
echo ""
echo "Total in folder: $mp4AllCount mp4"
echo "Found metadata / Processed / Success / Error (mp4): $mp4Found / $mp4Proc / $mp4Succ / $mp4Err"
echo ""
echo "Total in folder: $movAllCount mov"
echo "Found metadata / Processed / Success / Error (mov): $movFound / $movProc / $movSucc / $movErr"
echo ""
echo "Number of occured errors: $errNumber"
echo "List of errors provided avove this section."


# echo "Updated metadata in ${successCounter} mp4 files"
# echo "Recoded ${recodedCounter} mp4 files to add geo info"
# echo "Missing ${errorCounter} mp4 files"