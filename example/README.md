# Dojo OpenZeppelin Token contract example

Example project with ERC-20 and ERC-721 tokens.


## Running locally

### Terminal 1: Katana

```bash
# or...
./run_katana
```

### Terminal 2: Migration

Migration will publish your contracts to Katana, Slot or Starknet

```bash
# you can use the migrate script...
usage: ./migrate <PROFILE> [--offline] [--inspect] [--bindings]

# pass a profile...
./migrate dev
./migrate sepolia

# inspect only (will not migrate)
./migrate dev --inspect

# generate typescript bindings while building
./migrate dev --bindings

```

#### Terminal 3: Torii

The migrate script will create the torii config file to the profiel: `torii_PROFILE.toml`

```bash
# use the run_torii to start torii for a specific profile
./run_torii dev
```
