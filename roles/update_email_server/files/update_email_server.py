import java.util.Properties;

mailUser = "app_admin." + sys.argv[3] + "@gapnet.com";

connect(userConfigFile=sys.argv[1],userKeyFile=sys.argv[2], url='t3://vm4:7001')

edit()
startEdit()

# delete mail session
mailSession = cmo.lookupMailSession('appMailSession')
if mailSession != None:
	cmo.destroyMailSession(mailSession)

# create a new mail session
appMailSession = cmo.createMailSession('appMailSession')
cd('MailSessions/appMailSession');
set('Targets',jarray.array([ObjectName('com.bea:Name=app_cluster,Type=Cluster')],ObjectName))
appMailSession.setJNDIName('mil.stratcom.app.mail.session');
properties = java.util.Properties();
properties.put('mail.host','134.223.82.106');
properties.put('mail.user',mailUser);
properties.put('mail.transport.protocol','smtps');
properties.put('mail.smtps.host','134.223.82.106');
properties.put('mail.from',mailUser);
properties.put('mail.debug','false')
appMailSession.setProperties(properties);

save()
activate()
disconnect()
