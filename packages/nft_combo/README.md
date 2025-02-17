# nft_combo

A component that extends the Cairo OpenZeppelin token implementations with additional features.


## Features

### Extends [ERC-721](https://eips.ethereum.org/EIPS/eip-721)

* Additional function: `last_token_id()`: Returns the last minted token id, useful to mint sequentially.
* Additional function: `total_supply()`: Returns the total number of existing tokens (minted minus burned).
* Custom `token_uri()` hook: The OpenZeppelin ERC-721 [implementation](https://github.com/OpenZeppelin/cairo-contracts/blob/main/packages/token/src/erc721/erc721.cairo) provides a `token_uri()` that concatenates a constant pre-configured `base_uri` with the `token_id`, unsuitable for fully on-chain metadata. Implement the `token_uri()` hook to return a JSON string containing the token metadata.

Token metadata example (based on [OpenSea metadata standards](https://docs.opensea.io/docs/metadata-standards)):

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


### Implements [ERC-4906](https://eips.ethereum.org/EIPS/eip-4906): Metadata Update Extension

* Call the `metadata_update()` to emit an `MetadataUpdate` and trigger indexers to refresh one token's metadata.
* Call the `batch_metadata_update()` to emit a `BatchMetadataUpdate` and trigger indexers to refresh a range of tokens' metadata.


### Implements [ERC-7572](https://eips.ethereum.org/EIPS/eip-7572): Contract-level metadata via `contractURI()`

* Store a default uri at initalization to be returned by `contract_uri()`.
* Implement the `contract_uri()` hook to return a JSON string containing the contract metadata.
* Call the `contract_uri_updated()` to emit an `ContractURIUpdated` and trigger indexers to refresh contract metadata.

Contract metadata example (based on [EIP-7572](https://eips.ethereum.org/EIPS/eip-7572#schema-for-contracturi)):

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



## `ERC721ComboComponent`

This component implements the `ERC721ComboHooksTrait` to customize `token_uri()` and `contract_uri()`:

```rust
pub trait ERC721ComboHooksTrait<TContractState> {
    //
    // ERC-721 Metadata
    // Custom renderer for `token_uri()`
    // for fully on-chain metadata
    //
    fn token_uri(
        self: @ComponentState<TContractState>,
        token_id: u256,
    ) -> Option<ByteArray> { (Option::None) }

    //
    // ERC-7572
    // Contract-level metadata
    //
    fn contract_uri(
        self: @ComponentState<TContractState>,
    ) -> Option<ByteArray> { (Option::None)  }
}
```

### Setup instructions:

> WIP!!!

* replace `ERC721MixinImpl` with `ERC721ComboMixinImpl`
* replace `ERC721InternalImpl` with `ERC721ComboInternalImpl`
* replace `erc721.initializer()` with `erc721_combo.initializer()`
* implement `ERC721ComboHooksTrait` (optional)
* import `ERC721ComboComponent::ERC721HooksImpl`
* remove `ERC721HooksEmptyImpl` or move your `ERC721HooksTrait` calls to `ERC721ComboHooksTrait`

