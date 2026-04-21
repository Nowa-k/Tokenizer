# Mon Token (Tokenizer)

## But du projet
Construire et déployer un token sur la blockchain. Pour comprendre le cycle complet : écriture du smart contract, compilation, déploiement et utilisation.

## Information
- Projet réalisé sur la blockchain Sepolia
- Token basé sur ERC20

## Livrables
- Un token ERC20 : `Fefe42` (`F42`) sur Sepolia (`code/Fefe42mandatory.sol`).
- Un second contrat bonus : `Fefe42MintMultisig` (`code/Fefe42bonus.sol`) qui ajoute une validation multisignature pour `mint`.
- Le bonus ne crée pas un second token : il sécurise le mint du token `Fefe42` existant.

## Choix techniques
- Solidity `^0.8.20` : version récente, intègre les protections arithmétiques et est compatible avec OpenZeppelin v5.
- Standard ERC20 : c est le standard EVM le plus supporté (wallets, explorateurs, dApps, tooling). Il garantit l interopérabilité sans réinventer de logique de balances/transferts et bénéficie d audits communautaires massifs.
- OpenZeppelin : réutilisation des implémentations auditée (ERC20, Ownable) pour réduire les risques et accélérer le delivery.

## Réseau cible
- Ethereum Sepolia (testnet). Compilation et deployement fait par Remix.
Dans Etherscan vérifié le contract
- Fefe42 (token): 
- Fefe42MintMultisig (bonus): 


## Déploiement & usage
- Suivre `deployment/Mandatory.md` pour déployer le token `Fefe42`.
- Suivre `deployment/Bonus.md` pour déployer la multisig (`initialOwners` + `requiredApprovals`) puis transférer l'ownership du token au contrat multisig.
- Après déploiement, ajouter l'adresse du token dans MetaMask et vérifier les deux contrats sur Etherscan Sepolia (onglets Read/Write + Events).
