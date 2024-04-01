# Reverse SSH Tunnel Guide

This brief guide outlines how to establish a reverse SSH tunnel from a local machine, such as a Raspberry Pi, to a remote server. This allows for remote access to api running on the local machine, particularly using celluar network or public Wi-Fi. I have accomplished some IoT projects that required such a thing, and I needed minimal hassle with network configuration. I needed a solution that was easy to implement, and surprisingly, it was indeed straightforward.

## Prerequisites (I think it's obvious, but well..)

- Access to a terminal on the local machine and the remote server.
- SSH access to the remote server.
- A service running on the local machine that you wish to access remotely.

## 1. Obtain Local IP Address

First, find the local IP address of your machine. This is necessary to correctly route the SSH tunnel.

For Linux and macOS:

```
ip addr show
```

Or, for a more specific interface, such as Wi-Fi (often wlan0 on Linux or en0 on macOS):

```
ip addr show wlan0
```

Or on macOS, in most cases:

```
ipconfig getifaddr en0
```

Note: you can check another ip, dependent on your local network type.

## 2. Establish Reverse SSH Tunnel

Use the SSH command to create a reverse tunnel from the local machine to the server.
Replace <LocalPort>, <LocalIP>, <RemotePort>, and <ServerUser>@<ServerIP> with your specific details.

```
ssh -R <RemotePort>:<LocalIP>:<LocalPort> <ServerUser>@<ServerIP>
```

- <LocalPort>: The port on your local machine you're forwarding.
- <LocalIP>: The local IP address of your machine.
- <RemotePort>: The port on the server to listen on.
- <ServerUser>: Your username on the server.
- <ServerIP>: The IP address or hostname of your server.

3. Check the Connection

To verify the tunnel is working, you can list these listening ports on the server:

```
sudo ss -tuln | grep <RemotePort>
```

Or, if ss is not working:

```
sudo netstat -tuln | grep <RemotePort>
```

Note: You should see the server listening on <RemotePort> to verify.

4. Run Server on Local Machine

Ensure your service (e.g., a web server) is running on <LocalPort> on your local machine. 
This service can now be accessed via <RemotePort> on your server. Just don't mess up the port.

## Closing the SSH Tunnel

To close the tunnel, simply exit the SSH session:

- If you're in an interactive SSH session, type exit and press Enter.
- If the SSH command was run in the background, find the process with ps aux | grep ssh and kill it with kill <PID>.

## That's it.
