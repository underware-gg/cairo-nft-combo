import { useEffect, useMemo, useState } from "react";
import { init, SchemaType, SDK } from "@dojoengine/sdk";
import { dojoConfig } from "../dojoConfig.ts";
import { addAddressPadding } from "starknet";
import { useDojo } from "./dojo/useDojo";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { useComponentValue } from "@dojoengine/react";
import { Entity } from "@dojoengine/recs";
import { getContractByName } from "@dojoengine/core";

interface Token {
  fieldOrder: string[];
  name: string;
  symbol: string;
  tokenId: string;
  decimals: string;
  contractAddress: string;
}

interface Balance {
  fieldOrder: string[];
  balance: string;
  type: string;
  tokenMetadata: Token;
}

interface Transfer {
  fieldOrder: string[];
  from: string;
  to: string;
  amount: string;
  type: string;
  executedAt: string;
  tokenMetadata: Token;
  transactionHash: string;
}

interface ERCSchemaType extends SchemaType {
  ERC: {
    Token: Token;
    Balance: Balance;
    Transfer: Transfer;
  };
}

// Generate with sozo or define Schema
// const schema: SchemaType = {
const schema: ERCSchemaType = {
  ERC: {
    Token: {
      fieldOrder: ["name", "symbol", "tokenId", "decimals", "contractAddress"],
      name: "",
      symbol: "",
      tokenId: "",
      decimals: "",
      contractAddress: "",
    },
    Balance: {
      fieldOrder: ["balance", "type", "tokenMetadata"],
      balance: "",
      type: "",
      tokenMetadata: {} as Token,
    },
    Transfer: {
      fieldOrder: ["from", "to", "amount", "type", "executedAt", "transactionHash", "tokenMetadata"],
      from: "",
      to: "",
      amount: "",
      type: "",
      executedAt: "",
      transactionHash: "",
      tokenMetadata: {} as Token,
    },
  },
};



// interface TokenConfig {
//   fieldOrder: string[];
//   tokenAddress: string;
//   minterContract: string;
//   mintedCount: string;
// }
// interface OZSchemaType extends SchemaType {
//   oz_token: {
//     TokenConfig: TokenConfig;
//   };
// }
// const oz_schema: OZSchemaType = {
//   oz_token: {
//     TokenConfig: {
//       fieldOrder: ["tokenAddress", "minterContract", "mintedCount"],
//       tokenAddress: "",
//       minterContract: "",
//       mintedCount: "",
//     },
//   },
// };



// Initialize the SDK




function Tokens() {
  const {
    account,
    setup: {
      client,
      clientComponents: { TokenConfig },
     },
  } = useDojo();

  //
  // TokenConfig model
  const character_contract = getContractByName(dojoConfig.manifest, "oz_token", "character")
  const entityId = useMemo(() => getEntityIdFromKeys([
    BigInt(character_contract?.address ?? 0),
  ]) as Entity, [character_contract?.address])
  const token_config = useComponentValue(TokenConfig, entityId);


  //
  // SDK
  const [sdk, setSdk] = useState<SDK<ERCSchemaType> | null>(null);
  useEffect(() => {
    const _init = async () => {
      console.log(`SDK INIT...`, dojoConfig)
      const sdk = await init<ERCSchemaType>(
        {
          client: {
            rpcUrl: dojoConfig.rpcUrl,
            toriiUrl: dojoConfig.toriiUrl,
            relayUrl: dojoConfig.relayUrl,
            worldAddress: dojoConfig.manifest.world.address,
          },
          domain: {
            name: "oz_token",
            version: "1.0",
            chainId: "KATANA_LOCAL",
            revision: "1",
          },
        },
        schema
      );
      setSdk(sdk)
      console.log(`>>>>> SDK OK :`, sdk)
    }
    _init()
  }, [])



  useEffect(() => {
    let _unsubscribe: (() => void) | undefined;
    const _subscribe = async () => {
      console.log(`SUBSCRIBING...`);
      const subscription = await sdk?.subscribeEntityQuery(
        {
          ERC: {
            Balance: {
              $: {
                where: {
                  // player: {
                  //   $is: addAddressPadding(
                  //     account.account.address
                  //   ),
                  // },
                },
              },
            },
          },
        },
        (response) => {
          if (response.error) {
            console.error(
              "Error setting up entity sync:",
              response.error
            );
          } else if (
            response.data &&
            response.data[0].entityId !== "0x0"
          ) {
            console.log(`SUB DATA:`, response.data)
          }
        },
        { logging: true }
      );
      _unsubscribe = () => subscription?.cancel();
    };
    if (sdk) _subscribe();
    return () => {
      if (_unsubscribe) {
        _unsubscribe();
      }
    };
  }, [sdk, account?.account.address]);



  return (
    <div className="bg-gray-800 shadow-md rounded-lg p-4 sm:p-6 mb-4 sm:mb-6 w-full sm:w-96 my-4 sm:my-8">
      <div>
        <div className="mb-3 sm:mb-4">
          Minted: {(token_config?.minted_count ?? 0n).toString()}
        </div>
        <button
          className="w-full bg-red-600 hover:bg-red-700 text-white font-bold py-1 px-2 sm:py-2 sm:px-4 text-sm sm:text-base rounded transition duration-300 ease-in-out"
          onClick={async () => { 
            await client.character.mint({
              account: account.account,
              recipient: BigInt(account.account.address),
            })
          }}
          disabled={BigInt(account?.account?.address ?? 0) == 0n}
        >
          Mint Character
        </button>
      </div>
    </div>
  );
}

export default Tokens;
