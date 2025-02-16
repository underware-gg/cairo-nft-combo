import { DojoProvider, DojoCall } from "@dojoengine/core";
import { Account, AccountInterface, BigNumberish, CairoOption, CairoCustomEnum, ByteArray } from "starknet";
import * as models from "./models.gen";

export function setupWorld(provider: DojoProvider) {

	const build_cash_allowance_calldata = (owner: string, spender: string): DojoCall => {
		return {
			contractName: "cash",
			entrypoint: "allowance",
			calldata: [owner, spender],
		};
	};

	const cash_allowance = async (owner: string, spender: string) => {
		try {
			return await provider.call("example", build_cash_allowance_calldata(owner, spender));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cash_approve_calldata = (spender: string, amount: BigNumberish): DojoCall => {
		return {
			contractName: "cash",
			entrypoint: "approve",
			calldata: [spender, amount],
		};
	};

	const cash_approve = async (snAccount: Account | AccountInterface, spender: string, amount: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_cash_approve_calldata(spender, amount),
				"example",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_character_approve_calldata = (to: string, tokenId: BigNumberish): DojoCall => {
		return {
			contractName: "character",
			entrypoint: "approve",
			calldata: [to, tokenId],
		};
	};

	const character_approve = async (snAccount: Account | AccountInterface, to: string, tokenId: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_character_approve_calldata(to, tokenId),
				"example",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cash_balanceOf_calldata = (account: string): DojoCall => {
		return {
			contractName: "cash",
			entrypoint: "balanceOf",
			calldata: [account],
		};
	};

	const cash_balanceOf = async (account: string) => {
		try {
			return await provider.call("example", build_cash_balanceOf_calldata(account));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_character_balanceOf_calldata = (account: string): DojoCall => {
		return {
			contractName: "character",
			entrypoint: "balanceOf",
			calldata: [account],
		};
	};

	const character_balanceOf = async (account: string) => {
		try {
			return await provider.call("example", build_character_balanceOf_calldata(account));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_actions_cashFaucet_calldata = (): DojoCall => {
		return {
			contractName: "actions",
			entrypoint: "cash_faucet",
			calldata: [],
		};
	};

	const actions_cashFaucet = async (snAccount: Account | AccountInterface) => {
		try {
			return await provider.execute(
				snAccount,
				build_actions_cashFaucet_calldata(),
				"example",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cash_decimals_calldata = (): DojoCall => {
		return {
			contractName: "cash",
			entrypoint: "decimals",
			calldata: [],
		};
	};

	const cash_decimals = async () => {
		try {
			return await provider.call("example", build_cash_decimals_calldata());
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cash_faucet_calldata = (recipient: string): DojoCall => {
		return {
			contractName: "cash",
			entrypoint: "faucet",
			calldata: [recipient],
		};
	};

	const cash_faucet = async (snAccount: Account | AccountInterface, recipient: string) => {
		try {
			return await provider.execute(
				snAccount,
				build_cash_faucet_calldata(recipient),
				"example",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_character_getApproved_calldata = (tokenId: BigNumberish): DojoCall => {
		return {
			contractName: "character",
			entrypoint: "getApproved",
			calldata: [tokenId],
		};
	};

	const character_getApproved = async (tokenId: BigNumberish) => {
		try {
			return await provider.call("example", build_character_getApproved_calldata(tokenId));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_character_isApprovedForAll_calldata = (owner: string, operator: string): DojoCall => {
		return {
			contractName: "character",
			entrypoint: "isApprovedForAll",
			calldata: [owner, operator],
		};
	};

	const character_isApprovedForAll = async (owner: string, operator: string) => {
		try {
			return await provider.call("example", build_character_isApprovedForAll_calldata(owner, operator));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cash_mint_calldata = (recipient: string, amount: BigNumberish): DojoCall => {
		return {
			contractName: "cash",
			entrypoint: "mint",
			calldata: [recipient, amount],
		};
	};

	const cash_mint = async (snAccount: Account | AccountInterface, recipient: string, amount: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_cash_mint_calldata(recipient, amount),
				"example",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_character_mint_calldata = (recipient: string): DojoCall => {
		return {
			contractName: "character",
			entrypoint: "mint",
			calldata: [recipient],
		};
	};

	const character_mint = async (snAccount: Account | AccountInterface, recipient: string) => {
		try {
			return await provider.execute(
				snAccount,
				build_character_mint_calldata(recipient),
				"example",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_actions_mintCharacter_calldata = (): DojoCall => {
		return {
			contractName: "actions",
			entrypoint: "mint_character",
			calldata: [],
		};
	};

	const actions_mintCharacter = async (snAccount: Account | AccountInterface) => {
		try {
			return await provider.execute(
				snAccount,
				build_actions_mintCharacter_calldata(),
				"example",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cash_name_calldata = (): DojoCall => {
		return {
			contractName: "cash",
			entrypoint: "name",
			calldata: [],
		};
	};

	const cash_name = async () => {
		try {
			return await provider.call("example", build_cash_name_calldata());
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_character_name_calldata = (): DojoCall => {
		return {
			contractName: "character",
			entrypoint: "name",
			calldata: [],
		};
	};

	const character_name = async () => {
		try {
			return await provider.call("example", build_character_name_calldata());
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_character_ownerOf_calldata = (tokenId: BigNumberish): DojoCall => {
		return {
			contractName: "character",
			entrypoint: "ownerOf",
			calldata: [tokenId],
		};
	};

	const character_ownerOf = async (tokenId: BigNumberish) => {
		try {
			return await provider.call("example", build_character_ownerOf_calldata(tokenId));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_character_renderUri_calldata = (tokenId: BigNumberish): DojoCall => {
		return {
			contractName: "character",
			entrypoint: "render_uri",
			calldata: [tokenId],
		};
	};

	const character_renderUri = async (tokenId: BigNumberish) => {
		try {
			return await provider.call("example", build_character_renderUri_calldata(tokenId));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_character_safeTransferFrom_calldata = (from: string, to: string, tokenId: BigNumberish, data: Array<BigNumberish>): DojoCall => {
		return {
			contractName: "character",
			entrypoint: "safeTransferFrom",
			calldata: [from, to, tokenId, data],
		};
	};

	const character_safeTransferFrom = async (snAccount: Account | AccountInterface, from: string, to: string, tokenId: BigNumberish, data: Array<BigNumberish>) => {
		try {
			return await provider.execute(
				snAccount,
				build_character_safeTransferFrom_calldata(from, to, tokenId, data),
				"example",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_character_setApprovalForAll_calldata = (operator: string, approved: boolean): DojoCall => {
		return {
			contractName: "character",
			entrypoint: "setApprovalForAll",
			calldata: [operator, approved],
		};
	};

	const character_setApprovalForAll = async (snAccount: Account | AccountInterface, operator: string, approved: boolean) => {
		try {
			return await provider.execute(
				snAccount,
				build_character_setApprovalForAll_calldata(operator, approved),
				"example",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_character_supportsInterface_calldata = (interfaceId: BigNumberish): DojoCall => {
		return {
			contractName: "character",
			entrypoint: "supports_interface",
			calldata: [interfaceId],
		};
	};

	const character_supportsInterface = async (interfaceId: BigNumberish) => {
		try {
			return await provider.call("example", build_character_supportsInterface_calldata(interfaceId));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cash_symbol_calldata = (): DojoCall => {
		return {
			contractName: "cash",
			entrypoint: "symbol",
			calldata: [],
		};
	};

	const cash_symbol = async () => {
		try {
			return await provider.call("example", build_cash_symbol_calldata());
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_character_symbol_calldata = (): DojoCall => {
		return {
			contractName: "character",
			entrypoint: "symbol",
			calldata: [],
		};
	};

	const character_symbol = async () => {
		try {
			return await provider.call("example", build_character_symbol_calldata());
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_character_tokenUri_calldata = (tokenId: BigNumberish): DojoCall => {
		return {
			contractName: "character",
			entrypoint: "tokenURI",
			calldata: [tokenId],
		};
	};

	const character_tokenUri = async (tokenId: BigNumberish) => {
		try {
			return await provider.call("example", build_character_tokenUri_calldata(tokenId));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cash_totalSupply_calldata = (): DojoCall => {
		return {
			contractName: "cash",
			entrypoint: "totalSupply",
			calldata: [],
		};
	};

	const cash_totalSupply = async () => {
		try {
			return await provider.call("example", build_cash_totalSupply_calldata());
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cash_transfer_calldata = (recipient: string, amount: BigNumberish): DojoCall => {
		return {
			contractName: "cash",
			entrypoint: "transfer",
			calldata: [recipient, amount],
		};
	};

	const cash_transfer = async (snAccount: Account | AccountInterface, recipient: string, amount: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_cash_transfer_calldata(recipient, amount),
				"example",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cash_transferFrom_calldata = (sender: string, recipient: string, amount: BigNumberish): DojoCall => {
		return {
			contractName: "cash",
			entrypoint: "transferFrom",
			calldata: [sender, recipient, amount],
		};
	};

	const cash_transferFrom = async (snAccount: Account | AccountInterface, sender: string, recipient: string, amount: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_cash_transferFrom_calldata(sender, recipient, amount),
				"example",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_character_transferFrom_calldata = (from: string, to: string, tokenId: BigNumberish): DojoCall => {
		return {
			contractName: "character",
			entrypoint: "transferFrom",
			calldata: [from, to, tokenId],
		};
	};

	const character_transferFrom = async (snAccount: Account | AccountInterface, from: string, to: string, tokenId: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_character_transferFrom_calldata(from, to, tokenId),
				"example",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};



	return {
		cash: {
			allowance: cash_allowance,
			buildAllowanceCalldata: build_cash_allowance_calldata,
			approve: cash_approve,
			buildApproveCalldata: build_cash_approve_calldata,
			balanceOf: cash_balanceOf,
			buildBalanceOfCalldata: build_cash_balanceOf_calldata,
			decimals: cash_decimals,
			buildDecimalsCalldata: build_cash_decimals_calldata,
			faucet: cash_faucet,
			buildFaucetCalldata: build_cash_faucet_calldata,
			mint: cash_mint,
			buildMintCalldata: build_cash_mint_calldata,
			name: cash_name,
			buildNameCalldata: build_cash_name_calldata,
			symbol: cash_symbol,
			buildSymbolCalldata: build_cash_symbol_calldata,
			totalSupply: cash_totalSupply,
			buildTotalSupplyCalldata: build_cash_totalSupply_calldata,
			transfer: cash_transfer,
			buildTransferCalldata: build_cash_transfer_calldata,
			transferFrom: cash_transferFrom,
			buildTransferFromCalldata: build_cash_transferFrom_calldata,
		},
		character: {
			approve: character_approve,
			buildApproveCalldata: build_character_approve_calldata,
			balanceOf: character_balanceOf,
			buildBalanceOfCalldata: build_character_balanceOf_calldata,
			getApproved: character_getApproved,
			buildGetApprovedCalldata: build_character_getApproved_calldata,
			isApprovedForAll: character_isApprovedForAll,
			buildIsApprovedForAllCalldata: build_character_isApprovedForAll_calldata,
			mint: character_mint,
			buildMintCalldata: build_character_mint_calldata,
			name: character_name,
			buildNameCalldata: build_character_name_calldata,
			ownerOf: character_ownerOf,
			buildOwnerOfCalldata: build_character_ownerOf_calldata,
			renderUri: character_renderUri,
			buildRenderUriCalldata: build_character_renderUri_calldata,
			safeTransferFrom: character_safeTransferFrom,
			buildSafeTransferFromCalldata: build_character_safeTransferFrom_calldata,
			setApprovalForAll: character_setApprovalForAll,
			buildSetApprovalForAllCalldata: build_character_setApprovalForAll_calldata,
			supportsInterface: character_supportsInterface,
			buildSupportsInterfaceCalldata: build_character_supportsInterface_calldata,
			symbol: character_symbol,
			buildSymbolCalldata: build_character_symbol_calldata,
			tokenUri: character_tokenUri,
			buildTokenUriCalldata: build_character_tokenUri_calldata,
			transferFrom: character_transferFrom,
			buildTransferFromCalldata: build_character_transferFrom_calldata,
		},
		actions: {
			cashFaucet: actions_cashFaucet,
			buildCashFaucetCalldata: build_actions_cashFaucet_calldata,
			mintCharacter: actions_mintCharacter,
			buildMintCharacterCalldata: build_actions_mintCharacter_calldata,
		},
	};
}