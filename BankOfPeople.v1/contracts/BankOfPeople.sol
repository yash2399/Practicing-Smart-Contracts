// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BankOfPeople is ERC20 {
    uint256 private lendingPool = 0;
    address private immutable i_owner;

    struct Account {
        string accountHolderName;
        address accountAddress;
        uint accountBalance;
        uint amountBorrowed;
        uint shareInPool;
    }

    Account[] public accounts;

    mapping(address => uint) addressToBalance;
    mapping(address => Account) addressToAccount;
    mapping(uint => uint) idToBalance;
    mapping(address => uint) addressToId;

    string private s_name;
    string private s_symbol;

    constructor(
        string memory name_,
        string memory symbol_,
        address owner_
    ) ERC20(name_, symbol_) {
        s_name = name_;
        s_symbol = symbol_;
        i_owner = owner_;
    }

    function _createAccount(string memory _name) public {
        accounts.push(Account(_name, msg.sender, 0, 0, 0));
        uint id = accounts.length - 1;
        idToBalance[id] = 0;
        addressToId[msg.sender] = id;
    }

    function _depositMoney(address _address) public payable {
        uint id = addressToId[_address];
        accounts[id].accountBalance += msg.value;
        lendingPool += msg.value;
        accounts[id].shareInPool = accounts[id].accountBalance / lendingPool;
    }

    function _withdrawMoney(uint _amountToWithdraw) public {
        uint id = addressToId[msg.sender];
        require(
            _amountToWithdraw <
                (accounts[id].accountBalance - _lockedETH(msg.sender))
        );
        accounts[id].accountBalance -= _amountToWithdraw;
        payable(accounts[id].accountAddress).call{value: _amountToWithdraw};
        lendingPool -= _amountToWithdraw;
        accounts[id].shareInPool = accounts[id].accountBalance / lendingPool;
    }

    function _viewBalance() public view returns (uint) {
        uint id = addressToId[msg.sender];
        return accounts[id].accountBalance;
    }

    function _borrowMoney(uint _amountLent) public {
        uint id = addressToId[msg.sender];
        require(
            _amountLent <
                (2 * (accounts[id].accountBalance - _lockedETH(msg.sender))) / 3
        );
        _mint(msg.sender, _amountLent);
        accounts[id].amountBorrowed += _amountLent;
    }

    function _repayMoney(uint _amountRepaid) public payable {
        uint interest = _amountRepaid / 10;
        require(msg.value == interest);
        uint id = addressToId[msg.sender];
        _burn(msg.sender, _amountRepaid);
        accounts[id].amountBorrowed -= _amountRepaid;
        _payInterest(interest);
    }

    function _lockedETH(address _address) internal view returns (uint) {
        uint id = addressToId[_address];
        return (3 * (accounts[id].amountBorrowed)) / 2;
    }

    function _payInterest(uint _interest) internal view {
        payable(i_owner).call{value: _interest / 2};
        for (uint id = 0; id < accounts.length; id++) {
            payable(accounts[id].accountAddress).call{
                value: accounts[id].shareInPool * (_interest / 2)
            };
        }
    }
}
