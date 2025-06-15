# nft_combo

A Cairo component extending OpenZeppelin ERC-721 tokens.


## Setup

### Contract dependencies

* Add to your `Scarb.toml` dependencies:

```toml
[dependencies]
openzeppelin_token = { git = "https://github.com/OpenZeppelin/cairo-contracts", tag = "v1.0.0" }
openzeppelin_introspection = { git = "https://github.com/OpenZeppelin/cairo-contracts", tag = "v1.0.0" }
nft_combo = { git = "https://github.com/underware-gg/cairo-nft-combo", tag = "v1.0.1"}
```

### Adding OpenZeppelin ERC-721 + `nft_combo` to a new contract:

* Copy the `IERC721ComboABI` section from [`erc721/interface.cairo`](/packages/nft_combo/src/erc721/interface.cairo) to your contract's interface (see [character](/example/src/systems/character.cairo) example).

* Copy the `ERC721` section from the [character](/example/src/systems/character.cairo) example to your contract's body.

* Implement the `ERC721ComboHooksTrait` if you need it (see [character](/example/src/systems/character.cairo) example).

* Call the combo initializer in your `constructor` or `dojo_init()`:


### Adding `nft_combo` to existing ERC-721 contract:

* replace `ERC721MixinImpl` with `ERC721ComboMixinImpl`.
* replace `ERC721InternalImpl` with `ERC721ComboInternalImpl`.
* replace `erc721.initializer()` with `erc721_combo.initializer()` (see above).
* import `ERC721ComboComponent::ERC721HooksImpl`.
* remove `ERC721HooksEmptyImpl`, if used.
* or move your `ERC721HooksTrait` calls to `ERC721ComboHooksTrait`.
* Implement an admin funciton to cal the combo initializer.


## Initializer

`nft-combo` offers a range of options for providing token and contract metadata, conbining the `intitializer()` function and `ERC721ComboHooksTrait`.

```rust
fn initializer(ref self: TState,
    name: ByteArray,
    symbol: ByteArray,
    base_uri: Option<ByteArray>,
    contract_uri: Option<ByteArray>,
    max_supply: Option<u256>,
);
```

The component will search for available options, in this preference...

### Option 1: nft-combo renders the metadata

```rust
fn dojo_init(ref self: ContractState) {
    self.erc721_combo.initializer(
        "My Token",   // token name
        "MY",         // token symbol
        Option::None, // use hooks
        Option::None, // use hooks
        Option::None, // infinite supply
    );
}

pub impl ERC721ComboHooksImpl of ERC721ComboComponent::ERC721ComboHooksTrait<ContractState> {
    fn render_contract_uri(self: @ERC721ComboComponent::ComponentState<ContractState>) -> Option<ContractMetadata> {
        // add only the data you need...
        let metadata = ContractMetadata {
            name: self.name(),
            symbol: self.symbol(),
            description: "This is a test token",
            image: Option::Some("https://example.underware.gg/image.png"),
            banner_image: Option::None,
            featured_image: Option::None,
            external_link: Option::Some("https://example.underware.gg"),
            collaborators: Option::Some(array![starknet::contract_address_const::<0xabcd>()].span()),
        };
        (Option::Some(metadata))
    }
    fn render_token_uri(self: @ERC721ComboComponent::ComponentState<ContractState>, token_id: u256) -> Option<TokenMetadata> {
        // add only the data you need...
        let attributes: Array<Attribute> = array![
            Attribute {
                key: "Mood",
                value: "Terrific",
            },
        ];
        let additional_metadata: Array<Attribute> = array![
            Attribute {
                key: "Licence",
                value: "CC0-1.0",
            },
        ];
        let metadata = TokenMetadata {
            token_id,
            name: format!("{} #{}", self.name(), token_id),
            description: "This is a test token",
            image: Option::Some("https://example.underware.gg/image.png"),
            image_data: Option::None,
            external_url: Option::Some("https://example.underware.gg"),
            background_color: Option::Some("0x000000"),
            animation_url: Option::None,
            youtube_url: Option::None,
            attributes: Option::Some(attributes.span()),
            additional_metadata: Option::Some(additional_metadata.span()),
        };
        (Option::Some(metadata))
    }
}
```

### Option 2: Provide your own renderered metadata

