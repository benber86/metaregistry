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
    def get_id_info(_id: uint256) -> AddressInfo: view

interface RegistryHandler:
    def sync_pool_list(): nonpayable
    def get_coins(_pool: address) -> address[MAX_COINS]: view
    def get_n_coins(_pool: address) -> uint256: view
    def get_underlying_coins(_pool: address) -> address[MAX_COINS]: view
    def get_decimals(_pool: address) -> uint256[MAX_COINS]: view
    def get_underlying_decimals(_pool: address) -> uint256[MAX_COINS]: view
    def get_balances(_pool: address) -> uint256[MAX_COINS]: view
    def get_underlying_balances(_pool: address) -> uint256[MAX_COINS]: view
    def get_admin_balances(_pool: address) -> uint256[MAX_COINS]: view
    def get_lp_token(_pool: address) -> address: view
    def get_gauges(_pool: address) -> (address[10], int128[10]): view
    def is_meta(_pool: address) -> bool: view
    def get_pool_name(_pool: address) -> String[64]: view
    def get_fees(_pool: address) -> uint256[10]: view

registry_length: public(uint256)
get_registry: public(HashMap[uint256, Registry])
total_pools: uint256
internal_pool_registry: public(HashMap[address, uint256])
authorized_registries: HashMap[address, bool]
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

@external
def update_internal_pool_registry(_pool: address, _incremented_index: uint256):
    """
    @notice Update the registry associated with a pool
    @dev Callback function used by the registry handlers when syncing
    @param _pool Pool to update
    @param _incremented_index Index of the associated registry incremented by 1
    """
    assert self.authorized_registries[msg.sender]
    self.internal_pool_registry[_pool] = _incremented_index

@internal
def _update_single_registry(_index: uint256, _addr: address, _id: uint256, _registry_handler: address, _description: String[64], _is_active: bool):
    assert _index <= self.registry_length

    if _index == self.registry_length:
        self.registry_length += 1

    self.get_registry[_index] = Registry({addr: _addr, id: _id, registry_handler: _registry_handler, description: _description, is_active: _is_active})
    if (self.authorized_registries[_registry_handler] != _is_active):
        self.authorized_registries[_registry_handler] = _is_active


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
    self._update_single_registry(_index, registry.addr, registry.id, registry.registry_handler, registry.description, not registry.is_active)


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

@internal
def _sync_registry(_index: uint256):
        registry: Registry = self.get_registry[_index]
        if (registry.is_active):
            RegistryHandler(registry.registry_handler).sync_pool_list()

@external
def sync_registry(_index: uint256):
    """
    @notice Sync a particular registry
    @param _index Registry index
    """
    assert msg.sender == self.admin  # dev: admin-only function
    assert _index < self.registry_length
    self._sync_registry(_index)


@external
def sync():
    """
    @notice Gets all the pools from a registry that are not currently registered
    """
    assert msg.sender == self.admin  # dev: admin-only function

    for i in range(MAX_REGISTRIES):
        if i == self.registry_length:
            break
        self._sync_registry(i)

@internal
@view
def _get_registry_handler_from_pool(_pool: address) -> address:
    registry_index: uint256 = self.internal_pool_registry[_pool]
    assert registry_index > 0, "no registry"
    return self.get_registry[registry_index - 1].registry_handler

@external
@view
def get_coins(_pool: address) -> address[MAX_COINS]:
    return RegistryHandler(self._get_registry_handler_from_pool(_pool)).get_coins(_pool)

@external
@view
def get_n_coins(_pool: address) -> uint256:
    return RegistryHandler(self._get_registry_handler_from_pool(_pool)).get_n_coins(_pool)

@external
@view
def get_underlying_coins(_pool: address) -> address[MAX_COINS]:
    return RegistryHandler(self._get_registry_handler_from_pool(_pool)).get_underlying_coins(_pool)

@external
@view
def get_decimals(_pool: address) -> uint256[MAX_COINS]:
    return RegistryHandler(self._get_registry_handler_from_pool(_pool)).get_decimals(_pool)

@external
@view
def get_underlying_decimals(_pool: address) -> uint256[MAX_COINS]:
    return RegistryHandler(self._get_registry_handler_from_pool(_pool)).get_underlying_decimals(_pool)

@external
@view
def get_balances(_pool: address) -> uint256[MAX_COINS]:
    return RegistryHandler(self._get_registry_handler_from_pool(_pool)).get_balances(_pool)

@external
@view
def get_underlying_balances(_pool: address) -> uint256[MAX_COINS]:
    return RegistryHandler(self._get_registry_handler_from_pool(_pool)).get_underlying_balances(_pool)

@external
@view
def get_lp_token(_pool: address) -> address:
    return RegistryHandler(self._get_registry_handler_from_pool(_pool)).get_lp_token(_pool)

@external
@view
def get_gauges(_pool: address) -> (address[10], int128[10]):
    return RegistryHandler(self._get_registry_handler_from_pool(_pool)).get_gauges(_pool)

@external
@view
def is_meta(_pool: address) -> bool:
    return RegistryHandler(self._get_registry_handler_from_pool(_pool)).is_meta(_pool)

@external
@view
def get_pool_name(_pool: address) -> String[64]:
    return RegistryHandler(self._get_registry_handler_from_pool(_pool)).get_pool_name(_pool)

@external
@view
def get_fees(_pool: address) -> uint256[10]:
    """
    @dev Fees are expressed as integers
    @return Pool fee as uint256 with 1e10 precision
            Admin fee as 1e10 percentage of pool fee
            Mid fee
            Out fee
            6 blank spots for future use cases
    """
    return RegistryHandler(self._get_registry_handler_from_pool(_pool)).get_fees(_pool)

@external
@view
def get_admin_balances(_pool: address) -> uint256[MAX_COINS]:
    return RegistryHandler(self._get_registry_handler_from_pool(_pool)).get_admin_balances(_pool)

