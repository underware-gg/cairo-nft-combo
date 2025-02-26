pub mod common {
    pub mod interface;
    pub mod renderer;
    pub mod encoding;
}

pub mod erc721 {
    pub mod interface;
    pub mod erc721_combo;
}

#[cfg(test)]
mod tests {
    pub mod test_info;
}
