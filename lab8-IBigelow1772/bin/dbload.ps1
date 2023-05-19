#!/usr/bin/env pwsh
# Ian Bigelow
# Lab 8 - PowerShell Database Loader
# CS 3030 - Scripting Languages

Set-StrictMode –version 1

# Check Args
if($args.length -ne 2){
        Write-Host "Usage: ./dbload.ps1 INPUTCSV OUTPUTDB"
        Exit 1
}

# Process CSV File
try {
    $csv = import-csv $args[0] -delimiter "," 
}
catch {
    write-host ("Error opening CSV file: $_")
    exit 1
}

# Open Database
try {
	Add-Type -Path "dlls/System.Data.SQLite.dll"   
	$con = New-Object -TypeName System.Data.SQLite.SQLiteConnection
	$con.ConnectionString = "Data Source=$($args[1])" 
	$con.Open()
}
catch {
	write-host("Error opening database file: $_")   
	exit 1
}

# DROP tables and CREATE new tables
$transaction = $con.BeginTransaction("create")

$sql = $con.CreateCommand()
$sql.CommandText = 'DROP table if exists people'
[void]$sql.ExecuteNonQuery()

$sql = $con.CreateCommand()
$sql.CommandText = 'DROP table if exists courses'
[void]$sql.ExecuteNonQuery()

# Create People Table
$sql = $con.CreateCommand()
$sql.CommandText = 'CREATE table people (id text primary key unique,
  lastname text, firstname text, major text,
  email text, city text, state text, zip text);'
[void]$sql.ExecuteNonQuery()

# Create Courses Table
$sql = $con.CreateCommand()
$sql.CommandText = 'CREATE table courses (id text, subjcode text, coursenumber text, termcode text);'
[void]$sql.ExecuteNonQuery()

[void]$transaction.Commit()

# For Each Record in CSV file...
foreach($row in $csv){

	# INSERT a record into the People table
	$transaction = $con.BeginTransaction("addpersontransaction") 
	$sql.CommandText = "INSERT or REPLACE into people (id,firstname,lastname,email,major,city,state,zip)
	values(@id,@firstname,@lastname,@email,@major,@city,@state,@zip);" 
	[void]$sql.Parameters.AddWithValue("@id", $row.wnumber)   
	[void]$sql.Parameters.AddWithValue("@firstname", $row.firstname)
	[void]$sql.Parameters.AddWithValue("@lastname", $row.lastname)
	[void]$sql.Parameters.AddWithValue("@email", $row.email)
	[void]$sql.Parameters.AddWithValue("@major", $row.major)
	[void]$sql.Parameters.AddWithValue("@city", $row.city)
	[void]$sql.Parameters.AddWithValue("@state", $row.state)
	[void]$sql.Parameters.AddWithValue("@zip", $row.zip)

	[void]$sql.ExecuteNonQuery() 

	[void]$transaction.Commit() 

	# INSERT a record into the Courses table
	$course = $row.course.split(" ")

	$transaction = $con.BeginTransaction("addcoursestransaction") 
	$sql.CommandText = "INSERT into courses (id,subjcode,coursenumber,termcode)
	values(@id,@subjcode,@coursenumber,@termcode);" 
	[void]$sql.Parameters.AddWithValue("@id", $row.wnumber)   
	[void]$sql.Parameters.AddWithValue("@subjcode", $course[0])
	[void]$sql.Parameters.AddWithValue("@coursenumber", $course[1])
	[void]$sql.Parameters.AddWithValue("@termcode", $row.termcode)

	[void]$sql.ExecuteNonQuery() 

	[void]$transaction.Commit() 
}

exit 0