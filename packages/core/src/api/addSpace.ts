import type { providers, BigNumber } from 'ethers';
import type { EthRioStays } from 'stays-smart-contracts';
import type { SpaceRaw } from 'stays-data-models';
import type { IPFS } from '@windingtree/ipfs-apis';
import type { MethodOverrides, TxHashCallbackFn } from '../utils/sendHelper';
import { uid } from '@windingtree/org.id-utils';
import { utils as ipfsUtils } from '@windingtree/ipfs-apis';
import { sendHelper } from '../utils/sendHelper';

// Register space
export const addSpace = async (
  contract: EthRioStays,
  ipfsNode: IPFS,
  profileData: SpaceRaw,
  lodgingFacilityId: string,
  capacity: number,
  pricePerNightWei: BigNumber,
  active = true,
  overrides?: MethodOverrides,
  transactionHashCb?: TxHashCallbackFn,
  confirmations = 1
): Promise<string> => {

  const profileDataFile = ipfsUtils.obj2File(
    profileData,
    `space_${uid.simpleUid()}.json`
  );

  const ipfsCid = await ipfsNode.add(profileDataFile);
  const dataURI = `ipfs://${ipfsCid}`;

  overrides = overrides ? overrides : {};
  const owner = (contract.provider as providers.Web3Provider).getSigner();

  const receipt = await sendHelper(
    contract,
    'addSpace',
    [
      lodgingFacilityId,
      capacity,
      pricePerNightWei,
      active,
      dataURI
    ],
    owner,
    overrides,
    transactionHashCb,
    confirmations
  );

  const event = receipt.events?.find(e => e.event == 'SpaceAdded');
  const spaceId = event?.args?.spaceId;

  if (!spaceId) {
    throw new Error(`Unable to find "spaceId" in the transaction receipt`);
  }

  return spaceId;
};