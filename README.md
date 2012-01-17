This is a set of ssh helper scripts to do unmanaged automated ssh tunnels to production and dev systems for running remote commands or port forwaded connections.

For the purposes of this file
=============================
client = The box recieving the ssh connection. The client should have the matching public keys for the server.

server = The box initiating the ssh connection and running the cron service. This box should have the private keys.

The Files
=========
There are three scripts and a server side config.

tasktunnelcron.sh 
	- Is run by crontab on regulare intervals to check the state of and open named tunnels to clients defined in the tasktunneljobs.conf file on the same box.

tasktunnel.sh
	- Responds to connections made by tasktunnelcron.sh. It maintains an active ssh connection or indicates that there are named tunnel task requests on the client side.

tasktunnelservice.sh
	- Enables and closes a connection or returns the status of a named request that matches a tunnel job in the server side tasktunneljobs.conf. This script is located in /etc/init.d/tasktunnelservice on the client.

tasktunneljobs.conf
	- Defines active hosts and tunnel specifications on the server side. This config is read at run time. All entries are looped over and executed from top to bottom one at a time(serially).


