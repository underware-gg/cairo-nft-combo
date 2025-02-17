# nft_combo

A component for Cairo OpenZeppelin tokens including many useful NFT standards.


## Features

### [ERC-721](https://eips.ethereum.org/EIPS/eip-721): Custom `token_uri()`

The OpenZeppelin ERC721 implementation provides a `tokenURI()` that concatenates `base_uri()` and `token_id`, unsuitable for fully on-chain metadata.
Implement the `render_token_uri()` hook to return a JSON string containing the token metadata.

Example (based on [OpenSea metadata standards](https://docs.opensea.io/docs/metadata-standards)):

```json
{
  "id": "1",
  "name": "Duelist #1",
  "description": "Pistols at Dawn Duelist #1.",
  "image": "https://pistols.underware.gg/profiles/duelists/square/01.jpg",
  "attributes": [
    { "trait": "Name", "value": "Duke" },
    { "trait": "Honour", "value": "9.9" },
    { "trait": "Archetype", "value": "Honourable" }
  ]
}
```

### [ERC-7572](https://eips.ethereum.org/EIPS/eip-7572): Contract-level metadata via `contractURI()`

* Implement the `render_contract_uri()` hook to return a JSON string containing the contract metadata.

Example (based on [EIP-7572](https://eips.ethereum.org/EIPS/eip-7572#schema-for-contracturi)):

```json
{
  "name": "Example Contract",
  "symbol": "EC",
  "description": "Your description here",
  "image": "ipfs://QmTNgv3jx2HHfBjQX9RnKtxj2xv2xQCtbDXoRi5rJ3a46e",
  "banner_image": "ipfs://QmdChMVnMSq4U7oVKhud7wUSEZGnwuMuTY5rUQx57Ayp6H",
  "featured_image": "ipfs://QmS9m6e1E1NfioMM8dy1WMZNN2FRh2WDjeqJFWextqXCT8",
  "external_link": "https://project-website.com",
  "collaborators": ["0x388C818CA8B9251b393131C08a736A67ccB19297"]
}
```

* Call the `contract_uri_updated()` to emit an `ContractURIUpdated` event when indexers need to refresh contract metadata.


## `ERC721ComboComponent`

This component implements the `ERC721ComboHooksTrait` to customize `token_uri()` and `contract_uri()`:

```rust
pub trait ERC721ComboHooksTrait<TContractState> {
    //
    // ERC-721 Metadata
    // Custom renderer for `token_uri()`
    // for fully on-chain metadata
    //
    fn render_token_uri(
        self: @ComponentState<TContractState>,
        token_id: u256,
    ) -> ByteArray {""} // empty string fallback to ERC721Metadata

    //
    // ERC-7572
    // Contract-level metadata
    //
    fn render_contract_uri(
        self: @ComponentState<TContractState>,
    ) -> ByteArray {""}
}
```

### Setup instructions:

> WIP!!!

* replace `ERC721MixinImpl` with `ERC721ComboMixinImpl`
* replace `ERC721InternalImpl` with `ERC721ComboInternalImpl`
* replace `erc721.initializer()` with `erc721_combo.initializer()`

