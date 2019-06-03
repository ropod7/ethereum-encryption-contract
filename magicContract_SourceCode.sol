pragma solidity >=0.5.1 <0.6.0;

/*
/// @title Example of MagicContract;
/// All definitions aimed to show principle of contract;
/// Contract compilation is multilevel process described in mccompiler.py;
/// Source Code which was used in compilation described in:
/// magic/contracts/publicContract.sol for Public contract and in
/// magic/contracts/magicContract.sol for Private contract use;
*/
contract MagicContract {
    // BEGIN of Randomly generated definitions
    uint256[32] private bytesSubtr = [119, 218, 236, 102, 11, 173, 136, 196, 85, 140, 106, 159, 25, 48, 153, 49, 171, 8, 48, 122, 55, 249, 137, 142, 2, 53, 62, 221, 70, 133, 170, 153]; // bytes array of random 8 bits items
    uint256 private lastLineAdd = 1434093466119865833640005717506556725; // 13-15 bytes long
    uint256 private addressOperator = 2979881088218497434989893909734221955336187; // 18 bytes long
    uint256 private zeroesRemoval = 1553682268781453753453941523375839400060457643026323668405045; // 25 bytes long
    uint256 private salt = 249371852232419; // 6 bytes long
    uint256 private versionSalt = 1; // random 1-4
    // END of Randomly generated definitions
    // Contract expiration
    uint256 public Expires = now + 60 * 60 * 24 * 30 * 1; // 30 days
    // Salted Ethereum address of contract compilation creator
    uint256 private CreatorConst = 116727156174188091019688739584752390716576765452 - addressOperator;
    uint256 private maxParticipants = 7;
    // Ethereum address of contract creator
    address private Creator;
    address[] private Participants;

    /// No such modifier in magic/contracts/publicContract.sol;
    modifier onlyByParticipants(){
        uint j = 0;
        for (uint i; i < Participants.length; i++) {
            if (msg.sender == Participants[i])
                break;
            j++;
        }
        require(j != Participants.length && msg.sender == Creator);
        _;
    }
    
    modifier onlyByCreator(){
        require(msg.sender == Creator);
        _;
    }
    
    // Creator and compilation creator should be equal;
    modifier checkCreator() {
        require(Creator == address(CreatorConst + addressOperator));
        _;
    }
    
    /*
    /// @notice: Contract constructor;
    /// @param _participants: List of participants (if needed and no
    /// such param in magic/contracts/publicContract.sol);
    */
    constructor (address[] memory _participants) public
    {
        Creator = msg.sender;
        if (_participants.length > 0 && _participants.length <= maxParticipants) {
            setParticipants(_participants);
        }
    }

    /*
    /// @notice: Set/reset participants list (no such function in 
    /// magic/contracts/publicContract.sol);
    /// @permissions: Allowed to call only by creator;
    /// @param _participants: List of participants (if needed);
    */
    function setParticipants(address[] memory _participants)
    onlyByCreator()
    public
    {
        assert(_participants.length < maxParticipants);
        for (uint256 i; i<_participants.length; i++) {
            require(_participants[i] != Creator);
        }
        Participants = _participants;
    }
    
    /*
    /// @notice: Get participants list (no such function in 
    /// magic/contracts/publicContract.sol);
    /// @returns: list of participants;
    */
    function getParticipants()
    checkCreator() onlyByParticipants()
    public view returns (address[] memory)
    {
        return Participants;
    }
    
    /*
    /// @notice: Public function with input string to encode.
    /// NB! The input string should be exactly 25 bytes long (!!!) and the last
    /// part of splitted text should be EXTENDED WITH ZEROES at client side.
    /// @permissions: Allowed to call just by registered participants and 
    /// creator. (except magic/contracts/publicContract.sol);
    /// @param _number: 25 bytes part of splitted text.
    /// @returns: 32 bytes of encrypted part of string;
    */
    function encrypt(uint256 _number) 
    checkCreator() onlyByParticipants()
    public view returns (uint256)
    {
        if (now > Expires || _number < 2**(50*4)-1)
            revert();
        _number = zeroesRemovalTool(_number);
        uint256 number = shuffle(mixQuarters(shuffle(mixHalfs(_number + lastLineAdd, true), true)), true);
        // Salted shuffle sequence depends on versionSalt definition 
        if (versionSalt == 1) {
            return number;
        } else if (versionSalt == 2) {
            return shuffle(number, true);
        } else if (versionSalt == 3) {
            return shuffle(mixHalfs(shuffle(number, true), false), true);
        } else if (versionSalt == 4) {
            return shuffle(mixQuarters(shuffle(shuffle(number, true), true)), true);
        }
    }
    
    /*
    /// @notice: Public function with input string to decode;
    /// NB! The input string should be exactly 32 bytes long as from 'encode' output (!!!);
    /// @permissions: Allowed to call just by registered participants and 
    /// creator. (except magic/contracts/publicContract.sol);
    /// @param _number: 32 bytes part of splitted text;
    /// @returns 25 bytes of decrypted part of string;
    */
    function decrypt(uint256 _number)
    checkCreator() onlyByParticipants()
    public view returns (uint256) {
        uint256 number = decrypterByVersionSalt(_number);
        return zeroesRestoreTool(number);
    }
    
    /*
    /// @notice: Private function;
    /// Fills the tail zeroes of short/latest string by random words between 0xe0000 and 0xfffff;
    /// The lenght of zeroesRemoval defenition depends on number of zeroes at the string tail;
    */
    function zeroesRemovalTool(uint256 _number) private view returns (uint256) {
        for (uint256 i; i < 10; i++) {
            if ((0xfffff & _integerShifter(_number, i)) == 0) {
                _number |= _integerShifter(zeroesRemoval, i) << 5*4*i;
            } else {
                break;
            }
        }
        return _number;
    }

    /*
    /// @notice: THIS AND ALL FUNCTIONS BELOW AS THEY ARE IN ENC/DEC PROCESS AND NAMED;
    */
    function zeroesRestoreTool(uint256 _number) private view returns (uint256) {
        for (uint256 i; i < 10; i++) {
            if ((_integerShifter(zeroesRemoval, i) ^ _integerShifter(_number, i)) == 0) {
                _number = _number >> 5*4*(i+1) << 5*4*(i+1);
            } else {
                break;
            }
        }
        return _number;
    }
    
    function decrypterByVersionSalt(uint256 _number) private view returns (uint256) {
        uint256 number;
        if (versionSalt == 1) {
            number = popSalt(mixHalfs(shuffle(mixQuarters(shuffle(_number, false)), false), false));
        } else if (versionSalt == 2) {
            number = popSalt(mixHalfs(shuffle(mixQuarters(shuffle(shuffle(_number, false), false)), false), false));
        } else if (versionSalt == 3) {
            number = popSalt(mixHalfs(shuffle(mixQuarters(shuffle(shuffle(mixHalfs(shuffle(_number, false), false), false), false)), false), false));
        } else if (versionSalt == 4) {
            number = popSalt(mixHalfs(shuffle(mixQuarters(shuffle(shuffle(shuffle(mixQuarters(shuffle(_number, false)), false), false), false)), false), false));
        }
        return number - lastLineAdd;
    }

    function _integerShifter(uint256 _bigNumber, uint256 _i) private pure returns (uint256) {
        return (_bigNumber >> 5*4*_i) & 0xfffff;
    }

    function pushSalt(uint256 _number) private view returns (uint256) {
        uint256 toPush = _number >> 60*4;
        uint256 number;
        for (uint i; i < 4; i++) {
            uint256 shiftedSalt = (((((salt >> (4*4*i)) - toPush) & 2**16-1) & (2**(4*4)-1))) << (13*4);
            number |= ((_number >> (13*4) * i) & (2**(13*4)-1) | shiftedSalt) << (17*4*i);
        }
        if (versionSalt == 1) {
            return  number - (salt << (4*52));
        } else if (versionSalt == 2) {
            return  number - (salt << (4*32));
        } else if (versionSalt == 3) {
            return  number - (salt << (4*16));
        } else if (versionSalt == 4) {
            return  number - salt;
        }
        return number;
    }

    function popSalt(uint256 _number) private view returns (uint256) {
        if (versionSalt == 1) {
            _number += (salt << (4*52));
        } else if (versionSalt == 2) {
            _number += (salt << (4*32));
        } else if (versionSalt == 3) {
            _number += (salt << (4*16));
        } else if (versionSalt == 4) {
            _number += salt;
        }
        uint256 number;
        for (uint i; i < 4; i++) {
            number |= ((_number >> ((13+4)*4) * i) & (2**(13*4)-1)) << 13*4*i;
        }
        return number;
    }

    function shiftHalfs(uint256 _number) private pure returns (uint256, uint256) {
        uint256 part1;
        uint256 part2;
        part1 = _number >> 128;
        part2 = _number << 128;
        return (part1, part2);
    }

    function mixQuarters(uint256 _number) private pure returns (uint256) {
        uint256 andOp = (2**64-1);
        uint256 part1 = _number & andOp;
        uint256 part2 = _number >> (16*4) & andOp;
        uint256 part3 = _number >> (16*8) & andOp;
        uint256 part4 = _number >> (16*12) & andOp;
        return part4 | part3 << (16*4) | part2 << (16*8) | part1 << (16*12);
    }

    function mixHalfs(uint256 _number, bool _encrypt) private view returns (uint256) {
        uint256 part1;
        uint256 part2;
        uint256 number = _encrypt ? pushSalt(_number) : _number;
        (part1, part2) = shiftHalfs(number);
        return part1 | part2;
    }

    function shuffle(uint256 _number, bool _encrypt) private view returns (uint256) {
        uint256 shiftedHead;
        if (_encrypt == false) {
            _number = (((_number >> 62*4) + (_number & 255)) & 255) << 62*4 | (_number & 2**(31*8)-1);
            shiftedHead = _number >> (60*4);
            _number -= ((_number >> (29*4) & ((4**12-1) << (29)*4)) | shiftedHead) * versionSalt**2;
            _number = mixHalfs(_number, false);
        }
        uint256 number = 0;
        uint256 interim;
        uint256 interimCounter = _encrypt ? 0 : bytesSubtr.length-1;
        for (uint i; i < 32; i++) {
            interim = ((_number >> (i*8)) & 255);
            interim = _encrypt ? interim - bytesSubtr[interimCounter] : interim + bytesSubtr[interimCounter];
            interim &= 255;
            number |= interim << (256-(i+1)*8);
            if (_encrypt)
                interimCounter = (interimCounter == bytesSubtr.length-1) ? 0 : interimCounter + 1;
            else
                interimCounter = (interimCounter == 0) ? bytesSubtr.length-1 : interimCounter - 1;
        }
        if (_encrypt) {
            number = mixHalfs(number, false);
            shiftedHead = number >> (60*4);
            number += ((number >> (29*4) & ((4**12-1) << (29)*4)) | shiftedHead) * versionSalt**2;
            number = (((number >> 62*4) - (number & 255)) & 255) << 62*4 | (number & 2**(31*8)-1);
        }
        return number;
    }

    function destruct() public
    {
        require(msg.sender == Creator);
        selfdestruct(msg.sender);
    }
}
