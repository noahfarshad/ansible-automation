import os,sys
import datetime
import pickle

# Global Variables

wlsSettingsFile='/tmp/wlsConfigSettings__Monitor.txt'


"""------------------------------------------------------------------------------------
This script is truly python and not jython.  It runs locally as a python script versus
remotely through wlst.
--------------------------------------------------------------------------------------
"""


def printMessage(messageType, messageText):
    # used for printing messages

    currentTime=datetime.datetime.today()
    print str(currentTime) + ' <<<' + messageType + '>>> ' + messageText
    return()


def eat_pickle( fileName ):

  """This function opens the pickle file which contains the pickled contents
  of the original vars file.   The contents of the pickle file are returned.
  """

  data = pickle.load(open(fileName, 'rb'))
  return data




def updateSettingsFile ( settingsFile, recName, modifiable, settingPath, settingName, settingValue ):

   # writes the record entries to the settings file
   sectionName = 'Monitoring'

   modifiable_YES = 'IsModifiable: YES'
   modifiable_NO  = 'IsModifiable: NO'

   modifiableStr = modifiable_NO
   if str(modifiable) == 'YES':
      modifiableStr = modifiable_YES 

   
   settingsFile.write('- name: ' + recName + ' \n')
   settingsFile.write('  ' + modifiableStr + ' \n')
   settingsFile.write('  sectionName: ' + sectionName + ' \n')
   settingsFile.write('  settingPath: ' + settingPath + ' \n') 
   settingsFile.write('  settingName: ' + settingName + ' \n')
   settingsFile.write('  settingValue: ' + settingValue + ' \n')
   settingsFile.write('\n')



def createSettingsFile (mailSessionName, mailTarget, jndiName, sessionUserName):

   """-------------------------------------------------------------------
   Generate the output file containing the WLS configuration settings
   set during the creation of the monitoring related items.  The contents 
   of this file can be used by the Ansible role that monitors WLS 
   configuration settings.
   ----------------------------------------------------------------------
   """

   fileName = wlsSettingsFile
   settingsFile=open(fileName, 'w')

   path = '/MailSessions/' + mailSessionName
   modifiable_NO  = 'NO'
   
#  1.
   recName     = 'MailSessionName'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'Name'
   settingValue = mailSessionName
   updateSettingsFile ( settingsFile, recName, modifiable, settingPath, settingName, settingValue )
# 2.
   recName     = 'MailSessionType'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'Type'
   settingValue = 'MailSession'
   updateSettingsFile ( settingsFile, recName, modifiable, settingPath, settingName, settingValue )
# 3.
   recName     = 'MailJndiName'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'JNDIName'
   settingValue = jndiName
   updateSettingsFile ( settingsFile, recName, modifiable, settingPath, settingName, settingValue )
# 4.
   recName     = 'MailSessionUserName'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'SessionUsername'
   settingValue = sessionUserName
   updateSettingsFile ( settingsFile, recName, modifiable, settingPath, settingName, settingValue )

   settingsFile.close()

   print '-------------------------------------------------------------'
   print 'Settings Written to file: ' + fileName
   print '-------------------------------------------------------------'



#  Setup required property values read from the vars file

pickleFileName        = '{{remote_dir}}/{{pickle_file_name}}'

# Open and read in the pickle file contents
data = eat_pickle(pickleFileName)

mailSessionName  = data['mail_session_name']
mailTarget       = data['mail_target']
jndiName         = data['jndi_name']
sessionUserName  = data['session_username'] 

 
printMessage( 'INFO',' Creating Settings File For Monitoring ')
createSettingsFile (mailSessionName, mailTarget, jndiName, sessionUserName)


