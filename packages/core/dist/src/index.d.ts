import type { BigNumber, providers } from 'ethers';
import type { IPFS } from '@windingtree/ipfs-apis';
import type { LodgingFacilityRaw, LodgingFacility, SpaceRaw, Space } from 'stays-data-models';
import type { EthRioStays } from 'stays-smart-contracts';
import type { MethodOverrides, TxHashCallbackFn } from './utils/sendHelper';
import type { StayToken } from './types';
export declare type KnownProvider = providers.ExternalProvider | providers.JsonRpcProvider | providers.Web3Provider | providers.Provider | string;
export declare class EthRioContract {
    readonly address: string;
    readonly provider: providers.Provider;
    readonly contract: EthRioStays;
    readonly ipfsNode: IPFS;
    constructor(contractAddress: string, providerOrUri: KnownProvider, ipfsNode: IPFS);
    getLodgingFacilityIds(active: boolean): Promise<string[]>;
    getSpaceIds(lodgingFacilityId: string, active: boolean): Promise<string[]>;
    getAvailability(spaceId: string, startDay: number, numberOfDays: number): Promise<number[]>;
    getLodgingFacility(lodgingFacilityId: string): Promise<LodgingFacility | null>;
    getSpace(spaceId: string): Promise<Space | null>;
    getTokensOfOwner(owner: string): Promise<BigNumber[]>;
    getToken(tokenId: BigNumber): Promise<StayToken>;
    registerLodgingFacility(profileData: LodgingFacilityRaw, active?: boolean, fren?: string, // address
    overrides?: MethodOverrides, transactionHashCb?: TxHashCallbackFn, confirmations?: number): Promise<string>;
    addSpace(profileData: SpaceRaw, lodgingFacilityId: string, capacity: number, pricePerNightWei: BigNumber, active?: boolean, overrides?: MethodOverrides, transactionHashCb?: TxHashCallbackFn, confirmations?: number): Promise<string>;
    book(spaceId: string, startDay: number, numberOfDays: number, quantity: number, overrides?: MethodOverrides, transactionHashCb?: TxHashCallbackFn, confirmations?: number): Promise<BigNumber>;
}
