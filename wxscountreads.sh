OUTPUTFILENAME="countreport.csv"
EXCEPTIONFILENAME="exceptions.txt"
GENENAME=${1}
FILENUMBER=0
PROJECTNAME=${2}
if [ -z "${GENENAME}" ]
then
    echo "Usage : sh ${0} <genename>"
    exit 1
fi
if [ -z "${PROJECTNAME}" ]
then
    echo "Usage : sh ${0} <genename>"
    exit 1
fi
mkdir -p ../output/${GENENAME}
echo ",,,${1},,,,,,," >${OUTPUTFILENAME}
echo "Subject ID, Tumor Count(wxs), Blood Count(wxs), Ratio(Tumor Count/Blood Count)(wxs)" >>${OUTPUTFILENAME}
echo "Exceptions File" >${EXCEPTIONFILENAME}
for BLOODFILE in *_BLOOD_wxs
do
  FILENUMBER=`expr ${FILENUMBER} + 1`
  if [ "${FILENUMBER}" = "2000000" ]
  then
      read ANS
      break
  fi
  echo "FILENUMBER: ${FILENUMBER}"
  TUMORBASEFILENAME=`echo ${BLOODFILE} | sed 's/_BLOOD_/_TUMOR_/g'`
  SUBJECTID=`echo ${TUMORBASEFILENAME} | cut -d"_" -f2` 
  if  [ "${PROJECTNAME}" = "TCGA" ]
  then
     SUBJECTID=`echo ${TUMORBASEFILENAME} | cut -d"_" -f1` 
  fi
     
  CSVDATA="${SUBJECTID},"
  
  if test -f "${TUMORBASEFILENAME}"
  then
     COUNTTUMOR=`samtools view -c -F 260 ${TUMORBASEFILENAME}`
     COUNTBLOOD=`samtools view -c -F 260 ${BLOODFILE}`
     CSVDATA="${CSVDATA}""${COUNTTUMOR},${COUNTBLOOD}," 
     RATIO=`python /work/pi_gblanck/Mallika/bin/computeratio.py ${COUNTTUMOR}  ${COUNTBLOOD}`
     CSVDATA="${CSVDATA}""${RATIO},"
     echo "${CSVDATA}" >>${OUTPUTFILENAME}
  else
     echo "Cannot find:${TUMORBASEFILENAME1} for ${LINENUMBER}" >>${EXCEPTIONFILENAME}
  fi
done
echo "${FILENUMBER}" >>${EXCEPTIONFILENAME}
cp ${OUTPUTFILENAME} ../output/${GENENAME}
cp ${EXCEPTIONFILENAME} ../output/${GENENAME}
