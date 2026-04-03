// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFefe42 {
    // Appelle la fonction mint du token Fefe42 cible.
    function mint(address to, uint256 amount) external;
    // Recupere le nombre de decimales du token (normalement 18).
    function decimals() external view returns (uint8);
}

contract Fefe42MintMultisig {
    struct MintRequest {
        address to;
        uint256 amount;
        uint256 approvals;
        bool executed;
    }

    IFefe42 public immutable token;

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public requiredApprovals;

    uint256 private _mintRequestCounter;
    mapping(uint256 => MintRequest) public mintRequests;
    mapping(uint256 => mapping(address => bool)) public hasApproved;

    event MintProposed(
        uint256 indexed requestId,
        address indexed proposer,
        address indexed to,
        uint256 amountUnits
    );
    event MintApproved(uint256 indexed requestId, address indexed owner, uint256 approvals);
    event MintExecuted(uint256 indexed requestId, address indexed to, uint256 amountUnits);

    // Restreint l'appel aux adresses declarees comme owners multisig.
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    // Initialise le multisig: token cible, owners autorises et seuil de validation.
    // Le seuil doit etre au minimum 2 et au maximum le nombre total d'owners.
    constructor(address tokenAddress, address[] memory initialOwners, uint256 _requiredApprovals) {
        require(tokenAddress != address(0), "Invalid token");
        require(initialOwners.length >= 2, "At least 2 owners required");
        require(
            _requiredApprovals >= 2 && _requiredApprovals <= initialOwners.length,
            "Invalid approvals"
        );

        token = IFefe42(tokenAddress);

        for (uint256 i = 0; i < initialOwners.length; i++) {
            address owner = initialOwners[i];
            require(owner != address(0), "Owner zero");
            require(!isOwner[owner], "Owner not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }

        require(isOwner[msg.sender], "Deployer must be owner");
        requiredApprovals = _requiredApprovals;
    }

    // Cree une demande de mint en "tokens entiers" (ex: 10) puis convertit en units.
    function proposeMintTokens(address to, uint256 tokens)
        external
        onlyOwner
        returns (uint256 requestId)
    {
        require(tokens > 0, "Tokens zero");
        uint256 amountUnits = tokens * (10 ** uint256(token.decimals()));
        return _proposeMintUnits(to, amountUnits);
    }

    // Cree une demande de mint directement en units (wei du token).
    function proposeMintUnits(address to, uint256 amountUnits)
        external
        onlyOwner
        returns (uint256 requestId)
    {
        return _proposeMintUnits(to, amountUnits);
    }

    // Enregistre une nouvelle demande et compte l'approbation du proposeur (1/requiredApprovals).
    // L'execution ne se fera qu'une fois le seuil atteint via approveMint(requestId).
    function _proposeMintUnits(address to, uint256 amountUnits)
        internal
        returns (uint256 requestId)
    {
        require(to != address(0), "Invalid to");
        require(amountUnits > 0, "Amount zero");

        requestId = ++_mintRequestCounter;

        MintRequest storage req = mintRequests[requestId];
        req.to = to;
        req.amount = amountUnits;
        req.approvals = 1;

        hasApproved[requestId][msg.sender] = true;

        emit MintProposed(requestId, msg.sender, to, amountUnits);
        emit MintApproved(requestId, msg.sender, req.approvals);

        if (req.approvals >= requiredApprovals) {
            _executeMint(requestId, req);
        }
    }

    // Ajoute l'approbation d'un owner sur une demande existante.
    // Si le nombre d'approbations atteint le seuil, le mint est execute.
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

    // Execute le mint une seule fois pour la demande.
    // Le multisig doit etre owner du token pour que cet appel reussisse.
    function _executeMint(uint256 requestId, MintRequest storage req) internal {
        require(!req.executed, "Already executed");
        req.executed = true;

        token.mint(req.to, req.amount);

        emit MintExecuted(requestId, req.to, req.amount);
    }

    // Renvoie la liste complete des owners multisig.
    function getOwners() external view returns (address[] memory) {
        return owners;
    }
}
