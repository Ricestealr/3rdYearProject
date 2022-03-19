from ncclient import manager
from ncclient.xml_ import to_ele
import threading
import os
import sys

# Function to import configs from file
def read_from_file(filename, address_store):
    last_modified_time = os.path.getmtime(filename)
    with open(filename) as f:
        configs = f.readlines()

    for i in range(0,len(configs)):
        prefix, destination = configs[i].split("\n")[0].split(" ")
        print(prefix,destination)
        address_store[prefix] = destination

    print(last_modified_time)

    return address_store, last_modified_time

# Dictionary of prefixes and corresponding addresses
base_address_store = {
    # <prefix>: <address>
    'b001::': '2::2'
}

# Import configs from file
address_store, last_change_time = read_from_file("controller_config.txt", base_address_store)

print(address_store)

def main():
    print("main program")
    with manager.connect(host='192.168.10.3', port=830, username='netconf',password='netconf', hostkey_verify=False) as m:
        m.create_subscription()
        notifs_processed = 0
        while True:
            print('Waiting for next notification')

            # Holding until notification received
            n = m.take_notification()
            notifs_processed += 1

            # Parsing of received notification (MODIFY BASED ON SOURCE)
            notif_parts = n.notification_xml.split("><")
            print(notif_parts)
            notif_standard = notif_parts[0].split(" ")[1]
            event_time = notif_parts[1].split(">")[1].split("<")[0]
            notif_content = notif_parts[2].split(" ")[0]
            
            print("NOTIFICATION RECEIVED ID:", notifs_processed)
            print("Standard:", notif_standard)
            print("Time:", event_time)
            print("Content:", notif_content)
            # If it is a route miss notification
            if notif_content == "route-miss":
                notif_source = notif_parts[2].split(" ")[1]
                notif_route = notif_parts[3].split(">")[1].split("<")[0]
                print("Source:", notif_source)
                print("Prefix:", notif_route)
                prefix = notif_route
            else:
                prefix = None
            
            # Send modify running datastore RPC to accept request
            if prefix in address_store:
                add_route = '''
                <add-route xmlns="urn:sysrepo:ondemand">
                    <prefix>''' + prefix + '''/64</prefix>
                    <destination>''' + address_store[prefix] + '''</destination>
                </add-route>
                '''
                result = m.dispatch(to_ele(add_route))

main_thread = threading.Thread(name='main program', target=main, daemon = True)

# Start main thread that handles notifications and RPCs
main_thread.start()

# Menu for changing address_store dictionary used to update configurations
while True:
    print("SDN Controller Menu")
    # 1. Adds new configurations and updates existing
    print("1. Update address store using file")
    # 2. Deletes all existing routes and adds new one using the file
    print("2. Rebuild address store using file")
    # 3. Exits the program
    print("3. Exit program")
    keyboardinput = input()
    if keyboardinput == "1":
        print("updating address store")
        address_store, last_change_time = read_from_file("controller_config.txt", address_store)
    elif keyboardinput == "2":
        print("rebuilding address store")
        address_store.clear()
        address_store, last_change_time = read_from_file("controller_config.txt", {})
    elif keyboardinput == "3":
        sys.exit(0)
    else:
        print("Unrecognised Input")
