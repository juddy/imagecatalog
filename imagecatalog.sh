#!/bin/bash
#
# imagecatalog
#
# horrible old bash wrapper to dump a static HTML 4 document
# containing a thumbmail of an image (JPG) with ImageMagick
# further using the 'identify' tool to dump details of the JPG
# into a DAT file, which is read back as the input to 'text2gif'
#
# 2003(?) - 2016
#
# juddy@juddy.org
#
################################################################

#set -x
#umask 022

TEXT2GIF=$(which text2gif)
if [ -z $TEXT2GIF ]
then
    echo "No text2gif found in system.  Please install or download 'text2gif'. May be in 'giflib'."
    exit 1
else
    echo "Using system 'text2gif' - $TEXT2GIF"
fi

get_jpegs(){
        # Create a list of images to process
	find ./ -iname "*.JPG" -o -name "*.jp?g" | sed 's/^\.\///' > jpegs.$$
}


write_patterns(){
# Check and create pattern matching file
if [ ! -f patterns ]
then
    cat > patterns << EOF
    Image
    Format
    Geometry
    Colorspace
    Resolution
    Units
    Filesize
    Compression
    Quality
    Orientation
    Signature
    Tainted
EOF
fi
}


write_stub(){
# Create HTML stub
echo "Stubbing..."
cat > index.htm << EOF
<html>
<head>
<title>ImageCatalog $(pwd) - $(date)</title>
    <style type="text/css">
    <!--
    body {
    background-color: #000000;
    }
    body,td,th {
    font-family: Geneva, Arial, Helvetica, san-serif;
    font-size: 10pt;
    }
    a:link {
    color: #009900;
    }
    a:visited {
    color: #000066;
    }
    -->
    </style>
      </head>
      <body "color: rgb(0, 0, 0); background-color: rgb(0, 0, 0);"
       alink="#000099" link="#989499" vlink="#989499">
       <img alt="image catalog" src="imagecatalog.gif"><br>
       <br>
       <br>
       <!-- stub ends here -->
EOF
}

get_head(){

        # snarf raw JPEG header and entrails
        echo "Grabbing 128 bytes from $img"
        head -c 128 $img > DAT/$img_head.out
}


get_id(){
       
        echo "Identifying $img"
        identify -ping $img > DAT/"$img"_ident.out

}

create_dat(){

        # Get exif and other data from the image
        echo "Creating dat file for $img"
        identify -verbose -strip $img | grep --file=patterns | grep -v Version > ./DAT/${img}_ident-v.out
        date > DAT/"$img"_date.out
}

make_thumb(){
    
        # Create a thumbail
        THUMB_V=512
        THUMB_H=512
        echo "Creating thumb for $img"
        convert $img -antialias -sample ${THUMB_V}x${THUMB_H} +profile "*" IMG/${img}_thumb.png
}

close_stub(){
        
        echo "</html>" >> index.htm

        }


make_entry(){
#HTML
#generate html
echo "Making web entry..."
echo '<hr noshade="noshade" "height: 8px; width: 500px; margin-left: 0px; margin-right: auto;">\
       	<img alt="'$img'" src="IMG/'$img'_nametag.gif"><br>\
       	<a href=FULL/'$img' border=0 target=blank>\
       	<img src="IMG/'$img'_thumb.png"></a> <br>\
       	<img  src="IMG/'$img'_date.gif"><br>\
       	<img  alt='$(cat DAT/"$img"_ident-v.out)' src=IMG/'$img'_ident.gif><br>\
       	<hr noshade="noshade" style="height: 8px; width: 600px ; margin-left: 0px; margin-right: auto;">' >> index.htm

            for stat in $(find ./IMG/$img-$$/ -name "*.gif")
            do
               echo '<img  src="'$stat'"><br>' >> index.htm
            done

        echo '<hr noshade="noshade" style="height: 8px; width: 600px; margin-left: 0px; margin-right: auto;">
         <br>' >> index.htm


}

process_jpegs(){

while read img
do
        # Run the functions
        echo 'Converting' "$img" '...'
        get_head
        get_id
        create_dat
        make_thumb

        # Processed - now move to the archive directory
        echo "Moving full size image $img into FULL"
        mv $img ./FULL/

        echo "Generating tags and labels..."

                $TEXT2GIF -f 255 -t "$(cat DAT/"$img"_ident.out)" -c 180 180 180 > IMG/"$img"_ident.gif

                #a 'stat' is one line of the ident-v description from the EXIF tags
                stat="1"

                mkdir IMG/$img-$$
                while read line
                do
                    echo $line
                    $TEXT2GIF -f 255 -t "$line" -c 180 180 180 > ./IMG/$img-$$/"$img"_ident-v-$stat.gif
                    stat=$(expr $stat + 1)

                done < DAT/"$img"_ident-v.out

                $TEXT2GIF -f 255 -t "$(cat DAT/"$img"_ident.out)" -c 180 180 180 > IMG/"$img"_ident.gif
                $TEXT2GIF -f 255 -t "$(cat DAT/"$img"_date.out)" -c 200 200 200 > IMG/"$img"_date.gif
                $TEXT2GIF -f 255 -t "$(echo "$img")" -c 255 168 0 > IMG/"$img"_nametag.gif

	# Write the entry; label, tag, date, thumb
	make_entry

done < jpegs.$$
}

get_jpegs

write_stub

process_jpegs

close_stub

echo "----> index.htm"
