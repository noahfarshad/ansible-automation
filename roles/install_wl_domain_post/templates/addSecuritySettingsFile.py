import os,sys
import datetime
import pickle

# Global Variables

wlsSettingsFile_SecurityRealm='/tmp/wlsConfigSettings__SecurityRealm.txt'


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




def updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue ):

   # writes the record entries to the settings file

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



def writeBasicSettings(realmName, domainName, nodeManagerUser, securityType ):

   """-------------------------------------------------------------------
   Generate the output file containing the WLS configuration settings
   set during the creation of the clustger.  The contents of this
   file can be used by the Ansible role that monitors WLS configuration
   settings.
   ----------------------------------------------------------------------
   """

    
   modifiable_NO = 'NO'
   sectionName   = 'SecurityRealm.Root'
   
 
   path = '/' + securityType + '/' + domainName
   realmPath = path + '/Realms/' + realmName 

#  1.
   recName     = 'SecRealmBasicName'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'Name'
   settingValue = domainName
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

# 2.
   recName     = 'SecRealmBasicNodeManagerName'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'NodeManagerUsername'
   settingValue = nodeManagerUser
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

# 3.
   recName     = 'SecRealmBasicType'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'Type'
   settingValue = securityType
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

# 4.
   recName     = 'SecRealmBasicRealmName'
   modifiable  = modifiable_NO
   settingPath = realmPath
   settingName = 'Name'
   settingValue = realmName
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )





def writeAuditorSettings(realmName, domainName, auditorName, auditorVersion, auditorPath, auditorProvider):

   modifiable_NO  = 'NO'
   sectionName    = 'SecurityRealm.Auditor'
     
   path = '/SecurityConfiguration/' + domainName + '/Realms/' + realmName + '/Auditors/' + auditorName

#  1.
   recName     = 'SecRealmAuditorName'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'Name'
   settingValue = auditorName
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

#  2.
   recName     = 'SecRealmAuditorProvider'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'ProviderClassName'
   settingValue = auditorProvider
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )
   
#  3.
   recName     = 'SecRealmAuditorVersion'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'Version'
   settingValue = str(auditorVersion)
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )
   



def writeAuthorizerSettings(realmName, domainName, authorizerName, authorizerVersion, authorizerDeployEnabled, authorizerPath, authorizerProvider):

   modifiable_NO  = 'NO'
   sectionName    = 'SecurityRealm.Authorizer'
     
   path = '/SecurityConfiguration/' + domainName + '/Realms/' + realmName + '/Authorizers/' + authorizerName

#  1.
   recName     = 'SecRealmAuthorizerName'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'Name'
   settingValue = authorizerName
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

#  2.
   recName     = 'SecRealmAuthorizerProvider'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'ProviderClassName'
   settingValue = authorizerProvider
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

#  3.
   recName     = 'SecRealmAuthorizerDeployEnabled'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'PolicyDeploymentEnabled'
   settingValue = authorizerDeployEnabled
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

#  4.
   recName     = 'SecRealmAuthorizerVersion'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'Version'
   settingValue = str(authorizerVersion)
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )



def writeRoleMapperSettings(realmName, domainName, roleMapperName, roleMapperVersion, roleMapperDeployEnabled, roleMapperPath, roleMapperProvider):

   modifiable_NO  = 'NO'
   sectionName    = 'SecurityRealm.RoleMapper'     

   path = '/SecurityConfiguration/' + domainName + '/Realms/' + realmName + '/RoleMappers/' + roleMapperName

#  1.
   recName     = 'SecRealmRoleMapperName'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'Name'
   settingValue = roleMapperName
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

#  2.
   recName     = 'SecRealmRoleMapperProvider'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'ProviderClassName'
   settingValue = roleMapperProvider
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

#  3.
   recName     = 'SecRealmRoleMapperDeployEnabled'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'RoleDeploymentEnabled'
   settingValue = roleMapperDeployEnabled
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

#  4.
   recName     = 'SecRealmRoleMapperVersion'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'Version'
   settingValue = str(roleMapperVersion)
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )



