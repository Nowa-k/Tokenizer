// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    // Le déployeur devient automatiquement owner
    constructor() ERC20("Fefe42", "F42") Ownable(msg.sender) {
        _mint(msg.sender, 1000 * 10 ** decimals()); // 1000 tokens au propriétaire
    }

    // (Optionnel) Donner la possibilité au propriétaire de frapper plus tard
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
