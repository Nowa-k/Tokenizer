# Fefe42 (bonus) - multisig pour securiser le mint

## Objectif
Le bonus ajoute un contrat `Fefe42MintMultisig` qui controle le `mint` du token `Fefe42`.
Apres transfert d'ownership du token vers le multisig, un seul wallet ne peut plus mint tout seul.

## Contrats utilises
- Token ERC20: `code/Fefe42mandatory.sol` (`Fefe42`)
- Multisig mint: `code/Fefe42bonus.sol` (`Fefe42MintMultisig`)

## Deploiement (Remix + MetaMask Sepolia)
1. Deployer `Fefe42`.
2. Noter `tokenAddress`.
3. Deployer `Fefe42MintMultisig` avec:
- `tokenAddress`: adresse du `Fefe42`
- `initialOwners`: ex. `[0xOwnerA,0xOwnerB,0xOwnerC]`
- `_requiredApprovals`: ex. `2`
4. Noter `multisigAddress`.
5. Sur `Fefe42`, appeler `transferOwnership(multisigAddress)`.

## Verifications prealables (obligatoires)
Sur `Fefe42MintMultisig`:
- `getOwners()` retourne bien les owners.
- `requiredApprovals()` retourne le seuil choisi.
- `isOwner(ownerX)` retourne `true` pour chaque owner.

Sur `Fefe42`:
- `owner()` doit etre `multisigAddress`.

## Preuve du mint multisig (propose + approve)
Exemple avec `requiredApprovals = 2`.

### Etape 1 - Owner A propose
Depuis Owner A, appeler:
- `proposeMintTokens(to, tokens)`
- exemple: `to = 0xBeneficiary`, `tokens = 50`

Effet attendu:
- event `MintProposed(requestId, proposer, to, amountUnits)`
- event `MintApproved(requestId, ownerA, 1)`
- `amountUnits = 50 * 10^18 = 50000000000000000000`

Verification de l'état:
- `mintRequests(requestId)` doit montrer:
  - `to = 0xBeneficiary`
  - `amount = 50000000000000000000`
  - `approvals = 1`
  - `executed = false`

### Etape 2 - Owner B approuve
Depuis Owner B, appeler:
- `approveMint(requestId)` 

Effet attendu (seuil atteint):
- event `MintApproved(requestId, ownerB, 2)`
- event `MintExecuted(requestId, to, amountUnits)`

Verification d'etat:
- `mintRequests(requestId).executed = true`

### Etape 3 - Preuve on-chain du mint
Sur `Fefe42`:
- `balanceOf(0xBeneficiary)` augmente de `50000000000000000000`
- `totalSupply()` augmente du meme montant

## Preuve qu'un mint direct est bloque
Tester sur `Fefe42` depuis un EOA (pas le multisig):
- appel `mint(to, amount)`
- resultat attendu: revert (`onlyOwner`)
