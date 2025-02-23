# cairo-nft-combo

A Cairo component that extends OpenZeppelin ERC-721 tokens with additional features.

* Extends [ERC-721](https://eips.ethereum.org/EIPS/eip-721): `IERC721Minter`
* Implements [ERC-7572](https://eips.ethereum.org/EIPS/eip-7572): Contract-level metadata
* Implements [ERC-4906](https://eips.ethereum.org/EIPS/eip-4906): Metadata Update Extension
* Implements [ERC-2981](https://eips.ethereum.org/EIPS/eip-2981): NFT Royalty Standard
* Next: Fully on-chain metadata renderer

Detailed features and instructions at [`/packages/nft_combo`](/packages/nft_combo/)


## Contents

* [`/packages/nft_combo`](/packages/nft_combo/): The cairo `nft_combo` component
* [`/example`](/example/): A [Dojo](https://book.dojoengine.org/) project with ERC-721 and ERC-20 example tokens.


## Resources

* The [Dojo Book](https://book.dojoengine.org/)
* OpenZeppelin [Cairo Wizard](https://docs.openzeppelin.com/contracts-cairo/wizard)
* OpenZeppelin [Cairo Contracts](https://github.com/OpenZeppelin/cairo-contracts)
* OpenZeppelin ERC-721 component: [erc721.cairo](https://github.com/OpenZeppelin/cairo-contracts/blob/main/packages/token/src/erc721/erc721.cairo) / [erc20.cairo](https://github.com/OpenZeppelin/cairo-contracts/blob/main/packages/token/src/erc20/erc20.cairo)
* OpenZeppelin ERC-1155 component: [erc1155.cairo](https://github.com/OpenZeppelin/cairo-contracts/blob/main/packages/token/src/erc1155/erc1155.cairo)
* OpenZeppelin ERC-20 component: [erc20.cairo](https://github.com/OpenZeppelin/cairo-contracts/blob/main/packages/token/src/erc20/erc20.cairo)
