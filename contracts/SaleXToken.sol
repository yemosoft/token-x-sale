pragma solidity ^0.5.0;

import "./IERC20.sol";
import "./ERC20.sol";
import "./Ownable.sol";

contract SaleXToken is Ownable {
    
    using SafeMath for uint; 
    
    uint public TokenPrice; //USDT *Note: Can be edited.
    uint public TotalSoled;
    
    /* for token Owner Start */
    uint public TotalUsdt     = 0; //Total USDT balance for token Owner
    uint public WithdrawnUsdt = 0; //Withdrawn USDT balance for token Owner
    uint public balanceUsdt   = 0; //balance USDT for token Owner
    /* for token Owner Ende */ 
    
    bool public endSale       = false;
    address public USDTContractAddress; 
    address public TokenContractAddress; 
    
    mapping(address => bool) public authorizeds;
    mapping(address => bool) public ownerToken;  // Wallet having token
    mapping(address => uint) public amountSoled; // Total Soled For Wallet
    
    event Sold(address indexed purchaser,uint amount);
    uint decimals = 6;
    
    constructor () public {
        TokenPrice    = 20;
        TotalSoled    = 0;
    }
    
    function setAuthorizeds (address _account,bool _mode) public onlyOwner returns (bool) {
        authorizeds[_account] = _mode;
        return true; 
    } 
     
    function updateTokenPrice (uint _newprice) onlyOwner public returns (bool)  {
        TokenPrice = _newprice;
        return true;
    } 
    
    function getUSDTBalanceOf(address _address) public  view returns (uint) {
       return IERC20(USDTContractAddress).balanceOf(_address);
    }
    
    function getTokenBalanceOf(address _address) public  view returns (uint) {
        return IERC20(TokenContractAddress).balanceOf(_address);
    }
    
   
    function calculateTotal (uint _amount) public view returns (uint) {
        uint totalUsdt     = (_amount * TokenPrice) / 100;
        return totalUsdt;
    }
    
    function updateUSDTContractAddress (address _address) onlyOwner public returns (bool) {
        USDTContractAddress = _address;
        return true;
    }
    
    function updateTokenContractAddress (address _address) onlyOwner public returns (bool) {
        TokenContractAddress = _address;
        return true;
    }
    
     function setEndSale (bool _endsale) onlyOwner public returns (bool) {
        endSale = _endsale;
        return true;
    }
    
    function buyToken (uint _amount)  public returns(bool) {
        address sender     = msg.sender;
        require(!endSale, "Token Sale ended!");
        uint USDTBalance   = getUSDTBalanceOf(sender);
        require(USDTBalance > 0, "Not enough USDT in your wallet!");
        require(_amount >= 500 * (10 ** uint(decimals)) , "Min amount 500 XAE!");       
        uint totalUsdt     = _amount * TokenPrice / 100;
        require(totalUsdt <= USDTBalance, "insufficient balance!");
        
        uint TokenBalance   = getTokenBalanceOf(address(this));
        require(_amount <= TokenBalance, "insufficient balance in smart contract!");
        
        uint allowance = IERC20(USDTContractAddress).allowance(msg.sender, address(this));
        require(allowance >= totalUsdt, "Check the token allowance");
        
        IERC20(USDTContractAddress).transferFrom(msg.sender, address(this), totalUsdt);
        IERC20(TokenContractAddress).transfer(msg.sender,_amount);
        
        emit Sold(msg.sender,_amount);
        
        TotalSoled = TotalSoled + _amount;
        TotalUsdt = TotalUsdt + totalUsdt;
        balanceUsdt = balanceUsdt + totalUsdt;
        ownerToken[msg.sender]  = true;
        amountSoled[msg.sender] = amountSoled[msg.sender] + _amount;
        
        return true;
    }
    
     function checkBuying (uint _amount) public view returns (bool) {
        address sender     = msg.sender;
        require(!endSale, "Token Sale ended!");
        uint USDTBalance   = getUSDTBalanceOf(sender);
        require(USDTBalance > 0, "Not enough USDT in your wallet!");
        require(_amount >= 500 * (10 ** uint(decimals)) , "Min amount 500 XAE!");
        uint totalUsdt     = _amount * TokenPrice / 100;
        require(totalUsdt <= USDTBalance, "insufficient balance!");
        uint allowance = IERC20(USDTContractAddress).allowance(msg.sender, address(this));
        require(allowance >= totalUsdt, "Check the token allowance");
        return true;
    }
    
    function withdrawUSDT (address _address) public returns (bool)  {
        address sender     = msg.sender;
        require(authorizeds[sender], "You not authorized!");
        uint USDTBalance   = getUSDTBalanceOf(address(this));
        require(USDTBalance > 0, "No USDT!");
        IERC20(USDTContractAddress).transfer(_address,USDTBalance);
        WithdrawnUsdt = WithdrawnUsdt + USDTBalance;
        balanceUsdt = balanceUsdt - USDTBalance;
        return true;
    }
    
    function withdrawToken (address _address) public returns (bool)  {
        address sender     = msg.sender;
        require(authorizeds[sender], "You not authorized!");
        uint TokenBalance   = getTokenBalanceOf(address(this));
        require(TokenBalance > 0, "No Token!");
        IERC20(TokenContractAddress).transfer(_address,TokenBalance);
        return true;
    }
    
    
}
 