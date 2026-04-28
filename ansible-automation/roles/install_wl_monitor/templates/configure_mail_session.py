from java.util import Properties
import pickle


# Create the Mail Session


def eat_pickle( fileName ):

  """This function opens the pickle file which contains the pickled contents
  of the original vars file.   The contents of the pickle file are returned.
  """

  data = pickle.load(open(fileName, 'rb'))
  return data



def createMailSession(mailSessionName, mailTarget, jndiName, sessionUserName):

    try:
        print 'Create Email session ...';
        edit();
        startEdit();

        cd('/')
        path = '/MailSessions/' + mailSessionName
        target = 'com.bea:Name=' + mailTarget + ',Type=Server' 

        mailMbean = cmo.lookupMailSession(mailSessionName)
        if mailMbean == None:
           mailMbean = cmo.createMailSession(mailSessionName);

        cd(path);

        adminTarget=[]
        adminTarget.append(ObjectName(target))
        set('Targets', jarray.array(adminTarget, ObjectName))

        mailMbean.setJNDIName(jndiName);
        mailMbean.setSessionUsername(sessionUserName);

        properties = java.util.Properties();

#  The following block of commented out properties is in place for future work
#       properties.put('mail.to','lector@wlsscriptbook.com');
#       properties.put('mail.from','author@wlsscriptbook.com');
#       properties.put('mail.transport.protocol','smtp');
#       properties.put('mail.smtp.host','mail.wlsscriptbook.com');
#       properties.put('mail.smtp.port','25');

#        properties.put('mail.smtp.user','{{session_username}}');
#        properties.put('mail.smtp.password','{{weblogic_password}}');

        mailMbean.setProperties(properties);

        save();
        activate();

    except:
        print 'Exception while creating Email session  !';
        dumpStack();
        exit();


#  Setup required property values read from the vars file

pickleFileName        = '{{remote_dir}}/{{pickle_file_name}}'

# Open and read in the pickle file contents
data = eat_pickle(pickleFileName)


adminProtocol    = data['Admin_Protocol']
adminHost        = data['admin_host']
adminServerPort  = data['admin_server_port']
weblogicAdmin    = data['weblogic_admin']
mailSessionName  = data['mail_session_name']
mailTarget       = data['mail_target']
jndiName         = data['jndi_name']
sessionUserName  = data['session_username'] 

weblogicPassword = '{{weblogic_password}}'


# Generate the admin url and connect to the admin server

ADMIN_SERVER_URL = adminProtocol + '://' + adminHost + ':' + str(adminServerPort);

connect(weblogicAdmin, weblogicPassword, ADMIN_SERVER_URL);

# Create the Mail Session
createMailSession(mailSessionName, mailTarget, jndiName, sessionUserName)

exit()

