from ncclient import manager
from ncclient.xml_ import to_ele

with manager.connect(host='localhost', port=830, username='netconf',password='netconf', hostkey_verify=False) as m:
    print(m.connected)
    c = m.get_config(source='running').data_xml
    print(c)
    # print(m.server_capabilities)
    # food_in_rpc = '''<insert-food xmlns='urn:sysrepo:oven'><time>on-oven-ready</time></insert-food>'''
    # result = m.dispatch(to_ele(food_in_rpc))
    hicn_config = '''
        <config xmlns='urn:ietf:params:xml:ns:netconf:base:1.0'>
            <hicn-conf  xmlns="urn:sysrepo:hicn">
            <params>
                <enable_disable>false</enable_disable>
                <pit_max_size>-1</pit_max_size>
                <cs_max_size>-1</cs_max_size>
                <cs_reserved_app>-1</cs_reserved_app>
                <pit_dflt_lifetime_sec>-1</pit_dflt_lifetime_sec>
                <pit_max_lifetime_sec>-1</pit_max_lifetime_sec>
                <pit_min_lifetime_sec>-1</pit_min_lifetime_sec>
            </params>
            </hicn-conf>
        </config>
    '''    
    m.edit_config(config = hicn_config, target='running', default_operation='merge')
    hicn_rpc = '''<node-params-get xmlns="urn:sysrepo:hicn"/>'''
    result = m.dispatch(to_ele(hicn_rpc))
    c = m.get_config(source='running').data_xml
    print(c)
    print('hICN Script Execution Successful')
