pub mod common {
    pub mod interface;
}

pub mod erc721 {
    pub mod interface;
    pub mod erc721_combo;
}

pub mod utils {
    pub mod renderer;
    pub mod encoder;
}

#[cfg(test)]
mod tests {
    pub mod test_info;
}
