This is refactoring of a horrible old hack to create an HTML doc from a set of JPEGs

It uses 'identify' to snarf out the JPEG attributes.

These are dumped to a 'DAT' file.

The resulting DAT file is read by 'text2gif' to generate tags for the images.

***Use at your own risk***

----
#Prerequisites

**identify** - part of ImageMagick

**text2gif** - may be packaged with giflib.

Mac:

    brew install giflib imagemagick
    
Linux:

    [apt|yum] install text2gif imagemagick

----
#Usage

1. Clone this repository.
2. Add JPEG images to the 'imagecatalog' directory for processing, or copy imagecatalog.sh to a directory containing JPEGs.
3. ./imagecatalog.sh
4. Review the resuling **index.htm** file

----

#Detritus
imagecatalog.sh leaves text files containing various attributes in the DAT and TAG subdirectories. These attributes are rendered as GIFs inline with the image.

'FULL' directory contains the full-sized image, linked from the thumbnail.


