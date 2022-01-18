from ncclient import manager

m=manager.connect(host='localhost', port=830, username='netconf',password='netconf', hostkey_verify=False)
print(m.connected)
s = m.create_subscription(stream_name='urn:sysrepo:oven')
print(m.get_config(source='running'))

m.rpc('''<insert-food xmlns='urn:sysrepo:oven'>
             <time>on-oven-ready</time>
         </insert-food>''')
         
oven_config = '''<oven xmlns="urn:sysrepo:oven">
                    <turned-on>true</turned-on>
                    <temperature>200</temperature>
                 </oven>'''
m.edit_config(oven_config, format='xml', target='running', default_operation='merge',)

m.rpc('''<remove-food xmlns="urn:sysrepo:oven"/>''')

