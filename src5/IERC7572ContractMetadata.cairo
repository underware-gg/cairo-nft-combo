trait IERC7572ContractMetadata {
    // #[derive(Drop, PartialEq, starknet::Event)]
    // pub struct ContractURIUpdated {}

    fn contract_uri() -> ByteArray;
}
