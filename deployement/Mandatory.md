# Fefe42 sur Sepolia – guide de deploiement via Remix & MetaMask

## Apercu rapide
- Contrat ERC20 `Fefe42` (`F42`)
- Offre initiale : 1000 F42 frappes pour le compte deployeur (18 decimales)
- Proprietaire = deployeur, fonction `mint` accessible au seul owner pour emettre plus de tokens
- Reseau cible : Ethereum Sepolia (testnet)

## Prerequis
- Navigateur avec [MetaMask](https://metamask.io/) configure sur le reseau **Sepolia**
- Quelques ETH de test pour payer le gas (faucets Sepolia).
- [Remix](https://remix.ethereum.org) ouvert.

## Recuperer le contrat dans Remix
1) Dans Remix > `File Explorer` > `Load a local file` et importer `code/Fefe42.sol` depuis ce depot 

## Compilation
1) Onglet **Solidity Compiler**  
2) **Compile Fefe42.sol**.  

## Deploiement sur Sepolia
1) Onglet **Deploy & Run**  
2) Environnement : `Injected Provider - MetaMask` (Remix va utiliser le compte Sepolia actif).  
3) Contrat cible : `MyToken - Fefe42.sol`.
4) Cliquer **Deploy** puis signer dans MetaMask.  
5) Une fois mintee, copier l adresse du contrat (`Deployed Contracts` > copier l adresse).

## Ajouter le token dans MetaMask
1) Dans MetaMask > `Import tokens`  
2) Coller l adresse du contrat, symbole `F42`, decimales `18`.  
3) Le solde doit afficher **1000 F42** sur le compte deployeur.

## Verifier sur un explorateur
- Ouvrir [Sepolia Etherscan](https://sepolia.etherscan.io) et rechercher l adresse du contrat.

## Interagir apres deploiement
- Transfert standard ERC20 via MetaMask ou Etherscan (`transfer`).
- Frapper plus de tokens : fonction `mint(address to, uint256 amount)` depuis Remix/Etherscan, uniquement par le proprietaire.

## Infos utiles
- Source principale : `code/Fefe42.sol`
- Norme : ERC20
