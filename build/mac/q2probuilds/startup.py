import subprocess, os
from support.steam.client import SteamClient

client = SteamClient()

print("My steam id is: %s" % client.user.steam_id)
print("Logged on as: %s" % client.user.name)
print("Community profile: %s" % client.steam_id.community_url)
print("Last logon: %s" % client.user.last_logon)
print("Last logoff: %s" % client.user.last_logoff)

# Get current working dir
getcwd = os.getcwd()
subprocess.Popen("./q2pro" + " +set steamid " + str(client.user.steam_id), cwd=getcwd, shell=True)