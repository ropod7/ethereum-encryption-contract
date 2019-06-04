#!/usr/bin/env python3
# -*- coding: utf8 -*-
import os, sys
from random import randrange, shuffle
from json import dumps

print(sys.version)

boolAssert = "Bool assertion error"

PROJECT_ROOT = os.getcwd()

varName = "var name '%s'"

class MagicContract():
    _codeDelimiter = "|%CONTRACTBODY%|"
    _contractPath = os.path.join(PROJECT_ROOT, "magic", "contracts/")
    _privateSrcName = "magicContract.sol"
    _publicSrcName = "publicContract.sol"
    _name = "MagicContract"
    _compiledPath = os.path.join(PROJECT_ROOT, "magic", "compiled/")
    _sourcePath   = os.path.join(PROJECT_ROOT, "magic", "gen/")

    """ Constructor:
    creator: Ethereum wallet address of compilation creator of contract
    _saltVersion: Debug function to set salting process version by hand
    _private: Private contract compiles by default
    _months: Number of months availability of contract after registration"""
    def __init__(self, creator, _saltVersion=None, _private=True, _months=1):
        assert isinstance(_private, bool), boolAssert
        assert isinstance(_months, int)
        _contractName = __class__._privateSrcName if _private else __class__._publicSrcName
        self._contract = __class__._contractPath + _contractName
        self.creator = creator
        # BEGIN of Randomly generated definitions in contract source code
        # See the additions in self.struct named "|%BYTESSUBSTR%|" and "|%ZEROESREMOVAL%|"
        salt = self.genSalt(12, "salt")
        lastLineAdd = self.genSalt(randrange(26, 32), "lastLineAdd")
        addressOperator = self.genSalt(36, "addressOperator")
        self.contractNameTail = "%s_%s" % (int(os.times().elapsed), self.genSalt(5, "contractNameTail"))
        self.versionSalt = randrange(1, 5) if _saltVersion is None else _saltVersion
        print('\nversionSalt:', self.saltVersion)
        insideCodeOperator = addressOperator + lastLineAdd * (self.versionSalt + 1) - salt * (self.versionSalt + 5)
        # END of Randomly generated definitions in contract source code

        # Definition gives hidden (salted) Ethereum address of creator
        CreatorConst = int(creator, 0) - insideCodeOperator
        self.struct = {
                "|%CONTRACTNAMETAIL%|": self.contractNameTail,
                "|%ADDRESSOPERATOR%|" : addressOperator,
                # BEGIN of Randomly generated definitions in contract source code
                "|%ZEROESREMOVAL%|"   : self.zeroesRemovalGen(),
                # Generates random byte array of length of 32 bytes for 'bytesSubtr' definition
                "|%BYTESSUBSTR%|"     : [randrange(1, 250) for i in range(32)],
                # END of Randomly generated definitions in contract source code
                "|%CREATORCONST%|"    : CreatorConst,
                "|%LASTLINEADD%|"     : lastLineAdd,
                "|%VERSIONSALT%|"     : self.versionSalt,
                "|%MONTHS%|"          : _months,
                "|%SALT%|"            : salt,
                # Randomly generated names of defenitions:
                "addressOperator" : self.genVariable(varName % "addressOperator"),
                "zeroesRemoval"   : self.genVariable(varName % "zeroesRemoval"),
                "CreatorConst"    : self.genVariable(varName % "CreatorConst"),
                "versionSalt"     : self.genVariable(varName % "versionSalt"),
                "lastLineAdd"     : self.genVariable(varName % "lastLineAdd"),
                "bytesSubtr"      : self.genVariable(varName % "bytesSubtr"),
                "salt"            : self.genVariable(varName % "salt"),
            }

    def _zeroesRemovalMapper(self, number):
        return hex(number)[2:]

    # Each 'string' or byte string in Ethereum compiled body or input data of contract
    # ends with zeroes in tail. Such a method generates salt additions to completely
    # fill the tail inside the LATEST PART OF INPUT STRING. String that aimed to
    # encode inside the given contract.
    # Range between 0xe0000 and 0xfffff has empty cells in UTF table.
    # eg: each randomly generated 2.5 bytes joined to 25 bytes word.
    def zeroesRemovalGen(self):
        gen = [randrange(0xe0000, 0xfffff) for i in range(10)]
        output = "".join(map(self._zeroesRemovalMapper, gen))
        print("\nzeroesRemoval value: %s (%d bytes)" % ("0x" + output, len(output) / 2))
        return int("0x" + output, 0)

    # Gives random names of definitions
    def genVariable(self, definitionName):
        name = chr(randrange(97, 122)) + hex(self.genSalt(7))[2:]
        print("\n%s: %s" % (definitionName, name))
        return name

    # Generates salt for needed length of word.
    def genSalt(self, length, definitionName=""):
        output = "";
        for i in range(length):
            rr = 6 if length > 12 and len(output) < 16 else 16
            output += hex(randrange(1, rr))[2:]
        if definitionName:
            print("\n%s value: %s (%d bytes)" % (definitionName, "0x" + output, len(output) / 2))
        return int("0x" + output, 0)

    # Method makes:
    # 1. All random words and names of definitions;
    # 2. Shuffle of source code blocks;
    # 3. Writes of code into one line for following compilation;
    def inlineSource(self):
        with open(self._contract, "r") as f:
            body = f.read()
            for key, value in self.struct.items():
                body = str(value).join(body.split(key))
            body = body.split(__class__._codeDelimiter)
            codeBody = body[1].split('\n')
            shuffle(codeBody)
            body[1] = " ".join(codeBody)
            return " ".join(" ".join(body).split("\n"))

    # Method compiler.
    def compileSol(self, source, port=None):
        output = []
        sourceFN = "%ssource_%s.sol" % (__class__._sourcePath, self.contractNameTail)
        contractName = "%s%s_%s" % (__class__._compiledPath, __class__._name, self.contractNameTail)
        abiName = contractName + ".abi"
        binName = contractName + ".bin"
        with open(sourceFN, "w") as f:
            f.write(source)
        os.system("solc -o %s --bin --optimize --abi %s" % (__class__._compiledPath, sourceFN))
        with open(binName, "r") as f:
            output.append("0x" + f.readline())
        with open(abiName, "r") as f:
            output.append(f.readline())
        for obj in (abiName, sourceFN, binName):
            os.remove(obj)
        return tuple(output)

    @property
    def saltVersion(self):
        return self.versionSalt

if __name__ == "__main__":
    creator = '0x23b72a88012003e5d1fb304245ddb5256ecc8ca3'
    c = MagicContract(creator, _private=False, _months=24)
    output = c.inlineSource()
    print("\nGenerated Source Code:\n" + output, '\n')
    output = c.compileSol(output)

    assert isinstance(output, tuple), output
    code, abi = output
    print("\nCompiled Source Code:\n" + code)
    print("\nCreator address in compiled code:", creator in code)
