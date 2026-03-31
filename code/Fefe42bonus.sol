// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/ERC20.sol";

contract FefeBonus is ERC20 {
    struct MintRequest {
        address to;
        uint256 amount;      // montant en "unités ERC20" (donc déjà *10**decimals)
        uint256 approvals;
        bool executed;
    }

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public requiredApprovals;

    uint256 private _mintRequestCounter;
    mapping(uint256 => MintRequest) public mintRequests;
    mapping(uint256 => mapping(address => bool)) public hasApproved;

    event MintProposed(uint256 indexed requestId, address indexed proposer, address indexed to, uint256 amountUnits);
    event MintApproved(uint256 indexed requestId, address indexed owner, uint256 approvals);
    event MintExecuted(uint256 indexed requestId, address indexed to, uint256 amountUnits);

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    constructor(address[] memory initialOwners, uint256 _requiredApprovals)
        ERC20("FefeBonus42", "FB42")
    {
        require(initialOwners.length > 0, "Owners required");
        require(_requiredApprovals > 0 && _requiredApprovals <= initialOwners.length, "Invalid approvals");

        for (uint256 i = 0; i < initialOwners.length; i++) {
            address owner = initialOwners[i];
            require(owner != address(0), "Owner zero");
            require(!isOwner[owner], "Owner not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }

        require(isOwner[msg.sender], "Deployer must be owner");
        requiredApprovals = _requiredApprovals;

        // ✅ 2000 tokens au deployeur
        _mint(msg.sender, 2000 * 10 ** decimals());
    }

    // ====== VERSION SIMPLE (tu donnes des TOKENS, pas des unités) ======
    function proposeMintTokens(address to, uint256 tokens) external onlyOwner returns (uint256 requestId) {
        require(tokens > 0, "Tokens zero");
        uint256 amountUnits = tokens * 10 ** decimals();
        return _proposeMintUnits(to, amountUnits);
    }

    // ====== VERSION "RAW" (tu donnes des unités ERC20 directement) ======
    function proposeMintUnits(address to, uint256 amountUnits) external onlyOwner returns (uint256 requestId) {
        return _proposeMintUnits(to, amountUnits);
    }

    function _proposeMintUnits(address to, uint256 amountUnits) internal returns (uint256 requestId) {
        require(to != address(0), "Invalid to");
        require(amountUnits > 0, "Amount zero");

        requestId = ++_mintRequestCounter;

        MintRequest storage req = mintRequests[requestId];
        req.to = to;
        req.amount = amountUnits;
        req.approvals = 1; // le proposeur approuve automatiquement

        hasApproved[requestId][msg.sender] = true;

        emit MintProposed(requestId, msg.sender, to, amountUnits);
        emit MintApproved(requestId, msg.sender, req.approvals);

        if (req.approvals >= requiredApprovals) {
            _executeMint(requestId, req);
        }
    }

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

    function getOwners() external view returns (address[] memory) {
        return owners;
    }
}
