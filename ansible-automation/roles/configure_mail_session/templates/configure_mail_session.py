from java.util import Properties
import pickle


# Create the Mail Session


def eat_pickle( fileName ):

  """This function opens the pickle file which contains the pickled contents
  of the original vars file.   The contents of the pickle file are returned.
  """

  data = pickle.load(open(fileName, 'rb'))
  return data



def createMailSession(mailSessionName, mailCluster, mailServer, jndiName, sessionUserName):

    #Check to see that we're on a clustered or non-clustered environment
    try:
      state(mailCluster, 'Cluster')
      cluster = true
    except:
      cluster = false

    try:
        print 'Create Email session ...';
        edit();
        startEdit();

        cd('/')
        path = '/MailSessions/' + mailSessionName
        adminServer = 'com.bea:Name=' + mailServer + ',Type=Server'
        mailMbean = cmo.lookupMailSession(mailSessionName)
        if mailMbean == None:
           mailMbean = cmo.createMailSession(mailSessionName);

        adminTarget=[]
        adminTarget.append(ObjectName(adminServer))

        if cluster:
            clusters = 'com.bea:Name=' + mailCluster + ',Type=Cluster'
            adminTarget.append(ObjectName(clusters))

        cd(path);

        set('Targets', jarray.array(adminTarget, ObjectName))

        mailMbean.setJNDIName(jndiName);

        properties = java.util.Properties();
        properties.put('mail.host', mailHost);
        properties.put('mail.user', mailUser)
        properties.put('mail.transport.protocol', mailTransProtocol);
        properties.put('mail.smtps.host', mailSMTPSHost);
        properties.put('mail.from', mailFrom);
        properties.put('mail.debug', mailDebug);

        mailMbean.setProperties(properties);

        save();
        activate();

    except Exception, inst:
        print 'Exception while creating Email session  !';
        print inst
        print sys.exc_info()[0]
        exit();


#  Setup required property values read from the vars file

pickleFileName        = '{{gc2_remote_dir}}/{{pickle_file_name}}'

# Open and read in the pickle file contents
data = eat_pickle(pickleFileName)

mailHost         = data['mail_host']
mailUser         = data['mail_user']
mailTransProtocol= data['mail_transport_protocol']
mailSMTPSHost    = data['mail_smtps_host']
mailFrom         = data['mail_from']
mailDebug         = data['mail_debug']

adminProtocol    = data['Admin_Protocol']
adminHost        = data['admin_host']
adminServerPort  = data['admin_server_port']
weblogicAdmin    = data['weblogic_admin']
mailSessionName  = data['mail_session_name']
mailCluster       = data['mail_Cluster']
mailServer       = data['mail_Server']
jndiName         = data['jndi_name']
sessionUserName  = data['session_username']

weblogicPassword = '{{weblogic_password}}'


# Generate the admin url and connect to the admin server

ADMIN_SERVER_URL = adminProtocol + '://' + adminHost + ':' + str(adminServerPort);

connect(weblogicAdmin, weblogicPassword, ADMIN_SERVER_URL);

# Create the Mail Session
createMailSession(mailSessionName, mailCluster, mailServer, jndiName, sessionUserName)

exit()

