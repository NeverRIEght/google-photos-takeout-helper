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





# for json_file in *.mp4.json; do

#     filename="${json_file%.mp4.json}"
#     mp4_file="${filename}.mp4"
    
#     #json import

#     title=$(jq -r '.title' "$json_file")
#     echo "title = $title"

#     if [[ "$title" != "" ]]; then
#         $filename="${title%.mp4}"
#     fi

#     description=$(jq -r '.description' "$json_file")
#     echo "description = $description"

#     ctTimestamp=$(jq -r '.creationTime.timestamp' "$json_file")
#     ctTimestamp=$(date -u -r "$ctTimestamp" +"%Y-%m-%d %H:%M:%S")
#     echo "ctTimestamp = $ctTimestamp"

#     ptTimestamp=$(jq -r '.photoTakenTime.timestamp' "$json_file")
#     ptTimestamp=$(date -u -r "$ptTimestamp" +"%Y-%m-%d %H:%M:%S")
#     echo "ptTimestamp = $ptTimestamp"

#     latitude=$(jq -r '.geoData.latitude' "$json_file")
#     echo "latitude = $latitude"

#     longitude=$(jq -r '.geoData.longitude' "$json_file")
#     echo "longitude = $longitude"

#     altitude=$(jq -r '.geoData.altitude' "$json_file")
#     echo "altitude = $altitude"

#     filesCounter=$(($filesCounter+1))

#     if [ -e "$mp4_file" ]; then

#         if [[ "$latitude" == 0 ]] && [[ "$longitude" == 0 ]]; then
#             ffmpeg -y -i "${filename}".mp4 -metadata title="${title}" -metadata description="${description}" -c:v copy -c:a copy "gphoto-output-mp4/${filename}".mp4
#         else
#             ffmpeg -y -i "${filename}".mp4 -metadata title="${title}" -metadata description="${description}" -vf "geolocation=latitude=$latitude:longitude=$longitude:altitude=$altitude" -c:v libx264 -c:a copy "gphoto-output-mp4/${filename}".mp4
#         fi
        
# 	    touch -d "$ctTimestamp" "gphoto-output-mp4/${filename}".mp4

#         successCounter=$(($successCounter+1))

#     else
#         errorCounter=$(($errorCounter+1))
#     fi

# done


mkdir gphoto-output-mp4
rm -r gphoto-output-mp4/*

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
        mp4Found=$(($mp4Found+1))
        

        description=$(jq -r '.description' "$json_file")
        echo "description = $description"

        ctTimestamp=$(jq -r '.creationTime.timestamp' "$json_file")
        ctTimestamp=$(date -u -r "$ctTimestamp" +"%Y-%m-%d %H:%M:%S")
        echo "ctTimestamp = $ctTimestamp"

        ptTimestamp=$(jq -r '.photoTakenTime.timestamp' "$json_file")
        ptTimestamp=$(date -u -r "$ptTimestamp" +"%Y-%m-%d %H:%M:%S")
        echo "ptTimestamp = $ptTimestamp"

        latitude=$(jq -r '.geoData.latitude' "$json_file")
        echo "latitude = $latitude"

        longitude=$(jq -r '.geoData.longitude' "$json_file")
        echo "longitude = $longitude"

        altitude=$(jq -r '.geoData.altitude' "$json_file")
        echo "altitude = $altitude"

        if [[ "$latitude" == 0 ]] && [[ "$longitude" == 0 ]]; then
            output=$(ffmpeg -y -i "${fileName}".mp4 -metadata title="${title}" -metadata description="${description}" -c:v copy -c:a copy "gphoto-output-mp4/${fileName}".mp4)
            # if [[ $output == *"Error"* ]]; then
            #     ffmpegErrors+=("$output")
            # fi
            #ffmpegErrors+=("$output")
            
        else
            ffmpeg -y -i "${fileName}".mp4 -metadata title="${title}" -metadata description="${description}" -vf "geolocation=latitude=$latitude:longitude=$longitude:altitude=$altitude" -c:v libx264 -c:a copy "gphoto-output-mp4/${fileName}".mp4
        fi

        touch -d "$ctTimestamp" "gphoto-output-mp4/${fileName}".mp4

    elif [[ "$title" == *".mov"* ]]; then
        fileName="${title%.mov}"
        fileExtesion=".mov"
        fileJson="$json_file"
        movFound=$(($movFound+1))
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





    # filename="${json_file%.mp4.json}"
    # mp4_file="${filename}.mp4"
    
    # #json import

    # title=$(jq -r '.title' "$json_file")
    # echo "title = $title"

    # if [[ "$title" != "" ]]; then
    #     $filename="${title%.mp4}"
    # fi

    # description=$(jq -r '.description' "$json_file")
    # echo "description = $description"

    # ctTimestamp=$(jq -r '.creationTime.timestamp' "$json_file")
    # ctTimestamp=$(date -u -r "$ctTimestamp" +"%Y-%m-%d %H:%M:%S")
    # echo "ctTimestamp = $ctTimestamp"

    # ptTimestamp=$(jq -r '.photoTakenTime.timestamp' "$json_file")
    # ptTimestamp=$(date -u -r "$ptTimestamp" +"%Y-%m-%d %H:%M:%S")
    # echo "ptTimestamp = $ptTimestamp"

    # latitude=$(jq -r '.geoData.latitude' "$json_file")
    # echo "latitude = $latitude"

    # longitude=$(jq -r '.geoData.longitude' "$json_file")
    # echo "longitude = $longitude"

    # altitude=$(jq -r '.geoData.altitude' "$json_file")
    # echo "altitude = $altitude"

    # filesCounter=$(($filesCounter+1))

    # if [ -e "$mp4_file" ]; then

    #     if [[ "$latitude" == 0 ]] && [[ "$longitude" == 0 ]]; then
    #         ffmpeg -y -i "${filename}".mp4 -metadata title="${title}" -metadata description="${description}" -c:v copy -c:a copy "gphoto-output-mp4/${filename}".mp4
    #     else
    #         ffmpeg -y -i "${filename}".mp4 -metadata title="${title}" -metadata description="${description}" -vf "geolocation=latitude=$latitude:longitude=$longitude:altitude=$altitude" -c:v libx264 -c:a copy "gphoto-output-mp4/${filename}".mp4
    #     fi
        
	#     touch -d "$ctTimestamp" "gphoto-output-mp4/${filename}".mp4

    #     successCounter=$(($successCounter+1))

    # else
    #     errorCounter=$(($errorCounter+1))
    # fi

done


#Write mov metadata
#ffmpeg -i "$input_file" -map_metadata 0 -c:v copy -c:a copy -metadata title="$new_title" -metadata description="$new_description" -metadata creation_time="$new_creation_date" -metadata modification_time="$new_modification_date" -metadata location="$new_geo_location" -y output.mov


echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "Script finished. Statistics:"
echo "Scanned $jsonScanned json files."
# echo "Updated metadata in ${successCounter} mp4 files"
# echo "Recoded ${recodedCounter} mp4 files to add geo info"
# echo "Missing ${errorCounter} mp4 files"