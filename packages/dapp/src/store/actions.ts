import type { Space, LodgingFacility } from 'stays-data-models';
import type { Web3ModalProvider } from '../hooks/useWeb3Modal';
import type { IPFS } from '@windingtree/ipfs-apis';
import type { IProviderInfo } from 'web3modal';
import { ThemeMode } from '../components/SwitchThemeMode';
export interface GenericStateRecord {
  id: string;
  [key: string]: unknown;
}

export interface State {
  isConnecting: boolean;
  networkId?: number;
  isRightNetwork: boolean;
  provider?: Web3ModalProvider;
  injectedProvider?: IProviderInfo;
  account?: string;
  signIn: Function;
  signOut: Function;
  errors: string[];
  themeMode: ThemeMode;
  ipfsNode?: IPFS;
  isIpfsNodeConnecting: boolean;
  startIpfsNode: Function;
  stopIpfsNode: Function;
  [key: string]: unknown | GenericStateRecord[];
}

export interface SetConnectingAction {
  type: 'SET_CONNECTING',
  payload: boolean;
}

export interface SetAccountAction {
  type: 'SET_ACCOUNT',
  payload: string | undefined;
}

export interface SetIsRightNetworkAction {
  type: 'SET_IS_RIGHT_NETWORK',
  payload: boolean;
}

export interface SetNetworkIdAction {
  type: 'SET_NETWORK_ID',
  payload: number | undefined;
}

export interface SetProviderAction {
  type: 'SET_PROVIDER',
  payload: Web3ModalProvider | undefined;
}

export interface SetInjectedProviderAction {
  type: 'SET_INJECTED_PROVIDER',
  payload: IProviderInfo | undefined;
}

export interface SetWeb3modalFunctionsAction {
  type: 'SET_WEB3MODAL_FUNCTIONS',
  payload: {
    signIn: Function;
    signOut: Function;
  }
}

export interface AddErrorAction {
  type: 'ERROR_ADD';
  payload: string;
}

export interface RemoveErrorAction {
  type: 'ERROR_REMOVE';
  payload: number;
}

export interface RemoveAllErrorsAction {
  type: 'ERROR_REMOVE_ALL';
  payload: number;
}

export interface SetThemeModeAction {
  type: 'SET_THEME_MODE';
  payload: ThemeMode;
}

export interface SetIpfsNodeConnectingAction {
  type: 'SET_IPFS_NODE_CONNECTING';
  payload: boolean;
}

export interface SetIpfsNodeAction {
  type: 'SET_IPFS_NODE';
  payload: {
    ipfsNode: IPFS | undefined;
    startIpfsNode: Function;
    stopIpfsNode: Function;
  }
}

export interface SetRecordAction {
  type: 'SET_RECORD',
  payload: {
    name: string,
    record: GenericStateRecord
  }
}

export interface RemoveRecordAction {
  type: 'REMOVE_RECORD',
  payload: {
    name: string,
    id: string
  }
}

export interface SetSmartContractData {
  type: 'SET_SMART_CONTRACT_DATA',
  payload: LodgingFacility[]
}


export type Action =
  | SetConnectingAction
  | SetAccountAction
  | SetIsRightNetworkAction
  | SetNetworkIdAction
  | SetProviderAction
  | SetThemeModeAction
  | SetInjectedProviderAction
  | SetWeb3modalFunctionsAction
  | SetIpfsNodeConnectingAction
  | SetIpfsNodeAction
  | SetRecordAction
  | RemoveRecordAction
  | AddErrorAction
  | RemoveErrorAction
  | SetSmartContractData
  | RemoveAllErrorsAction;
