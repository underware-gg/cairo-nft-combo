mod systems {
    mod actions;
    mod character;
    mod cash;
    mod components {
        mod erc721_hooks;
        mod coin_component;
        mod token_component;
    }
}

mod models {
    mod store;
    mod coin_config;
    mod token_config;
    mod starter;
}

#[cfg(test)]
mod tests {
    mod test_cash;
    mod test_character;
    mod test_world;
    mod utils;
}
