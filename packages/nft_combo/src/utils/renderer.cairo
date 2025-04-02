use crate::utils::encoder::{Encoder};
use starknet::{ContractAddress};
pub use graffiti::json::{JsonImpl, Attribute};

// Based on OpenSea metadata standards
// https://docs.opensea.io/docs/metadata-standards#metadata-structure
#[derive(Drop)]
pub struct TokenMetadata {
    pub token_id: u256,
    pub name: ByteArray,
    pub description: ByteArray,
    pub image: ByteArray,
    // optionals
    pub image_data: Option<ByteArray>,
    pub external_url: Option<ByteArray>,
    pub background_color: Option<ByteArray>,
    pub animation_url: Option<ByteArray>,
    pub youtube_url: Option<ByteArray>,
    pub attributes: Option<Span<Attribute>>,
    pub additional_metadata: Option<Span<Attribute>>,
}

// Based on OpenSea contract metadata standards
// https://docs.opensea.io/docs/contract-level-metadata
#[derive(Drop)]
pub struct ContractMetadata {
    pub name: ByteArray,
    pub symbol: ByteArray,
    pub description: ByteArray,
    // optionals
    pub image: Option<ByteArray>,
    pub banner_image: Option<ByteArray>,
    pub featured_image: Option<ByteArray>,
    pub external_link: Option<ByteArray>,
    pub collaborators: Option<Span<ContractAddress>>,
}

pub trait MetadataRendererTrait {
    fn render_token_metadata(metadata: TokenMetadata) -> ByteArray;
    fn render_contract_metadata(metadata: ContractMetadata) -> ByteArray;
}

pub impl MetadataRenderer of MetadataRendererTrait {
    fn render_token_metadata(metadata: TokenMetadata) -> ByteArray {
        let json = JsonImpl::new()
            .add("id", format!("{}", metadata.token_id))
            .add("name", metadata.name)
            .add("description", metadata.description)
            .add("image", metadata.image)
            .add_if_some("image_data", metadata.image_data)
            .add_if_some("external_url", metadata.external_url)
            .add_if_some("background_color", metadata.background_color)
            .add_if_some("animation_url", metadata.animation_url)
            .add_if_some("youtube_url", metadata.youtube_url)
            .add_if_some("metadata", MetadataHelper::_format_metadata(metadata.attributes, metadata.additional_metadata))
            .add_array_if_some("attributes", MetadataHelper::_create_traits_array(metadata.attributes));
        let result = json.build();
        (Encoder::encode_json(result, false))
    }
    fn render_contract_metadata(metadata: ContractMetadata) -> ByteArray {
        let json = JsonImpl::new()
            .add("name", metadata.name)
            .add("symbol", metadata.symbol)
            .add("description", metadata.description)
            .add_if_some("image", metadata.image)
            .add_if_some("banner_image", metadata.banner_image)
            .add_if_some("featured_image", metadata.featured_image)
            .add_if_some("external_link", metadata.external_link)
            .add_array_if_some("collaborators", MetadataHelper::_create_address_array(metadata.collaborators));
        let result = json.build();
        (Encoder::encode_json(result, false))
    }
}

#[generate_trait]
impl MetadataHelper of MetadataHelperTrait {
    fn _format_metadata(attributes1: Option<Span<Attribute>>, attributes2: Option<Span<Attribute>>) -> Option<ByteArray> {
        let mut json = JsonImpl::new();
        match attributes1 {
            Option::Some(attr) => {
                let mut n: usize = 0;
                while (n < attr.len()) {
                    let attr: @Attribute = attr.at(n);
                    json = json.add(attr.key.clone(), attr.value.clone());
                    n += 1;
                };
            },
            Option::None => {}
        };
        match attributes2 {
            Option::Some(attr) => {
                let mut n: usize = 0;
                while (n < attr.len()) {
                    let attr: @Attribute = attr.at(n);
                    json = json.add(attr.key.clone(), attr.value.clone());
                    n += 1;
                };
            },
            Option::None => {}
        };
        if (json.data.len() > 0) {
            (Option::Some(json.build()))
        } else {
            (Option::None)
        }
    }
    fn _create_traits_array(attributes: Option<Span<Attribute>>) -> Option<Span<ByteArray>> {
        (match attributes {
            Option::Some(attr) => {
                let mut result: Array<ByteArray> = array![];
                let mut n: usize = 0;
                while (n < attr.len()) {
                    let attr: @Attribute = attr.at(n);
                    let json = JsonImpl::new()
                        .add("trait", attr.key.clone())
                        .add("value", attr.value.clone());
                    result.append(json.build());
                    n += 1;
                };
                (Option::Some(result.span()))
            },
            Option::None => {(Option::None)}
        })
    }
    fn _create_address_array(addresses: Option<Span<ContractAddress>>) -> Option<Span<ByteArray>> {
        (match addresses {
            Option::Some(addresses) => {
                let mut result: Array<ByteArray> = array![];
                let mut n: usize = 0;
                while (n < addresses.len()) {
                    let addr: felt252 = (*addresses.at(n)).into();
                    result.append(format!("{:x}", addr));
                    n += 1;
                };
                (Option::Some(result.span()))
            },
            Option::None => {(Option::None)}
        })
    }

}
