# @version 0.2.15
"""
@title Curve Registry Handler for v2 Crypto Registry
@license MIT
"""

MAX_COINS: constant(int128) = 8
MAX_POOLS: constant(int128) = 128


interface BaseRegistry:
    def get_coins(_pool: address) -> address[MAX_COINS]: view
    def get_decimals(_pool: address) -> uint256[MAX_COINS]: view
    def get_balances(_pool: address) -> uint256[MAX_COINS]: view
    def get_gauge(_pool: address) -> address: view
    def get_n_coins(_pool: address) -> uint256: view
    def pool_count() -> uint256: view
    def pool_list(pool_id: uint256) -> address: view

interface MetaRegistry:
    def admin() -> address: view
    def update_internal_pool_registry(_pool: address, _incremented_index: uint256): nonpayable
    def registry_length() -> uint256: view

interface AddressProvider:
    def get_address(_id: uint256) -> address: view

address_provider: constant(address) = 0x0000000022D53366457F9d5E68Ec105046FC4383
metaregistry: public(address)
base_registry: public(BaseRegistry)
total_pools: public(uint256) 
registry_index: uint256
registry_id: uint256


@external
def __init__(_metaregistry: address, _id: uint256):
    self.metaregistry = _metaregistry
    self.base_registry = BaseRegistry(AddressProvider(address_provider).get_address(_id))
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
    @dev In the event of a removal on the registry, sync will be unreliable. A manual update is required
    """
    assert msg.sender == self.metaregistry
    pool_count: uint256 = self.base_registry.pool_count()
    last_pool: uint256 = self.total_pools
    for i in range(last_pool, last_pool + MAX_POOLS):
        if i == pool_count:
            break
        MetaRegistry(self.metaregistry).update_internal_pool_registry(self.base_registry.pool_list(i), self.registry_index + 1)
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
    self.total_pools -= 1


@external
@view
def get_coins(_pool: address) -> address[MAX_COINS]:
    return self.base_registry.get_coins(_pool)


@external
@view
def get_n_coins(_pool: address) -> uint256:
    return self.base_registry.get_n_coins(_pool)


@external
@view
def get_underlying_coins(_pool: address) -> address[MAX_COINS]:
    return self.base_registry.get_coins(_pool)


@external
@view
def get_decimals(_pool: address) -> uint256[MAX_COINS]:
    return self.base_registry.get_decimals(_pool)


@external
@view
def get_underlying_decimals(_pool: address) -> uint256[MAX_COINS]:
    return self.base_registry.get_decimals(_pool)