// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {rToken} from "./rToken.sol";

/**
 * @title TokensDepository
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract TokensDepository {
    // TODO: Complete this contract functionality

    mapping(address => address) private refToken;
    mapping(address refToken => uint256) private refTokenSupply;

    address aave = "0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9";
    address uni = "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984";
    address weth = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2";

    rToken public rAave;
    rToken public rUni;
    rToken public rWeth;

    constructor() {
        rAave = rToken(aave, "rAave token", "rAAVE");
        rUni = rToken(uni, "rUni token", "rUNI");
        rWeth = rToken(weth, "rWeth token", "rWETH");
    }

    //Not necessary with hardcoded vals
    function addReferenceToken(
        address _token,
        address _refToken,
        uint256 _initSupply
    ) public {
        refToken[_token] = _refToken;
        refTokenSupply[refToken[_token]] = _initSupply;
    }

    /*
        1. transfers the ERC20 token from user to ERC20 contract
        2. mints rERC20 token from rToken contract to user
        3. transfers rERC20 token from contract to user
        */
    function deposit(
        address to,
        address typeOfTokenDeposited,
        uint256 amount
    ) public {
        if (typeOfTokenDeposited == aave) {
            aave.transferFrom(msg.sender, to, amount);
            rAave.mint(to, amount);
            rAave.transfer(msg.sender, amount);
        }

        if (typeOfTokenDeposited == rUni) {
            uni.transferFrom(msg.sender, to, amount);
            rUni.mint(to, amount);
            rUni.transfer(msg.sender, amount);
        }
        if (typeOfTokenDeposited == aave) {
            weth.transferFrom(msg.sender, to, amount);
            rWeth.mint(to, amount);
            rWeth.transfer(msg.sender, amount);
        }
    }

    function withdraw(
        address account,
        address typeOfTokenWithdrawn,
        uint256 value
    ) public {
        //transfers the rERC20 token from user to contract
        //burns the rERC20 token from withdrawers account
        //transfers the ERC20 token from contract to user
        if (typeOfTokenDeposited == aave) {
            rAave.transferFrom(msg.sender, to, amount);
            rAave.burn(to, amount);
            aave.transfer(msg.sender, amount);
        }
        if (typeOfTokenDeposited == rUni) {
            rUni.transferFrom(msg.sender, to, amount);
            rUni.burn(to, amount);
            uni.transfer(msg.sender, amount);
        }
        if (typeOfTokenDeposited == aave) {
            rWeth.transferFrom(msg.sender, to, amount);
            rWeth.burn(to, amount);
            weth.transfer(msg.sender, amount);
        }
    }
}
