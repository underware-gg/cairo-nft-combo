
use starknet::{ContractAddress};

// TODO: compute the correct ids
// https://docs.openzeppelin.com/contracts-cairo/1.0.0/introspection#computing_the_interface_id
pub const IERC721Minter_ID: felt252 = selector!("IERC721Minter_ID");

//
// cloned from ERC721ABI:
// https://github.com/OpenZeppelin/cairo-contracts/blob/v1.0.0/packages/token/src/erc721/interface.cairo
//
#[starknet::interface]
pub trait IERC721ComboABI<TState> {
    //-----------------------------------
    // IERC721ComboABI start
    //
    // (ISRC5)
    fn supports_interface(self: @TState, interface_id: felt252) -> bool;
    // (IERC721)
    fn balance_of(self: @TState, account: ContractAddress) -> u256;
    fn owner_of(self: @TState, token_id: u256) -> ContractAddress;
    fn safe_transfer_from(ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>);
    fn transfer_from(ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u256);
    fn approve(ref self: TState, to: ContractAddress, token_id: u256);
    fn set_approval_for_all(ref self: TState, operator: ContractAddress, approved: bool);
    fn get_approved(self: @TState, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(self: @TState, owner: ContractAddress, operator: ContractAddress) -> bool;
    // (CamelOnly)
    fn balanceOf(self: @TState, account: ContractAddress) -> u256;
    fn ownerOf(self: @TState, tokenId: u256) -> ContractAddress;
    fn safeTransferFrom(ref self: TState, from: ContractAddress, to: ContractAddress, tokenId: u256, data: Span<felt252>);
    fn transferFrom(ref self: TState, from: ContractAddress, to: ContractAddress, tokenId: u256);
    fn setApprovalForAll(ref self: TState, operator: ContractAddress, approved: bool);
    fn getApproved(self: @TState, tokenId: u256) -> ContractAddress;
    fn isApprovedForAll(self: @TState, owner: ContractAddress, operator: ContractAddress) -> bool;
    // (IERC721Metadata)
    fn name(self: @TState) -> ByteArray;
    fn symbol(self: @TState) -> ByteArray;
    fn token_uri(self: @TState, token_id: u256) -> ByteArray;
    // (CamelOnly)
    fn tokenURI(self: @TState, tokenId: u256) -> ByteArray;
    //-----------------------------------
    // IERC721Minter
    fn max_supply(self: @TState) -> u256;
    fn total_supply(self: @TState) -> u256;
    fn last_token_id(self: @TState) -> u256;
    fn is_minting_paused(self: @TState) -> bool;
    fn is_owner_of(self: @TState, address: ContractAddress, token_id: u256) -> bool;
    fn token_exists(self: @TState, token_id: u256) -> bool;
    // (CamelOnly)
    fn maxSupply(self: @TState) -> u256;
    fn totalSupply(self: @TState) -> u256;
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
    // IERC721ComboABI end
    //-----------------------------------
}


//
// ERC-721: Minter extension
//
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
