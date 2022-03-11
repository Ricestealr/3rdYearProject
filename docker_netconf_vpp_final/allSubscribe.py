from ncclient import manager


m = manager.connect(host='localhost', port=830, username='netconf',password='netconf', hostkey_verify=False)
m.create_subscription()

while True:
    print('waiting for next notification')
    n = m.take_notification()
    print(n.notification_xml)