def writeLockoutManagerSettings(realmName, domainName, lockMgrName, lockMgrEnabled, lockMgrThreshold, lockMgrDuration, lockMgrResetDuration):

   modifiable_NO   = 'NO'
   modifiable_YES  = 'YES'
   sectionName     = 'SecurityRealm.LockoutManager'   
  
   path = '/SecurityConfiguration/' + domainName + '/Realms/' + realmName + '/' + lockMgrName +'/' + lockMgrName;

#  1.
   recName     = 'SecRealmLockMgrName'
   modifiable  = modifiable_YES
   settingPath = path
   settingName = 'Name'
   settingValue = lockMgrName
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

#  2.
   recName     = 'SecRealmLockMgrEnabled'
   modifiable  = modifiable_YES
   settingPath = path
   settingName = 'LockoutEnabled'
   settingValue = lockMgrEnabled
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

#  3.
   recName     = 'SecRealmLockMgrDuration'
   modifiable  = modifiable_YES
   settingPath = path
   settingName = 'LockoutDuration'
   settingValue = str(lockMgrDuration)
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

#  4.
   recName     = 'SecRealmLockMgrResetDuration'
   modifiable  = modifiable_YES
   settingPath = path
   settingName = 'LockoutResetDuration'
   settingValue = str(lockMgrResetDuration)
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

#  5.
   recName     = 'SecRealmLockMgrThreshold'
   modifiable  = modifiable_YES
   settingPath = path
   settingName = 'LockoutThreshold'
   settingValue = str(lockMgrThreshold)
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )


def writePasswordValidatorSettings(realmName, domainName, pwdValName, pwdValVersion, pwdValProvider, pwdValMinLength, pwdValMinLower, pwdValMinUpper, pwdValNonAlpha, pwdValSpecial, pwdValMinNumeric):

   modifiable_NO   = 'NO'
   modifiable_YES  = 'YES'
   sectionName     = 'SecurityRealm.PasswordValidator'     

   path = '/SecurityConfiguration/' + domainName + '/Realms/' + realmName + '/PasswordValidators/' + pwdValName;

#  1.
   recName     = 'SecRealmPwdValName'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'Name'
   settingValue = pwdValName
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

#  2.
   recName     = 'SecRealmPwdValProvider'
   modifiable  = modifiable_NO
   settingPath = path
   settingName = 'ProviderClassName'
   settingValue = pwdValProvider
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

#  3.
   recName     = 'SecRealmPwdValMinLower'
   modifiable  = modifiable_YES
   settingPath = path
   settingName = 'MinLowercaseCharacters'
   settingValue = str(pwdValMinLower)
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

#  4.
   recName     = 'SecRealmPwdValMinNonAlpha'
   modifiable  = modifiable_YES
   settingPath = path
   settingName = 'MinNonAlphanumericCharacters'
   settingValue = str(pwdValNonAlpha)
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

#  5.
   recName     = 'SecRealmPwdValMinNumeric'
   modifiable  = modifiable_YES
   settingPath = path
   settingName = 'MinNumericCharacters'
   settingValue = str(pwdValMinNumeric)
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

#  6.
   recName     = 'SecRealmPwdValMinSpecial'
   modifiable  = modifiable_YES
   settingPath = path
   settingName = 'MinNumericOrSpecialCharacters'
   settingValue = str(pwdValSpecial)
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

#  7.
   recName     = 'SecRealmPwdValMinLength'
   modifiable  = modifiable_YES
   settingPath = path
   settingName = 'MinPasswordLength'
   settingValue = str(pwdValMinLength)
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

#  8.
   recName     = 'SecRealmPwdValMinUpper'
   modifiable  = modifiable_YES
   settingPath = path
   settingName = 'MinUppercaseCharacters'
   settingValue = str(pwdValMinUpper)
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )

#  9.
   recName     = 'SecRealmPwdValVersion'
   modifiable  = modifiable_YES
   settingPath = path
   settingName = 'Version'
   settingValue = str(pwdValVersion)
   updateSettingsFile ( settingsFile, sectionName, recName, modifiable, settingPath, settingName, settingValue )




# Setup required property values read from the vars file

pickleFileName        = '{{remote_dir}}/{{pickle_file_name}}'

# Open and read in the pickle file contents
data = eat_pickle(pickleFileName)

