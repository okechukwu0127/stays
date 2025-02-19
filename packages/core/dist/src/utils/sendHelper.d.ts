import type { EthRioStays } from 'stays-smart-contracts';
import type { ContractReceipt, Signer, CallOverrides, PayableOverrides } from 'ethers';
export declare type MethodOverrides = CallOverrides | PayableOverrides;
export declare type TxHashCallbackFn = (txHash: string) => void;
export declare const sendHelper: (contract: EthRioStays, method: string, args: unknown[], sender: Signer, overrides?: MethodOverrides | undefined, transactionHashCb?: TxHashCallbackFn | undefined, confirmations?: number) => Promise<ContractReceipt>;
