// SPDX-License-Identifier: GPL
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IEthRioStays.sol";
import "./StayEscrow.sol";
import "./libraries/StayTokenMeta.sol";

// import "hardhat/console.sol";


contract EthRioStays is IEthRioStays, StayEscrow, ERC721URIStorage, ERC721Enumerable {
  using Counters for Counters.Counter;
  Counters.Counter private _stayTokenIds;

  uint32 public constant dayZero = 1645567342; // 22 Feb 2022
  address private constant _ukraineDAO = 0x633b7218644b83D57d90e7299039ebAb19698e9C; // ukrainedao.eth https://twitter.com/Ukraine_DAO/status/1497274679823941632
  uint8 private constant _ukraineDAOfee = 2; // percents

  // Schema conformance URLs for reference
  string public constant lodgingFacilitySchemaURI = "";
  string public constant spaceSchemaURI = "";
  string public constant staySchemaURI = "";

  // Lodging Facility is any type of accommodation: hotel, hostel, apartment, etc.
  struct LodgingFacility {
    address owner;
    bool active;
    bool exists;
    string dataURI; // must be conformant with "lodgingFacilitySchemaURI"
    address fren;
  }

  // Space = Room Type
  struct Space {
    bytes32 lodgingFacilityId;
    uint16 capacity; // number of rooms of this type
    uint256 pricePerNightWei;
    bool active;
    bool exists;
    string dataURI; // must be conformant with "spaceSchemaURI"
  }

  // Stay
  struct Stay {
    bytes32 spaceId;
    uint16 startDay;
    uint16 numberOfDays;
    uint16 quantity;
    bool checkIn;
    bool checkOut;
  }

  bytes32[] private _lodgingFacilityIds;

  // Facility owner => LodgingFacility[]
  mapping (address => bytes32[]) private _facilityIdsByOwner;

  // facilityId => LodgingFacility
  mapping (bytes32 => LodgingFacility) public lodgingFacilities;

  // facilityId => spaceId[]
  mapping (bytes32 => bytes32[]) private _spaceIdsByFacilityId;

  // spaceId => Space
  mapping (bytes32 => Space) public spaces;

  // spaceId => daysFromDayZero => numberOfBookings
  mapping(bytes32 => mapping(uint16 => uint16)) private _booked;

  // Stay token => Stay
  mapping(uint256 => Stay) private _stays;

  constructor() ERC721("EthRioStays", "ERS22") {}

  /**
   * Modifiers
   */
  modifier onlyLodgingFacilityOwner(bytes32 _lodgingFacilityId) {
    require(
      _msgSender() == lodgingFacilities[_lodgingFacilityId].owner,
      "Only lodging facility owner is allowed"
    );
    _;
  }

  modifier onlySpaceOwner(bytes32 _spaceId) {
    require(
      _msgSender() == lodgingFacilities[spaces[_spaceId].lodgingFacilityId].owner,
      "Only space owner is allowed"
    );
    _;
  }

  modifier onlyTokenOwner(uint256 _tokenId) {
    require(
      _msgSender() == ownerOf(_tokenId),
      "Only stay token owner is allowed"
    );
    _;
  }

  /**
   * Lodging Facilities Getters
   */
  // All registered Ids
  function getAllLodgingFacilityIds() public view override returns (bytes32[] memory) {
    return _lodgingFacilityIds;
  }

  // All ACTIVE facilities Ids
  function getActiveLodgingFacilityIds() public view override returns (bytes32[] memory activeLodgingFacilityIds) {
    activeLodgingFacilityIds = new bytes32[](_getActiveLodgingFacilitiesCount());
    uint256 index;

    for (uint256 i = 0; i < _lodgingFacilityIds.length; i++) {
      if (lodgingFacilities[_lodgingFacilityIds[i]].active) {
        activeLodgingFacilityIds[index] = _lodgingFacilityIds[i];
        index++;
      }
    }
  }

  // All spaces Ids from facility by Id
  function getSpaceIdsByFacilityId(bytes32 _lodgingFacilityId) public view override returns (bytes32[] memory) {
    return _spaceIdsByFacilityId[_lodgingFacilityId];
  }

  // All ACTIVE spaces Ids from facility by Id
  function getActiveSpaceIdsByFacilityId(bytes32 _lodgingFacilityId) public view override returns (bytes32[] memory activeSpacesIds) {
    activeSpacesIds = new bytes32[](_getActiveSpacesCount(_lodgingFacilityId));
    bytes32[] memory facilitiesSpaces = _spaceIdsByFacilityId[_lodgingFacilityId];
    uint256 index;

    for (uint256 i = 0; i < facilitiesSpaces.length; i++) {
      if (spaces[facilitiesSpaces[i]].active) {
        activeSpacesIds[index] = facilitiesSpaces[i];
        index++;
      }
    }
  }

  // Availability of the space
  function getAvailability(
    bytes32 _spaceId,
    uint16 _startDay,
    uint16 _numberOfDays
  ) public view override returns (uint16[] memory) {
    _checkBookingParams(_spaceId, _startDay, _numberOfDays);

    Space memory _s = spaces[_spaceId];
    uint16[] memory _availability = new uint16[](_numberOfDays);

    for (uint16 _x = 0; _x < _numberOfDays; _x++) {
      _availability[_x] = _s.capacity - _booked[_spaceId][_startDay+_x];
    }

    return _availability;
  }

  // Facilities by owner
  function getLodgingFacilityIdsByOwner(address _owner) public view override returns (bytes32[] memory) {
    return _facilityIdsByOwner[_owner];
  }

  // Facility details
  function getLodgingFacilityById(bytes32 _lodgingFacilityId) public view override returns(
    bool exists,
    address owner,
    bool active,
    string memory dataURI
  ) {
    LodgingFacility storage facility = lodgingFacilities[_lodgingFacilityId];
    exists = facility.exists;
    owner = facility.owner;
    active = facility.active;
    dataURI = facility.dataURI;
  }

  // Space details
  function getSpaceById(bytes32 _spaceId) public view override returns (
    bool exists,
    bytes32 lodgingFacilityId,
    uint16 capacity,
    uint256 pricePerNightWei,
    bool active,
    string memory dataURI
  ) {
    Space storage space = spaces[_spaceId];
    exists = space.exists;
    lodgingFacilityId = space.lodgingFacilityId;
    capacity = space.capacity;
    pricePerNightWei = space.pricePerNightWei;
    active = space.active;
    dataURI = space.dataURI;
  }

  /*
   * Lodging Facilities Management
   */

  // Lodging Facility registration (with fren option)
  function registerLodgingFacility(string calldata _dataURI, bool _active, address _fren) public override {
    _dataUriMustBeProvided(_dataURI);

    bytes32 _id = keccak256(
      abi.encodePacked(
        _msgSender(),
        _dataURI
      )
    );

    require(!lodgingFacilities[_id].exists, "Facility already exists");

    lodgingFacilities[_id] = LodgingFacility(
      _msgSender(),
      _active,
      true,
      _dataURI,
      _fren
    );
    _lodgingFacilityIds.push(_id);
    _facilityIdsByOwner[_msgSender()].push(_id);

    emit LodgingFacilityCreated(_id, _msgSender(), _dataURI);
  }

  // Lodging Facility registration (WITHOUT fren option)
  function registerLodgingFacility(string calldata _dataURI, bool _active) public override {
    return registerLodgingFacility(_dataURI, _active, address(0));
  }

  function updateLodgingFacility(bytes32 _lodgingFacilityId, string calldata _newDataURI) public override onlyLodgingFacilityOwner(_lodgingFacilityId) {
    lodgingFacilities[_lodgingFacilityId].dataURI = _newDataURI;
    emit LodgingFacilityUpdated(_lodgingFacilityId, _newDataURI);
  }

  function activateLodgingFacility(bytes32 _lodgingFacilityId) public override onlyLodgingFacilityOwner(_lodgingFacilityId) {
    lodgingFacilities[_lodgingFacilityId].active = true;
    emit LodgingFacilityActiveState(_lodgingFacilityId, true);
  }

  function deactivateLodgingFacility(bytes32 _lodgingFacilityId) public override onlyLodgingFacilityOwner(_lodgingFacilityId) {
    lodgingFacilities[_lodgingFacilityId].active = false;
    emit LodgingFacilityActiveState(_lodgingFacilityId, false);
  }

  function yieldLodgingFacility(bytes32 _lodgingFacilityId, address _newOwner) public override onlyLodgingFacilityOwner(_lodgingFacilityId) {
    emit LodgingFacilityOwnershipTransfer(_lodgingFacilityId, lodgingFacilities[_lodgingFacilityId].owner, _newOwner);
    lodgingFacilities[_lodgingFacilityId].owner = _newOwner;
  }

  function deleteLodgingFacility(bytes32 _lodgingFacilityId) public override onlyLodgingFacilityOwner(_lodgingFacilityId) {
    lodgingFacilities[_lodgingFacilityId].exists = false;
    emit LodgingFacilityRemoved(_lodgingFacilityId);
  }

  /*
   * Spaces
   */
  function addSpace(
    bytes32 _lodgingFacilityId,
    uint16 _capacity,
    uint256 _pricePerNightWei,
    bool _active,
    string calldata _dataURI
  ) public {
    bytes32 _i = _lodgingFacilityId;

    _facilityShouldExist(_i);
    _shouldOnlyBeCalledByOwner(_i, "Only facility owner may add Spaces");
    _dataUriMustBeProvided(_dataURI);

    bytes32 _id = keccak256(abi.encodePacked(
      _i,
      _dataURI
    ));

    require(!spaces[_id].exists, "Space already exists");

    spaces[_id] = Space(
      _i,
      _capacity,
      _pricePerNightWei,
      _active,
      true,
      _dataURI
    );
    _spaceIdsByFacilityId[_i].push(_id);

    emit SpaceAdded(_i, _capacity, _pricePerNightWei, _active, _dataURI);
  }

  function updateSpace(
    uint256 _spaceIndex,
    uint16 _capacity,
    uint256 _pricePerNightWei,
    bool _active,
    string calldata _dataURI
  ) public {
    // TODO
  }

  /**
   * Stay escrow
   */

  function deposit(
    address payee,
    bytes32 spaceId
  ) public payable override(StayEscrow) {
    super.deposit(payee, spaceId);
  }

  // Complete withdraw. Allowed in Checkout deposit state only
  function withdraw(
    address payable payee,
    bytes32 _spaceId
  )
    internal override(StayEscrow)
  {
    super.withdraw(payee, _spaceId);
  }

  // Partial withdraw
  function withdraw(
    address payable payee,
    uint256 payment,
    bytes32 _spaceId
  ) internal override(StayEscrow) {
    // partial withdraw condition
    require(
      payment <= spaces[_spaceId].pricePerNightWei,
      "Withdraw amount not allows in this state"
    );
    super.withdraw(payee, payment, _spaceId);
  }

  /**
   * Glider
   */
  // Book a new stay in a space
  function newStay(
    bytes32 _spaceId,
    uint16 _startDay,
    uint16 _numberOfDays,
    uint16 _quantity
  ) public payable override returns (uint256) {
    _checkBookingParams(_spaceId, _startDay, _numberOfDays);

    Space storage _s = spaces[_spaceId];
    uint256 _stayPrice = _numberOfDays * _quantity * _s.pricePerNightWei;

    require(msg.value >= _stayPrice, "Need. More. Money!");

    for (uint16 _x = 0; _x < _numberOfDays; _x++) {
      require(
        _s.capacity - _booked[_spaceId][_startDay+_x] >= _quantity,
        "Insufficient inventory"
      );
      _booked[_spaceId][_startDay+_x] += _quantity;
    }

    deposit(_msgSender(), _spaceId);

    _stayTokenIds.increment();
    uint256 _newStayTokenId = _stayTokenIds.current();
    _safeMint(_msgSender(), _newStayTokenId);

    // Inline tokenURI (data:application/json;base64)
    string memory _tokenURI = StayTokenMeta.createTokenUri(
      _newStayTokenId,
      _s.lodgingFacilityId,
      _spaceId,
      _startDay,
      _numberOfDays,
      _quantity
    );
    _setTokenURI(_newStayTokenId, _tokenURI);

    _stays[_newStayTokenId] = Stay(
      _spaceId,
      _startDay,
      _numberOfDays,
      _quantity,
      false,
      false
    );

    // @todo: escrow
    // facility owner should be able to claim 1-night amount during check-in
    // then, facility owner should be able to claim full amount on check-out day

    // @todo LIF/WIN
    // @todo LodgingFacility loyalty token
    // @todo divert all the excess WEI to Ukraine DAO
    // @todo Receive Ukraine Supporter NFT

    emit NewStay(_spaceId, _newStayTokenId);

    return _newStayTokenId;
  }

  /**
   * CheckIn
   */

  // Stay checkIn; can be called by a stay token owner
  function checkIn(uint256 _tokenId) public override onlyTokenOwner(_tokenId) {
    Stay storage _stay = _stays[_tokenId];
    require(!_stay.checkIn, "Already checked in");
    bytes32 _spaceId = _stay.spaceId;
    uint256 firstNight = spaces[_spaceId].pricePerNightWei;
    // Partial withdraw, just for a first night
    _stay.checkIn = true;
    withdraw(
      payable(lodgingFacilities[spaces[_spaceId].lodgingFacilityId].owner),
      firstNight,
      _spaceId
    );
    emit CheckIn(_tokenId);
  }

  /**
   * CheckOut
   */

  function checkOut(uint256 _tokenId) public virtual override {
    Stay storage _stay = _stays[_tokenId];
    require(!_stay.checkOut, "Already checked out");
    bytes32 _spaceId = _stay.spaceId;
    address spaceOwner = lodgingFacilities[spaces[_spaceId].lodgingFacilityId].owner;
    require(
      _msgSender() == spaceOwner,
      "Only space owner is allowed"
    );
    // CheckOut condition by time
    require(
      dayZero + (_stay.startDay + _stay.numberOfDays) * 86400 >= block.timestamp,
      "Forbidden unless checkout date"
    );
    // Complete withdraw (rest of deposit)
    _stay.checkOut = true;
    withdraw(
      payable(spaceOwner),
      _spaceId
    );
    emit CheckOut(_tokenId);
  }

  /*
   * Helpers
   */

  function _facilityShouldExist(bytes32 _i) internal view {
    require(lodgingFacilities[_i].exists, "Facility does not exist");
  }

  function _spaceShouldExist(bytes32 _i) internal view {
    require(spaces[_i].exists, "Space does not exist");
  }

  function _shouldOnlyBeCalledByOwner(bytes32 _i, string memory _message) internal view {
    require(lodgingFacilities[_i].owner == _msgSender(), _message);
  }

  function _dataUriMustBeProvided(string memory _uri) internal pure {
    require(bytes(_uri).length > 0, "Data URI must be provided");
  }

  function _checkBookingParams(bytes32 _spaceId, uint256 _startDay, uint16 _numberOfDays) internal view {
    require(dayZero + _startDay * 86400 > block.timestamp - 86400 * 2, "Don't stay in the past"); // @todo this could be delegated to frontend
    require(lodgingFacilities[spaces[_spaceId].lodgingFacilityId].active, "Lodging Facility is inactive");
    require(spaces[_spaceId].active, "Space is inactive");
    require(_numberOfDays > 0, "Number of days should be 1 or more");
  }

  function _getActiveLodgingFacilitiesCount() internal view returns (uint256 count) {
    for (uint256 i = 0; i < _lodgingFacilityIds.length; i++) {
      if (lodgingFacilities[_lodgingFacilityIds[i]].active) {
        count++;
      }
    }
  }

  function _getActiveSpacesCount(bytes32 _lodgingFacilityId) internal view returns (uint256 count) {
    bytes32[] storage facilitiesSpaces = _spaceIdsByFacilityId[_lodgingFacilityId];

    for (uint256 i = 0; i < facilitiesSpaces.length; i++) {
      if (spaces[facilitiesSpaces[i]].active) {
        count++;
      }
    }
  }

  /** Overrides */

  function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    override(ERC721, ERC721Enumerable)
  {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    super._burn(tokenId);
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
  {
    return super.tokenURI(tokenId);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }
}
