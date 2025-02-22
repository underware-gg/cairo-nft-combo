# nft_combo

A Cairo component that extends OpenZeppelin tokens with additional features.


## Features

### Extends [ERC-721](https://eips.ethereum.org/EIPS/eip-721): `IERC721Minter`

* Simple helpers for minting tokens.

```rust
#[starknet::interface]
pub trait IERC721Minter<TState> {
    // returns the maximum number of tokens that can be minted
    fn max_supply(self: @TState) -> u256;
    // returns the total number of existing tokens (minted minus burned)
    fn total_supply(self: @TState) -> u256;
    // returns the last minted token id
    fn last_token_id(self: @TState) -> u256;
    // returns true if minting is paused
    fn is_minting_paused(self: @TState) -> bool;

    ///--- internal (available to the contract only)
    // token initializer (extends OZ ERC721 initializer)
    fn initializer(ref self: TState,
        name: ByteArray,
        symbol: ByteArray,
        base_uri: ByteArray,
        contract_uri: ByteArray,
        max_supply: u256,
    );
    // mints the next token sequnetially, based on supply
    fn _mint_next(ref self: TState, recipient: ContractAddress) -> u256;
    // sets the maximum number of tokens that can be minted
    fn _set_max_supply(ref self: TState, max_supply: u256);
    // pauses/unpauses minting
    fn _set_minting_paused(ref self: TState, paused: bool);
    // panics if caller is not owner of the token
    fn _require_owner_of(self: @TState, caller: ContractAddress, token_id: u256) -> ContractAddress;
}
```

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

* Emit events that trigger indexers to refresh one tokens metadata.

```rust
#[starknet::interface]
pub trait IERC4906MetadataUpdate<TState> {
    // emits the `MetadataUpdate` event
    fn emit_metadata_update(ref self: TState, token_id: u256);
    // emits the `BatchMetadataUpdate` event
    fn emit_batch_metadata_update(ref self: TState, from_token_id: u256, to_token_id: u256);
}
```


### Implements [ERC-7572](https://eips.ethereum.org/EIPS/eip-7572): Contract-level metadata via `contractURI()`

* A default uri can be set at initialization or by `_set_contract_uri()`.
* `ERC721ComboHooksTrait::contract_uri()`: hook to provide dynamic, fully on-chain JSON contract metadata, bypassing the default stored uri.
* `emit_contract_uri_updated()`: Emits an `ContractURIUpdated` event to trigger indexers to refresh contract metadata.

```rust
#[starknet::interface]
pub trait IERC7572ContractMetadata<TState> {
    // returns the contract metadata (dynamic or stored)
    fn contract_uri(self: @TState) -> ByteArray;
    // emits the `ContractURIUpdated` event
    fn emit_contract_uri_updated(ref self: TState);
    
    ///--- internal (available to the contract only)
    // Sets the default stored contract URI.
    fn _set_contract_uri(ref self: TState, contract_uri: ByteArray);
    // Reads the default stored contract URI.
    fn _contract_uri(self: @TState) -> ByteArray;
}
```

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



### Implements [ERC-2981](https://eips.ethereum.org/EIPS/eip-2981): NFT Royalty Standard

