import sys
import datetime
from java.lang import System
import javax
from javax.management import RuntimeMBeanException
from java.lang import UnsupportedOperationException
from java.io import File
from java.io import FileInputStream
import pickle


def printMessage(messageType, messageText):

    currentTime=datetime.datetime.today()
    print str(currentTime) + ' <<<' + messageType + '>>> ' + messageText
    return()


def eat_pickle( fileName ):

  """This function opens the pickle file which contains the pickled contents
  of the original vars file.   The contents of the pickle file are returned.
  """

  data = pickle.load(open(fileName, 'rb'))
  return data



def add_Auditor(securityRealmName, domainName, auditorPath, auditorBeanName):

#  Add the Auditor

   cd ('/SecurityConfiguration/' + domainName + '/Realms/' + securityRealmName)

   try: 

      edit()
      theBean = cmo.lookupAuditor(auditorBeanName)
      
      if theBean == None:

        printMessage('INFO',' ')
        printMessage('INFO','=================================================================')
        printMessage('INFO','  Auditor, being Created. ')
        printMessage('INFO','=================================================================')
        printMessage('INFO',' ')

        startEdit()

        cmo.createAuditor(auditorBeanName,auditorPath)
 
        save()
        activate(block='true')

      else:

        printMessage('INFO',' ')
        printMessage('INFO','=================================================================')
        printMessage('INFO','  Auditor already Exists')
        printMessage('INFO', ' So no changes were made ')
        printMessage('INFO','=================================================================')
        printMessage('INFO',' ')

 
   except java.lang.UnsupportedOperationException, usoe:
    
     pass
  
   except weblogic.descriptor.BeanAlreadyExistsException,bae:
    
     pass
  
   except java.lang.reflect.UndeclaredThrowableException,udt:
    
     pass



def add_Authorizer(securityRealmName, domainName, authorizerPath, authorizerBeanName):

#  Add the Authorizer

   cd ('/SecurityConfiguration/' + domainName + '/Realms/' + securityRealmName)

   try: 

      edit()
      theBean = cmo.lookupAuthorizer(authorizerBeanName)
      
      if theBean == None:

        printMessage('INFO',' ')
        printMessage('INFO','=================================================================')
        printMessage('INFO','  Authorizer, being Created. ')
        printMessage('INFO','=================================================================')
        printMessage('INFO',' ')

        startEdit()

        cmo.createAuthorizer(authorizerBeanName,authorizerPath)
 
        save()
        activate(block='true')

      else:

        printMessage('INFO',' ')
        printMessage('INFO','=================================================================')
        printMessage('INFO','  Authorizer already Exists')
        printMessage('INFO', ' So no changes were made ')
        printMessage('INFO','=================================================================')
        printMessage('INFO',' ')

 
   except java.lang.UnsupportedOperationException, usoe:
    
     pass
  
   except weblogic.descriptor.BeanAlreadyExistsException,bae:
    
     pass
  
   except java.lang.reflect.UndeclaredThrowableException,udt:
    
     pass




def add_RoleMapper(securityRealmName, domainName, roleMapperPath, roleMapperBeanName):

#  Add the Role Mapper

   cd ('/SecurityConfiguration/' + domainName + '/Realms/' + securityRealmName)

   try: 

      edit()
      theBean = cmo.lookupRoleMapper(roleMapperBeanName)
      
      if theBean == None:

        printMessage('INFO',' ')
        printMessage('INFO','=================================================================')
        printMessage('INFO','  Role Mapper, being Created. ')
        printMessage('INFO','=================================================================')
        printMessage('INFO',' ')

        startEdit()

        cmo.createRoleMapper(roleMapperBeanName,roleMapperPath)
 
        save()
        activate(block='true')

      else:

        printMessage('INFO',' ')
        printMessage('INFO','=================================================================')
        printMessage('INFO','  Role Mapper already Exists')
        printMessage('INFO', ' So no changes were made ')
        printMessage('INFO','=================================================================')
        printMessage('INFO',' ')

 
   except java.lang.UnsupportedOperationException, usoe:
    
     pass
  
   except weblogic.descriptor.BeanAlreadyExistsException,bae:
    
     pass
  
   except java.lang.reflect.UndeclaredThrowableException,udt:
    
     pass



def add_LockoutManager(lockoutThreshold, lockoutDuration, lockoutResetDuration):

#  Add a Lockout Manager if it does not exist

#  See if a Lockout Manager is already installed

  try: 
#     cd('/')
# start an edit session
     edit()
     startEdit()
     cd('/')
     ulm=cmo.getSecurityConfiguration().getDefaultRealm().getUserLockoutManager()

     isEnabled = ulm.isLockoutEnabled()
  
     print 'isLockoutEnabled. ' + str(isEnabled)


     if isEnabled == False:

        printMessage('INFO',' ')
        printMessage('INFO','=================================================================')
        printMessage('INFO','  Lockout Manager is not Enabled, being Enabled. ')
        printMessage('INFO','=================================================================')
        printMessage('INFO',' ')

#        startEdit()
        ulm.setLockoutEnabled(True)

        # lockout threshold - when gets an account locked
        ulm.setLockoutThreshold(lockoutThreshold)
        
        # amount (in minutes) how long an account is locked

        ulm.setLockoutDuration(lockoutDuration)

        ulm.setLockoutResetDuration(lockoutResetDuration)
       
        save()
        activate(block='true')       

     else:

        printMessage('INFO',' ')
        printMessage('INFO','=================================================================')
        printMessage('INFO','  Lockout Manager is already Enabled')
        printMessage('INFO', ' So no changes were made ')
        printMessage('INFO','=================================================================')
        printMessage('INFO',' ')

  except:

     dumpStack()
  

