
#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Tester {
    #[key]
    pub key: felt252, // always 1
    //------
    pub enable_uri_hooks: bool,
    pub enable_default_royalty_hook: bool,
    pub enable_token_royalty_hook: bool,
}
