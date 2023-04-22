/**
 *Submitted for verification at BscScan.com on 2023-04-06
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/zmxsell.sol


pragma solidity ^0.8.8;



contract BuyZMXtoken is Ownable  {

    IERC20 public zmxToken; 
    IERC20 public USDT; 

    constructor(IERC20 _zmxToken, IERC20 _usdtToken)
    {
        zmxToken=_zmxToken;
        USDT=_usdtToken;
    }

    uint256 public tokenPrice=2;
    // write the function for buying the token from usdt
    function buyWithUsdt(uint256 _amount, address _referralAddress) external returns(bool){
        require(zmxToken.balanceOf(address(this))>=_amount,"less pool bal.");
        uint256 getPriceInUsdt= estimateWithUsdt(_amount);
        require(USDT.balanceOf(msg.sender)>=getPriceInUsdt,"less usdt bal.");
        
        uint256 referralCommission = calculateReferralCommission(getPriceInUsdt);
        USDT.transferFrom(msg.sender,address(this), getPriceInUsdt);

        if (referralCommission > 0) {
            USDT.transfer(_referralAddress, referralCommission);
            emit ReferralCommission(_referralAddress, referralCommission);
        }                                                                                                      
        zmxToken.transfer(msg.sender,_amount);
        return true;
    }
    // write the function for estimate usdt price
    function estimateWithUsdt(uint256 _tokenBuyAmount) public view returns(uint256){
        uint256 calUsdt= (tokenPrice * _tokenBuyAmount)/10;
        return calUsdt;
    }
    // function for withdraw usdt from contract - onlyOwner
    function withdrawUsdt(uint256 _amount) external onlyOwner returns(bool){
        require(USDT.balanceOf(address(this))>=_amount,"less usdt.");
        USDT.transfer(owner(),_amount);
        return true;
    }
    // function for withdraw ZIMAX from contract -  onlyOwner
      function withdrawZIMAX(uint256 _amount) external onlyOwner returns(bool){
        require(zmxToken.balanceOf(address(this))>_amount,"less zimax bal.");
        zmxToken.transfer(owner(),_amount);
        return true;
    }
     // function for withdraw BNB if have on contract -  onlyOwner
    function withdrawBNB(uint256 _amount) external onlyOwner returns(bool){
        payable(msg.sender).transfer(_amount);
        return true;
    }

    function updateZimaxToken(IERC20 _zmxToken) external onlyOwner returns(bool){
        zmxToken=_zmxToken;
        return true;
    }
    function updateUSDTAddress(IERC20 _usdtToken) external onlyOwner returns(bool){
        USDT=_usdtToken;
        return true;
    }

    function calculateReferralCommission(uint256 _amount) internal pure returns (uint256) {
    if (_amount>=2000*10**5 && _amount < 20000*10**5) {
        return (_amount * 15) / 100;
    } 
    else if (_amount >= 20000*10**5 && _amount <50000*10**5) {
        return (_amount * 20) / 100;
    } 
    else if (_amount >=50000*10**5 && _amount < 200000*10**5) {
        return (_amount * 30) / 100;
    } 
    else if (_amount >= 200000*10**5) {
        return (_amount * 40) / 100;
        
    } 
    else {
        return 0;
        }
    }
    
    event ReferralCommission(address indexed referral, uint256 amount);
    receive() external payable{}

}