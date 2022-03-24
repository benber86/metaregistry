# @version 0.2.15
"""
@title Curve Registry Handler for v2 Factory
@license MIT
"""

MAX_METAREGISTRY_COINS: constant(int128) = 8
MAX_COINS: constant(int128) = 2
MAX_POOLS: constant(int128) = 128


interface BaseRegistry:
    def get_coins(_pool: address) -> address[MAX_COINS]: view
    def get_decimals(_pool: address) -> uint256[MAX_COINS]: view
    def get_balances(_pool: address) -> uint256[MAX_COINS]: view
    def get_gauge(_pool: address) -> address: view
    def get_n_coins(_pool: address) -> uint256: view
    def get_token(_pool: address) -> address: view
    def pool_count() -> uint256: view
    def pool_list(pool_id: uint256) -> address: view

interface MetaRegistry:
    def admin() -> address: view
    def update_internal_pool_registry(_pool: address, _incremented_index: uint256): nonpayable
    def registry_length() -> uint256: view

interface AddressProvider:
    def get_address(_id: uint256) -> address: view

interface GaugeController:
    def gauge_types(gauge: address) -> int128: view

metaregistry: public(address)
base_registry: public(BaseRegistry)
total_pools: public(uint256) 
registry_index: uint256
registry_id: uint256

ADDRESS_PROVIDER: constant(address) = 0x0000000022D53366457F9d5E68Ec105046FC4383
GAUGE_CONTROLLER: constant(address) = 0x2F50D538606Fa9EDD2B11E2446BEb18C9D5846bB


@external
def __init__(_metaregistry: address, _id: uint256):
    self.metaregistry = _metaregistry
    self.base_registry = BaseRegistry(AddressProvider(ADDRESS_PROVIDER).get_address(_id))
    self.registry_id = _id
    self.registry_index = MetaRegistry(_metaregistry).registry_length()


@external
@view
def is_registered(_pool: address) -> bool:
    """
    @notice Check if a pool belongs to the registry using get_n_coins
    @param _pool The address of the pool
    @return A bool corresponding to whether the pool belongs or not
    """
    return self.base_registry.get_n_coins(_pool) > 0

@external
def sync_pool_list():
    """
    @notice Records any newly added pool on the metaregistry
    @dev To be called from the metaregistry
    """
    assert msg.sender == self.metaregistry
    pool_count: uint256 = self.base_registry.pool_count()
    last_pool: uint256 = self.total_pools
    for i in range(last_pool, last_pool + MAX_POOLS):
        if i == pool_count:
            break
        MetaRegistry(self.metaregistry).update_internal_pool_registry(self.base_registry.pool_list(i), self.registry_index + 1)
        self.total_pools += 1

@internal
@view
def _pad_uint_array(_array: uint256[MAX_COINS]) -> uint256[MAX_METAREGISTRY_COINS]:
    _padded_array: uint256[MAX_METAREGISTRY_COINS] = empty(uint256[MAX_METAREGISTRY_COINS])
    for i in range(MAX_COINS):
        _padded_array[i] = _array[i]
    return _padded_array


@internal
@view
def _get_coins(_pool: address) -> address[MAX_METAREGISTRY_COINS]:
    _coins: address[MAX_COINS] = self.base_registry.get_coins(_pool)
    _padded_coins: address[MAX_METAREGISTRY_COINS] = empty(address[MAX_METAREGISTRY_COINS])
    for i in range(MAX_COINS):
        _padded_coins[i] = _coins[i]
    return _padded_coins

@external
@view
def get_coins(_pool: address) -> address[MAX_METAREGISTRY_COINS]:
    return self._get_coins(_pool)

@external
@view
def get_underlying_coins(_pool: address) -> address[MAX_METAREGISTRY_COINS]:
    return self._get_coins(_pool)

@external
@view
def get_n_coins(_pool: address) -> uint256:
    return 2


@internal
@view
def _get_decimals(_pool: address) -> uint256[MAX_METAREGISTRY_COINS]:
    return self._pad_uint_array(self.base_registry.get_decimals(_pool))

@external
@view
def get_decimals(_pool: address) -> uint256[MAX_METAREGISTRY_COINS]:
    return self._get_decimals(_pool)

@external
@view
def get_underlying_decimals(_pool: address) -> uint256[MAX_METAREGISTRY_COINS]:
    return self._get_decimals(_pool)

@internal
@view
def _get_balances(_pool: address) -> uint256[MAX_METAREGISTRY_COINS]:
    return self._pad_uint_array(self.base_registry.get_balances(_pool))

@external
@view
def get_balances(_pool: address) -> uint256[MAX_METAREGISTRY_COINS]:
    return self._get_balances(_pool)

@external
@view
def get_underlying_balances(_pool: address) -> uint256[MAX_METAREGISTRY_COINS]:
    return self._get_balances(_pool)

@external
@view
def get_lp_token(_pool: address) -> address:
    return self.base_registry.get_token(_pool)

@external
@view
def get_gauges(_pool: address) -> (address[10], int128[10]):
    gauges: address[10] = empty(address[10])
    types: int128[10] = empty(int128[10])
    gauges[0] = self.base_registry.get_gauge(_pool)
    types[0] = GaugeController(GAUGE_CONTROLLER).gauge_types(gauges[0])
    return (gauges, types)