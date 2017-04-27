#!/bin/bash

pagesDir=pages
commonsDir=common-parts
styleDir=style
targetDir=./target
galleriesDir=galleries
galleryNameFile=name.txt
galleryLink=gallery.links

mainPages=( "index.html:O nas"
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
      pageHtmlFilename=$1
      echo ""
      echo "Creating empty ${targetDir}/${pageHtmlFilename}"
      touch ${targetDir}/${pageHtmlFilename}
}

updatingWithCommon () {
   pageHtmlFilename=$1
   sourceFile=$2
   echo "Adding to ${targetDir}/${pageHtmlFilename} the ${sourceFile}"

   if [ -f ${sourceFile} ] ; then
      cat ${sourceFile} >> ${targetDir}/${pageHtmlFilename}
   else
      echo "File ${sourceFile} does not exist"
      exit 1
   fi
}

addMenuBar () {
   pageHtmlFilename=$1

   for menubarMapping in "${mainPages[@]}" ; do
      menubarFName="${menubarMapping%%:*}"
      menubarTitle="${menubarMapping##*:}"
      if [[ "${pageHtmlFilename}" == "${menubarFName}" ]] ; then
         echo "          <li class='selected'><a href='${menubarFName}'>${menubarTitle}</a></li>" >> ${targetDir}/${pageHtmlFilename}
      else
         echo "          <li><a href='${menubarFName}'>${menubarTitle}</a></li>" >> ${targetDir}/${pageHtmlFilename}
      fi
   done
}

addPageContent () {
   pageHtmlFilename=$1
   pageHtmlTitle=$2

   if [ -f ${pagesDir}/${pageHtmlFilename} ] ; then
      echo "Adding to ${targetDir}/${pageHtmlFilename} page content from ${pagesDir}/${pageHtmlFilename} "
      cat ${pagesDir}/${pageHtmlFilename} >> ${targetDir}/${pageHtmlFilename}
   else
      echo "Adding to ${targetDir}/${pageHtmlFilename} empty page content"
      echo "        <h1>${pageHtmlTitle}</h1>"      >> ${targetDir}/${pageHtmlFilename}
      echo "        <p>Dział w budowie</p>" >> ${targetDir}/${pageHtmlFilename}
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
   pageHtmlFilename=$1
   echo "Adding to ${targetDir}/${pageHtmlFilename} the last date of modification"
   echo "Data ostatniej modyfikacji: $(date +'%Y-%m-%d %H:%M:%S')" >> ${targetDir}/${pageHtmlFilename}
}

generateGalleryLinks(){
   for gallery in ${galleriesDir}/* ; do
      echo "Creating gallery link to: ${gallery}"
      if [ ! -f ${gallery}/${galleryNameFile} ] ; then
         echo "FAILURE: I can't find ${gallery}/${galleryNameFile}"
         exit -1
      fi

      galleryPage="galeria_$(basename ${gallery}).html"

      # prepending line
      line="<p><a href="${galleryPage}">$(cat ${gallery}/${galleryNameFile})</a></p>"
      echo "${line}" > ${targetDir}/${galleryLink}.tmp
      [[ -f ${targetDir}/${galleryLink} ]] && cat ${targetDir}/${galleryLink} >> ${targetDir}/${galleryLink}.tmp
      mv -f ${targetDir}/${galleryLink}.tmp ${targetDir}/${galleryLink}

   done
}

generatePage(){
       pageHtmlFilename=$1
       pageHtmlTitle=$2

       creatingEmptyHTML     "${pageHtmlFilename}"
       updatingWithCommon    "${pageHtmlFilename}"  ${commonsDir}/header.txt
       addMenuBar            "${pageHtmlFilename}"
       updatingWithCommon    "${pageHtmlFilename}"  ${commonsDir}/news-start.txt
       if [[ ${pageHtmlFilename} == galeria* ]] ; then
           updatingWithCommon    "${pageHtmlFilename}"  ${targetDir}/${galleryLink}
       else
           updatingWithCommon    "${pageHtmlFilename}"  ${commonsDir}/news.txt
       fi
       updatingWithCommon    "${pageHtmlFilename}"  ${commonsDir}/news-end.txt
       addPageContent        "${pageHtmlFilename}"  "${pageHtmlTitle}"
       updatingWithCommon    "${pageHtmlFilename}"  ${commonsDir}/updatebar.txt
       addUpdateDateAndTime  "${pageHtmlFilename}"
       updatingWithCommon    "${pageHtmlFilename}"  ${commonsDir}/footer.txt
}

main () {
   cleanTargetDir

   generateGalleryLinks

   for mapping in "${mainPages[@]}" ; do
       pageHtmlFilename="${mapping%%:*}"
       pageHtmlTitle="${mapping##*:}"
       generatePage "${pageHtmlFilename}" "${pageHtmlTitle}"
   done

   copyStyleAndImages
   
   verifyHtmlSyntax
}

main