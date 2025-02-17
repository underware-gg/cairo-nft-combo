
use starknet::{ContractAddress};

// TODO: compute the correct ids
// https://docs.openzeppelin.com/contracts-cairo/0.20.0/introspection#computing_the_interface_id
pub const IERC4906_ID: felt252 = selector!("IERC4906_ID");
pub const IERC7572_ID: felt252 = selector!("IERC7572_ID");

//
// cloned from ERC721ABI:
// https://github.com/OpenZeppelin/cairo-contracts/blob/v0.20.0/packages/token/src/erc721/interface.cairo
//
#[starknet::interface]
pub trait IERC721ComboABI<TState> {
    //-----------------------------------
    // IERC721ComboABI
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
    // (IERC721CamelOnly)
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
    // (IERC721MetadataCamelOnly)
    fn tokenURI(self: @TState, tokenId: u256) -> ByteArray;
    // (IERC721Info)
    fn total_supply(self: @TState) -> u256;
    fn last_token_id(self: @TState) -> u256;
    //-----------------------------------
    // IERC4906MetadataUpdate
    fn metadata_update(ref self: TState, token_id: u256);
    fn batch_metadata_update(ref self: TState, from_token_id: u256, to_token_id: u256);
    //-----------------------------------
    // IERC7572ContractMetadata
    fn contract_uri(self: @TState) -> ByteArray;
    fn contractURI(self: @TState) -> ByteArray;
    fn contract_uri_updated(ref self: TState);
}

//
// ERC-721: Info extension
//
#[starknet::interface]
pub trait IERC721Info<TState> {
    fn total_supply(self: @TState) -> u256;
    fn last_token_id(self: @TState) -> u256;
}

//
// ERC-4906: Metadata Update Extension
// https://eips.ethereum.org/EIPS/eip-4906
//
#[starknet::interface]
pub trait IERC4906MetadataUpdate<TState> {
    // protected
    fn metadata_update(ref self: TState, token_id: u256);
    fn batch_metadata_update(ref self: TState, from_token_id: u256, to_token_id: u256);
}

//
// ERC-7572: Contract-level metadata
// https://eips.ethereum.org/EIPS/eip-7572
//
#[starknet::interface]
pub trait IERC7572ContractMetadata<TState> {
    fn contract_uri(self: @TState) -> ByteArray;
    fn contractURI(self: @TState) -> ByteArray;
    // protected
    fn contract_uri_updated(ref self: TState);
}

