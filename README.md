# cairo-nft-combo

A Cairo component extending OpenZeppelin ERC-721 tokens.

* Implements [ERC-7572](https://eips.ethereum.org/EIPS/eip-7572): Contract-level metadata
* Implements [ERC-4906](https://eips.ethereum.org/EIPS/eip-4906): Metadata Update Extension
* Implements [ERC-2981](https://eips.ethereum.org/EIPS/eip-2981): NFT Royalty Standard
* Fully on-chain metadata renderer with `ERC721ComboHooksTrait`
* New [ERC-721](https://eips.ethereum.org/EIPS/eip-721) extension `IERC721Minter`, including...
  * Token ID counter
  * Sequential minting with `_mint_next()`
  * **Reserved** supply and minting, with `_mint_next_reserved()`
  * Max supply control (or infinite) with `max_supply()` and `minted_supply()`
  * Token availability with `available_supply()`
  * Minting pause control

Next...

* ERC-1155 combo
* ERC-1155 example


## Contents

* [`/packages/nft_combo`](/packages/nft_combo/): The cairo `nft_combo` component
* [`/example`](/example/): A [Dojo](https://book.dojoengine.org/) project with ERC-721 and ERC-20 example tokens.
* [`/src5`](/src5/): SRC5 interface generators.


## Resources

* The [Dojo Book](https://book.dojoengine.org/)
* OpenZeppelin [Cairo Wizard](https://docs.openzeppelin.com/contracts-cairo/wizard)
* OpenZeppelin [Cairo Contracts](https://github.com/OpenZeppelin/cairo-contracts)
* OpenZeppelin ERC-721 component: [erc721.cairo](https://github.com/OpenZeppelin/cairo-contracts/blob/main/packages/token/src/erc721/erc721.cairo) / [erc20.cairo](https://github.com/OpenZeppelin/cairo-contracts/blob/main/packages/token/src/erc20/erc20.cairo)
* OpenZeppelin ERC-1155 component: [erc1155.cairo](https://github.com/OpenZeppelin/cairo-contracts/blob/main/packages/token/src/erc1155/erc1155.cairo)
* OpenZeppelin ERC-20 component: [erc20.cairo](https://github.com/OpenZeppelin/cairo-contracts/blob/main/packages/token/src/erc20/erc20.cairo)
