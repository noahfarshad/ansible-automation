domain_path = sys.argv[1]

#Connect to the adminserver and update machine settings
readDomain(domain_path)
cd('Server')
serverList=ls(returnMap='true')
for server in serverList:
    cd(server)
    cd('SSL')
    nameList=ls(returnMap='true')
    for name in nameList:
        cd(name)
        set('JsseEnabled','true')
        cd('..')
    cd('../..')
updateDomain()
exit()

