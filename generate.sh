#!/bin/bash

pagesDir=pages
commonsDir=common-parts
styleDir=style
targetDir=./target
galleriesDir=galleries
galleryNameFile=name.txt

array=( "index.html:O nas"
        "aktualnosci.html:Aktualności"
        "turnusy.html:Turnusy"
        "galeria.html:Galeria"
        "prawne.html:Regulamin / Status"
        "kontakt.html:Kontakt" )

cleanTargetDir(){
   echo "Creating fresh target dir ${targetDir}"
   rm -rf ${targetDir}
   mkdir -p ${targetDir}
}

creatingEmptyHTML () {
      fName=$1
      echo ""
      echo "Creating empty ${targetDir}/${fName}"
      touch ${targetDir}/${fName}
}

updatingWithCommon () {
   fName=$1
   sourceFile=$2
   echo "Adding to ${targetDir}/${fName} the ${sourceFile}"

   if [ -f ${sourceFile} ] ; then
      cat ${sourceFile} >> ${targetDir}/${fName}
   else
      echo "File ${sourceFile} does not exist"
      exit 1
   fi
}

addMenuBar () {
   fName=$1

   for menubarMapping in "${array[@]}" ; do
      menubarFName="${menubarMapping%%:*}"
      menubarTitle="${menubarMapping##*:}"
      if [[ "${fName}" == "${menubarFName}" ]] ; then
         echo "          <li class='selected'><a href='${menubarFName}'>${menubarTitle}</a></li>" >> ${targetDir}/${fName}
      else
         echo "          <li><a href='${menubarFName}'>${menubarTitle}</a></li>" >> ${targetDir}/${fName}
      fi
   done
}

addPageContent () {
   fName=$1
   title=$2

   if [ -f ${pagesDir}/${fName} ] ; then
      echo "Adding to ${targetDir}/${fName} page content from ${pagesDir}/${fName} "
      cat ${pagesDir}/${fName} >> ${targetDir}/${fName}
   else
      echo "Adding to ${targetDir}/${fName} empty page content"
      echo "        <h1>${title}</h1>"      >> ${targetDir}/${fName}
      echo "        <p>Dział w budowie</p>" >> ${targetDir}/${fName}
   fi
}

copyStyleAndImages () {
   cp -fr ${styleDir} ${targetDir}
}

verifyHtmlSyntax () {
   echo ""
   for file2Verify in ${targetDir}/*.html ; do

      tidy -utf8 -q -e -xml ${file2Verify}
      exitCode=$?
      if [ ${exitCode} -eq 2 ] ; then
         echo ""
         echo "FAILURE: HTML syntax is incorrect in ${file2Verify}"
         exit ${exitCode}
      else
         echo "HTML syntax is OK in ${file2Verify}"
      fi
   done
   echo ""
   echo "SUCCESS"
}

addUpdateDateAndTime () {
   fName=$1
   echo "Adding to ${targetDir}/${fName} the last date of modification"
   echo "Data ostatniej modyfikacji: $(date +'%Y-%m-%d %H:%M:%S')" >> ${targetDir}/${fName}
}

generateGalleryLinks(){
   var=0
   for gallery in ${galleriesDir}/* ; do
      var=$((var + 1))
      echo "Creating gallery link to: ${gallery}"
      if [ ! -f ${gallery}/${galleryNameFile} ] ; then
         echo "FAILURE: I can't find ${gallery}/${galleryNameFile}"
         exit -1
      fi
      galleryLink=gallery.links
      galleryPage=gallery_${var}.html

      # prepending line
      line="<p><a href="${galleryPage}">$(cat ${gallery}/${galleryNameFile})</a></p>"
      echo "${line}" > ${targetDir}/${galleryLink}.tmp
      [[ -f ${targetDir}/${galleryLink} ]] && cat ${targetDir}/${galleryLink} >> ${targetDir}/${galleryLink}.tmp
      mv -f ${targetDir}/${galleryLink}.tmp ${targetDir}/${galleryLink}

   done
}


main () {
   cleanTargetDir

   generateGalleryLinks

   for mapping in "${array[@]}" ; do
       fName="${mapping%%:*}"
       title="${mapping##*:}"

       creatingEmptyHTML     "${fName}"
       updatingWithCommon    "${fName}"  ${commonsDir}/header.txt
       addMenuBar            "${fName}"
       updatingWithCommon    "${fName}"  ${commonsDir}/news-start.txt
       updatingWithCommon    "${fName}"  ${commonsDir}/news.txt
       updatingWithCommon    "${fName}"  ${commonsDir}/news-end.txt
       addPageContent        "${fName}"  "${title}"
       updatingWithCommon    "${fName}"  ${commonsDir}/updatebar.txt
       addUpdateDateAndTime  "${fName}"
       updatingWithCommon    "${fName}"  ${commonsDir}/footer.txt
   done

   copyStyleAndImages
   
   verifyHtmlSyntax
}

main