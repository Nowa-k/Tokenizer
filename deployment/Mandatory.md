# Fefe42 sur Sepolia – guide de deploiement via Remix & MetaMask

## Apercu rapide
- Contrat ERC20 `Fefe42` (`F42`)
- Offre initiale : 2000 F42 frappes pour le compte deployeur
- Proprietaire = deployeur, la fonction `mint` est accessible au seul owner pour emettre plus de tokens
- Reseau cible : Ethereum Sepolia (testnet)

## Prerequis
-   Remix.ide
-   Metamask

## Ajouter le contract dans Remix
Dans Remix > `File Explorer` <:
- Importer `code/Fefe42mandatory.sol` 
ou 
- Crée un fichier dans contracts copié/collé le fichier `code/Fefe42mandatory.sol`  

## Compilation
1) Dans l'onglet **Solidity Compiler**
2) **Compile Fefe42mandatory.sol**.

## Déploiement sur Sepolia
1) Aller dans l´onglet **Deploy & Run**  
2) Choisir l'environnement `Browser extension` : `Sepolia - MetaMask`
3) Contrat cible : `MyToken - Fefe42mandatory.sol`.
4) Cliquer **Deploy & Verify** puis signer dans MetaMask.  

## Verifier sur un explorateur
- Ouvrir [Sepolia Etherscan](https://sepolia.etherscan.io) et rechercher l adresse du contrat.

## Ajouter le token dans MetaMask
1) Dans MetaMask > `Import tokens`  
2) Coller l adresse du contrat, symbole `F42`, decimales `18`.  
3) Le solde doit afficher **2000 F42** sur le compte deployeur.

## Si le contract existe déjà
Remplir **At address** avec l'adresse du contract 

## Action à réaliser
1) Décimal : Vérifié que la comformité avec le déploiement du contract
2) Owner : Comparer l'adress du owner avec le déployeur
3) Symbol : Vérifier le symbol
4) totalSupply : Combien de token son disponible
5) Mint - Tester avec le propriétaire du contract et non propriétaire 
 - Pour 1000 tokens - mint -> 1000000000000000000000
6) Verifier totalSupply


## Infos utiles
- Source principale : `code/Fefe42mandatory.sol`
- Norme : ERC20
