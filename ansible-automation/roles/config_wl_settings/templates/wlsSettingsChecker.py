import sys
import datetime
from java.lang.reflect import UndeclaredThrowableException
from java.lang import System
import javax
from javax.management import RuntimeMBeanException
import pickle
from java.io import File


"""---------------------------------------------------------------------------
  wlsSettingsChecker.py

  This script reads in the pickled version of the vars file containing
  the list of Weblogic Server (WLS) properties and for each of those
  properties it checks if the property matches the expected value.  If the
  value does not match it reports the discrepency.

  In the case of a discrepency; if the specific attribute is modifiable the
  script will set the value back to the expected value and will report the
  results of the update.
------------------------------------------------------------------------------
"""


def eat_pickle( fileName ):

  """This function opens the pickle file which contains the pickled contents
  of the original vars file.   The contents of the pickle file are returned.
  """

  data = pickle.load(open(fileName, 'rb'))
  return data




def updateSetting( settingsFile, settingPath, settingName, settingValue):

   # Update the specified attribute setting

   cd('/')
# start an edit session
   edit()
# lock the configuration
   startEdit()
   mBean = getMBean(settingPath)
   if mBean is None:

      settingsFile.write("=================================================================" + ' \n')
      settingsFile.write("  Specified MBean does not exist: " + settingPath + ' \n')
      settingsFile.write("=================================================================" + ' \n')

      print '================================================================='
      print '  Specified MBean does not exist: ' + settingPath
      print '================================================================='

   else:
      cd (settingPath)
      set (settingName, settingValue)

# Activate changes
   save()
   activate(block='true', timeout=600000)


def getSetting( settingsFile, settingPath, settingName):

   # Get the current value of the attribute.

   cd('/')
# start an edit session
   edit()

   value = 'ERROR_OCCURRED'

   try:
       mBean = getMBean(settingPath)

       if mBean is None:

          print '================================================================='
          print '  Specified MBean does not exist: ' + settingPath
          print '================================================================='
          
          settingsFile.write("=================================================================" + ' \n')
          settingsFile.write("  Specified MBean does not exist: " + settingPath + ' \n')
          settingsFile.write("=================================================================" + ' \n')
       else:
          cd (settingPath)

          try:
            value = get (settingName)

          except:
             print '================================================================='
             print ' *** Specified Attribute does not exist: ' + settingName + '  ****'
             print '================================================================='

             settingsFile.write("=================================================================" + ' \n')
             settingsFile.write("  Specified Attribute does not exist: " + settingName + "  ****" + ' \n')
             settingsFile.write("=================================================================" + ' \n')

   except:
      print '================================================================='
      print ' *** Specified MBean does not exist: ' + settingPath
      print '================================================================='

      settingsFile.write("=================================================================" + ' \n')
      settingsFile.write("  Specified MBean does not exist: " + settingPath + ' \n')
      settingsFile.write("=================================================================" + ' \n')


   return value



def main(argv):
  global debug


#  Setup required property values read from the property file

  adminProtocol      = '{{Admin_Protocol}}'
  adminServer        = '{{Admin_Server}}'
  adminHttpsPort      = '{{Admin_Server_HTTPS_Port}}'
  userConfigFilePath = '{{admin_server_encrypted_config_file}}'
  userKeyFilePath    = '{{admin_server_encrypted_key_file}}'
  pickleFileName     = '{{gc2_remote_dir}}/{{pickle_file_name}}'

#  Connect to admin server

  adminUrl = adminProtocol  + '://' + adminServer + ':' + str(adminHttpsPort)

  print 'adminUrl. ' + adminUrl
  connect('{{weblogic_admin}}', '{{weblogic_password}}', adminUrl);

# Open and read in the pickle file contents
  data = eat_pickle(pickleFileName)

#  Name of the output file
  fileName = "/tmp/configure_weblogic_settings.out" 
  settingsFile=open(fileName, 'w')

#  Convert the contents of the pickle file to a dictionary
  wlsProperties = data['wl_config_settings']

  findingCnt = 0
# Loop through the list of dictionary records and process each one
  for record in wlsProperties:
     isModifiable = str(record['IsModifiable'])
     sectionName  = str(record['sectionName'])
     settingPath  = str(record['settingPath'])
     settingName  = str(record['settingName'])
     settingValue = str(record['settingValue'])
   
     # Get the initial value of the setting
     value = getSetting( settingsFile, settingPath, settingName)

     # Verify if the setting needs to change
     if str(value) != settingValue:

        isModifiableStr = 'False'
        if isModifiable == str(1):
           isModifiableStr = 'True'

        print " "
        print "========================================================================="
        print "SectionName:    " + sectionName
        print "Property:       " + settingName
        print "Path:           " + settingPath
        print "Current Value:  " + str(value)
        print "Expected Value: " + settingValue
        print "IsModifiable:   " + isModifiableStr
        print "========================================================================="
        print " "

        settingsFile.write("  " + ' \n')
        settingsFile.write("=========================================================================" + ' \n')
        settingsFile.write("SectionName:    " + sectionName + ' \n')
        settingsFile.write("Property:       " + settingName + ' \n')
        settingsFile.write("Path:           " + settingPath + ' \n')
        settingsFile.write("Current Value:  " + str(value) + ' \n')
        settingsFile.write("Expected Value: " + settingValue + ' \n')
        settingsFile.write("IsModifiable:   " + isModifiableStr + ' \n')
        settingsFile.write("=========================================================================" + ' \n')
        settingsFile.write(" " + ' \n')
        findingCnt = findingCnt + 1

        # If and Only If this property is Modifiable 
        if (isModifiable == str(1)):

           # If an exception occurred in the get routine DO NOT attempt to update the attribute value!
           if (value != 'ERROR_OCCURRED'):
              # Set the specified attribute value
              updateSetting( settingsFile, settingPath, settingName, settingValue)

              # Get the results after the activation of the Changes
              value = getSetting( settingsFile, settingPath, settingName)

              print " "
              print "========================================================================="
              print "Correcting Property: " + settingName
              print "Value, after update. " + str(value)
              print "========================================================================="
              print " "

              settingsFile.write(" " + ' \n')
              settingsFile.write("=========================================================================" + ' \n')
              settingsFile.write("Correcting Property: " + settingName + ' \n')
              settingsFile.write("Value, after update. " + str(value) + ' \n')
              settingsFile.write("=========================================================================" + ' \n')
              settingsFile.write(" " + ' \n')


  if (findingCnt == 0):
     settingsFile.write("++No WLS Findings -- All Values as EXPECTED! " + ' \n')
  settingsFile.close()

  print '-------------------------------------------------------------'
  print 'Settings Written to file: ' + fileName
  print '-------------------------------------------------------------'


if __name__ == "main":
  main(sys.argv[1:])

