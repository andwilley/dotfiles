import sys, json

statuses = json.load(sys.stdin)['InstanceStatuses']

if statuses:
    print(statuses[0]['InstanceState']['Name'])
else:
    print('stopped')
