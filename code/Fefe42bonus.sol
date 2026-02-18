// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    // Une demande de mint suit un cycle: creation -> approbations -> execution.
    struct MintRequest {
        address to;          // Destinataire du mint
        uint256 amount;      // Quantite a frapper
        uint256 approvals;   // Nombre de signatures deja recues
        bool executed;       // True quand le mint a ete execute
    }

    // Configuration de la multisig.
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public requiredApprovals; // Quorum minimal pour executer un mint

    // Stockage des demandes de mint.
    uint256 private _mintRequestCounter;
    mapping(uint256 => MintRequest) public mintRequests;
    // hasApproved[requestId][owner] == true si cet owner a deja signe cette demande.
    mapping(uint256 => mapping(address => bool)) public hasApproved;

    // Evenements pour tracer toute la vie d'une demande.
    event MintProposed(uint256 indexed requestId, address indexed proposer, address indexed to, uint256 amount);
    event MintApproved(uint256 indexed requestId, address indexed owner, uint256 approvals);
    event MintExecuted(uint256 indexed requestId, address indexed to, uint256 amount);

    // Restreint l'appel aux adresses definies comme owners.
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    constructor(address[] memory initialOwners, uint256 _requiredApprovals) ERC20("FefeBonus42", "FB42") {
        // Le contrat doit avoir au moins un owner et un quorum valide.
        require(initialOwners.length > 0, "Owners required");
        require(_requiredApprovals > 0 && _requiredApprovals <= initialOwners.length, "Invalid approvals");

        // Enregistre chaque owner (non nul et unique).
        for (uint256 i = 0; i < initialOwners.length; i++) {
            address owner = initialOwners[i];
            require(owner != address(0), "Owner zero");
            require(!isOwner[owner], "Owner not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }

        // Le deployeur doit faire partie des owners pour recevoir l'offre initiale
        require(isOwner[msg.sender], "Deployer must be owner");

        requiredApprovals = _requiredApprovals; // Seuil de signatures a atteindre
        _mint(msg.sender, 1000 * 10 ** decimals()); // 1000 tokens au deployeur (owner)
    }


    /// @notice Propose un mint; le proposant signe automatiquement.
    function proposeMint(address to, uint256 amount) external onlyOwner returns (uint256 requestId) {
        // Parametres minimaux de la demande.
        require(to != address(0), "Invalid to");
        require(amount > 0, "Amount zero");

        // Cree une nouvelle demande avec un identifiant incremental.
        requestId = ++_mintRequestCounter;
        MintRequest storage req = mintRequests[requestId];
        req.to = to;
        req.amount = amount;
        req.approvals = 1; // Le proposant signe automatiquement

        hasApproved[requestId][msg.sender] = true;

        // Deux evenements: creation puis compteur d'approbations courant.
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
        // Verifie que la demande existe, qu'elle n'est pas deja executee,
        // et que ce owner n'a pas deja vote.
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
        req.executed = true; // Marque avant le mint pour bloquer toute re-execution
        _mint(req.to, req.amount);
        emit MintExecuted(requestId, req.to, req.amount);
    }

    // Helpers de lecture
    function getOwners() external view returns (address[] memory) {
        return owners;
    }
}
