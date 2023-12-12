// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "src/contracts/erc20-2/TokensDepository.sol";
import "src/contracts/erc20-2/rToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokensDepository2 is Test {
    TokensDepository public depository;

    address aaveHolder;
    address uniHolder;
    address wethHolder;

    uint256 initAaveBalance;
    uint256 initUniBalance;
    uint256 initWethBalance;

    address deployer;
    address constant AAVE_ADDRESS =
        address(0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9);
    address constant UNI_ADDRESS =
        address(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);
    address constant WETH_ADDRESS =
        address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    IERC20 public aave = IERC20(AAVE_ADDRESS);
    IERC20 public uni = IERC20(UNI_ADDRESS);
    IERC20 public weth = IERC20(WETH_ADDRESS);

    rToken public rAave;
    rToken public rUni;
    rToken public rWeth;

    function setUp() public {
        deployer = address(1);

        // Deploying the depository contract
        depository = new TokensDepository();

        // Deploying the respective rToken smart contracts, each with their respective reference token addresses
        /* not needed? yes, needed since we want to have tests checking that these did indeed get the tokens they are supposed to 
        get via minting-process in the deposit function of the TokensDepository contracy */
        rAave = new rToken(AAVE_ADDRESS, "rAave token", "rAave");
        rUni = new rToken(UNI_ADDRESS, "rUni token", "rUni");
        rWeth = new rToken(WETH_ADDRESS, "rWeth token", "rWeth");

        // Holders loaded from mainnet
        aaveHolder = address(0x2eFB50e952580f4ff32D8d2122853432bbF2E204);
        uniHolder = address(0x193cEd5710223558cd37100165fAe3Fa4dfCDC14);
        wethHolder = address(0x741AA7CFB2c7bF2A1E7D4dA2e3Df6a56cA4131F3);

        // Sending eth to holders
        vm.deal(aaveHolder, 1 ether);
        vm.deal(uniHolder, 1 ether);
        vm.deal(wethHolder, 1 ether);

        initAaveBalance = IERC20(AAVE_ADDRESS).balanceOf(aaveHolder);
        initUniBalance = IERC20(UNI_ADDRESS).balanceOf(uniHolder);
        initWethBalance = IERC20(WETH_ADDRESS).balanceOf(wethHolder);
    }

    function testDepositTokensA() public {
        console.log("Testing Deposits...");

        // Deposit Tokens
        // för varje protokoll behöver jag först connecta till varje holder för att approvea varje resp kontrakt

        // 15 AAVE
        uint256 aaveAmount = 15 ether;
        vm.startPrank(aaveHolder);
        aave.approve(address(depository), aaveAmount);
        depository.deposit(AAVE_ADDRESS, aaveAmount);

        // 5231 UNI
        uint256 uniAmount = 5231 ether;
        vm.startPrank(uniHolder);
        uni.approve(address(depository), uniAmount);
        depository.deposit(UNI_ADDRESS, uniAmount);

        // 33 WETH from WETH Holder
        uint256 wethAmount = 33 ether;
        vm.startPrank(wethHolder);
        weth.approve(address(depository), wethAmount);
        depository.deposit(WETH_ADDRESS, wethAmount);

        // TODO: Check that the tokens were sucessfully transferred to the depository
        // Assert that the tokens were successfully transferred to the depository
        assert(aave.balanceOf(address(depository)) == aaveAmount);
        assert(uni.balanceOf(address(depository)) == uniAmount);
        assert(weth.balanceOf(address(depository)) == wethAmount);

        // Jag måste på något sätt få tag på rToken adresserna som deployats för varje token-typ

        // Assert that the rTokens were successfully minted
        // TODO: Check that the right amount of receipt tokens were minted
        assert(
            depository.receiptTokens(AAVE_ADDRESS).balanceOf(aaveHolder) ==
                aaveAmount
        );
        assert(
            depository.receiptTokens(UNI_ADDRESS).balanceOf(uniHolder) ==
                uniAmount
        );
        assert(
            depository.receiptTokens(WETH_ADDRESS).balanceOf(wethHolder) ==
                wethAmount
        );

        // -------------------------------- WITHDRAWALS --------------------------------
        console.log("Testing Withdrawals...");
        vm.startPrank(aaveHolder);
        depository.withdraw(AAVE_ADDRESS, aaveAmount);

        vm.startPrank(uniHolder);
        depository.withdraw(UNI_ADDRESS, uniAmount);

        vm.startPrank(wethHolder);
        depository.withdraw(WETH_ADDRESS, wethAmount);

        // Skriv test för att se att withdraw faktiskt funkar -->
        // TODO: Check that the tokens were sucessfully withdrawn from the depository
        // assert(aave.balanceOf(address(depository)) == 0);
        // assert(uni.balanceOf(address(depository)) == 0);
        // assert(weth.balanceOf(address(depository)) == 0);

        // Check that that right amounts of tokens were withdrawn (depositors got back their assets)
        assertEq(IERC20(AAVE_ADDRESS).balanceOf(aaveHolder), initAaveBalance);
        assertEq(IERC20(UNI_ADDRESS).balanceOf(uniHolder), initUniBalance);
        assertEq(IERC20(WETH_ADDRESS).balanceOf(wethHolder), initWethBalance);

        // Assert that the rTokens were successfully burned
        assertEq(
            depository.receiptTokens(AAVE_ADDRESS).balanceOf(aaveHolder),
            0
        );
        assertEq(depository.receiptTokens(UNI_ADDRESS).balanceOf(uniHolder), 0);
        assertEq(
            depository.receiptTokens(WETH_ADDRESS).balanceOf(wethHolder),
            0
        );
    }
}
