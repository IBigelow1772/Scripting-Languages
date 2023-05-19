#!/usr/bin/env pwsh
# Ian Bigelow
# Lab 7 - PowerShell Search and Report
# CS 3030 - Scripting Languages
# **Lab 2 Search and Report Rewrite using PowerShell

Set-StrictMode –version 1

if($args.length -ne 1){
	Write-Host "Usage: srpt.ps1 FOLDER"
	Exit 1
}

$file = $args[0]
$fileData = @()
$fileData = Get-ChildItem -Recurse -Path $args[0]

# $dirCnt = ( Get-ChildItem $fileData -Recurse | Measure-Object ).Count.ToString("N0")
$dirCnt = 0
$fileCnt = 0
$symLnk = 0
$oldFileCnt = 0
$lrgFileCnt = 0
$graphicFileCnt = 0
$tmpFileCnt = 0
$exeFileCnt = 0
$totalSize = 0
$executionTime = 0
$hostName = hostname
$todaysDate = & date

# Loop though list and increment counters accordingly
foreach ($f in $fileData){
	# Check if Symbolic Link
	if ( ($f.GetType().Name -eq "FileInfo") -and ($f.mode -match 'l') ) {
		$symLnk++
	}

	# Check if File
	if ( ($f.GetType().Name -eq "FileInfo") -and ($f.mode -notmatch 'l') ) {
		$fileCnt++
		$totalSize += $f.Length
	}

	# Check if Large File
	if ( ($f.GetType().Name -eq "FileInfo") -and ($f.mode -notmatch 'l') -and ($f.length -gt 500000) ) {
		$lrgFileCnt++
   	}

	# Check if Temporary File
	if ( ($f.GetType().Name -eq "FileInfo") -and ($f.mode -notmatch 'l') -and ($f.name -match '\.o$') ) {
		$tmpFileCnt++
	}

	# Check if Graphics File
	if ( ($f.GetType().Name -eq "FileInfo") -and ($f.mode -notmatch 'l') -and ($f.name -match '\.jpg$|\.gif|\.bmp') ) {
		$graphicFileCnt++
	}

	# Check if Directory
	if ( $f.GetType().Name -eq "DirectoryInfo" ) {
		$dirCnt++
	}

	# Check if Old File
	if ($f.LastWriteTime -lt (Get-Date).addDays(-365)) {
		$oldFileCnt++
	}

	# Check if Executable
	if ( ($f.GetType().Name -eq "FileInfo") -and ($f.mode -notmatch 'l') -and ($f.name -match '\.exe|\.bat|\.ps1') ) {
		$exeFileCnt++
	}
}

$totalSize = $totalSize.ToString("N0")

# Print Output
Write-Host "SearchReport $hostName $file $todaysDate" 
Write-Host "Execution time $executionTime" 
Write-Host "Directories $dirCnt"
Write-Host "Files $fileCnt" 
Write-Host "Sym links $symLnk" 
Write-Host "Old files $oldFileCnt" 
Write-Host "Large files $lrgFileCnt" 
Write-Host "Graphics files $graphicFileCnt" 
Write-Host "Temporary files $tmpFileCnt" 
Write-Host "Executable files $exeFileCnt" 
Write-Host "TotalFileSize $totalSize" 

Exit 0
