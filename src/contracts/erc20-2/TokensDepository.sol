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

    mapping(address => IERC20) public validERC20Tokens;
    mapping(address => rToken) public receiptTokens;

    address public aaveAddress =
        address(0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9);
    address public uniAddress =
        address(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);
    address public wethAddress =
        address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    IERC20 public aaveToken;
    IERC20 public uniToken;
    IERC20 public wethToken;

    rToken public rAave;
    rToken public rUni;
    rToken public rWeth;

    constructor() {
        //Will this make the owner of this TokensDepository contract the owner of the below contracts?
        // Answer is yes - the depositor (msg.sender) to the TokensDepository contract will become the owner(!) of the underlying reference token,
        // this since the constructor sets owner = msg.sender --> thus only the depositor can mint and burn tokens

        // Det sättet jag gör det här på --> dvs inte skickar in parametrar genom konstruktorn gör att jag måste vara säker på att jag matchar
        // med testen som görs (för att kunna hitta de deployade rToken kontrakten)
        rAave = new rToken(aaveAddress, "rAave token", "rAave");
        rUni = new rToken(uniAddress, "rUni token", "rUni");
        rWeth = new rToken(wethAddress, "rWeth token", "rWeth");

        //We also need to store these in a mapping
        validERC20Tokens[aaveAddress] = IERC20(aaveAddress);
        validERC20Tokens[uniAddress] = IERC20(uniAddress);
        validERC20Tokens[wethAddress] = IERC20(wethAddress);

        receiptTokens[aaveAddress] = rAave;
        receiptTokens[uniAddress] = rUni;
        receiptTokens[wethAddress] = rWeth;
    }

    modifier tokenIsValid() {
        require(true); // token which is valid
        _;
    }

    /*
        1. transfers the ERC20 token from user to ERC20 contract
        2. mints rERC20 token from rToken contract to user
        3. transfers rERC20 token from contract to user
        */
    // Should implement the approver functionality - no?
    function deposit(address typeOfTokenDeposited, uint256 amount) public {
        validERC20Tokens[typeOfTokenDeposited].transferFrom(
            msg.sender,
            address(this),
            amount
        ); //make sure to handle some tokens returning a boolean here

        /* why is msg.sender eligible to mint here? well because the depositor becomes 
            the owner of the reference asset, once again since we set msg.sender = owner on the ref contract */

        // #_mint description in ERC20: "Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0)."
        // dvs de skapas OCH skickas till account (msg.sender) i det här fallet, dvs vi behöver inte minta OCH transferra
        receiptTokens[typeOfTokenDeposited].mint(msg.sender, amount);
    }

    // transfers the rERC20 token from user to contract
    // burns the rERC20 token from withdrawers account    (behöver vi verkligen transfera OCH bränna tokens? går det inte att bränna direkt? borde gå)
    // samma som för #mint så är det här beskrivningen på #burn i ERC20: "Destroys a `value` amount of tokens from `account`, lowering the total supply." dvs
    // vi behöver inte transferra efter burn, det görs per automatik
    function withdraw(address typeOfTokenWithdrawn, uint256 value) public {
        receiptTokens[typeOfTokenWithdrawn].burn(msg.sender, value); // We are not burning the tokens IN the depository --> we are burning them from the msg.senders EOA
        //is this really needed? maybe actually since this is about the other ERC20 token
        // being tranferred back (not receipt/reference token)
        validERC20Tokens[typeOfTokenWithdrawn].transfer(msg.sender, value);
    }
}
