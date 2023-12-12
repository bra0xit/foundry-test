// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title rToken
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract rToken is ERC20 {
    address public underlyingToken;
    address public owner;

    constructor(
        address _underlyingToken,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        underlyingToken = _underlyingToken;
        owner = msg.sender;
    }

    function burn(address account, uint256 value) public {
        require(msg.sender == owner, "Not Owner");
        _burn(account, value);
    }

    function mint(address to, uint256 amount) public {
        require(msg.sender == owner, "Not Owner");
        _mint(to, amount);
    }
}
