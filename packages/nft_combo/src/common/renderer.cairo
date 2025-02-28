use crate::common::encoder::{Base64Encoder};
use starknet::{ContractAddress};
pub use graffiti::json::{JsonImpl, Attribute};

#[derive(Drop)]
pub struct TokenMetadata {
    pub token_id: u256,
    pub name: ByteArray,
    pub description: ByteArray,
    pub image: ByteArray,
    pub attributes: Span<Attribute>,
    pub additional_metadata: Span<Attribute>,
}

#[derive(Drop)]
pub struct ContractMetadata {
    pub name: ByteArray,
    pub symbol: ByteArray,
    pub description: ByteArray,
    pub image: ByteArray,
    pub banner_image: ByteArray,
    pub featured_image: ByteArray,
    pub external_link: ByteArray,
    pub collaborators: Span<ContractAddress>,
}

pub trait MetadataRendererTrait {
    fn render_token_metadata(metadata: TokenMetadata) -> ByteArray;
    fn render_contract_metadata(metadata: ContractMetadata) -> ByteArray;
}

pub impl MetadataRenderer of MetadataRendererTrait {
    fn render_token_metadata(metadata: TokenMetadata) -> ByteArray {
        let json = JsonImpl::new()
            .add_if_not_null("id", format!("{}", metadata.token_id))
            .add_if_not_null("name", metadata.name)
            .add_if_not_null("description", metadata.description)
            .add_if_not_null("image", metadata.image)
            .add_if_not_null("metadata", MetadataHelper::_format_metadata(metadata.attributes, metadata.additional_metadata))
            .add_array("attributes", MetadataHelper::_create_traits_array(metadata.attributes));
        let result = json.build();
        (Base64Encoder::encode_json(result, false))
    }
    fn render_contract_metadata(metadata: ContractMetadata) -> ByteArray {
        let json = JsonImpl::new()
            .add_if_not_null("name", metadata.name)
            .add_if_not_null("symbol", metadata.symbol)
            .add_if_not_null("description", metadata.description)
            .add_if_not_null("image", metadata.image)
            .add_if_not_null("banner_image", metadata.banner_image)
            .add_if_not_null("featured_image", metadata.featured_image)
            .add_if_not_null("external_link", metadata.external_link)
            .add_array("collaborators", MetadataHelper::_create_address_array(metadata.collaborators));
        let result = json.build();
        (Base64Encoder::encode_json(result, false))
    }
}

#[generate_trait]
impl MetadataHelper of MetadataHelperTrait {
    fn _format_metadata(attributes1: Span<Attribute>, attributes2: Span<Attribute>) -> ByteArray {
        let mut json = JsonImpl::new();
        let mut n: usize = 0;
        while (n < attributes1.len()) {
            let attr: @Attribute = attributes1.at(n);
            json = json.add(attr.key.clone(), attr.value.clone());
            n += 1;
        };
        let mut n: usize = 0;
        while (n < attributes2.len()) {
            let attr: @Attribute = attributes2.at(n);
            json = json.add(attr.key.clone(), attr.value.clone());
            n += 1;
        };
        (json.build())
    }
    fn _create_traits_array(attributes: Span<Attribute>) -> Span<ByteArray> {
        let mut result: Array<ByteArray> = array![];
        let mut n: usize = 0;
        while (n < attributes.len()) {
            let attr: @Attribute = attributes.at(n);
            let json = JsonImpl::new()
                .add("trait", attr.key.clone())
                .add("value", attr.value.clone());
            result.append(json.build());
            n += 1;
        };
        (result.span())
    }
    fn _create_address_array(addresses: Span<ContractAddress>) -> Span<ByteArray> {
        let mut result: Array<ByteArray> = array![];
        let mut n: usize = 0;
        while (n < addresses.len()) {
            let addr: felt252 = (*addresses.at(n)).into();
            result.append(format!("{:x}", addr));
            n += 1;
        };
        (result.span())
    }

}
