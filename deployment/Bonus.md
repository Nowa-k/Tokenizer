# Fefe42 (bonus) - extension multisig du mint

## Objectif du bonus
Le bonus est une adaptation du mandatory:
- Le token reste celui du mandatory: `Fefe42` (`F42`) dans `code/Fefe42mandatory.sol`.
- Le bonus ajoute un contrat separé de gouvernance (`code/Fefe42bonus.sol`) qui impose plusieurs signatures pour autoriser `mint`.
- Le mint n'est plus controle par une seule clef apres transfert d'ownership.

## Architecture
- Contrat 1: `Fefe42` (mandatory), ERC20 + `Ownable`.
- Contrat 2: `Fefe42MintMultisig` (bonus), qui orchestre les demandes de mint:
  - `proposeMintTokens(to, tokens)` ou `proposeMintUnits(to, amountUnits)`
  - `approveMint(requestId)`
  - execution automatique quand `approvals >= requiredApprovals`


## Import et compilation
- `code/Fefe42bonus.sol`

## Deploiement sur Sepolia
1) Dans **Deploy & Run**, environnement `Injected Provider - MetaMask`.
2) Deployer `Fefe42 - Fefe42mandatory.sol`.
3) Noter l'adresse du token (`tokenAddress`).
4) Deployer `Fefe42MintMultisig - Fefe42bonusv2.sol` avec:
- `tokenAddress`: adresse du `Fefe42` deja deploye
- `initialOwners`: tableau d'adresses unique, ex:
`[0xOwnerA, 0xOwnerB, 0xOwnerC]`
- `_requiredApprovals`: ex `2`
5) Noter l'adresse du multisig (`multisigAddress`).
6) Sur `Fefe42`, appeler `transferOwnership(multisigAddress)` depuis l'owner actuel.

## Verification obligatoire (preuve bonus)
### 1) La config multisig est correcte
Sur `Fefe42MintMultisig` (Read):
- `getOwners()` renvoie les owners attendus
- `requiredApprovals()` renvoie le seuil choisi
- `isOwner(address)` confirme chaque owner

### 2) L'ownership du token a bien ete transferee
Sur `Fefe42` (Read):
- `owner()` doit etre `multisigAddress`

### 3) Un mint direct ne marche plus
- Tenter `mint(to, amount)` depuis un EOA owner historique sur `Fefe42`: revert attendu (car seul le multisig est owner).

### 4) Le mint multisig fonctionne
1) Owner A appelle `proposeMintTokens(to, tokens)`.
2) Recuperer `requestId` via event `MintProposed`.
3) Owner B (et autres si necessaire) appelle `approveMint(requestId)`.
4) Quand le seuil est atteint, event `MintExecuted` emis.
5) Verifier `balanceOf(to)` et `totalSupply()` sur `MyToken`.
