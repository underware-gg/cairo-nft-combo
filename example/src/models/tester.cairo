
#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Tester {
    #[key]
    pub key: felt252, // always 1
    //------
    pub skip_uri_hooks: bool,
}
