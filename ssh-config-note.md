## SSH config note

1. First, get a new SSH key pair.

    ```
    ssh-keygen -t rsa -b 4096 -C "email@something.com"`
    ```

    Then add system path for the keys, and passphrase.
    **It's generally to safe to use it withour passphrase**

2. Then copy the public key to the remote server, 

    - `<port>` for custom port if needed, 
    - `<path>` for public file aka `.key.pub`
    -
    ```
    ssh-copy-id -i <path> -p <port> root@ip
    ```

4. Update config (`~/.ssh/config`),

    - `<name>` just any unique name
    - `<ip>` actuall ip of host
    - `<port>` port if needed
    - `<login>` username
    - `<path>` path for `.key` file
    - 
    ```
    Host <name>
        HostName <ip>
        Port <port>
        User <login>
        IdentityFile <path>
        PasswordAuthentication yes
        PreferredAuthentications publickey,password
    ```

3. `Optional` Set permissions on remote host:
    ``` 
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    ```

4. `Optional` To use no password login within local network:

    Copy identity to the host and update `~/.ssh/config`, assumming id localed at `~/.ssh/id_rsa`:
    - `<name>` just any unique name
    - `<user>` user login
    - `<ip>` LAN ip of host
    -
    ```
    ssh-copy-id -i ~/.ssh/id_rsa.pub <user>@<ip>
    ```
    -
    ```
    Host <name>
        HostName <ip>
        User <user>
        IdentityFile ~/.ssh/id_rsa
