
use starknet::{ContractAddress};

// TODO: compute the correct ids
// https://docs.openzeppelin.com/contracts-cairo/1.0.0/introspection#computing_the_interface_id
pub const IERC1155Minter_ID: felt252 = selector!("IERC1155Minter_ID");

//
// cloned from ERC721ABI:
// https://github.com/OpenZeppelin/cairo-contracts/blob/v1.0.0/packages/token/src/erc1155/interface.cairo
//
#[starknet::interface]
pub trait IERC1155ComboABI<TState> {
    //-----------------------------------
    // IERC1155ComboABI start
    //
    // (ISRC5)
    fn supports_interface(self: @TState, interface_id: felt252) -> bool;
    // (IERC1155)
    fn balance_of(self: @TState, account: ContractAddress, token_id: u256) -> u256;
    fn balance_of_batch(
        self: @TState, accounts: Span<ContractAddress>, token_ids: Span<u256>,
    ) -> Span<u256>;
    fn safe_transfer_from(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        value: u256,
        data: Span<felt252>,
    );
    fn safe_batch_transfer_from(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        token_ids: Span<u256>,
        values: Span<u256>,
        data: Span<felt252>,
    );
    fn is_approved_for_all(
        self: @TState, owner: ContractAddress, operator: ContractAddress,
    ) -> bool;
    fn set_approval_for_all(ref self: TState, operator: ContractAddress, approved: bool);
    // (IERC1155Camel)
    fn balanceOf(self: @TState, account: ContractAddress, tokenId: u256) -> u256;
    fn balanceOfBatch(
        self: @TState, accounts: Span<ContractAddress>, tokenIds: Span<u256>,
    ) -> Span<u256>;
    fn safeTransferFrom(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        tokenId: u256,
        value: u256,
        data: Span<felt252>,
    );
    fn safeBatchTransferFrom(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        tokenIds: Span<u256>,
        values: Span<u256>,
        data: Span<felt252>,
    );
    fn isApprovedForAll(self: @TState, owner: ContractAddress, operator: ContractAddress) -> bool;
    fn setApprovalForAll(ref self: TState, operator: ContractAddress, approved: bool);
    // (IERC1155MetadataURI)
    // fn name(self: @TState) -> ByteArray;
    // fn symbol(self: @TState) -> ByteArray;
    fn uri(self: @TState, token_id: u256) -> ByteArray;
    //-----------------------------------
    // IERC1155Minter
    fn max_supply(self: @TState, tokenId: u256) -> u256;
    fn available_supply(self: @TState, tokenId: u256) -> u256;
    fn total_supply(self: @TState, tokenId: u256) -> u256;
    fn is_minting_paused(self: @TState) -> bool;
    fn is_minted_out(self: @TState, tokenId: u256) -> bool;
    fn is_owner_of(self: @TState, address: ContractAddress, token_id: u256) -> bool;
    // (CamelOnly)
    fn maxSupply(self: @TState, tokenId: u256) -> u256;
    fn availableSupply(self: @TStat, tokenId: u256e) -> u256;
    fn totalSupply(self: @TState, tokenId: u256) -> u256;
    //-----------------------------------
    // IERC7572ContractMetadata
    fn contract_uri(self: @TState) -> ByteArray;
    // (CamelOnly)
    fn contractURI(self: @TState) -> ByteArray;
    //-----------------------------------
    // IERC4906MetadataUpdate
    //-----------------------------------
    // IERC2981RoyaltyInfo
    fn royalty_info(self: @TState, token_id: u256, sale_price: u256) -> (ContractAddress, u256);
    fn default_royalty(self: @TState) -> (ContractAddress, u128, u128);
    fn token_royalty(self: @TState, token_id: u256) -> (ContractAddress, u128, u128);
    // (CamelOnly)
    fn royaltyInfo(self: @TState, token_id: u256, sale_price: u256) -> (ContractAddress, u256);
    fn defaultRoyalty(self: @TState) -> (ContractAddress, u128, u128);
    fn tokenRoyalty(self: @TState, token_id: u256) -> (ContractAddress, u128, u128);
    // IERC1155ComboABI end
    //-----------------------------------
}


//
// ERC-721: Minter extension
//
#[starknet::interface]
pub trait IERC1155Minter<TState> {
    // returns the maximum amount of tokens that can be minted
    fn max_supply(self: @TState) -> u256;
    // returns the amount of reserved tokens, minted only by _mint_next_reserved()
    fn reserved_supply(self: @TState) -> u256;
    // returns the amount of available tokens (max_supply - minted_supply - reserved_supply)
    fn available_supply(self: @TState) -> u256;
    // returns the total amount of minted tokens (same as last_token_id())
    fn minted_supply(self: @TState) -> u256;
    // returns the total amount of existing tokens (minted - burned)
    fn total_supply(self: @TState) -> u256;
    // returns the last minted token id
    fn last_token_id(self: @TState) -> u256;
    // returns true if minting is paused
    fn is_minting_paused(self: @TState) -> bool;
    // returns true if minted all of the supply
    fn is_minted_out(self: @TState) -> bool;
    // returns true if address is the owner of the token
    fn is_owner_of(self: @TState, address: ContractAddress, token_id: u256) -> bool;
    // returns true if the token exists (is owned)
    fn token_exists(self: @TState, token_id: u256) -> bool;
}
/// InternalImpl (available to the contract only)
#[starknet::interface]
pub trait IERC1155MinterProtected<TState> {
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
    // mints the next token sequentially, based on supply
    fn _mint_next(ref self: TState, recipient: ContractAddress) -> u256;
    // mints the next token sequentially, from reserved supply
    fn _mint_next_reserved(ref self: TState, recipient: ContractAddress) -> u256;
    // sets the maximum amount of tokens that can be minted
    fn _set_max_supply(ref self: TState, max_supply: u256);
    // sets the amount of reserved tokens, minted only by _mint_next_reserved()
    fn _set_reserved_supply(ref self: TState, reserved_supply: u256);
    // pauses/unpauses minting
    fn _set_minting_paused(ref self: TState, paused: bool);
    // panics if caller is not owner of the token
    fn _require_owner_of(self: @TState, caller: ContractAddress, token_id: u256) -> ContractAddress;
}
