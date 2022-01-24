OUTPUTFILENAME="countreport.csv"
HTMLFILENAME="countreport.html"
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
echo "Subject ID, Tumor Count(wgs), Blood Count(wgs), Ratio(Tumor Count/Blood Count)(wgs), Tumor Count(wxs), Blood Count(wxs), Ratio(Tumor Count/Blood Count)(wxs)" >>${OUTPUTFILENAME}
echo "<html><style>table,th,td { border: 1px solid black; }</style><table><tr><th>Subject ID</th><th>Tumor Count(wgs)</th><th>Blood Count(wgs)</th><th>Ratio(Tumor Count/Blood Count)(wgs)</th><th>Tumor Count(wxs)</th><th>Blood Count(wxs)</th><th>Ratio(Tumor Count/Blood Count)(wxs)</th></tr>" >${HTMLFILENAME}
echo "Exceptions File" >${EXCEPTIONFILENAME}
for BLOODFILE in *_BLOOD_wgs
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
     
  CSVDATA="${PROJECTNAME}_${SUBJECTID},"
  if  [ "${PROJECTNAME}" = "TCGA" ]
  then
     CSVDATA="${SUBJECTID},"
  fi
  
  HTMLDATA="<tr><td>${PROJECTNAME}_${SUBJECTID}</td>"
  if test -f "${TUMORBASEFILENAME}"
  then
     COUNTTUMOR=`samtools view -c -F 260 ${TUMORBASEFILENAME}`
     COUNTBLOOD=`samtools view -c -F 260 ${BLOODFILE}`
     CSVDATA="${CSVDATA}""${COUNTTUMOR},${COUNTBLOOD}," 
     HTMLDATA="${HTMLDATA}""<td>${COUNTTUMOR}</td><td>${COUNTBLOOD}</td>" 
     RATIO=`python /work/pi_gblanck/Mallika/bin/computeratio.py ${COUNTTUMOR}  ${COUNTBLOOD}`
     CSVDATA="${CSVDATA}""${RATIO},"
     HTMLDATA="${HTMLDATA}""<td>${RATIO}</td>"
     BLOODFILE1=`echo ${BLOODFILE} | sed 's/_wgs/_wxs/g'`
     #BLOODFILE1="${PROJECTNAME}_${SUBJECTID}_BLOOD_wxs"
     if test -f "${BLOODFILE1}" 
     then
         TUMORBASEFILENAME1=`echo ${BLOODFILE1} | sed 's/_BLOOD_/_TUMOR_/g'`
         if test -f "${TUMORBASEFILENAME1}" 
         then
             COUNTTUMOR=`samtools view -c -F 260 ${TUMORBASEFILENAME1}`
             COUNTBLOOD=`samtools view -c -F 260 ${BLOODFILE1}`
             CSVDATA="${CSVDATA}""${COUNTTUMOR},${COUNTBLOOD}," 
             HTMLDATA="${HTMLDATA}""<td>${COUNTTUMOR}<//td><td>${COUNTBLOOD}</td>" 
             RATIO=`python /work/pi_gblanck/Mallika/bin/computeratio.py ${COUNTTUMOR}  ${COUNTBLOOD}`
             CSVDATA="${CSVDATA}""${RATIO}"
             HTMLDATA="${HTMLDATA}""<td>${RATIO}</td></tr>"
             echo "${HTMLDATA}" >>${HTMLFILENAME}
             echo "${CSVDATA}" >>${OUTPUTFILENAME}
         else
             echo "Cannot find:${TUMORBASEFILENAME1} for ${LINENUMBER}" >>${EXCEPTIONFILENAME}
         fi
     fi
  else
     echo "Cannot find:${TUMORBASEFILENAME} for ${LINENUMBER}" >>${EXCEPTIONFILENAME}
  fi
done
echo "</table></html>" >>${HTMLFILENAME}
echo "${FILENUMBER}" >>${EXCEPTIONFILENAME}
cp ${HTMLFILENAME} ../output/${GENENAME}
cp ${OUTPUTFILENAME} ../output/${GENENAME}
cp ${EXCEPTIONFILENAME} ../output/${GENENAME}
