#!/bin/bash

pagesDir=pages
commonsDir=common-parts
styleDir=style
target=./temporary-target-dir

array=( "index.html:O nas"
        "aktualnosci.html:Aktualności"
        "turnusy.html:Turnusy"
        "galeria.html:Galeria"
        "prawne.html:Regulamin / Status"
        "kontakt.html:Kontakt" )

creatingEmptyHTML () {
   for mapping in "${array[@]}" ; do
      fName="${mapping%%:*}"
      echo "Creating empty ${target}/${fName}"   
      touch ${target}/${fName} 
   done
} 

updatingWithCommon () {
   sourceFile=${commonsDir}/$1
   for mapping in "${array[@]}" ; do
      fName="${mapping%%:*}"
      echo "Updating ${target}/${fName} with ${sourceFile}"   
   
      if [ -f ${sourceFile} ] ; then
         cat ${sourceFile} >> ${target}/${fName} 
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
            echo "          <li class='selected'><a href='${menubarFName}'>${menubarTitle}</a></li>" >> ${target}/${fName} 
         else 
            echo "          <li><a href='${menubarFName}'>${menubarTitle}</a></li>" >> ${target}/${fName} 
         fi
      done
      
   done
} 

addPageContent () {
   for mapping in "${array[@]}" ; do
      fName="${mapping%%:*}"
      title="${mapping##*:}"
      
      if [ -f ${pagesDir}/${fName} ] ; then
         echo "Adding page content from ${pagesDir}/${fName} to ${target}/${fName}"   
         cat ${pagesDir}/${fName} >> ${target}/${fName} 
      else 
         echo "Adding empty content to ${target}/${fName}"   
         echo "        <h1>${title}</h1>"      >> ${target}/${fName} 
         echo "        <p>Dział w budowie</p>" >> ${target}/${fName} 
      fi
      
   done
}

copyStyleAndImages () {
   cp -fr ${styleDir} ${target}
}

checkHTMLPages () {
   for mapping in "${array[@]}" ; do
      fName="${mapping%%:*}"

      echo "Checking HTML syntax of ${target}/${fName}"   
      
      tidy -utf8 -xml -q -e ${target}/${fName}
   done
}

main () {
   echo "Creating fresh target dir ${target}"
   rm -rf ${target}
   mkdir -p ${target}

   creatingEmptyHTML
   updatingWithCommon header.txt
   addMenuBar
   updatingWithCommon news.txt
   addPageContent
   updatingWithCommon footer.txt
   
   copyStyleAndImages
   
   checkHTMLPages
}

main