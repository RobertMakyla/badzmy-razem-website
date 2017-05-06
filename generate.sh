#!/bin/bash

####################################  Variables  #####################################
pagesDir=pages
commonsDir=common-parts
styleDir=style
targetDir=./target
galleriesDir=galleries

galleryNameFile=name.txt
galleryLinkFile=gallery.links
galleryPrefix=galeria
galleryContentSuffix=content

####################################  Maps  ###########################################
mainPagesMap=( "index.html:O nas"
               "aktualnosci.html:Aktualności"
               "galeria.html:Galeria"
               "prawne.html:Regulamin / Statut"
               "sprawozdania.html:Sprawozdania"
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
   srcFileAbsolutePath=$2
   echo "Adding to ${targetDir}/${pageHtmlFilename} the ${srcFileAbsolutePath}"

   if [ -f ${srcFileAbsolutePath} ] ; then
      cat ${srcFileAbsolutePath} >> ${targetDir}/${pageHtmlFilename}
   else
      echo "File ${srcFileAbsolutePath} does not exist"
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
   srcParentDir=$1
   srcFilename=$2
   dstParentDir=$3
   dstFilename=$4
   title=$5

   if [ -f ${srcParentDir}/${srcFilename} ] ; then
      echo "Adding to ${dstParentDir}/${dstFilename} page content from ${srcParentDir}/${srcFilename} "
      cat ${srcParentDir}/${srcFilename} >> ${dstParentDir}/${dstFilename}
   else
      echo "Adding to ${dstParentDir}/${dstFilename} empty page content"
      echo "        <h1>${title}</h1>"      >> ${dstParentDir}/${dstFilename}
      echo "        <p>Dział w budowie</p>" >> ${dstParentDir}/${dstFilename}
   fi
}

copyStyleAndImages () {
   cp -fr ${styleDir} ${targetDir}
   cp -fr ${galleriesDir} ${targetDir}
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

generatingGalleryLinksAndContentAndMap(){
   for galleryDir in ${galleriesDir}/* ; do

      ############################
      #                          #
      # Creating .link file      #
      #                          #
      ############################
      echo "Creating gallery link to: ${galleryDir}"
      if [ ! -f ${galleryDir}/${galleryNameFile} ] ; then
         echo "FAILURE: I can't find ${galleryDir}/${galleryNameFile}"
         exit -1
      fi

      galleryHtmlPage="${galleryPrefix}_$(basename ${galleryDir}).html"
      description=$(cat ${galleryDir}/${galleryNameFile})

      # pre-pending lines (newest on the top)
      line="<p><a href="${galleryHtmlPage}">${description}</a></p>"
      echo "${line}" > ${targetDir}/${galleryLinkFile}.tmp
      [[ -f ${targetDir}/${galleryLinkFile} ]] && cat ${targetDir}/${galleryLinkFile} >> ${targetDir}/${galleryLinkFile}.tmp
      mv -f ${targetDir}/${galleryLinkFile}.tmp ${targetDir}/${galleryLinkFile}

      ############################
      #                          #
      # Creating *.content files #
      #                          #
      ############################
      echo "Creating gallery content of: ${galleryDir}"
      galleryContentFile="${galleryHtmlPage}.${galleryContentSuffix}"

      # starting content file
      echo "<h1>${description}</h1>"                     >> ${targetDir}/${galleryContentFile}
      echo '<div class="sliderClass">'                   >> ${targetDir}/${galleryContentFile}
      echo '  <ul id="image-gallery" class="cS-hidden">' >> ${targetDir}/${galleryContentFile}

      # filling gallery content file with images
      for imgFile in ${galleryDir}/* ; do
          if [[ ${imgFile} != ${galleryDir}/${galleryNameFile} ]] ; then
              echo "    <li data-thumb='${imgFile}' >" >> ${targetDir}/${galleryContentFile}
              echo "        <img src='${imgFile}' />"  >> ${targetDir}/${galleryContentFile}
              echo "     </li>"                        >> ${targetDir}/${galleryContentFile}
          fi
      done
      # ending content file
      echo '  </ul>' >> ${targetDir}/${galleryContentFile}
      echo '</div>'  >> ${targetDir}/${galleryContentFile}

      #####################################
      #                                   #
      # Putting Together Mapping:         #
      # Gallery HTML FILE : Gallery Title #
      #                                   #
      #####################################
      galleryPagesMap[${galleryHtmlPage}]=${description}

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

       if [[ ${filename} == ${galleryPrefix}*.html ]] ; then
           echo "I am not putting side logo on gallery pages - as there's no place there"
       else
           updatingWithCommon   "${filename}"  ${commonsDir}/sidelogo.txt
       fi

       updatingWithCommon   "${filename}"  ${commonsDir}/pagecontent-start.txt

       if [[ ${filename} == ${galleryPrefix}_*.html ]] ; then
           addPageContent       "${targetDir}"  "${filename}.${galleryContentSuffix}"  "${targetDir}"  "${filename}"  "${title}"
       else
           addPageContent       "${pagesDir}"   "${filename}"                          "${targetDir}"  "${filename}"  "${title}"
       fi

       updatingWithCommon       "${filename}"  ${commonsDir}/updatebar.txt
       addUpdateDateAndTime     "${filename}"
       updatingWithCommon       "${filename}"  ${commonsDir}/footer.txt
}

main () {
   cleanTargetDir

   generatingGalleryLinksAndContentAndMap

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