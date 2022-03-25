# @version 0.2.15
"""
@title Curve Registry Handler for v1 Registry
@license MIT
"""

MAX_COINS: constant(int128) = 8
MAX_POOLS: constant(int128) = 128

interface BaseRegistry:
    def get_coins(_pool: address) -> address[MAX_COINS]: view
    def get_A(_pool: address) -> uint256: view
    def get_underlying_coins(_pool: address) -> address[MAX_COINS]: view
    def get_decimals(_pool: address) -> uint256[MAX_COINS]: view
    def get_underlying_decimals(_pool: address) -> uint256[MAX_COINS]: view
    def get_balances(_pool: address) -> uint256[MAX_COINS]: view
    def get_underlying_balances(_pool: address) -> uint256[MAX_COINS]: view
    def get_admin_balances(_pool: address) -> uint256[MAX_COINS]: view
    def get_gauges(_pool: address) -> (address[10], int128[10]): view
    def get_lp_token(_pool: address) -> address: view
    def get_virtual_price_from_lp_token(_token: address) -> uint256: view
    def get_pool_name(_pool: address) -> String[64]: view
    def get_pool_asset_type(_pool: address) -> uint256: view
    def get_n_coins(_pool: address) -> uint256[2]: view
    def get_fees(_pool: address) -> uint256[2]: view
    def pool_count() -> uint256: view
    def pool_list(pool_id: uint256) -> address: view
    def is_meta(_pool: address) -> bool: view

interface MetaRegistry:
    def admin() -> address: view
    def update_internal_pool_registry(_pool: address, _incremented_index: uint256): nonpayable
    def registry_length() -> uint256: view
    def update_lp_token_mapping(_pool: address, _token: address): nonpayable

interface AddressProvider:
    def get_address(_id: uint256) -> address: view

metaregistry: public(address)
base_registry: public(BaseRegistry)
total_pools: public(uint256) 
registry_index: uint256
registry_id: uint256


ADDRESS_PROVIDER: constant(address) = 0x0000000022D53366457F9d5E68Ec105046FC4383

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
    return self.base_registry.get_n_coins(_pool)[0] > 0

@internal
@view
def _get_lp_token(_pool: address) -> address:
    return self.base_registry.get_lp_token(_pool)

@external
def sync_pool_list():
    """
    @notice Records any newly added pool on the metaregistry
    @dev To be called from the metaregistry
    @dev In the event of a removal on the registry, sync will be unreliable. A manual update is required
    """
    assert msg.sender == self.metaregistry
    pool_count: uint256 = self.base_registry.pool_count()
    last_pool: uint256 = self.total_pools
    for i in range(last_pool, last_pool + MAX_POOLS):
        if i == pool_count:
            break
        _pool: address = self.base_registry.pool_list(i)
        MetaRegistry(self.metaregistry).update_internal_pool_registry(_pool, self.registry_index + 1)
        MetaRegistry(self.metaregistry).update_lp_token_mapping(_pool, self._get_lp_token(_pool))
        self.total_pools += 1

@external
def remove_pool(_pool: address):
    """
    @notice Removes a pool from the metaregistry
    @dev To be called from the metaregistry
    @dev To be used when a pool is removed from the registry
    @dev A removed registry pool may hide a new pool
    """
    assert msg.sender == self.metaregistry
    MetaRegistry(self.metaregistry).update_internal_pool_registry(_pool, 0)
    MetaRegistry(self.metaregistry).update_lp_token_mapping(ZERO_ADDRESS, self._get_lp_token(_pool))
    self.total_pools -= 1

@external
def add_pool(_pool: address):
    """
    @notice Add a pool to the metaregistry
    @dev To be called from the metaregistry
    @dev To be used when a pool was added to the base registry before a pool removal
    """
    assert msg.sender == self.metaregistry
    MetaRegistry(self.metaregistry).update_internal_pool_registry(_pool, self.registry_index + 1)
    MetaRegistry(self.metaregistry).update_lp_token_mapping(_pool, self._get_lp_token(_pool))
    self.total_pools -= 1


@external
@view
def get_coins(_pool: address) -> address[MAX_COINS]:
    return self.base_registry.get_coins(_pool)


@external
@view
def get_n_coins(_pool: address) -> uint256:
    return self.base_registry.get_n_coins(_pool)[0]


@external
@view
def get_underlying_coins(_pool: address) -> address[MAX_COINS]:
    return self.base_registry.get_underlying_coins(_pool)


@external
@view
def get_decimals(_pool: address) -> uint256[MAX_COINS]:
    return self.base_registry.get_decimals(_pool)


@external
@view
def get_underlying_decimals(_pool: address) -> uint256[MAX_COINS]:
    return self.base_registry.get_underlying_decimals(_pool)

@external
@view
def get_balances(_pool: address) -> uint256[MAX_COINS]:
    return self.base_registry.get_balances(_pool)

@external
@view
def get_underlying_balances(_pool: address) -> uint256[MAX_COINS]:
    return self.base_registry.get_underlying_balances(_pool)

@external
@view
def get_lp_token(_pool: address) -> address:
    return self._get_lp_token(_pool)

@external
@view
def get_gauges(_pool: address) -> (address[10], int128[10]):
    return self.base_registry.get_gauges(_pool)

@external
@view
def is_meta(_pool: address) -> bool:
    return self.base_registry.is_meta(_pool)

@external
@view
def get_pool_name(_pool: address) -> String[64]:
    return self.base_registry.get_pool_name(_pool)

@external
@view
def get_fees(_pool: address) -> uint256[10]:
    fees: uint256[10] = empty(uint256[10])
    pool_fees: uint256[2] = self.base_registry.get_fees(_pool)
    for i in range(2):
        fees[i] = pool_fees[i]
    return fees

@external
@view
def get_admin_balances(_pool: address) -> uint256[MAX_COINS]:
    return self.base_registry.get_admin_balances(_pool)

@external
@view
def get_pool_asset_type(_pool: address) -> uint256:
    return self.base_registry.get_pool_asset_type(_pool)

@external
@view
def get_A(_pool: address) -> uint256:
    return self.base_registry.get_A(_pool)

@external
@view
def get_D(_pool: address) -> uint256:
    return 0

@external
@view
def get_gamma(_pool: address) -> uint256:
    return 0

@external
@view
def get_virtual_price_from_lp_token(_token: address) -> uint256:
    return self.base_registry.get_virtual_price_from_lp_token(_token)