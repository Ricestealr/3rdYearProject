from ncclient import manager
from ncclient.xml_ import to_ele
import time

# Dictionary of prefixes and corresponding addresses
address_store = {
    # <prefix>: <address>
    '0912:9BB1:5782': '0912:9BB1:5782:3412:F304:AD03:85A4:2212'
}

# Total Number of Notifications Received and Parsed in Session
notifs_processed = 0
food_in = False

with manager.connect(host='localhost', port=830, username='netconf',password='netconf', hostkey_verify=False) as m:
    ### TEST LINE
    print(m.connected)
    
    c = m.get_config(source='running').data_xml
    
    ### TEST LINE
    print(c)
    print(m.server_capabilities)    
    
    # Create subsription to VPP/Oven
    # Filter received subscriptions
    m.create_subscription()
    
    # Permanent while loop to handle incoming notifications
    while True:
        print('Waiting for next notification')
        
        # Holding until notification received
        n = m.take_notification()
        notifs_processed += 1
        
        ### TEST LINE TO PRINT RECEIVED NOTIF
        print(n.notification_xml)
        
        ### TEST NOTIFICATION
        # test_notif = '''
        #     <notification xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0">
        #         <eventTime>2022-02-23T16:37:49.143120687+00:00</eventTime>
        #         <oven-ready xmlns="urn:sysrepo:oven"/>
        #     </notification>
        # '''
        # if notifs_processed == 1:
            # n = test_notif
        ###
        
        
        # Parsing of received notification (MODIFY BASED ON SOURCE)
        notif_parts = n.notification_xml.split("><")
        print(notif_parts)
        notif_standard = notif_parts[0].split(" ")[1]
        event_time = notif_parts[1].split(">")[1].split("<")[0]
        notif_content = notif_parts[2].split(" ")[0]
        notif_source = notif_parts[2].split(" ")[1]
        notif_route = notif_parts[3].split(">")[1].split("<")[0]
        
        print("NOTIFICATION RECEIVED ID:", notifs_processed)
        print("Standard:", notif_standard)
        print("Time:", event_time)
        print("Content:", notif_content)
        print("Source:", notif_source)
        print("Prefix", notif_route)
        
        ### NEED TO EXTRACT IPv6 PREFIX FOR FUTURE IMPLEMENTATION
        # prefix = '0912:9BB1:5782'
        prefix = notif_route
        
        # Send modify running datastore RPC to accept request
        if prefix in address_store:
            # New running datastore for new route (TO BE CHANGED)
            add_route = '''
            <add-route xmlns="urn:sysrepo:ondemand">
                <prefix>''' + prefix + '''</prefix>
                <destination>''' + address_store[prefix] + '''</destination>
            </add-route>
            '''
            result = m.dispatch(to_ele(add_route))

