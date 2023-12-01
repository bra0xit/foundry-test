// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

pragma solidity ^0.8.0;

contract MyERC20Contract is ERC20 {
    string private _name = "BraxitCoin";
    string private _symbol = "BRXC";

    address public owner;

    constructor() ERC20(_name, _symbol) {
        owner = msg.sender;
    }

    function burn(address account, uint256 value) public {
        _burn(account, value);
    }

    function mint(address to, uint256 amount) public {
        require(msg.sender == owner, "Not Owner");
        _mint(to, amount);
    }
}