```rust
fn dojo_init(ref self: ContractState) {
    self.erc721_combo.initializer(
        "My Token",   // token name
        "MY",         // token symbol
        Option::None, // use hooks
        Option::None, // use hooks
        Option::None, // infinite supply
    );
}

pub impl ERC721ComboHooksImpl of ERC721ComboComponent::ERC721ComboHooksTrait<ContractState> {
    fn contract_uri(self: @ERC721ComboComponent::ComponentState<ContractState>) -> Option<ByteArray> {
        // render your own on-chain metadata
        let uri = format!("data:application/json,{{\"name\":\"{} ERC-721 token\"}}", self.name());
        (Option::Some(uri))
        // or use off-chain metadata...
        // (Option::Some("https://example.underware.gg/contract.json"))
    }
    fn token_uri(self: @ERC721ComboComponent::ComponentState<ContractState>, token_id: u256) -> Option<ByteArray> {
        // render your own on-chain metadata
        let uri = format!("data:application/json,{{\"name\":\"{} #{}\"}}", self.name(), token_id);
        (Option::Some(uri))
        // or use off-chain metadata...
        // (Option::Some("https://example.underware.gg/token/1.json"))
    }
}
```

### Option 3: Standard off-chain metadata, using `base_uri`.

```rust
fn dojo_init(ref self: ContractState) {
    self.erc721_combo.initializer(
        "My Token",   // token name
        "MY",         // token symbol
        Option::Some("https://example.underware.gg/token/"),
        Option::Some("https://example.underware.gg/contract.json"),
        Option::None, // infinite supply
    );
}
// token_uri(1) returns: "https://example.underware.gg/token/1"
```

### Option 4: Automatic metadata based on token name and id

```rust
fn dojo_init(ref self: ContractState) {
    self.erc721_combo.initializer(
        "My Token",   // token name
        "MY",         // token symbol
        Option::None, // automatic token metadata
        Option::None, // automatic contract metadata
        Option::None, // infinite supply
    );
}
// contract_uri() returns: "data:application/json,{"symbol":"MY","name":"My Token","description":"My Token ERC-721 token"}"
// token_uri(1) returns:  "data:application/json,{"id":"1","name":"My Token #1","description":"My Token ERC-721 token"}"
```


### Additional initialization

* Max supply: the maximum number of tokens that can be minted by `IERC721Minter`.
* Default royalty
* Pause minting

```rust
fn dojo_init(ref self: ContractState) {
    self.erc721_combo.initializer(
        TOKEN_NAME(),
        TOKEN_SYMBOL(),
        Option::None(),
        Option::None(),
        Option::Some(1000), // max supply
    );
    // set default royalty to 5%, payable to 0x1234
    self.erc721_combo._set_default_royalty('0x1234', 500);
    // sometimes it's a good idea to deploy paused and unpause later
    self.erc721_combo._set_minting_paused(true);
}
```


## ERC-721: `IERC721Minter`