def add_PasswordValidator(minPasswordLength, minLowercaseChars, minUppercaseChars, minNonAlphaChars, minNumOrSpecialChars, minNumericChars):

# Add the Password Validator if it does not exist

  try: 
     cd('/')
# start an edit session
     edit()

     realm        = cmo.getSecurityConfiguration().getDefaultRealm()
     pwdvalidator = realm.lookupPasswordValidator('SystemPasswordValidator')

     if pwdvalidator:

        printMessage('INFO',' ')
        printMessage('INFO','=================================================================')
        printMessage('INFO','  Password Validator already Exists')
        printMessage('INFO', ' So no changes were made ')
        printMessage('INFO','=================================================================')
        printMessage('INFO',' ')

     else:

        printMessage('INFO',' ')
        printMessage('INFO','=================================================================')
        printMessage('INFO',' System Password Validator does not Exist, being Created. ')
        printMessage('INFO','=================================================================')
        printMessage('INFO',' ')

        startEdit()     
        syspwdValidator = realm.createPasswordValidator('SystemPasswordValidator', 
          'com.bea.security.providers.authentication.passwordvalidator.SystemPasswordValidator')

        save()
        activate(block='true')

        edit()
        startEdit()

        pwdvalidator.setMinPasswordLength(minPasswordLength)
        pwdvalidator.setMinLowercaseCharacters(minLowercaseChars)
        pwdvalidator.setMinUppercaseCharacters(minUppercaseChars)
        pwdvalidator.setMinNonAlphanumericCharacters(minNonAlphaChars)
        pwdvalidator.setMinNumericOrSpecialCharacters(minNumOrSpecialChars)
        pwdvalidator.setMinNumericCharacters(minNumericChars)
        
        save()
        activate(block='true')

  except:

     dumpStack()



#  Add a Lockout Manager if it does not exist
def main(argv):
  global debug

#  runMode can be CREATE or REPORT
  runMode=sys.argv[1]
  runMode=runMode.upper()

# if the playbook is run in REPORT mode this python script should do nothing!
  if runMode == 'CREATE':

#    Setup required property values read from the vars file
     pickleFileName     = '{{remote_dir}}/{{pickle_file_name}}'
     adminProtocol      = '{{Admin_Protocol}}'
     adminServer        = '{{Admin_Server}}'
     adminHttpsPort     = {{Admin_Server_HTTPS_Port}}
     adminHttpPort      = {{Admin_Server_HTTP_Port}}



#    Open and read in the pickle file contents
     data = eat_pickle(pickleFileName)


#    Security Realm Properties
     securityRealmName = data['Security_Realm_Name']

#    Domain Name 
     domainName = data['Domain_Name']

#    Role Mapper Properties
     roleMapperPath     = data['Role_Mapper_Path']
     roleMapperBeanName = data['Role_Mapper_Bean_Name'] 

#    Authorizer Properties
     authorizerPath     = data['Authorizer_Path']
     authorizerBeanName = data['Authorizer_Bean_Name']

#    Auditor Properties
     auditorPath     = data['Auditor_Path']
     auditorBeanName = data['Auditor_Bean_Name']

#    Setup the Lockout Manager Settings
     lockoutManagerEnabledTmp = data['Lockout_Enabled']
     lockoutThreshold         = data['Lockout_Threshold'] 
     lockoutDuration          = data['Lockout_Duration']
     lockoutResetDuration     = data['Lockout_Reset_Duration']

     lockoutManagerEnabled = False
     if lockoutManagerEnabledTmp == 1:
        lockoutManagerEnabled = True 

#    Setup the Password Validator Settings
     minPasswordLength = data['Password_Validator_Minimum_Password_Length']
     minLowercaseChars = data['Password_Validator_Minimum_Lowercase_Characters']     
     minUppercaseChars = data['Password_Validator_Minimum_Uppercase_Characters']
     minNonAlphaChars  = data['Password_Validator_Minimum_NonAlphanumeric_Characters']
     minNumOrSpecialChars = data['Password_Validator_Minimum_Numeric_Or_Special_Characters']
     minNumericChars     = data['Password_Validator_Minimum_Numeric_Characters']

     adminUrl = adminProtocol  + '://' + adminServer + ':' + str(adminHttpPort)

     print 'adminUrl. ' + adminUrl

     #  Connect to the admin Server
     #connect(userConfigFile=userConfigFilePath, userKeyFile=userKeyFilePath, url=adminUrl)
     #connect(userConfigFile=userConfigFilePath, userKeyFile=userKeyFilePath, url=adminUrl)
     connect('{{weblogic_admin}}', '{{weblogic_password}}', adminUrl);


     printMessage( 'INFO',' Attempting to Add Lockout Manager ')
     
     print 'lockoutManagerEnabled. ' + str(lockoutManagerEnabled)

     if lockoutManagerEnabled == True:
        add_LockoutManager(lockoutThreshold, lockoutDuration, lockoutResetDuration)

     printMessage('INFO',' Attempting to Add Password Validator ')
     add_PasswordValidator(minPasswordLength, minLowercaseChars, minUppercaseChars, minNonAlphaChars, minNumOrSpecialChars, minNumericChars)


     printMessage('INFO',' Attempting to Add Auditor ')
     add_Auditor(securityRealmName, domainName, auditorPath, auditorBeanName)


  return

#
if __name__ == "main":
  main(sys.argv[1:])

