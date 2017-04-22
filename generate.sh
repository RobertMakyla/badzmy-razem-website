#!/bin/bash

pagesDir=pages
commonsDir=common-parts
styleDir=style
targetDir=./target

array=( "index.html:O nas"
        "aktualnosci.html:Aktualności"
        "turnusy.html:Turnusy"
        "galeria.html:Galeria"
        "prawne.html:Regulamin / Status"
        "kontakt.html:Kontakt" )

creatingEmptyHTML () {
   for mapping in "${array[@]}" ; do
      fName="${mapping%%:*}"
      echo "Creating empty ${targetDir}/${fName}"
      touch ${targetDir}/${fName}
   done
} 

updatingWithCommon () {
   sourceFile=${commonsDir}/$1
   for mapping in "${array[@]}" ; do
      fName="${mapping%%:*}"
      echo "Updating ${targetDir}/${fName} with ${sourceFile}"
   
      if [ -f ${sourceFile} ] ; then
         cat ${sourceFile} >> ${targetDir}/${fName}
      else 
         echo "File ${sourceFile} does not exist"
         exit 1
      fi
   done
} 

addMenuBar () {
   for mapping in "${array[@]}" ; do
      fName="${mapping%%:*}"

      for menubarMapping in "${array[@]}" ; do
         menubarFName="${menubarMapping%%:*}"
         menubarTitle="${menubarMapping##*:}"

         if [[ "${fName}" == "${menubarFName}" ]] ; then
                echo "Adding menu-bar for ${fName} with title ${menubarTitle}"   
            echo "          <li class='selected'><a href='${menubarFName}'>${menubarTitle}</a></li>" >> ${targetDir}/${fName}
         else 
            echo "          <li><a href='${menubarFName}'>${menubarTitle}</a></li>" >> ${targetDir}/${fName}
         fi
      done
      
   done
} 

addPageContent () {
   for mapping in "${array[@]}" ; do
      fName="${mapping%%:*}"
      title="${mapping##*:}"
      
      if [ -f ${pagesDir}/${fName} ] ; then
         echo "Adding page content from ${pagesDir}/${fName} to ${targetDir}/${fName}"
         cat ${pagesDir}/${fName} >> ${targetDir}/${fName}
      else 
         echo "Adding empty content to ${targetDir}/${fName}"
         echo "        <h1>${title}</h1>"      >> ${targetDir}/${fName}
         echo "        <p>Dział w budowie</p>" >> ${targetDir}/${fName}
      fi
      
   done
}

copyStyleAndImages () {
   cp -fr ${styleDir} ${targetDir}
}

checkHTMLPages () {
   for mapping in "${array[@]}" ; do
      fName="${mapping%%:*}"

      echo "Checking HTML syntax of ${targetDir}/${fName}"
      
      tidy -utf8 -q -e -xml ${targetDir}/${fName}
      exitCode=$?
      if [ ${exitCode} -eq 2 ] ; then
         echo "FAILURE in ${fName}"
         exit ${exitCode}
      else
         echo "HTML syntax is OK in ${fName}"
      fi

   done
}

addUpdateDateAndTime () {
   for mapping in "${array[@]}" ; do
      fName="${mapping%%:*}"
      echo "Updating last date and time in ${targetDir}/${fName}"
      echo "Data ostatniej modyfikacji: $(date +'%Y-%m-%d %H:%M:%S')" >> ${targetDir}/${fName}
   done
}

main () {
   echo "Creating fresh target dir ${targetDir}"
   rm -rf ${targetDir}
   mkdir -p ${targetDir}

   creatingEmptyHTML
   updatingWithCommon header.txt
   addMenuBar
   updatingWithCommon news.txt
   addPageContent
   updatingWithCommon updatebar.txt
   addUpdateDateAndTime
   updatingWithCommon footer.txt

   copyStyleAndImages
   
   checkHTMLPages
}

main

echo ""
echo "SUCCESS"