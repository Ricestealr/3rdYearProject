from ncclient import manager

m=manager.connect(host='localhost', port=830, username='netconf',password='netconf', hostkey_verify=False)
print(m.connected)
