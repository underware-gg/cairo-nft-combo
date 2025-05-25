# src5 interface ids

### Resources

* OpenZeppelin: [interface](https://github.com/OpenZeppelin/cairo-contracts/blob/main/packages/token/src/erc721/interface.cairo)
* OpenZeppelin: [Computing the interface ID](https://docs.openzeppelin.com/contracts-cairo/1.0.0/introspection#computing_the_interface_id)
* Tool: [src5-rs](https://github.com/ericnordelo/src5-rs)

## Generation...

Setup [src5-rs](https://github.com/ericnordelo/src5-rs)

```sh
cargo install src5-rs
```

Generate...

```sh
#
# baseline: matches OpenZeppelin
# https://github.com/OpenZeppelin/cairo-contracts/blob/release-v1.0.0/packages/token/src/common/erc2981/interface.cairo
#
src5_rs parse ./IERC2981RoyaltyInfo.cairo
+-----------------------------------------------------------------------+-------------------------------------------------------------------+
| SRC5 Function Signature:                                              | Extended Function Selector:                                       |
+-----------------------------------------------------------------------+-------------------------------------------------------------------+
| IERC2981RoyaltyInfo                                                   |                                                                   |
| royalty_info((u128,u128),(u128,u128))->(ContractAddress,(u128,u128))  | 0x2d3414e45a8700c29f119a54b9f11dca0e29e06ddcb214018fc37340e165ed6 |
| Id: 0x2d3414e45a8700c29f119a54b9f11dca0e29e06ddcb214018fc37340e165ed6 |                                                                   |
+-----------------------------------------------------------------------+-------------------------------------------------------------------+
```

```sh
src5_rs parse ./IERC7572ContractMetadata.cairo
+-----------------------------------------------------------------------+-------------------------------------------------------------------+
| SRC5 Function Signature:                                              | Extended Function Selector:                                       |
+-----------------------------------------------------------------------+-------------------------------------------------------------------+
| IERC7572ContractMetadata                                              |                                                                   |
| contract_uri()->(Array<bytes31>,felt252,usize)                        | 0x12c8405df0790491b695f1b5bf7d22c855ae0b1745deaa890f763bb9d0a06ca |
| Id: 0x12c8405df0790491b695f1b5bf7d22c855ae0b1745deaa890f763bb9d0a06ca |                                                                   |
+-----------------------------------------------------------------------+-------------------------------------------------------------------+
```
