# @version 0.2.15
"""
@title Curve Meta Registry
@license MIT
"""

MAX_COINS: constant(int128) = 8
MAX_REGISTRIES: constant(int128) = 64

struct Registry:
    addr: address
    id: uint256 # id in the address provider
    registry_handler: address # contract with custom logic to id (sub)categories
    description: String[64]
    is_active: bool

struct Pool:
    addr: address
    categories: uint256
    name: String[64]
    lp_token: address
    base_pool: address
    coins: address[MAX_COINS]
    underlying_coins: address[MAX_COINS]

struct AddressInfo:
    addr: address
    is_active: bool
    version: uint256
    last_modified: uint256
    description: String[64]

interface AddressProvider:
    def admin() -> address: view
    def get_address(_id: uint256) -> address: view
    def get_registry() -> address: view
    def get_id_info(_id: uint256) -> AddressInfo: view


registry_length: uint256
get_registry: public(HashMap[uint256, Registry])
total_pools: uint256
pool_handlers: public(HashMap[address, address])
admin: public(address)
address_provider: public(AddressProvider)


@external
def __init__(_admin: address):
    self.admin = _admin
    self.address_provider = AddressProvider(0x0000000022D53366457F9d5E68Ec105046FC4383)


@external
def update_address_provider(_provider: address):
    """
    @notice Update the address provider contract
    @dev Only callable by admin
    @param _provider New provider address
    """
    assert msg.sender == self.admin  # dev: admin-only function
    assert _provider != ZERO_ADDRESS  # dev: not to zero
    self.address_provider = AddressProvider(_provider)


@internal
def _update_single_registry(_index: uint256, _addr: address, _id: uint256, _registry_handler: address, _description: String[64], _is_active: bool):
    assert _index <= self.registry_length

    if _index == self.registry_length:
        self.registry_length += 1

    self.get_registry[_index] = Registry({addr: _addr, id: _id, registry_handler: _registry_handler, description: _description, is_active: _is_active})


@external
def update_single_registry(_index: uint256, _addr: address, _id: uint256, _registry_handler: address, _description: String[64], _is_active: bool):
    """
    @notice Creates or update a single registry entry
    @param _index The index of the registry in get_registry, equals to registry_length for new entry
    @param _addr Address of the registry contract
    @param _id Id number in the address provider
    @param _registry_handler Address of the handler contract
    @param _description Name of the registry
    @param _is_active Whether registry is active
    """
    assert msg.sender == self.admin  # dev: admin-only function
    self._update_single_registry(_index, _addr, _id, _registry_handler, _description, _is_active)


@external
def update_registry_handler(_index: uint256, _registry_handler: address):
    """
    @notice Updates the contract used to handle a registry
    @param _index The index of the registry in get_registry
    @param _registry_handler Address of the new handler contract
    """
    assert msg.sender == self.admin  # dev: admin-only function
    assert _index < self.registry_length
    registry: Registry = self.get_registry[_index]
    self._update_single_registry(_index, registry.addr, registry.id, _registry_handler, registry.description, registry.is_active)


@external
def switch_registry_active_status(_index: uint256):
    """
    @notice Disables an active registry (and vice versa)
    @param _index The index of the registry in get_registry
    """
    assert msg.sender == self.admin  # dev: admin-only function
    assert _index < self.registry_length
    registry: Registry = self.get_registry[_index]
    active_status: bool = False
    if registry.is_active == False:
        active_status = True
    self._update_single_registry(_index, registry.addr, registry.id, registry.registry_handler, registry.description, active_status)


@external
def add_registry_by_address_provider_id(_id: uint256, _registry_handler: address):
    """
    @notice Add a registry from the address provider entry
    @param _id Id number in the address provider
    @param _registry_handler Address of the handler contract
    """
    assert msg.sender == self.admin  # dev: admin-only function

    pool_info: AddressInfo = self.address_provider.get_id_info(_id)
    self._update_single_registry(self.registry_length, pool_info.addr, _id, _registry_handler, pool_info.description, pool_info.is_active)


@external
def update_registry_addresses() -> uint256:
    """
    @notice Updates all out-of-date registry addresses from the address provider
    @return The number of updates applied
    """
    assert msg.sender == self.admin  # dev: admin-only function
    count: uint256 = 0
    for i in range(MAX_REGISTRIES):
        if i == self.registry_length:
            break
        registry: Registry = self.get_registry[i]
        if (registry.is_active and registry.addr != self.address_provider.get_address(registry.id)):
            pool_info: AddressInfo = self.address_provider.get_id_info(i)
            self._update_single_registry(i, pool_info.addr, registry.id, registry.registry_handler, pool_info.description, pool_info.is_active)
            count += 1
    return count