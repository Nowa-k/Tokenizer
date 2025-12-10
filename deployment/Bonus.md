# Fefe42 (bonus) – deploiement et preuve de la multisig

## Apercu rapide
- Contrat ERC20 `FefeBonus42` (`FB42`) avec frappe controlee par une multisig interne.
- Offre initiale : 1000 FB42 frappes pour le deployeur (il doit faire partie des owners).
- Multisig : liste d adresses owners + seuil `requiredApprovals` pour valider un mint.
- Source a utiliser : `code/Fefe42bonus.sol`.

## Prerequis
- MetaMask sur Sepolia avec quelques ETH de test.
- Remix ouvert (https://remix.ethereum.org).
- Adresses des owners (incluant le compte deployeur) et choix du seuil d approbation.

## Import et compilation
1) Remix > `File Explorer` > `Load a local file` > importer `code/Fefe42bonus.sol`.
2) Onglet **Solidity Compiler** > **Compile Fefe42bonus.sol**.

## Deploiement sur Sepolia
1) Onglet **Deploy & Run**.
2) Environnement : `Injected Provider - MetaMask`.
3) Contrat cible : `MyToken - Fefe42bonus.sol`.
4) Renseigner le constructeur :
   - `initialOwners` : tableau d adresses entre crochets, ex `[0xOwner1, 0xOwner2]`. Le compte MetaMask actif doit etre dans cette liste.
   - `requiredApprovals` : seuil d approbation (>=1 et <= nombre d owners), ex `2`.
5) Cliquer **Deploy** puis signer dans MetaMask.
6) Recuperer l adresse du contrat (panneau `Deployed Contracts`).

## Prouver que la multisig existe
- **Lire la config** : sur Remix (onglet `Deployed Contracts`) ou Etherscan > Read Contract :
  - `getOwners()` renvoie la liste des owners enregistres.
  - `requiredApprovals()` affiche le seuil de signatures necessaires.
  - `isOwner(address)` permet de verifier un owner en particulier.
- **Montrer l offre initiale au deployeur** : `balanceOf(deployerAddress)` doit retourner `1000 * 10^18`.
- **Demontrer le besoin de plusieurs signatures** :
  1) Owner A appelle `proposeMint(to, amount)` et obtient un `requestId` (event `MintProposed`).
  2) Tant que `approvals < requiredApprovals`, l appel `approveMint(requestId)` par un autre owner est requis. Chaque signature emet `MintApproved`.
  3) La frappe n est executee (`MintExecuted`) que lorsque le nombre d approbations atteint `requiredApprovals`.
  4) Verifier avec `balanceOf(to)` que le mint n a eu lieu qu apres assez de signatures.
- **Tracer les evenements** : sur Etherscan, onglet `Events`, montrer la suite `MintProposed` -> `MintApproved` -> `MintExecuted` pour prouver la coordination multisig.

## Ajouter le token dans MetaMask
1) MetaMask > `Import tokens`.
2) Coller l adresse du contrat, symbole `FB42`, decimales `18`.
3) Le solde du deployeur doit afficher 1000 F42.

## Rappels utiles
- Seul un owner peut proposer ou approuver un mint.
- Le deployeur doit etre dans `initialOwners` sinon le constructeur revert.
