"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerLodgingFacility = void 0;
const org_id_utils_1 = require("@windingtree/org.id-utils");
const ipfs_apis_1 = require("@windingtree/ipfs-apis");
const sendHelper_1 = require("../utils/sendHelper");
// Register facility
const registerLodgingFacility = (contract, ipfsNode, profileData, active = true, fren, overrides, transactionHashCb, confirmations = 1) => __awaiter(void 0, void 0, void 0, function* () {
    var _a, _b;
    const profileDataFile = ipfs_apis_1.utils.obj2File(profileData, `lodgingFacility_${org_id_utils_1.uid.simpleUid()}.json`);
    const ipfsCid = yield ipfsNode.add(profileDataFile);
    const dataURI = `ipfs://${ipfsCid}`;
    overrides = overrides ? overrides : {};
    const owner = contract.provider.getSigner();
    const receipt = yield (0, sendHelper_1.sendHelper)(contract, fren
        ? 'registerLodgingFacility(string,bool,address)'
        : 'registerLodgingFacility(string,bool)', [
        dataURI,
        active,
        ...(fren ? [fren] : [])
    ], owner, overrides, transactionHashCb, confirmations);
    const event = (_a = receipt.events) === null || _a === void 0 ? void 0 : _a.find(e => e.event == 'LodgingFacilityCreated');
    const facilityId = (_b = event === null || event === void 0 ? void 0 : event.args) === null || _b === void 0 ? void 0 : _b.facilityId;
    if (!facilityId) {
        throw new Error(`Unable to find "facilityId" in the transaction receipt`);
    }
    return facilityId;
});
exports.registerLodgingFacility = registerLodgingFacility;
//# sourceMappingURL=registerLodgingFacility.js.map