from ncclient import manager
from ncclient.xml_ import to_ele

with manager.connect(host='localhost', port=830, username='netconf',password='netconf', hostkey_verify=False) as m:
    print(m.connected)
    c = m.get_config(source='running').data_xml
    print(c)
 #   print(m.server_capabilities)
    food_in_rpc = '''<insert-food xmlns='urn:sysrepo:oven'><time>on-oven-ready</time></insert-food>'''
    result = m.dispatch(to_ele(food_in_rpc))
    oven_config = '''
        <config xmlns='urn:ietf:params:xml:ns:netconf:base:1.0'>
            <oven xmlns='urn:sysrepo:oven'>
                <turned-on>true</turned-on>
                <temperature>200</temperature>
            </oven>
        </config>
    '''    
    m.edit_config(config = oven_config, target='running', default_operation='merge')

