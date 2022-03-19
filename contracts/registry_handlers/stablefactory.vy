# @version 0.2.15
"""
@title Curve Meta Registry
@license MIT
"""

MAX_COINS: constant(int128) = 8
MAX_POOLS: constant(int128) = 128


interface Factory:
    def get_coins(_pool: address) -> address[MAX_COINS]: view
    def get_decimals(_pool: address) -> uint256[MAX_COINS]: view
    def get_balances(_pool: address) -> uint256[MAX_COINS]: view
    def get_gauge(_pool: address) -> address: view
    def get_n_coins(_pool: address) -> uint256: view
    def pool_count() -> uint256: view
    def pool_list(pool_id: uint256) -> address: view

interface MetaRegistry:
    def admin() -> address: view
    def update_internal_pool_registry(_pool: address, _index: uint256): nonpayable

metaregistry: public(address)
factory: public(Factory)
total_pools: public(uint256) 
registry_index: uint256


@external
def __init__(_metaregistry: address, _factory: address, _index: uint256):
    self.metaregistry = _metaregistry
    self.factory = Factory(_factory)
    self.registry_index = _index


@external
@view
def is_registered(_pool: address) -> bool:
    return self.factory.get_n_coins(_pool) > 0

@external
def sync_pool_list():
    assert msg.sender == self.metaregistry
    pool_count: uint256 = self.factory.pool_count()
    last_pool: uint256 = self.total_pools
    for i in range(last_pool, last_pool + MAX_POOLS):
        if i == pool_count:
            break
        MetaRegistry(self.metaregistry).update_internal_pool_registry(self.factory.pool_list(i), self.registry_index)
        self.total_pools += 1

@external
@view
def get_coins(_pool: address) -> address[MAX_COINS]:
    return self.factory.get_coins(_pool)