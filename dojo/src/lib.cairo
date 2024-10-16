mod systems {
    mod actions;
    mod character;
    mod components {
        mod erc721_hooks;
        mod token_component;
    }
}

mod models {
    mod store;
    mod token_config;
    mod starter;
}

#[cfg(test)]
mod tests {
    mod test_character;
    mod test_world;
    mod utils;
}