* The OpenZeppelin [implementation](https://github.com/OpenZeppelin/cairo-contracts/blob/main/packages/token/src/common/erc2981/interface.cairo) was used as reference, but not included to avoid additional dependencies, and for simplicity.
* The fee **denominator** is constant `10_000` (same as the OZ implementations default). Meaning that for every `1%` fees, increase the **numerator** by `100`.
* It is acceptable market practice to set royalty fees between `2.5%` (numerator `250`) and `5%` (numerator `500`).
* The component will calculate royalties in this order...

1. Per-token royalty implemented in the contract by the hook `ERC721ComboHooksTrait::token_royalty(token_id) -> Option<RoyaltyInfo>`.
2. Default royalty implemented in the contract by the hook `ERC721ComboHooksTrait::default_royalty() -> Option<RoyaltyInfo>`.
3. Defautl royalty set with `_set_default_royalty()`.
4. If none is available, no royalties will be requested.

> IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. Marketplaces are [expected](https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments) to voluntarily pay royalties together with sales.

```rust
#[starknet::interface]
pub trait IERC2981RoyaltyInfo<TState> {
    // Returns how much royalty is owed and to whom, based on a sale price that may be denominated
    // in any unit of exchange. The royalty amount is denominated and should be paid in that same
    // unit of exchange.
    fn royalty_info(self: @TState, token_id: u256, sale_price: u256) -> (ContractAddress, u256);
    // Returns the royalty information that all ids in this contract will default to.
    // The returned tuple contains:
    // - `t.0`: The receiver of the royalty payment.
    // - `t.1`: The numerator of the royalty fraction.
    // - `t.2`: The denominator of the royalty fraction.
    fn default_royalty(self: @TState) -> (ContractAddress, u128, u128);
    // Returns the royalty information specific to a token.
    // If no specific royalty information is set for the token, the default is returned.
    // The returned tuple contains:
    // - `t.0`: The receiver of the royalty payment.
    // - `t.1`: The numerator of the royalty fraction.
    // - `t.2`: The denominator of the royalty fraction.
    fn token_royalty(self: @TState, token_id: u256) -> (ContractAddress, u128, u128);
    
    ///--- internal (available to the contract only)
    // Sets the royalty information that all ids in this contract will default to.
    // Requirements:
    // - `receiver` cannot be the zero address.
    // - `fee_numerator` cannot be greater than the fee denominator.
    fn _set_default_royalty(ref self: TState, receiver: ContractAddress, fee_numerator: u128);
    // Sets the default royalty percentage and receiver to zero.
    fn _delete_default_royalty(ref self: TState);
}
```




## `ERC721ComboComponent`

Implements the `ERC721ComboHooksTrait` in your contract, including only the functions you need to customize:

```rust
pub trait ERC721ComboHooksTrait<TContractState> {
    //
    // ERC-721 Metadata
    // Custom renderer for `token_uri()`, for fully on-chain metadata
    fn token_uri(self: @ComponentState<TContractState>, token_id: u256) -> Option<ByteArray> { (Option::None) }

    //
    // ERC-7572
    // Contract-level metadata
    fn contract_uri(self: @ComponentState<TContractState>) -> Option<ByteArray> { (Option::None)  }

    //
    // ERC-2981
    // Default royalty info
    fn default_royalty(self: @ComponentState<TContractState>, token_id: u256) -> Option<RoyaltyInfo> {
        (Option::None)
    }
    // Per-token royalty info
    fn token_royalty(self: @ComponentState<TContractState>, token_id: u256) -> Option<RoyaltyInfo> {
        (Option::None)
    }

    //
    // ERC721Component::ERC721HooksTrait
    fn before_update(ref self: ComponentState<TContractState>, to: ContractAddress, token_id: u256, auth: ContractAddress) {}
    fn after_update(ref self: ComponentState<TContractState>, to: ContractAddress, token_id: u256, auth: ContractAddress) {}
}
```

## Setup instructions:

> WIP!!!

* replace `ERC721MixinImpl` with `ERC721ComboMixinImpl`
* replace `ERC721InternalImpl` with `ERC721ComboInternalImpl`
* replace `erc721.initializer()` with `erc721_combo.initializer()`
* implement `ERC721ComboHooksTrait` (optional)
* import `ERC721ComboComponent::ERC721HooksImpl`
* remove `ERC721HooksEmptyImpl` or move your `ERC721HooksTrait` calls to `ERC721ComboHooksTrait`


```rust
fn dojo_init(ref self: ContractState) {
    let mut world = self.world(@"example");
    self.erc721_combo.initializer(
        TOKEN_NAME(),
        TOKEN_SYMBOL(),
        BASE_URI(),
        CONTRACT_URI(),
        MAX_SUPPLY(),
    );
}
```
