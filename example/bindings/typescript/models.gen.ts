import type { SchemaType as ISchemaType } from "@dojoengine/sdk";

import { BigNumberish } from 'starknet';

// Type definition for `example::models::coin_config::CoinConfig` struct
export interface CoinConfig {
	coin_address: string;
	minter_address: string;
	faucet_amount: BigNumberish;
}

// Type definition for `example::models::coin_config::CoinConfigValue` struct
export interface CoinConfigValue {
	minter_address: string;
	faucet_amount: BigNumberish;
}

// Type definition for `example::models::token_config::TokenConfig` struct
export interface TokenConfig {
	token_address: string;
	minter_address: string;
	minted_count: BigNumberish;
}

// Type definition for `example::models::token_config::TokenConfigValue` struct
export interface TokenConfigValue {
	minter_address: string;
	minted_count: BigNumberish;
}

export interface SchemaType extends ISchemaType {
	example: {
		CoinConfig: CoinConfig,
		CoinConfigValue: CoinConfigValue,
		TokenConfig: TokenConfig,
		TokenConfigValue: TokenConfigValue,
	},
}
export const schema: SchemaType = {
	example: {
		CoinConfig: {
			coin_address: "",
			minter_address: "",
			faucet_amount: 0,
		},
		CoinConfigValue: {
			minter_address: "",
			faucet_amount: 0,
		},
		TokenConfig: {
			token_address: "",
			minter_address: "",
			minted_count: 0,
		},
		TokenConfigValue: {
			minter_address: "",
			minted_count: 0,
		},
	},
};
export enum ModelsMapping {
	CoinConfig = 'example-CoinConfig',
	CoinConfigValue = 'example-CoinConfigValue',
	TokenConfig = 'example-TokenConfig',
	TokenConfigValue = 'example-TokenConfigValue',
}