#!/bin/sh
# export all *.png out of Krita to the *.tga textures
# Note : In Krita : Layer, export Groups to batch it.

    for arg in *.png
        do
        fullpath=${arg%/*}
        filename=${arg##*/}
        extension=$(echo $arg|sed 's/.*\(\.[a-zA-Z0-9]*\)$/\1/')
        tgaconverted=$(echo $arg|sed 's/\(.*\)\..\+/\1/')".tga"
        
        convert $arg -resize 512x512 $tgaconverted
        mv $tgaconverted ../../../../o_ayumi.pk3dir/models/player/ayumi/$tgaconverted
    done

