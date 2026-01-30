# Moon Token (Tokenizer)

## But du projet
Construire et déployer un token sur la blockchain. Pour comprendre le cycle complet : écriture du smart contract, compilation, déploiement et utilisation.

## Information
- Projet réalisé sur la blockchain Sepolia
- Token basé sur ERC20

## Token(s) livrés
- Mandatory : `Fefe42` (`F42`) sur Sepolia. Fonction de base d'un token.
- Bonus : `FefeBonus42` (`FB42`) sur Sepolia – même base ERC20 mais frappe contrôlée par une multisig.

## Choix techniques
- Solidity `^0.8.20` : version récente, intègre les protections arithmétiques et est compatible avec OpenZeppelin v5.
- Standard ERC20 : c est le standard EVM le plus supporté (wallets, explorateurs, dApps, tooling). Il garantit l interopérabilité sans réinventer de logique de balances/transferts et bénéficie d audits communautaires massifs.
- OpenZeppelin : réutilisation des implémentations auditée (ERC20, Ownable) pour réduire les risques et accélérer le delivery.

## Réseau cible
- Ethereum Sepolia (testnet). Compilation et deployement fait par Remix.
Dans Etherscan vérifié le contract
- Fefe42: 
- FefeBonus42: 


## Déploiement & usage
- Suivre `deployment/Mandatory.md` pour la version simple, `deployment/Bonus.md` pour la multisig (remplir `initialOwners` + `requiredApprovals`).
- Après déploiement, ajouter l adresse du contrat dans MetaMask et vérifier sur Etherscan Sepolia (onglet Read/Write + Events).
