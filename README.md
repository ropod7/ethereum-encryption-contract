### The Magic Contract Source Code and compilation example.

The Principle used in etherecho.com ethereum dapp, which is deprecated as a project and will be removed soon.
The Source Code of project is open and may be used in any type of multilevel contract system of projects based on Ethereum Blockchain to ease encrypt and decrypt texts at their side.

The principles of compilation describes in mccompiler.py and principles of usage may find in doc string of contract source code.

Base principle of contract is simple: encrypt and decrypt text back, but at the client side:
- (before encryption) Text should be 'hexlified' and decoded from human readable 'UTF-8' string to bytes string;
- (before encryption) Text should be splitted to 25 bytes long word each and equal;
- (before encryption) The tail of text/string should be extended by zeroes to get 25 bytes length of word;
- (after encryption) Output encrypted words should be joined to single long encoded code to transfer between users/participants ('encrypt' function returns back encrypted word of 32 bytes long);
- (before decryption) Text should be splitted to 32 bytes long word each and equal (as it returns 'encrypt' function);
- (after decryption) Text should be 'unhexlified' and encoded to human readable 'UTF-8' string;

Example of preprocess:
````python3
from binascii import hexlify
    
text = "Hello World!"
    
hexified = hexlify((text).encode()).decode()
    
word_to_encrypt = "0x" + hexified + "0" * (50 - len(hexified))
print(word_to_encrypt) 

````

returns '0x48656c6c6f20576f726c642100000000000000000000000000'

Which is exact what we need to push into 'encrypt' function of contract.

The output of function 'encrypt' of contract will return word of 32 bytes long. These bytes we will push into 'decrypt' function which returns 25 bytes long word back to encode to human readable 'UTF-8' string.
