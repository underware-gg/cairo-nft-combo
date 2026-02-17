# Agent Integration Guide for cairo-nft-combo

This guide provides instructions for AI agents on how to use the `nft_combo` package to build ERC-721 contracts on Starknet.

## Quick Start

### 1. Add Dependency

Add the following to `Scarb.toml`:

```toml
[dependencies]
nft_combo = { git = "https://github.com/underware-gg/cairo-nft-combo" }
openzeppelin = { version = "3.0.0" } # Earliest supported version is 1.0.0
```

### 2. Contract Template

Here is a complete example of a contract using `ERC721ComboComponent`.

```cairo
#[starknet::contract]
mod MyNFT {
    use starknet::ContractAddress;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc721::ERC721Component;
    use nft_combo::erc721::erc721_combo::ERC721ComboComponent;

    //
    // Components
    //
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: ERC721ComboComponent, storage: erc721_combo, event: ERC721ComboEvent);

    //
    // Impls
    //
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721ComboMixinImpl = ERC721ComboComponent::ERC721ComboMixinImpl<ContractState>;

    //
    // Internal Impls
    //
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;
    impl ERC721ComboInternalImpl = ERC721ComboComponent::InternalImpl<ContractState>;

    //
    // Storage
    //
    #[storage]
    struct Storage {
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        erc721_combo: ERC721ComboComponent::Storage,
    }

    //
    // Events
    //
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        ERC721ComboEvent: ERC721ComboComponent::Event,
    }

    //
    // Constructor
    //
    #[constructor]
    fn constructor(
        ref self: ContractState,
        owner: ContractAddress,
    ) {
        let name = "My NFT";
        let symbol = "NFT";
        let base_uri = "https://api.example.com/metadata/";
        let contract_uri = "https://api.example.com/contract.json";
        
        // Initialize Combo Component (handles ERC721 init as well)
        self.erc721_combo.initializer(
            name, 
            symbol, 
            Option::Some(base_uri),
            Option::Some(contract_uri),
            Option::Some(1000) // Max supply, or Option::None for unlimited supply.
        );

        // Mint reserved tokens (optional)
        // self.erc721_combo._set_reserved_supply(100);
    }
}
```

## detailed Usage

### Hooks (ERC721ComboHooksTrait)

To customize metadata or royalties, implement the `ERC721ComboHooksTrait` in your contract.

```cairo
    use nft_combo::erc721::erc721_combo::ERC721ComboComponent::{
        ERC721ComboHooksTrait,
        RoyaltyInfo
    };

    impl ERC721ComboHooksImpl of ERC721ComboHooksTrait<ContractState> {
        fn render_contract_uri(self: @ERC721ComboComponent::ComponentState<ContractState>) -> Option<ContractMetadata> {
            // https://docs.opensea.io/docs/contract-level-metadata
            let metadata: ContractMetadata = ContractMetadata {
                name: self.name(),
                symbol: self.symbol(),
                description: constants::METADATA_DESCRIPTION(),
                image: Option::Some(constants::CONTRACT_IMAGE()),
                banner_image: Option::Some(constants::BANNER_IMAGE()),
                featured_image: Option::None,
                external_link: Option::Some(constants::EXTERNAL_LINK()),
                background_color: Option::Some(constants::CONTRACT_COLOR()),
                collaborators: Option::None,
            };
            (Option::Some(metadata))
        }

        fn render_token_uri(self: @ERC721ComboComponent::ComponentState<ContractState>, token_id: u256) -> Option<TokenMetadata> {
            let self = self.get_contract(); // get the component's contract state
            let mut store: Store = StoreTrait::new(self.world_default());
            // gather data
            // Attributes appear in clients and marketplace
            let attributes: Array<Attribute> = array![
                Attribute {
                    key: "Status",
                    value: "Alive",
                },
                Attribute {
                    key: "Mood",
                    value: "Terrific",
                },
            ];
            // (optional) Additional metadata can be added, and are not displayed at marketplaces
            let additional_metadata: Array<Attribute> = array![
                Attribute {
                    key: "Licence",
                    value: "CC0-1.0",
                },
            ];
            // return the metadata to be rendered by the component
            // https://docs.opensea.io/docs/metadata-standards#metadata-structure
            let metadata: TokenMetadata = TokenMetadata {
                token_id,
                name: format!("Token #{}", token_id.low),
                description: constants::METADATA_DESCRIPTION(),
                image: Option::Some(constants::SVG_BASE64_ENCODED()),
                image_data: Option::None,
                external_url: Option::Some(constants::EXTERNAL_LINK()), // TODO: format external token link
                background_color: Option::Some("000000),
                animation_url: Option::None,
                youtube_url: Option::None,
                attributes: Option::Some(attributes),
                additional_metadata: Option::Some(additional_metadata),
            };
            (Option::Some(metadata))
        }
    }
```

### Public Interface (IERC721ComboABI)

The `ERC721ComboMixinImpl` exposes:
- **ERC-721**: Standard methods (`owner_of`, `transfer_from`, etc.)
- **ERC-721 Minter**:
    - `max_supply()`
    - `total_supply()`
    - `minted_supply()`
    - `last_token_id()`
    - `is_minting_paused()`
- **ERC-7572**: `contract_uri()`
- **ERC-2981**: `royalty_info()`, `default_royalty()`, `token_royalty()`

### Internal Functions

- `_mint_next(recipient)`: Mints the next sequential token ID.
- `_mint_next_reserved(recipient)`: Mints from the reserved supply.
- `_set_max_supply(option)`: Updates max supply.
- `_set_reserved_supply(amount)`: Updates reserved supply.
- `_set_minting_paused(bool)`: Pauses/unpauses minting.
- `_set_contract_uri(option)`: Updates contract URI.
- `_set_default_royalty(receiver, fee_numerator)`: Updates default royalties.

## Best Practices

- Always initialize the component in the constructor using `self.erc721_combo.initializer(...)`.
- Set a max supply in the constructor or use `Option::None` for unlimited supply.
- You must define minting permissions.
- Call `self.erc721_combo._mint_next(recipient)` for sequential minting (e.g., in a public `mint` function).
- Implement `ERC721ComboHooksTrait::render_contract_uri()` to customize contract metadata.
- Implement `ERC721ComboHooksTrait::render_token_uri()` to customize token metadata.
