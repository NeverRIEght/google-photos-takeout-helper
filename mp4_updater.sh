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



successCounter=0
errorCounter=0
filesCounter=0
recodedCounter=0



mkdir gphoto-output-mp4
rm -r gphoto-output-mp4/*

for json_file in *.mp4.json; do

    filename="${json_file%.mp4.json}"
    mp4_file="${filename}.mp4"
    
    #json import

    title=$(jq -r '.title' "$json_file")
    echo "title = $title"

    if [[ "$title" != "" ]]; then
        $filename="${title%.mp4}"
    fi

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

    filesCounter=$(($filesCounter+1))

    if [ -e "$mp4_file" ]; then

        if [[ "$latitude" == 0 ]] && [[ "$longitude" == 0 ]]; then
            ffmpeg -y -i "${filename}".mp4 -metadata title="${title}" -metadata description="${description}" -c:v copy -c:a copy "gphoto-output-mp4/${filename}".mp4
        else
            ffmpeg -y -i "${filename}".mp4 -metadata title="${title}" -metadata description="${description}" -vf "geolocation=latitude=$latitude:longitude=$longitude:altitude=$altitude" -c:v libx264 -c:a copy "gphoto-output-mp4/${filename}".mp4
        fi
        
	    touch -d "$ctTimestamp" "gphoto-output-mp4/${filename}".mp4

        successCounter=$(($successCounter+1))
        
    else
        errorCounter=$(($errorCounter+1))
    fi

done





echo ""
echo ""
echo ""
echo "Scanned ${filesCounter} json files"
echo "Updated metadata in ${successCounter} mp4 files"
echo "Recoded ${recodedCounter} mp4 files to add geo info"
echo "Missing ${errorCounter} mp4 files"