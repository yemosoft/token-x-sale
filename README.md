# SaleXToken Smart Contract

This smart contract is specifically developed for [project name] as a token sale contract. This README file provides essential information about the features, usage, and development process of the contract.

## Overview

- **Contract Name:** SaleXToken
- **Version:** Solidity ^0.5.0
- **Dependencies:** IERC20.sol, ERC20.sol, Ownable.sol, SafeMath.sol
- **Decimals:** 6

## Functions and Features

### Token Sale

- `buyToken(uint _amount)`: This function allows purchasing tokens up to the specified amount. The purchase process is executed by checking the user's balance, contract balance, and permission status.

### Information Retrieval

- `getUSDTBalanceOf(address _address)`: Retrieves the USDT balance of the specified address.
- `getTokenBalanceOf(address _address)`: Retrieves the token balance of the specified address.
- `calculateTotal(uint _amount)`: Calculates the total USDT amount for the specified quantity.

### Contract Settings

- `setAuthorizeds(address _account, bool _mode)`: Authorizes or deauthorizes the specified account.
- `updateTokenPrice(uint _newprice)`: Updates the token price.
- `updateUSDTContractAddress(address _address)`: Updates the USDT contract address.
- `updateTokenContractAddress(address _address)`: Updates the token contract address.
- `setEndSale(bool _endsale)`: Ends or continues the token sale.

### Information Checks

- `checkBuying(uint _amount)`: Checks the token purchase status for the specified amount.

### Withdrawal Operations

- `withdrawUSDT(address _address)`: Withdraws the total USDT balance by an authorized user.
- `withdrawToken(address _address)`: Withdraws the total token balance by an authorized user.

## Installation and Usage

1. Open the terminal in the project directory and run the following command to install dependencies:

    ```bash
    npm install
    ```

2. Use Truffle to compile the contract:

    ```bash
    truffle compile
    ```

3. To test the contract:

    ```bash
    truffle test
    ```

4. To deploy the contract:

    ```bash
    truffle migrate
    ```

5. Set the required parameters for the contract and perform operations for usage.

## Contributors

- [Full Name](https://github.com/username)

## License

This project is licensed under [License Type]. For detailed information, refer to the [LICENSE](LICENSE) file.
