import { useEffect, useMemo, useState } from "react";
import { useComponentValue } from "@dojoengine/react";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { getContractByName } from "@dojoengine/core";
import { dojoConfig } from "../dojoConfig.ts";
import { useDojo } from "./dojo/useDojo";
import { Entity } from "@dojoengine/recs";
// GraphQL client
import { ApolloClient, gql, InMemoryCache, useQuery } from "@apollo/client";
import { BigNumberish } from "starknet";

export const isBigint = (v: BigNumberish | null): boolean => {try {return (v != null && BigInt(v) >= 0n)} catch {return false}}
export const bigintToHex = (v: BigNumberish | null | undefined) => (!v ? '0x0' : `0x${BigInt(v).toString(16)}`)
export const isPositiveBigint = (v: BigNumberish | null): boolean => (isBigint(v) && BigInt(v ?? 0) > 0n)

//---------------------------
// Queries
//
const ercBalance = gql`
query erc_balance(
  $address: String
){
  ercBalance(
    accountAddress: $address
  ){
  	type
    balance
    tokenMetadata{
      name
      symbol
      tokenId
      decimals
      contractAddress
    }
  }
}
`;
const ercTransfer = gql`
query erc_transfer($address: String, $limit: Int){
  ercTransfer(
    accountAddress: $address
    limit: $limit
  ){
  	type
    from
    to
    amount
    executedAt
    transactionHash
    tokenMetadata{
      name
      symbol
      tokenId
      decimals
      contractAddress
    }
  }
}
`;

//---------------------------
// QL Client
// https://www.apollographql.com/docs/react/data/queries
//
export const ql_client = (GQLUrl: string) => {
  return new ApolloClient({
    uri: GQLUrl,
    defaultOptions: {
      watchQuery: {
        fetchPolicy: "no-cache",
        nextFetchPolicy: "no-cache",
      },
      query: {
        fetchPolicy: "no-cache",
      },
      mutate: {
        fetchPolicy: "no-cache",
      },
    },
    cache: new InMemoryCache({
      addTypename: false,
    }),
  });
};

type Variables = Record<string, string | number | number[] | boolean | null | undefined | Date>;
const useCustomQuery = (
  toriiUrl: string,
  query: any,
  variables?: Variables,
  skip?: boolean
) => {
  const client = useMemo(() => {
    return ql_client(toriiUrl);
  }, [toriiUrl]);
  const { data, refetch } = useQuery(query, {
    client: client,
    variables: variables,
    skip: skip,
  });
  return { data, refetch };
};


//---------------------------
// Torii data
//

export type ERC_Type = 'ERC20' | 'ERC721'

interface ERC_Token {
  name: string;
  symbol: string;
  decimals: number;
  contractAddress: bigint;
}
export type ERC20_Token = ERC_Token & {
  balance: bigint;
  balance_eth: bigint;
}
export type ERC721_Token = ERC_Token & {
  balance: bigint
  tokenIds: bigint[]
}
export type ERC_Tokens = {
  ERC20: ERC20_Token[],
  ERC721: ERC721_Token[],
}

export function useTokensByOwner(owner: BigNumberish) {
  const variables = useMemo(() => ({
    address: bigintToHex(owner).toLowerCase(),
  }), [owner]);
  const { data, refetch } = useCustomQuery(
    dojoConfig.toriiUrl+'/graphql',
    ercBalance,
    variables,
    !isPositiveBigint(owner)
  );
  const tokens = useMemo(() => {
    let tokens: ERC_Tokens = {
      ERC20: [],
      ERC721: [],
    }
    data?.ercBalance?.forEach((token: any) => {
      const type = token.type as ERC_Type
      const contractAddress = BigInt(token.tokenMetadata.contractAddress)
      let tokenIndex = tokens[type].findIndex(t => t.contractAddress === contractAddress)
      if (type === 'ERC20') {
        if (tokenIndex == -1) {
          tokens[type].push({
            name: token.tokenMetadata.name,
            symbol: token.tokenMetadata.symbol,
            decimals: Number(token.tokenMetadata.decimals),
            contractAddress,
            balance: 0n,
            balance_eth: 0n,
          })
          tokenIndex = tokens[type].length - 1
        }
        tokens[type][tokenIndex].balance += BigInt(token.balance)
        tokens[type][tokenIndex].balance_eth = (tokens[type][tokenIndex].balance / (10n ** BigInt(tokens[type][tokenIndex].decimals)))
      } else if (type === 'ERC721') {
        if (tokenIndex == -1) {
          tokens[type].push({
            name: token.tokenMetadata.name,
            symbol: token.tokenMetadata.symbol,
            decimals: Number(token.tokenMetadata.decimals),
            contractAddress,
            balance: 0n,
            tokenIds: [],
          })
          tokenIndex = tokens[type].length - 1
        }
        tokens[type][tokenIndex].balance++
        tokens[type][tokenIndex].tokenIds.push(BigInt(token.tokenMetadata.tokenId))
      }
    })
    // console.log(`TOKENS:`, tokens)
    return tokens;
  }, [data])
  return {
    tokens,
    refetch,
  }
}



function TokensQL() {
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
  // Tokens
  const { tokens, refetch } = useTokensByOwner(account?.account?.address ?? 0n)
  useEffect(() => {
    refetch?.()
  }, [refetch, token_config?.minted_count])

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
        {tokens.ERC721.map((token) => (
          <div key={token.symbol}>
            {token.symbol}: {token.balance.toString()} ({token.tokenIds.map(id => id.toString()).join(', ')})
          </div>
        ))}
        {tokens.ERC20.map((token) => (
          <div key={token.symbol}>
            {token.symbol}: {token.balance_eth.toString()}
          </div>
        ))}
      </div>
    </div>
  );
}

export default TokensQL;
