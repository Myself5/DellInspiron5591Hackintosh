#!/bin/bash

# Created by arch-dev on 02/06/2020
# Updated by arch-dev on 23/04/2022
# Copyright © 2022 ArchSoftware Inc. All rights reserved.

TOOLS="Tools"
OUTDIR="Out"
TEMP="Temp"
ACPI="ACPI"

function check()
{
 CMD=$1
 if [[ ! $CMD > /dev/null ]]; then
  if [[ $OSTYPE == "linux-gnu" ]]; then
   sudo apt install curl
  elif [[ $OSTYPE == "darwin" ]]; then
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
   brew install curl
  fi
 fi
}

function reset()
{
 rm -rf $OUTDIR
 rm -rf $TOOLS
}

function download()
{
 DIR=$1
 FILE=$2
 while IFS= read -r line; do
  link=$(echo $line | cut -d ',' -f 1)
  files=$(echo $line | cut -d ',' -f 3)
  version=$(curl -Ls -o /dev/null -w %{url_effective} $(echo $link | sed s/download.*/latest/g) | grep -o 'tag/[v.0-9]*' | awk -F/ '{print $2}' | sed 's/^v\(.*\)/\1/')
  name=$(echo $line | cut -d ',' -f 2 | sed s/##VERSION##/$version/g)
  name_current=$(echo $line | cut -d ',' -f 2 | sed s/##VERSION##/current/g)
  
  echo Downloading $name version: $version...
  if [[ $(echo $link | cut -d '/' -f 6) == "releases" ]]; then
   curl -L $link$version/$name.zip > $DIR/$name_current.zip &
  elif [[ $(echo $link | cut -d '/' -f 6) == "archive" ]]; then
   curl -L $link/master.zip > $DIR/$name_current.zip &
  fi
  until [[ -z `jobs|grep -E -v 'Done|Terminated'` ]]; do
   sleep 0.05; echo -n '.'
  done
  echo Extracting $name...
  unzip -o $DIR/$name_current.zip -d $DIR/$name_current
  until [[ -z `jobs|grep -E -v 'Done|Terminated'` ]]; do
   sleep 0.05; echo -n '.'
  done
 done <$FILE
}

function processKexts()
{
 DIR=$1
 OUT=$2
 FILE=$3
 while IFS= read -r line; do
  link=$(echo $line | cut -d ',' -f 1)
  files=$(echo $line | cut -d ',' -f 3 | sed s/#/\ /g)
  name=$(echo $line | cut -d ',' -f 2 | sed s/##VERSION##/current/g)
  for file in ${files}
  do
   echo Copying $file...
   find $DIR/$name -name $file -exec cp -R {} $OUT \;
   until [[ -z `jobs|grep -E -v 'Done|Terminated'` ]]; do
     sleep 0.05; echo -n '.'
   done
  done
 done <$FILE
 echo Copying prebuilt Kexts...
 cp -R Prebuilt/*.kext $OUT
}

function clean()
{
 echo Cleaning up...
 rm -rf $TEMP
}

cd "$(dirname "$0")"
reset
mkdir -p $OUTDIR/EFI/{BOOT,OC/{ACPI,Drivers,Kexts,Resources/{Audio,Font,Image,Label},Tools}}
check "curl"
echo Downloading necessary files...
mkdir $TEMP
download $TEMP "Dependencies/packages.txt"
mkdir $TOOLS
download $TOOLS "Dependencies/tools.txt"
echo Copying files to EFI...
processKexts $TEMP $OUTDIR/EFI/OC/Kexts "Dependencies/packages.txt"
while IFS= read -r line; do
 cp $TEMP/$(echo $line | cut -d ',' -f 1) $OUTDIR/$(echo $line | cut -d ',' -f 2)
done <"Dependencies/efi.txt"
cp $TEMP/OcBinaryData/OcBinaryData-master/Resources/Audio/OCEFIAudio_VoiceOver_Boot.mp3 $OUTDIR/EFI/OC/Resources/Audio/
cp -R $TEMP/OcBinaryData/OcBinaryData-master/Resources/Font $OUTDIR/EFI/OC/Resources/
cp -R $TEMP/OcBinaryData/OcBinaryData-master/Resources/Image $OUTDIR/EFI/OC/Resources/
cp -R $TEMP/OcBinaryData/OcBinaryData-master/Resources/Label $OUTDIR/EFI/OC/Resources/
cp $ACPI/*.aml $OUTDIR/EFI/OC/ACPI
cp config.plist $OUTDIR/EFI/OC
echo Completed!!
echo Run Audio/install.sh script once booted the first time and follow the instructions!!
clean