New [ERC-721](https://eips.ethereum.org/EIPS/eip-721) interface for supply control and minting helpers.

* Simple helpers for minting tokens.

```rust
#[starknet::interface]
pub trait IERC721Minter<TState> {
    // returns the maximum number of tokens that can be minted
    fn max_supply(self: @TState) -> u256;
    // returns the total number of existing tokens (minted minus burned)
    fn total_supply(self: @TState) -> u256;
    // returns the total number of minted tokens (same as last_token_id())
    fn minted_supply(self: @TState) -> u256;
    // returns the last minted token id
    fn last_token_id(self: @TState) -> u256;
    // returns true if minting is paused
    fn is_minting_paused(self: @TState) -> bool;
    // returns true if address is the owner of the token
    fn is_owner_of(self: @TState, address: ContractAddress, token_id: u256) -> bool;
    // returns true if the token exists (is owned)
    fn token_exists(self: @TState, token_id: u256) -> bool;
}
/// InternalImpl (available to the contract only)
#[starknet::interface]
pub trait IERC721MinterProtected<TState> {
    // token initializer (extends OZ ERC721 initializer)
    fn initializer(ref self: TState,
        name: ByteArray,
        symbol: ByteArray,
        base_uri: Option<ByteArray>,
        contract_uri: Option<ByteArray>,
        max_supply: Option<u256>,
    );
    // returns the stored default value of base_uri
    fn _base_uri(ref self: TState) -> ByteArray;
    // mints the next token sequnetially, based on supply
    fn _mint_next(ref self: TState, recipient: ContractAddress) -> u256;
    // sets the maximum number of tokens that can be minted (use Option::None for infinite supply)
    fn _set_max_supply(ref self: TState, max_supply: Option<u256>);
    // pauses/unpauses minting
    fn _set_minting_paused(ref self: TState, paused: bool);
    // panics if caller is not owner of the token
    fn _require_owner_of(self: @TState, caller: ContractAddress, token_id: u256) -> ContractAddress;
}
```

* Hooks to customize `token_uri()`. The OpenZeppelin ERC-721 [implementation](https://github.com/OpenZeppelin/cairo-contracts/blob/main/packages/token/src/erc721/erc721.cairo) concatenates a constant pre-configured `base_uri` with the `token_id`, unsuitable for fully on-chain metadata. The component will return in this precedence...

1. Implement the `ERC721ComboHooksTrait::render_token_uri()` hook to use a fully rendered JSON string, just by returning it's `TokenMetadata`.
2. Implement the `ERC721ComboHooksTrait::token_uri()` hook to render uri in the contract, returning the formatted url or json string.
3. Default, the concatenation of `base_uri` with the `token_id`.

Token metadata example (based on [OpenSea metadata standards](https://docs.opensea.io/docs/metadata-standards#metadata-structure)):

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


## ERC-7572: Contract-level metadata

Implements [ERC-7572](https://eips.ethereum.org/EIPS/eip-7572), with additional hooks to to customize `contract_uri()`.

The component will return in this precedence...

1. Implement the `ERC721ComboHooksTrait::render_contract_uri()` hook to use a fully rendered JSON string, just by returning it's `ContractMetadata`.
2. Implement the ERC721ComboHooksTrait::`contract_uri()` hook to render uri in the contract, returning the formatted url or json string.
3. Default uri set at initialization or by `_set_contract_uri()`.
4. Auto generated simple metadata based with token name and symbol.

* `emit_contract_uri_updated()`: Emits an `ContractURIUpdated` event to trigger indexers to refresh contract metadata.

```rust
#[starknet::interface]
pub trait IERC7572ContractMetadata<TState> {
    // returns the contract metadata
    fn contract_uri(self: @TState) -> ByteArray;
}
/// InternalImpl (available to the contract only)
#[starknet::interface]
pub trait IERC7572ContractMetadataProtected<TState> {
    fn _set_contract_uri(ref self: TState, contract_uri: Option<ByteArray>);
    // returns the stored default value of contract_uri URI
    fn _contract_uri(self: @TState) -> Option<ByteArray>;
    // emits the `ContractURIUpdated` event
    fn _emit_contract_uri_updated(ref self: TState);
}
```

Contract metadata example (based on [EIP-7572](https://eips.ethereum.org/EIPS/eip-7572#schema-for-contracturi) and [OpenSea contract metadata standards](https://docs.opensea.io/docs/contract-level-metadata)):

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

## ERC-4906: Metadata Update Extension

Implements [ERC-4906](https://eips.ethereum.org/EIPS/eip-4906).

* Emit events that trigger indexers to refresh one tokens metadata.

```rust
#[starknet::interface]
pub trait IERC4906MetadataUpdate<TState> {
}
/// InternalImpl (available to the contract only)
#[starknet::interface]
pub trait IERC4906MetadataUpdateProtected<TState> {
    // emits the `MetadataUpdate` event
    fn _emit_metadata_update(ref self: TState, token_id: u256);
    // emits the `BatchMetadataUpdate` event
    fn _emit_batch_metadata_update(ref self: TState, from_token_id: u256, to_token_id: u256);
}
```


## ERC-2981: NFT Royalty Standard

Implements [ERC-2981](https://eips.ethereum.org/EIPS/eip-2981) for NFT Royalty control, based on OpenZeppelin [erc2981](https://github.com/OpenZeppelin/cairo-contracts/blob/main/packages/token/src/common/erc2981/interface.cairo).

* It is acceptable market practice to set royalty fees between `2.5%` (numerator `250`) and `5%` (numerator `500`).
* The fee **denominator** is constant `10_000` (same as the OZ implementations default). For every `1%` fees, increase the **numerator** by `100`.
* The component will calculate royalties in this order...

1. Per-token royalty implemented in the contract by the hook `ERC721ComboHooksTrait::token_royalty(token_id) -> Option<RoyaltyInfo>`.
2. Default royalty implemented in the contract by the hook `ERC721ComboHooksTrait::default_royalty() -> Option<RoyaltyInfo>`.
3. Defautl royalty set with `_set_default_royalty()`.
4. If none is available, no royalties will be requested.

> IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. Marketplaces are [expected](https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments) to voluntarily pay royalties together with sales.

```rust
#[starknet::interface]
pub trait IERC2981RoyaltyInfo<TState> {
    /// Returns how much royalty is owed and to whom, based on a sale price that may be denominated
    /// in any unit of exchange. The royalty amount is denominated and should be paid in that same
    /// unit of exchange.
    fn royalty_info(self: @TState, token_id: u256, sale_price: u256) -> (ContractAddress, u256);
    /// Returns the royalty information that all ids in this contract will default to.
    /// The returned tuple contains:
    /// - `t.0`: The receiver of the royalty payment.
    /// - `t.1`: The numerator of the royalty fraction.
    /// - `t.2`: The denominator of the royalty fraction.
    fn default_royalty(self: @TState) -> (ContractAddress, u128, u128);
    /// Returns the royalty information specific to a token.
    /// If no specific royalty information is set for the token, the default is returned.
    /// The returned tuple contains:
    /// - `t.0`: The receiver of the royalty payment.
    /// - `t.1`: The numerator of the royalty fraction.
    /// - `t.2`: The denominator of the royalty fraction.
    fn token_royalty(self: @TState, token_id: u256) -> (ContractAddress, u128, u128);
}
/// InternalImpl (available to the contract only)
#[starknet::interface]
pub trait IERC2981RoyaltyInfoProtected<TState> {
    // Sets the royalty information that all ids in this contract will default to.
    // Requirements:
    // - `receiver` cannot be the zero address.
    // - `fee_numerator` cannot be greater than the fee denominator.
    fn _set_default_royalty(ref self: TState, receiver: ContractAddress, fee_numerator: u128);
    // Sets the default royalty percentage and receiver to zero.
    fn _delete_default_royalty(ref self: TState);
}
```


## The `ERC721ComboHooksTrait` hooks

Implement the `ERC721ComboHooksTrait` in your contract, including only the functions you need to customize:

```rust
pub trait ERC721ComboHooksTrait<TContractState> {
    //
    // ERC-721 Metadata
    // Custom token metadata, either...
    // 1. pass the metadata to be rendered by the component
    fn render_token_uri(
        self: @ComponentState<TContractState>,
        token_id: u256,
    ) -> Option<renderer::TokenMetadata> {(Option::None)}
    // 2. or pass the rendered uri, which can be a url or a json string prefixed with `data:application/json,`
    fn token_uri(
        self: @ComponentState<TContractState>,
        token_id: u256,
    ) -> Option<ByteArray> {(Option::None)}

    //
    // ERC-7572
    // Contract-level metadata, either...
    // 1. pass the metadata to be rendered by the component
    fn render_contract_uri(
        self: @ComponentState<TContractState>,
    ) -> Option<renderer::ContractMetadata> {(Option::None)}
    // 2. or pass the rendered uri, which can be a url or a json string prefixed with `data:application/json,`
    fn contract_uri(
        self: @ComponentState<TContractState>,
    ) -> Option<ByteArray> {(Option::None)}

    //
    // ERC-2981
    // Default royalty info
    fn default_royalty(
        self: @ComponentState<TContractState>,
        token_id: u256,
    ) -> Option<RoyaltyInfo> {(Option::None)}
    // Per-token royalty info
    fn token_royalty(
        self: @ComponentState<TContractState>,
        token_id: u256,
    ) -> Option<RoyaltyInfo> {(Option::None)}

    //
    // ERC721Component::ERC721HooksTrait
    fn before_update(
        ref self: ComponentState<TContractState>,
        to: ContractAddress,
        token_id: u256,
        auth: ContractAddress,
    ) {}
    fn after_update(
        ref self: ComponentState<TContractState>,
        to: ContractAddress,
        token_id: u256,
        auth: ContractAddress,
    ) {}
}
```
