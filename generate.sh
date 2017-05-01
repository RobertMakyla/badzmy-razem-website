#!/bin/bash

####################################  Variable  ######################################
pagesDir=pages
commonsDir=common-parts
styleDir=style
targetDir=./target
galleriesDir=galleries

galleryNameFile=name.txt
galleryLinkFile=gallery.links
galleryPrefix=galeria

####################################  Maps  ###########################################
mainPagesMap=( "index.html:O nas"
               "aktualnosci.html:Aktualności"
               "turnusy.html:Turnusy"
               "galeria.html:Galeria"
               "prawne.html:Regulamin / Status"
               "kontakt.html:Kontakt" )

declare -A galleryPagesMap

####################################  Functions  #####################################

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

   for menubarMapping in "${mainPagesMap[@]}" ; do
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
   pageHtmlParentDir=$1
   pageHtmlFilename=$2
   pageHtmlTitle=$3

   if [ -f ${pageHtmlParentDir}/${pageHtmlFilename} ] ; then
      echo "Adding to ${targetDir}/${pageHtmlFilename} page content from ${pageHtmlParentDir}/${pageHtmlFilename} "
      cat ${pagesDir}/${pageHtmlParentDir} >> ${targetDir}/${pageHtmlFilename}
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
   for eachHtmlFile in ${targetDir}/*.html ; do

      tidy -utf8 -q -e -xml ${eachHtmlFile}
      exitCode=$?
      if [ ${exitCode} -eq 2 ] ; then
         echo ""
         echo "FAILURE: HTML syntax is incorrect in ${eachHtmlFile}"
         exit ${exitCode}
      else
         echo "HTML syntax is OK in ${eachHtmlFile}"
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

generatingGalleryLinksAndMap(){
   for galleryDir in ${galleriesDir}/* ; do
      echo "Creating gallery link to: ${galleryDir}"
      if [ ! -f ${galleryDir}/${galleryNameFile} ] ; then
         echo "FAILURE: I can't find ${galleryDir}/${galleryNameFile}"
         exit -1
      fi

      galleryNewPage="${galleryPrefix}_$(basename ${galleryDir}).html"
      description=$(cat ${galleryDir}/${galleryNameFile})

      # pre-pending lines
      line="<p><a href="${galleryNewPage}">${description}</a></p>"
      echo "${line}" > ${targetDir}/${galleryLinkFile}.tmp
      [[ -f ${targetDir}/${galleryLinkFile} ]] && cat ${targetDir}/${galleryLinkFile} >> ${targetDir}/${galleryLinkFile}.tmp
      mv -f ${targetDir}/${galleryLinkFile}.tmp ${targetDir}/${galleryLinkFile}

      # Putting Together Mapping:
      # Gallery HTML FILE : Gallery Title
      galleryPagesMap[${galleryNewPage}]=${description}

   done
}

generatePage(){
       filename=$1
       title=$2

       creatingEmptyHTML        "${filename}"
       updatingWithCommon       "${filename}"  ${commonsDir}/header.txt
       addMenuBar               "${filename}"
       updatingWithCommon       "${filename}"  ${commonsDir}/news-start.txt

       if [[ ${filename} == ${galleryPrefix}*.html ]] ; then
           updatingWithCommon   "${filename}"  ${targetDir}/${galleryLinkFile}
       else
           updatingWithCommon   "${filename}"  ${commonsDir}/news.txt
       fi

       updatingWithCommon       "${filename}"  ${commonsDir}/news-end.txt
       addPageContent           "${pagesDir}"  "${filename}"  "${title}"
       updatingWithCommon       "${filename}"  ${commonsDir}/updatebar.txt
       addUpdateDateAndTime     "${filename}"
       updatingWithCommon       "${filename}"  ${commonsDir}/footer.txt
}

main () {
   cleanTargetDir

   generatingGalleryLinksAndMap

   # generating galleries
   for K in "${!galleryPagesMap[@]}" ; do
       filename=$K
       title=${galleryPagesMap[$K]}
       generatePage "${filename}" "${title}"
   done

   # generating main pages
   for mainPage in "${mainPagesMap[@]}" ; do
       filename="${mainPage%%:*}"
       title="${mainPage##*:}"
       generatePage "${filename}" "${title}"
   done

   copyStyleAndImages
   
   verifyHtmlSyntax
}

main