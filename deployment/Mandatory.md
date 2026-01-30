# Fefe42 sur Sepolia – guide de deploiement via Remix & MetaMask

## Apercu rapide
- Contrat ERC20 `Fefe42` (`F42`)
- Offre initiale : 1000 F42 frappes pour le compte deployeur (18 decimales)
- Proprietaire = deployeur, fonction `mint` accessible au seul owner pour emettre plus de tokens
- Reseau cible : Ethereum Sepolia (testnet)

## Prerequis
-   Remix.ide
-   Metamask
## Ajouter le contract dans Remix
Dans Remix > `File Explorer` > `Load a local file` et importer `code/Fefe42mandatory.sol`

## Compilation
1) Onglet **Solidity Compiler**
2) **Compile Fefe42mandatory.sol**.  

## 1er déploiement sur Sepolia
1) Onglet **Deploy & Run**  
2) Environnement : `Injected Provider - MetaMask` | `Sepolia - MetaMask`
3) Contrat cible : `MyToken - Fefe42mandatory.sol`.
4) Cliquer **Deploy & Verify** puis signer dans MetaMask.  

## Verifier sur un explorateur
- Ouvrir [Sepolia Etherscan](https://sepolia.etherscan.io) et rechercher l adresse du contrat.

## Ajouter le token dans MetaMask
1) Dans MetaMask > `Import tokens`  
2) Coller l adresse du contrat, symbole `F42`, decimales `18`.  
3) Le solde doit afficher **1000 F42** sur le compte deployeur.

## Si le contract existe déjà
1) Remplir **At address** avec l'adresse du contract 

## Interagir apres deploiement
- 
- 

## Infos utiles
- Source principale : `code/Fefe42mandatory.sol`
- Norme : ERC20
