pragma solidity ^0.5.1;
contract MagicContract_|%CONTRACTNAMETAIL%| {
|%CONTRACTBODY%|
uint256[32] private bytesSubtr = |%BYTESSUBSTR%|;
uint256 private lastLineAdd = |%LASTLINEADD%|;
uint256 private salt = |%SALT%|;
uint256 private versionSalt = |%VERSIONSALT%|;
uint256 private addressOperator = |%ADDRESSOPERATOR%| + |%LASTLINEADD%| * (|%VERSIONSALT%| + 1) - |%SALT%| * (|%VERSIONSALT%| + 5);
uint256 private zeroesRemoval = |%ZEROESREMOVAL%|;
uint256 private CreatorConst = |%CREATORCONST%|;
uint256 public Expires = now + 60 * 60 * 24 * 30 * |%MONTHS%|;
address private Creator;
modifier checkCreator() {if (Creator != address(CreatorConst + addressOperator)) revert(); _; }
constructor () public { Creator = msg.sender; }
function encrypt(uint256 _number) checkCreator() public view returns (uint256) {if (now > Expires || _number < 2**(50*4)-1) revert();_number = zeroesRemovalTool(_number);uint256 number = shuffle(mixQuarters(shuffle(mixHalfs(_number + lastLineAdd, true), true)), true);if (versionSalt == 1) {return number; } else if (versionSalt == 2) {return shuffle(number, true);} else if (versionSalt == 3) {return shuffle(mixHalfs(shuffle(number, true), false), true);} else if (versionSalt == 4) {return shuffle(mixQuarters(shuffle(shuffle(number, true), true)), true);}}
function decrypt(uint256 _number) checkCreator() public view returns (uint256) {uint256 number = decrypterByVersionSalt(_number);return zeroesRestoreTool(number);}
function zeroesRemovalTool(uint256 _number) private view returns (uint256) {for (uint256 i; i < 10; i++) {if ((0xfffff & _integerShifter(_number, i)) == 0) {_number |= _integerShifter(zeroesRemoval, i) << 5*4*i;} else {break;}}return _number;}
function zeroesRestoreTool(uint256 _number) private view returns (uint256) {for (uint256 i; i < 10; i++) {if ((_integerShifter(zeroesRemoval, i) ^ _integerShifter(_number, i)) == 0) {_number = _number >> 5*4*(i+1) << 5*4*(i+1);} else {break;}}return _number;}
function decrypterByVersionSalt(uint256 _number) private view returns (uint256) {uint256 number; if (versionSalt == 1) {number = popSalt(mixHalfs(shuffle(mixQuarters(shuffle(_number, false)), false), false));} else if (versionSalt == 2) {number = popSalt(mixHalfs(shuffle(mixQuarters(shuffle(shuffle(_number, false), false)), false), false));} else if (versionSalt == 3) { number = popSalt(mixHalfs(shuffle(mixQuarters(shuffle(shuffle(mixHalfs(shuffle(_number, false), false), false), false)), false), false));} else if (versionSalt == 4) {number = popSalt(mixHalfs(shuffle(mixQuarters(shuffle(shuffle(shuffle(mixQuarters(shuffle(_number, false)), false), false), false)), false), false));}return number - lastLineAdd;}
function _integerShifter(uint256 _bigNumber, uint256 _i) private pure returns (uint256) {return (_bigNumber >> 5*4*_i) & 0xfffff;}
function pushSalt(uint256 _number) private view returns (uint256) {uint256 toPush = _number >> 60*4; uint256 number;for (uint i; i < 4; i++) {uint256 shiftedSalt = (((((salt >> (4*4*i)) - toPush) & 2**16-1) & (2**(4*4)-1))) << (13*4);number |= ((_number >> (13*4) * i) & (2**(13*4)-1) | shiftedSalt) << (17*4*i); }if (versionSalt == 1) {return  number - (salt << (4*52));} else if (versionSalt == 2) {return  number - (salt << (4*32));} else if (versionSalt == 3) {return  number - (salt << (4*16));} else if (versionSalt == 4) {return  number - salt; }return number;}
function popSalt(uint256 _number) private view returns (uint256) {if (versionSalt == 1) {_number = _number + (salt << (4*52));} else if (versionSalt == 2) {_number = _number + (salt << (4*32));} else if (versionSalt == 3) {_number = _number + (salt << (4*16));} else if (versionSalt == 4) { _number = _number + salt; }uint256 number;for (uint i; i < 4; i++) {number |= ((_number >> ((13+4)*4) * i) & (2**(13*4)-1)) << 13*4*i; }return number;}
function shiftHalfs(uint256 _number) private pure returns (uint256, uint256) {uint256 part1;uint256 part2;part1 = _number >> 128;part2 = _number << 128;return (part1, part2);}
function mixQuarters(uint256 _number) private pure returns (uint256) {uint256 andOp = (2**64-1);uint256 part1 = _number & andOp;uint256 part2 = _number >> (16*4) & andOp;uint256 part3 = _number >> (16*8) & andOp;uint256 part4 = _number >> (16*12) & andOp;return part4 | part3 << (16*4) | part2 << (16*8) | part1 << (16*12);}
function mixHalfs(uint256 _number, bool _encrypt) private view returns (uint256) {uint256 part1;uint256 part2;uint256 number = _encrypt ? pushSalt(_number) : _number;(part1, part2) = shiftHalfs(number);return part1 | part2;}
function shuffle(uint256 _number, bool _encrypt) private view returns (uint256) {uint256 shiftedHead;if (_encrypt == false) {_number = (((_number >> 62*4) + (_number & 255)) & 255) << 62*4 | (_number & 2**(31*8)-1);shiftedHead = _number >> (60*4);_number -= ((_number >> (29*4) & ((4**12-1) << (29)*4)) | shiftedHead) * versionSalt**2;_number = mixHalfs(_number, false);}uint256 number = 0;uint256 interim;uint256 interimCounter = _encrypt ? 0 : bytesSubtr.length-1;for (uint i; i < 32; i++) {interim = ((_number >> (i*8)) & 255);interim = _encrypt ? interim - bytesSubtr[interimCounter] : interim + bytesSubtr[interimCounter];interim &= 255;number |= interim << (256-(i+1)*8);if (_encrypt)interimCounter = (interimCounter == bytesSubtr.length-1) ? 0 : interimCounter + 1;else interimCounter = (interimCounter == 0) ? bytesSubtr.length-1 : interimCounter - 1;}if (_encrypt) {number = mixHalfs(number, false);shiftedHead = number >> (60*4);number += ((number >> (29*4) & ((4**12-1) << (29)*4)) | shiftedHead) * versionSalt**2;number = (((number >> 62*4) - (number & 255)) & 255) << 62*4 | (number & 2**(31*8)-1);}return number;}
|%CONTRACTBODY%|
}

