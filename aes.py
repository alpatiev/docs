import argparse
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
from base64 import b64encode, b64decode

class AES_256_ECB:
    """~
    AES ECB MODE WITH 256-BIT KEY = 32 CHAR, I/O IS STRING 
    """
    @staticmethod
    def __pad(data):
        block_size = 16
        padding_length = block_size - (len(data) % block_size)
        padding = bytes([padding_length]) * padding_length
        return data + padding

    @staticmethod
    def __unpad(data):
        padding_length = data[-1]
        return data[:-padding_length]

    @staticmethod
    def ENCRYPT(KEY, PLAINTEXT):
        backend = default_backend()
        cipher = Cipher(algorithms.AES(KEY.encode()), modes.ECB(), backend=backend)
        encryptor = cipher.encryptor()
        padded_plaintext = AES_256_ECB.__pad(PLAINTEXT.encode())
        ciphertext = encryptor.update(padded_plaintext) + encryptor.finalize()
        return b64encode(ciphertext).decode()

    @staticmethod
    def DECRYPT(KEY, CIPHERTEXT):
        backend = default_backend()
        cipher = Cipher(algorithms.AES(KEY.encode()), modes.ECB(), backend=backend)
        decryptor = cipher.decryptor()
        decoded_ciphertext = b64decode(CIPHERTEXT)
        padded_plaintext = decryptor.update(decoded_ciphertext) + decryptor.finalize()
        return AES_256_ECB.__unpad(padded_plaintext).decode()
