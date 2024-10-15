# dojo-oz-token
Dojo OpenZeppelin ERC-721 Token sample


### Profiling

| Project State                    | Memory Usage |
|----------------------------------|--------------|
| dojo_starter                     | 2.51 GB       |
| added openzeppelin dependency    | 3.35 GB       |



## OpenZeppelin samples

* Preset: [presets/erc721.cairo](https://github.com/OpenZeppelin/cairo-contracts/blob/main/packages/presets/src/erc721.cairo)

* Main component: [erc721.cairo](https://github.com/OpenZeppelin/cairo-contracts/blob/main/packages/token/src/erc721/erc721.cairo)

* Enumerable component (not used): [erc721_enumerable.cairo](https://github.com/OpenZeppelin/cairo-contracts/blob/main/packages/token/src/erc721/extensions/erc721_enumerable/erc721_enumerable.cairo)

* [Wizard](https://docs.openzeppelin.com/contracts-cairo/0.17.0/wizard)



## OpenZeppelin setup

| OpenZeppelin Version | Scarb Version |
|----------------------|----------------|
| v0.17.0              | 2.8.2          |
| v0.16.0              | 2.8.0          |
| v0.15.1              | 2.7.0          |

* Cloned [OpenZeppelin](https://github.com/OpenZeppelin/cairo-contracts) to [underware-gg](https://github.com/underware-gg/cairo-contracts)

* Fetch tags from upstream

```sh
cd cairo-contracts
git fetch --tags upstream
git push --tags
```

* Created `pistols` branch over `v0.15.1` tag

```sh
cd cairo-contracts
git checkout v0.15.1
git branch pistols
git checkout pistols
git commit -m 'token_base' --allow-empty
git tag token_base
git push --set-upstream origin pistols
```

* (test later): Rebase `pistols` branch over `v0.XX.0` tag

```sh
cd cairo-contracts
git checkout pistols
git rebase --onto v0.Xx.0 origin/master
```



