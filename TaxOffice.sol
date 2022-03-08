// SPDX-License-Identifier: MIT

/*

 /$$$$$$            /$$                   /$$                             /$$
 /$$__  $$          | $$                  | $$                            | $$
| $$  \__/  /$$$$$$ | $$   /$$  /$$$$$$  /$$$$$$    /$$$$$$  /$$$$$$/$$$$ | $$$$$$$
| $$       |____  $$| $$  /$$/ /$$__  $$|_  $$_/   /$$__  $$| $$_  $$_  $$| $$__  $$
| $$        /$$$$$$$| $$$$$$/ | $$$$$$$$  | $$    | $$  \ $$| $$ \ $$ \ $$| $$  \ $$
| $$    $$ /$$__  $$| $$_  $$ | $$_____/  | $$ /$$| $$  | $$| $$ | $$ | $$| $$  | $$
|  $$$$$$/|  $$$$$$$| $$ \  $$|  $$$$$$$  |  $$$$/|  $$$$$$/| $$ | $$ | $$| $$$$$$$/
 \______/  \_______/|__/  \__/ \_______/   \___/   \______/ |__/ |__/ |__/|_______/

    http://app.caketomb.finance
*/

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// File @openzeppelin/contracts/GSN/Context.sol@v3.4.2



pragma solidity >=0.6.0 <0.8.0;


// File @openzeppelin/contracts/access/Ownable.sol@v3.4.2



pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// File contracts/owner/Operator.sol



pragma solidity 0.6.12;


contract Operator is Context, Ownable {
    address private _operator;

    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);

    constructor() internal {
        _operator = _msgSender();
        emit OperatorTransferred(address(0), _operator);
    }

    function operator() public view returns (address) {
        return _operator;
    }

    modifier onlyOperator() {
        require(_operator == msg.sender, "operator: caller is not the operator");
        _;
    }

    function isOperator() public view returns (bool) {
        return _msgSender() == _operator;
    }

    function transferOperator(address newOperator_) public onlyOwner {
        _transferOperator(newOperator_);
    }

    function _transferOperator(address newOperator_) internal {
        require(newOperator_ != address(0), "operator: zero address given for new operator");
        emit OperatorTransferred(address(0), newOperator_);
        _operator = newOperator_;
    }
}


// File contracts/interfaces/ITaxable.sol



pragma solidity 0.6.12;

interface ITaxable {
    function setTaxTiersTwap(uint8 _index, uint256 _value) external returns (bool);

    function setTaxTiersRate(uint8 _index, uint256 _value) external returns (bool);

    function enableAutoCalculateTax() external;

    function disableAutoCalculateTax() external;

    function taxRate() external returns (uint256);

    function setTaxCollectorAddress(address _taxCollectorAddress) external;

    function setTaxRate(uint256 _taxRate) external;

    function setBurnThreshold(uint256 _burnThreshold) external;

    function excludeAddress(address _address) external returns (bool);

    function isAddressExcluded(address _address) external returns (bool);

    function includeAddress(address _address) external returns (bool);

    function setcaketombOracle(address _caketombOracle) external;

    function setTaxOffice(address _taxOffice) external;
}


// File contracts/TaxOffice.sol



pragma solidity 0.6.12;



contract TaxOffice is Operator {
    address public caketomb;

    constructor(address _caketomb) public {
        require(_caketomb != address(0), "caketomb address cannot be 0");
        caketomb = _caketomb;
    }

    function setTaxTiersTwap(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(caketomb).setTaxTiersTwap(_index, _value);
    }

    function setTaxTiersRate(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(caketomb).setTaxTiersRate(_index, _value);
    }

    function enableAutoCalculateTax() public onlyOperator {
        ITaxable(caketomb).enableAutoCalculateTax();
    }

    function disableAutoCalculateTax() public onlyOperator {
        ITaxable(caketomb).disableAutoCalculateTax();
    }

    function setTaxRate(uint256 _taxRate) public onlyOperator {
        ITaxable(caketomb).setTaxRate(_taxRate);
    }

    function setBurnThreshold(uint256 _burnThreshold) public onlyOperator {
        ITaxable(caketomb).setBurnThreshold(_burnThreshold);
    }

    function setTaxCollectorAddress(address _taxCollectorAddress) public onlyOperator {
        ITaxable(caketomb).setTaxCollectorAddress(_taxCollectorAddress);
    }

    function excludeAddressFromTax(address _address) external onlyOperator returns (bool) {
        return ITaxable(caketomb).excludeAddress(_address);
    }

    function includeAddressInTax(address _address) external onlyOperator returns (bool) {
        return ITaxable(caketomb).includeAddress(_address);
    }

    function setTaxablecaketombOracle(address _caketombOracle) external onlyOperator {
        ITaxable(caketomb).setcaketombOracle(_caketombOracle);
    }

    function transferTaxOffice(address _newTaxOffice) external onlyOperator {
        ITaxable(caketomb).setTaxOffice(_newTaxOffice);
    }
}
