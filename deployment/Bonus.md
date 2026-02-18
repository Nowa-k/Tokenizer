# Fefe42 (bonus) – deploiement et preuve de la multisig

## Apercu rapide
- Contrat ERC20 `FefeBonus42` (`FB42`)
- Offre initiale : 1000 FB42 frappes pour le deployeur (il doit faire partie des owners).
- Multisig : liste d'adresses owners + seuil `requiredApprovals` pour valider un mint.
- Source à utiliser : `code/Fefe42bonus.sol`.

## Prerequis
- Remix.ide
- Metamask
- Adresses des owners (incluant le compte deployeur) et choix du seuil d'approbation.

## Import et compilation
Dans Remix > `File Explorer` <: 
- Importer `code/Fefe42bonus.sol`
ou
- Crée un fichier dans contracts copié/collé le fichier `code/Fefe42mandatory.sol`  

## Compilation
1) Dans l'onglet **Solidity Compiler**
2) **Compile Fefe42bonus.sol**

## Déploiement sur Sepolia
1) Aller dans l´onglet  **Deploy & Run**.
2) Choisir l'environnement : `Injected Provider - MetaMask`.
3) Contrat cible : `MyToken - Fefe42bonus.sol`.
4) Renseigner dans constructeur :
   - `initialOwners` : tableau d'adresses entre crochets, ex `[0xOwner1, 0xOwner2]`
   ["0x880D30896Cb0C5c4F0f792624684993BDEb7eC25","0xb394D4e101B506057D1Ee116B240c5d57f2AcA92"]
   - `requiredApprovals` : le seuil d'approbation (>=1 et <= nombre d'owners), ex `2`.
5) Cliquer **Deploy** puis signer dans MetaMask
6) Recuperer l'adresse du contrat `0x833315E2CdbFfCdB100d1e7D255e88F231797B9f`

## Prouver que la multisig existe
- **Lire la config** : sur Remix (onglet `Deployed Contracts`) ou Etherscan > Read Contract :
  - `getOwners()` renvoie la liste des owners enregistres.
  - `requiredApprovals()` affiche le nombre de signatures necessaires.
  - `isOwner(address)` permet de verifier un owner en particulier.
- **Vérifier l'offre initiale au deployeur** : `balanceOf(deployerAddress)` doit retourner `1000 * 10^18`.
- **Tester le multisig** :
  1) Owner A appelle `proposeMint(to, amount)` et obtient un `requestId` (event `MintProposed`).
  2) Tant que `approvals < requiredApprovals`, l'appel `approveMint(requestId)` par un autre owner est requis. Chaque signature emet `MintApproved`.
  3) `MintExecuted` est lancé quand  `requiredApprovals` est bon.
  4) Verifier avec `balanceOf(to)` que le mint a eu lieu uniquement après assez de signatures.
- **Tracer les évenements** : sur Etherscan, onglet `Events`, montrer la suite `MintProposed` -> `MintApproved` -> `MintExecuted` pour prouver la coordination multisig.

## Ajouter le token dans MetaMask
1) MetaMask > `Import tokens`.
2) Coller l adresse du contrat, symbole `FB42`, decimales `18`.
3) Le solde du deployeur doit afficher 1000 F42.

