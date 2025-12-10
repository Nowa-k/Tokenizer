// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    struct MintRequest {
        address to;
        uint256 amount;
        uint256 approvals;
        bool executed;
    }

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public requiredApprovals;

    uint256 private _mintRequestCounter;
    mapping(uint256 => MintRequest) public mintRequests;
    mapping(uint256 => mapping(address => bool)) public hasApproved;

    event MintProposed(uint256 indexed requestId, address indexed proposer, address indexed to, uint256 amount);
    event MintApproved(uint256 indexed requestId, address indexed owner, uint256 approvals);
    event MintExecuted(uint256 indexed requestId, address indexed to, uint256 amount);

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    constructor(address[] memory initialOwners, uint256 _requiredApprovals) ERC20("Fefe42", "F42") {
        require(initialOwners.length > 0, "Owners required");
        require(_requiredApprovals > 0 && _requiredApprovals <= initialOwners.length, "Invalid approvals");

        for (uint256 i = 0; i < initialOwners.length; i++) {
            address owner = initialOwners[i];
            require(owner != address(0), "Owner zero");
            require(!isOwner[owner], "Owner not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }

        // Le deployeur doit faire partie des owners pour recevoir l'offre initiale
        require(isOwner[msg.sender], "Deployer must be owner");

        requiredApprovals = _requiredApprovals;
        _mint(msg.sender, 1000 * 10 ** decimals()); // 1000 tokens au deployeur (owner)
    }


    /// @notice Propose un mint; le proposant signe automatiquement.
    function proposeMint(address to, uint256 amount) external onlyOwner returns (uint256 requestId) {
        require(to != address(0), "Invalid to");
        require(amount > 0, "Amount zero");

        requestId = ++_mintRequestCounter;
        MintRequest storage req = mintRequests[requestId];
        req.to = to;
        req.amount = amount;
        req.approvals = 1;

        hasApproved[requestId][msg.sender] = true;

        emit MintProposed(requestId, msg.sender, to, amount);
        emit MintApproved(requestId, msg.sender, req.approvals);

        // execution immediate si quorum atteint avec la signature du proposant
        if (req.approvals >= requiredApprovals) {
            _executeMint(requestId, req);
        }
    }

    /// @notice Approuve un mint deja propose; execute si quorum atteint.
    function approveMint(uint256 requestId) external onlyOwner {
        MintRequest storage req = mintRequests[requestId];
        require(req.to != address(0), "Unknown request");
        require(!req.executed, "Already executed");
        require(!hasApproved[requestId][msg.sender], "Already approved");

        hasApproved[requestId][msg.sender] = true;
        req.approvals += 1;

        emit MintApproved(requestId, msg.sender, req.approvals);

        if (req.approvals >= requiredApprovals) {
            _executeMint(requestId, req);
        }
    }

    function _executeMint(uint256 requestId, MintRequest storage req) internal {
        require(!req.executed, "Already executed");
        req.executed = true;
        _mint(req.to, req.amount);
        emit MintExecuted(requestId, req.to, req.amount);
    }

    // Helpers de lecture
    function getOwners() external view returns (address[] memory) {
        return owners;
    }
}