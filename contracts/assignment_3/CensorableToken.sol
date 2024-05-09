// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

// import "hardhat/console.sol";

// Import BaseAssignment.sol
import "../BaseAssignment.sol";

contract CensorableToken is ERC20, AccessControl, Ownable, BaseAssignment {
    mapping(address => bool) public isBlacklisted;

    // Event emitted when an address is blacklisted
    event Blacklisted(address indexed account);

    // Event emitted when an address is removed from the blacklist
    event Unblacklisted(address indexed account);

    // Event emitted that checks _beforetokentransfer
    event BeforeTokenTransferCalled(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    // OpenZeppelin access control for blacklisting
    bytes32 public constant BLACK_ROLE = keccak256("BLACK_ROLE");

    constructor(
        address _validator,
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        address _initialOwner
    ) BaseAssignment(_validator) Ownable(_initialOwner) ERC20(_name, _symbol) {
        // console.log("Constructor begins!");
        // console.log(msg.sender);

        uint256 valQuota = 10 ether;
        // Mint quota of owner.
        uint256 ownerQuota = _initialSupply - valQuota;
        _mint(_initialOwner, ownerQuota);

        // Mint quota of validator.
        _mint(_validator, valQuota);

        // Using AccessControl is not allowed by validator,
	// but it is shown here how to implement it.


        // Grant the contract deployer the default admin role: 
        // it will be able to grant and revoke any roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        // Grant role to owner for (un)blacklisting.
        _grantRole(BLACK_ROLE, _initialOwner);

        // Grant role to validator for (un)blacklisting.
        _grantRole(BLACK_ROLE, _validator);

        // console.log("Constructor ended!");
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Function to blacklist an address
    // function blacklistAddress(address _account) external onlyRole(BLACK_ROLE) {
    function blacklistAddress(address _account) external {
        // if (!hasRole(BLACK_ROLE, msg.sender)) {
        //     revert();
        // }
        // require(hasRole(BLACK_ROLE, msg.sender), "Not allowed");

        require(
            isValidator(msg.sender) || msg.sender == owner(),
            "Not allowed"
        );

        // console.log("Blacklist / account %o / %o", isBlacklisted[_account], _account);

        // require(!isBlacklisted[_account], "Address is already blacklisted");
        isBlacklisted[_account] = true;
        emit Blacklisted(_account);

        // console.log("Blacklist!");
    }

    // Function to remove an address from the blacklist
    function unblacklistAddress(address _account) external {
    // function unblacklistAddress(address _account) external onlyRole(BLACK_ROLE) {
        // require(hasRole(BLACK_ROLE, msg.sender), "Not allowed");

        require(
            isValidator(msg.sender) || msg.sender == owner(),
            "Not allowed"
        );

        // console.log("UNBlacklist / account %o / %o", isBlacklisted[_account], _account);

        // require(isBlacklisted[_account], "Address is not blacklisted");
        isBlacklisted[_account] = false;
        emit Unblacklisted(_account);

        // console.log("UNBlacklist!");
    }

    // Overrides transfer function to check if sender or receiver is blacklisted
    function _update(
        address _from,
        address _to,
        uint256 _amount
    ) internal override {
        // console.log('_update');
        require(
            !isBlacklisted[_from],
            "Sender is blacklisted and cannot transfer tokens"
        );
        require(
            !isBlacklisted[_to],
            "Receiver is blacklisted and cannot receive tokens"
        );

        // console.log(isBlacklisted[_to]);
        // console.log(isBlacklisted[_from]);

        // Emit an event when _beforeTokenTransfer is called
        emit BeforeTokenTransferCalled(_from, _to, _amount);
        super._update(_from, _to, _amount);
    }
}
