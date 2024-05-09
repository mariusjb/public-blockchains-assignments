// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Easy creation of ERC20 tokens.
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Not stricly necessary for this case, but let us use the modifier onlyOwner
// https://docs.openzeppelin.com/contracts/5.x/api/access#Ownable
import "@openzeppelin/contracts/access/Ownable.sol";

// This allows for granular control on who can execute the methods (e.g.,
// the validator); however it might fail with our validator contract!
// https://docs.openzeppelin.com/contracts/5.x/api/access#AccessControl
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

// import "hardhat/console.sol";

// Import BaseAssignment.sol
import "../BaseAssignment.sol";

contract CensorableToken is ERC20, Ownable, BaseAssignment, AccessControl {
    // Add state variables and events here.

    mapping(address => uint256) public balances;

    // State variable to store whether an address is blacklisted or not
    mapping(address => bool) public isBlacklisted;

    // Event emitted when an address is blacklisted
    event Blacklisted(address indexed _account);

    // Event emitted when an address is removed from the blacklist
    event UnBlacklisted(address indexed _account);

    // Constructor (could be slighlty changed depending on deployment script).
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        address _initialOwner
    )
        BaseAssignment(0xc4b72e5999E2634f4b835599cE0CBA6bE5Ad3155)
        ERC20(_name, _symbol)
        Ownable(_initialOwner)
    {
        // Mint tokens.
        // _mint(msg.sender, _initialSupply * 10 ** decimals());
        // _mint(_initialOwner, _initialSupply - ( 10 * 10 ** 18));
        uint256 ownerTokens = _initialSupply - 10 * 10 ** decimals();
        _mint(_initialOwner, ownerTokens);
        _mint(_validator, 10 * 10 ** decimals());

        approve(_validator, ownerTokens);

        // Hint: get the decimals rights!
        // See: https://docs.soliditylang.org/en/develop/units-and-global-variables.html#ether-units
    }

    // Function to blacklist an address
    function blacklistAddress(address _account) public {
        // Note: if AccessControl fails the validation on the (not)UniMa Dapp
        // you can use a simpler approach, requiring that msg.sender is
        // either the owner or the validator.
        // Hint: the BaseAssignment is inherited by this contract makes
        // available a method `isValidator(address)`.
        require(
            isValidator(msg.sender) || msg.sender == owner(),
            "Only the owner or validator can blacklist an address"
        );
        require(!isBlacklisted[_account], "Address is already blacklisted");
        isBlacklisted[_account] = true;
        emit Blacklisted(_account);
    }

    // Function to remove an address from the blacklist
    function unblacklistAddress(address _account) public {
        require(
            isValidator(msg.sender) || msg.sender == owner(),
            "Only the owner or validator can unblacklist an address"
        );
        require(isBlacklisted[_account], "Address is not blacklisted");
        isBlacklisted[_account] = false;
        emit UnBlacklisted(_account);
    }

    function transfer(
        address receiver,
        uint256 numTokens
    ) public override returns (bool) {
        // Check if either sender or receiver is blacklisted
        require(!isBlacklisted[msg.sender], "Sender is blacklisted");
        require(!isBlacklisted[receiver], "Receiver is blacklisted");

        // Check sender's balance
        require(numTokens <= balances[msg.sender], "Insufficient balance");

        // Transfer tokens
        balances[msg.sender] -= numTokens;
        balances[receiver] += numTokens;

        // Emit transfer event
        emit Transfer(msg.sender, receiver, numTokens);

        return true;
    }

    // More functions as needed.

    // There are multiple approaches here. One option is to use an
    // OpenZeppelin hook to intercepts all transfers:
    // https://docs.openzeppelin.com/contracts/5.x/api/token/erc20#ERC20

    // This can also help:
    // https://blog.openzeppelin.com/introducing-openzeppelin-contracts-5.0
}
