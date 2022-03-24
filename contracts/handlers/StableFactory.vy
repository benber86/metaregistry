# @version 0.2.15
"""
@title Curve Registry Handler for v1 Factory (latest)
@license MIT
"""

MAX_METAREGISTRY_COINS: constant(int128) = 8
MAX_COINS: constant(int128) = 4
MAX_POOLS: constant(int128) = 128


interface BaseRegistry:
    def get_coins(_pool: address) -> address[MAX_COINS]: view
    def get_underlying_coins(_pool: address) -> address[MAX_COINS]: view
    def get_decimals(_pool: address) -> uint256[MAX_COINS]: view
    def get_underlying_decimals(_pool: address) -> uint256[MAX_METAREGISTRY_COINS]: view
    def get_balances(_pool: address) -> uint256[MAX_COINS]: view
    def get_underlying_balances(_pool: address) -> uint256[MAX_METAREGISTRY_COINS]: view
    def get_gauge(_pool: address) -> address: view
    def get_n_coins(_pool: address) -> uint256: view
    def get_pool_asset_type(_pool: address) -> uint256: view
    def is_meta(_pool: address) -> bool: view
    def pool_count() -> uint256: view
    def pool_list(pool_id: uint256) -> address: view

interface MetaRegistry:
    def admin() -> address: view
    def update_internal_pool_registry(_pool: address, _incremented_index: uint256): nonpayable
    def registry_length() -> uint256: view

interface AddressProvider:
    def get_address(_id: uint256) -> address: view

interface CurvePool:
    def balances(i: uint256) -> uint256: view

interface CurveLegacyPool:
    def balances(i: int128) -> uint256: view

interface ERC20:
    def balanceOf(_addr: address) -> uint256: view
    def decimals() -> uint256: view
    def totalSupply() -> uint256: view
    def name() -> String[64]: view

interface GaugeController:
    def gauge_types(gauge: address) -> int128: view

metaregistry: public(address)
base_registry: public(BaseRegistry)
total_pools: public(uint256) 
admin: public(address)
registry_index: uint256
registry_id: uint256

ADDRESS_PROVIDER: constant(address) = 0x0000000022D53366457F9d5E68Ec105046FC4383
BTC_BASE_POOL: constant(address) = 0x7fC77b5c7614E1533320Ea6DDc2Eb61fa00A9714
GAUGE_CONTROLLER: constant(address) = 0x2F50D538606Fa9EDD2B11E2446BEb18C9D5846bB

@external
def __init__(_metaregistry: address, _id: uint256):
    self.metaregistry = _metaregistry
    self.base_registry = BaseRegistry(AddressProvider(ADDRESS_PROVIDER).get_address(_id))
    self.registry_id = _id
    self.registry_index = MetaRegistry(_metaregistry).registry_length()

@internal
@view
def _get_btc_underlying_balances(_pool: address) -> uint256[MAX_METAREGISTRY_COINS]:
    """
    @notice Get balances for each underlying coin within a metapool
    @dev  Used with BTC factory metapools that do not have a base_pool attribute
    @param _pool Metapool address
    @return uint256 list of underlying balances
    """

    underlying_balances: uint256[MAX_METAREGISTRY_COINS] = empty(uint256[MAX_METAREGISTRY_COINS])
    underlying_balances[0] = CurvePool(_pool).balances(0)

    base_total_supply: uint256 = ERC20(self.base_registry.get_coins(_pool)[1]).totalSupply()
    if base_total_supply > 0:
        underlying_pct: uint256 = CurvePool(_pool).balances(1) * 10**36 / base_total_supply
        for i in range(3):
            underlying_balances[i + 1] = CurveLegacyPool(BTC_BASE_POOL).balances(i) * underlying_pct / 10**36
    return underlying_balances

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

@external
@view
def get_coins(_pool: address) -> address[MAX_METAREGISTRY_COINS]:
    _coins: address[MAX_COINS] = self.base_registry.get_coins(_pool)
    _padded_coins: address[MAX_METAREGISTRY_COINS] = empty(address[MAX_METAREGISTRY_COINS])
    for i in range(MAX_COINS):
        _padded_coins[i] = _coins[i]
    return _padded_coins


@external
@view
def get_n_coins(_pool: address) -> uint256:
    return self.base_registry.get_n_coins(_pool)


@external
@view
def get_underlying_coins(_pool: address) -> address[MAX_METAREGISTRY_COINS]:
    _coins: address[MAX_COINS] = self.base_registry.get_underlying_coins(_pool)
    _padded_coins: address[MAX_METAREGISTRY_COINS] = empty(address[MAX_METAREGISTRY_COINS])
    for i in range(MAX_COINS):
        _padded_coins[i] = _coins[i]
    return _padded_coins


@external
@view
def get_decimals(_pool: address) -> uint256[MAX_METAREGISTRY_COINS]:
    return self._pad_uint_array(self.base_registry.get_decimals(_pool))

@external
@view
def get_underlying_decimals(_pool: address) -> uint256[MAX_METAREGISTRY_COINS]:
    return self.base_registry.get_underlying_decimals(_pool)

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
    if not (self.base_registry.is_meta(_pool)):
        return self._get_balances(_pool)
    if (self.base_registry.get_pool_asset_type(_pool) == 2):
        # some metapools (BTC) do not have a base_pool attribute so some registry functions 
        # will revert because the pools are not recognized as metapools.
        return self._get_btc_underlying_balances(_pool)
    return self.base_registry.get_underlying_balances(_pool)

@external
@view
def get_lp_token(_pool: address) -> address:
    return _pool

@external
@view
def get_gauges(_pool: address) -> (address[10], int128[10]):
    gauges: address[10] = empty(address[10])
    types: int128[10] = empty(int128[10])
    gauges[0] = self.base_registry.get_gauge(_pool)
    types[0] = GaugeController(GAUGE_CONTROLLER).gauge_types(gauges[0])
    return (gauges, types)

@external
@view
def is_meta(_pool: address) -> bool:
    return self.base_registry.is_meta(_pool)

@external
@view
def get_pool_name(_pool: address) -> String[64]:
    if self.base_registry.get_n_coins(_pool) > 0:
        return ERC20(_pool).name()
    else:
        return ""