# Basic Security Realm Settings
realmName       = data['Security_Realm_Name']
domainName      = data['Domain_Name']
nodeManagerUser = data['Node_Manager_User_Name']
securityType    = data['Security_Type']

# Auditor Settings
auditorName     = data['Auditor_Bean_Name']
auditorVersion  = data['Auditor_Version']
auditorPath     = data['Auditor_Path']
auditorProvider = data['Auditor_Provider_Class']

# Authorizer Settings
authorizerName             = data['Authorizer_Bean_Name']
authorizerVersion          = data['Authorizer_Version']
authorizerDeployEnabledTmp = data['Authorizer_Deployment_Enabled']
authorizerPath             = data['Authorizer_Path']
authorizerProvider         = data['Authorizer_Provider_Class']

authorizerDeployEnabled='false'
if authorizerDeployEnabledTmp == 1:
   authorizerDeployEnabled='true'

# Role Mapper
roleMapperName             = data['Role_Mapper_Bean_Name']
roleMapperVersion          = data['Role_Mapper_Version']
roleMapperDeployEnabledTmp = data['Role_Mapper_Deployment_Enabled']
roleMapperPath             = data['Role_Mapper_Path']
roleMapperProvider         = data['Role_Mapper_Provider_Class']

roleMapperDeployEnabled='false'
if roleMapperDeployEnabledTmp == 1:
   roleMapperDeployEnabled='true'

# Lockout Manager
lockMgrName            = data['Lockout_Name']
lockMgrEnabledTmp      = data['Lockout_Enabled']
lockMgrThreshold       = data['Lockout_Threshold']
lockMgrDuration        = data['Lockout_Duration']
lockMgrResetDuration   = data['Lockout_Reset_Duration']

lockMgrEnabled='false'
if lockMgrEnabledTmp == 1:
   lockMgrEnabled='true'


# Password Validator
pwdValName             = data['Password_Validator_Name']
pwdValVersion          = data['Password_Validator_Version']
pwdValProvider         = data['Password_Validator_Provider_Class']
pwdValMinLength        = data['Password_Validator_Minimum_Password_Length']
pwdValMinLower         = data['Password_Validator_Minimum_Lowercase_Characters']
pwdValMinUpper         = data['Password_Validator_Minimum_Uppercase_Characters']
pwdValNonAlpha         = data['Password_Validator_Minimum_NonAlphanumeric_Characters']
pwdValMinNumeric       = data['Password_Validator_Minimum_Numeric_Characters']
pwdValSpecial          = data['Password_Validator_Minimum_Numeric_Or_Special_Characters']

 
# open the settings file
fileName = wlsSettingsFile_SecurityRealm
settingsFile=open(fileName, 'w')

# Write out Basic Security Realm Settings
 
printMessage( 'INFO',' Creating Settings File For Security Real - Security Settings ')

# Write out the Basic Security Realm Settings

writeBasicSettings(realmName, domainName, nodeManagerUser, securityType)

# Write out the Auditor Settings

writeAuditorSettings(realmName, domainName, auditorName, auditorVersion, auditorPath, auditorProvider)

# Write out the Authorizer Settings

writeAuthorizerSettings(realmName, domainName, authorizerName, authorizerVersion, authorizerDeployEnabled, authorizerPath, authorizerProvider)

# Write out the Role Manager Settings

writeRoleMapperSettings(realmName, domainName, roleMapperName, roleMapperVersion, roleMapperDeployEnabled, roleMapperPath, roleMapperProvider)

# Write out the Lockout Manager

writeLockoutManagerSettings(realmName, domainName, lockMgrName, lockMgrEnabled, lockMgrThreshold, lockMgrDuration, lockMgrResetDuration)

# Write out the Password Validator

writePasswordValidatorSettings(realmName, domainName,  pwdValName, pwdValVersion, pwdValProvider, pwdValMinLength, pwdValMinLower, pwdValMinUpper, pwdValNonAlpha, pwdValSpecial, pwdValMinNumeric)


settingsFile.close()

print '-------------------------------------------------------------'
print 'Settings Written to file: ' + fileName
print '-------------------------------------------------------------'



