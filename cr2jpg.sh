#!/bin/sh

TMPDIR=".exiv2"
OUTDIR="."
PREVIEW="-preview3"
SUFFIX="CR2"
JPEGSUFFIX=".jpg"
#MOGRIFY_PARAM="-quality 75 -resize 1200x1200"
MOGRIFY_PARAM="-quality 75 -resize 2048x2048"
comment=""

while getopts ":o:c:" opt; do
	case $opt in
		o) OUTDIR="${OPTARG}"
		;;
		c) comment="${OPTARG}"
		;;
	esac
done

DELETE_TMP=0
if [ ! -d "${TMPDIR}" ]
then
	DELETE_TMP=1
	mkdir "${TMPDIR}"
fi

if [ ! -d "${OUTDIR}" ]
then
	mkdir "${OUTDIR}"
fi

for infile in "$@"
do
	in_filename=${infile##*/}
	in_basename=${in_filename%%.*} 
	in_ext=${in_filename#*.}
	in_ext=`echo ${in_ext} | tr '[:lower:]' '[:upper:]'`
#	echo ${in_filename} " || " ${in_basename} " || " ${in_ext}
	if [ "${in_ext}" == "${SUFFIX}" -a -f "${infile}" ]
	then
		exiv2 -ep3 -l "${TMPDIR}" "${infile}"
		jpegfile="${OUTDIR}/${in_basename}${JPEGSUFFIX}"
		jpegprev="${TMPDIR}/${in_basename}${PREVIEW}${JPEGSUFFIX}"
#		echo "${jpegprev}" -- "${jpegfile}"
		mv "${jpegprev}" "${jpegfile}"
		exiv2 -ee -l "${TMPDIR}" "${infile}"
		exiv2 -ie -l "${TMPDIR}" "${jpegfile}"
		exiv2 -dt "${jpegfile}"
		jhead -autorot "${jpegfile}" > /dev/null
		mogrify ${MOGRIFY_PARAM} "${jpegfile}"
		if [ "${comment}" != "" ]
		then
			jhead -cl "${comment}" "${jpegfile}" > /dev/null
		fi
		jhead -ft "${jpegfile}" > /dev/null
	fi
done

if [ "${DELETE_TMP}" == 1 ]
then
	rm -r "${TMPDIR}"
fi