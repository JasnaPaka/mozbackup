# 
# Skript na tvorbu automatických instalaèních balíèkù pro jednotlivé jazykové verze MozBackupu
#
# Autor: Pavel Cvrèek <jasnapaka@jasnapaka.com>
# Poslední úprava: 2008-05-03
#
# Pøíklad použití:
# .\compile.ps1 1.4.8
# 
# -> vytvoøí release verze 1.4.8 v podadresáøi bin

$version = $args[0]

# Zkontroluje se poèet vstupních parametrù
if ($args.length -eq 0) {
  echo "Chybí vstupní parametr udávající verzi.";
  return;
}

# Funkce pro zkopírování souborù pro daný jazyk
function copyFiles ([string]$dir, [string]$version) {
  if (test-path .\$dir) {
    del .\$dir -recurse
  } 
  md .\$dir\
  cd .\$dir\
  md .\MozBackup-$version-EN\
  cd .\MozBackup-$version-EN\

  # Nakopírování potøebných souborù
  cp ..\..\..\source\MozBackup.exe .\MozBackup.exe
  cp ..\..\..\source\backup.ini .\backup.ini  
  cp ..\..\..\source\profilefiles.txt .\profilefiles.txt    
  cp ..\..\..\source\Default.mozprofile .\Default.mozprofile
  
  md .\dll\
  cp ..\..\..\source\dll\DelZip190.dll .\dll\DelZip190.dll
  
  cp ..\..\..\doc\english\changelog.txt .\changelog.txt
  cp ..\..\..\doc\english\license.txt .\license.txt
  cp ..\..\..\doc\english\readme.txt .\readme.txt
  
  cp ..\..\..\doc\english\language.nsi .\language.nsi
}

# Funkce pro nakopírování a rozbalení jazykového souboru
function copyLanguage ($language) {
  cp ..\..\..\l10n\$language.zip .\$language.zip
  unzip .\$language.zip -d .
  del .\$language.zip
}

function createZIP ($language, $languageShort, $version) {
  
  cd ..
  $filename = "MozBackup-" + $version + "-" + $languageShort + ".zip";
  zip $filename .\MozBackup-$version-$languageShort\MozBackup.exe
  zip $filename .\MozBackup-$version-$languageShort\backup.ini
  zip $filename .\MozBackup-$version-$languageShort\Default.lng
  zip $filename .\MozBackup-$version-$languageShort\changelog.txt
  zip $filename .\MozBackup-$version-$languageShort\license.txt
  zip $filename .\MozBackup-$version-$languageShort\readme.txt
  zip $filename .\MozBackup-$version-$languageShort\profilefiles.txt    
  zip $filename .\MozBackup-$version-$languageShort\Default.mozprofile  
  
  zip $filename .\MozBackup-$version-$languageShort\dll\DelZip190.dll
  
  mv .\$filename ..\bin\$version\$filename
  cd ..
}

function createInstaller ([string]$version) {
  cp .\installer.nsi .\install\MozBackup-$version-EN\installer.nsi
  cp .\langs.nsi .\install\MozBackup-$version-EN\langs.nsi
  cd .\install
  cd .\MozBackup-$version-EN\
  
  makensis /Dlanguage=$language /DshortLanguage=$languageShort /Dversion=$version .\installer.nsi  
  
  mv .\MozBackup-$version.exe ..\..\bin\$version\MozBackup-$version.exe
  
  cd ..
  cd ..
}

# Funkce pro spuštìní všech akcí souvisejících s pøípravou instalátoru a ZIP balíèku pro daný jazyk
function createDistribution ([string]$version) {

  if (!(test-path .\bin)) {
    md .\bin	
  }

  if (!(test-path .\bin\$version\)) {
    md .\bin\$version\	
  }

  # Priprava a vytvoreni ZIP verze 
  copyFiles "tempZip" $version;
  copyLanguage "english";
  createZIP "english" "EN" $version;
  
  # Priprava instalátoru
  copyFiles "install" $version;
  md .\l10n
  cd .\l10n
  
  cp ..\..\..\..\l10n\english.zip .\en.zip
  cp ..\..\..\..\l10n\czech.zip .\cs.zip
  cp ..\..\..\..\l10n\slovak.zip .\sk.zip
  cp ..\..\..\..\l10n\german.zip .\de.zip
  cp ..\..\..\..\build\unzip.exe .\unzip.exe
  
  cd ..
  cd ..  
  cd ..

  createInstaller $version;
}

$Dirs = get-childitem .
foreach ($dir in $Dirs) {
if (!( ($dir.extension.length -gt 0) -and ($dir.extension.length -lt $dir.Name.length) )) {    
    del -recurse $dir.name
  }
}

# Vymaže se adresáø bin
if (test-path .\bin) {
  rm -recurse .\bin
}
md .\bin

# Nakopírují se a rozbalí soubory s jazykovým nastavením
createDistribution $args[0]

#createDistribution "czech" "CZ" $args[0]
#createDistribution "slovak" "SK" $args[0]
#createDistribution "german" "DE" $args[0]

# Vytvoøí se kontrolní souèty
fsum bin\$version\* bin\$version\MD5SUM
