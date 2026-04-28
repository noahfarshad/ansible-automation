
import os, sys;
import subprocess;
import datetime;



# Updates config.xml with the contents of the health file

def readFile( filename ):

  with open(filename) as f:
    lines = f.readlines()
    lines.append("")

  return lines



# Start of the main line code

# Read in the contents of the config.xml file 

configDir = "{{config_dir}}"
configFile = configDir + "config.xml"

lines = []
lines = readFile (configFile)

xmlFile = "{{remote_dir}}" + "/" + "moduleHealthState.xml"

healthLines = []
healthLines = readFile (xmlFile)


# Find the end of the domain configuration
for i in range(len(lines)):

   # if the end of the domain configuration
   if ("</domain>" in lines[i]):
      domainLine = i

      break


outputFileContents = []
j=0
while j < i:
  outputFileContents.append(lines[j])
  j = j + 1


# Add the Health output to the config.xml
for l in range(len(healthLines)):
   outputFileContents.append(healthLines[l])

outputFileContents.append("</domain>")
outputFileContents.append("\n")


# Write to the output file

file_handle = open(configFile,"wb")
for i in range(len(outputFileContents)):
   file_handle.write(outputFileContents[i])

file_handle.close()



