# About

This repo is supposed to store all sorts of scripts, helpers or doc pages. If you find what you need, feel free to use.

# Notes

- `aes.py`

    Quite simple implementation of AES-256 with ECB mode for string input/output.

- `dev_offloader.sh`

    While setting up an Ubuntu Server, I needed to install network drivers, which required a network connection.

- `nginx_visitors.sh`

    Watch and review your website visitors, create analytics using ipinfo.io

- `reverse_ssh.md`

    Did it a long time ago, probably need to review it.

- `simple-mnist-nn-from-scratch.ipynb`

    A very cool and simple example of a 2-layer NN on the MNIST dataset.

- `sshpass-tweaked.sh` 

    The default implementation of sshpass does not work from an alias on MacOS. Here is the fix:
    ```
    curl -s -O https://raw.githubusercontent.com/alpatiev/docs master/sshpass-tweaked.sh && bash sshpass-tweaked.sh -install
    ```

- `turn_off_deb_updates.sh`

    Just turn off snapd and stop droplet daemon.
