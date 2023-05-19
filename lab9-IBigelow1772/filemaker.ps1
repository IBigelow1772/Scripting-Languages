#!/usr/bin/env pwsh
# Ian Bigelow
# Lab 9 - PowerShell Filemaker
# CS 3030 - Scripting Languages

# RUN: ./filemaker.ps1 lab9cmds outputfile.txt 3

# Write to Output File
function writeToFile ($outputFile, $outputString) { 
    $outputString = $outputString -replace [regex]::escape("\t"), "`t" 
    $outputString = $outputString -replace [regex]::escape("\n"), "`n" 
    try {
        add-content -path $outputFile -value $outputString -nonewline 
    }
    catch {
        write-host "Write failed to file $($outputFile): $_"
        exit 1
    }
}

# Check parameters
if ($args.length -ne 3) {
    write-host ("Usage: ./filemaker.ps1 INPUTCOMMANDFILE OUTPUTFILE RECORDCOUNT")
    exit 1
}

# Convert RecordCount
try{
	$recordCount = [int]$args[2]
	if($recordCount -lt 1){
		write-host ("Error: RECORDCOUNT must be a positive integer")
		exit 1 
	}
}
catch{
	write-host ("Error Converting RecordCount to INT")
    exit 1
}

# Read File
try {
    $inputCommands = Get-Content -path $args[0] -erroraction stop 
}
catch {
    write-host ("Error opening or reading command file: $($_)") 
    exit 1
}

# Create New File
try {
    $outputFile = $args[1]
    New-Item -path $outputFile -Force -erroraction stop | out-null 
}
catch {
    write-host ("Error opening output file: $($_)") 
    exit 1
}

$randomFiles = @{}

foreach ($command in $inputCommands){    
    if ($command -match '^HEADER\s+"(.*)"$') { 
	    writeToFile $outputFile $matches.1 
    }
    if ($command -match '^WORD\s+(.*)\s+"(.*)"$') { 
	    $WORDLabel = $matches.1 
	    $WORDFilename = $matches.2 

        try {
            $wordFile = Get-Content -path $WORDFilename -erroraction stop 
            $randomFiles[$WORDFilename] = $wordFile
        }
        catch {
            write-host ("Error opening or reading command file: $($_)") 
            exit 1
        }
    }
}

for ($i = 0; $i -lt $recordCount; $i++){
    $randomWords = @{}
    foreach ($command in $inputCommands){
        if ($command -match '^STRING\s+"(.*)"$' -or $command -match "^STRING\s+'(.*)'$" ) { 
	        writeToFile $outputFile $matches.1 
        }
        if ($command -match '^WORD\s+(.*)\s+"(.*)"$') { 
            $WORDLabel = $matches.1 
            $WORDFilename = $matches.2 
            
            $randomWord = Get-Random -inputobject $randomFiles[$WORDFilename]
            $randomWords[$wordLabel] = $randomWord
            writeToFile $outputFile $randomWord
        }
        if ($command -match '^INTEGER\s+(\w+)\s+(\d+)\s+(\d+)$') { 
            $integerLabel = $matches.1 
            $integerMin = $($matches.2).toInt32($null) 
            $integerMax = $($matches.3).toInt32($null) 
            $randomInteger = Get-Random -min $integerMin -max $integerMax
            $randomWords[$integerLabel] = $randomInteger
            writeToFile $outputFile $randomInteger
        }
        if ($command -match '^REFER\s+(\w+)$' ) { 
            $referLabel = $matches.1 
            writeToFile $outputFile $randomWords[$referLabel]
        }
    }
}

