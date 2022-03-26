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

struct PoolInfo:
    registry: uint256
    location: uint256

struct AddressInfo:
    addr: address
    is_active: bool
    version: uint256
    last_modified: uint256
    description: String[64]

struct CoinInfo:
    index: uint256
    register_count: uint256
    swap_count: uint256
    swap_for: address[MAX_INT128]

interface AddressProvider:
    def admin() -> address: view
    def get_address(_id: uint256) -> address: view
    def get_id_info(_id: uint256) -> AddressInfo: view

interface RegistryHandler:
    def sync_pool_list(_limit: uint256): nonpayable
    def reset_pool_list(): nonpayable
    def get_coins(_pool: address) -> address[MAX_COINS]: view
    def get_A(_pool: address) -> uint256: view
    def get_D(_pool: address) -> uint256: view
    def get_gamma(_pool: address) -> uint256: view
    def get_n_coins(_pool: address) -> uint256: view
    def get_underlying_coins(_pool: address) -> address[MAX_COINS]: view
    def get_decimals(_pool: address) -> uint256[MAX_COINS]: view
    def get_underlying_decimals(_pool: address) -> uint256[MAX_COINS]: view
    def get_balances(_pool: address) -> uint256[MAX_COINS]: view
    def get_underlying_balances(_pool: address) -> uint256[MAX_COINS]: view
    def get_admin_balances(_pool: address) -> uint256[MAX_COINS]: view
    def get_pool_asset_type(_pool: address) -> uint256: view
    def get_lp_token(_pool: address) -> address: view
    def get_virtual_price_from_lp_token(_token: address) -> uint256: view
    def get_gauges(_pool: address) -> (address[10], int128[10]): view
    def is_meta(_pool: address) -> bool: view
    def get_pool_name(_pool: address) -> String[64]: view
    def get_fees(_pool: address) -> uint256[10]: view
    def get_n_underlying_coins(_pool: address) -> uint256: view

registry_length: public(uint256)
get_registry: public(HashMap[uint256, Registry])
internal_pool_registry: public(HashMap[address, PoolInfo])
get_pool_from_lp_token: public(HashMap[address, address])
authorized_registries: HashMap[address, bool]
admin: public(address)
address_provider: public(AddressProvider)
pool_count: uint256
pool_list: public(address[65536])

# mapping of coins -> pools for trading
# a mapping key is generated for each pair of addresses via
# `bitwise_xor(convert(a, uint256), convert(b, uint256))`
markets: HashMap[uint256, address[65536]]
market_counts: HashMap[uint256, uint256]
coin_count: public(uint256)  # total unique coins registered
coins: HashMap[address, CoinInfo]
get_coin: public(address[65536])  # unique list of registered coins
# bitwise_xor(coina, coinb) -> (coina_pos, coinb_pos) sorted
# stored as uint128[2]
coin_swap_indexes: HashMap[uint256, uint256]


@external
def __init__(_admin: address):
    self.admin = _admin
    self.address_provider = AddressProvider(0x0000000022D53366457F9d5E68Ec105046FC4383)

@internal
def _register_coin(_coin: address):
    if self.coins[_coin].register_count == 0:
        coin_count: uint256 = self.coin_count
        self.coins[_coin].index = coin_count
        self.get_coin[coin_count] = _coin
        self.coin_count += 1
    self.coins[_coin].register_count += 1

@internal
def _register_coin_pair(_coina: address, _coinb: address, _key: uint256):
    # register _coinb in _coina's array of coins
    coin_b_pos: uint256 = self.coins[_coina].swap_count
    self.coins[_coina].swap_for[coin_b_pos] = _coinb
    self.coins[_coina].swap_count += 1
    # register _coina in _coinb's array of coins
    coin_a_pos: uint256 = self.coins[_coinb].swap_count
    self.coins[_coinb].swap_for[coin_a_pos] = _coina
    self.coins[_coinb].swap_count += 1
    # register indexes (coina pos in coinb array, coinb pos in coina array)
    if convert(_coina, uint256) < convert(_coinb, uint256): 
        self.coin_swap_indexes[_key] = shift(coin_a_pos, 128) + coin_b_pos
    else:
        self.coin_swap_indexes[_key] = shift(coin_b_pos, 128) + coin_a_pos

@internal
def _unregister_coin(_coin: address):
    self.coins[_coin].register_count -= 1

    if self.coins[_coin].register_count == 0:
        self.coin_count -= 1
        coin_count: uint256 = self.coin_count
        location: uint256 = self.coins[_coin].index

        if location < coin_count:
            coin_b: address = self.get_coin[coin_count]
            self.get_coin[location] = coin_b
            self.coins[coin_b].index = location

        self.coins[_coin].index = 0
        self.get_coin[coin_count] = ZERO_ADDRESS

@internal
def _unregister_coin_pair(_coina: address, _coinb: address, _coinb_idx: uint256):
    """
    @param _coinb_idx the index of _coinb in _coina's array of unique coin's 
    """
    # decrement swap counts for both coins
    self.coins[_coina].swap_count -= 1

    # retrieve the last currently occupied index in coina's array
    coina_arr_last_idx: uint256 = self.coins[_coina].swap_count

    # if coinb's index in coina's array is less than the last
    # overwrite it's position with the last coin
    if _coinb_idx < coina_arr_last_idx:
        # here's our last coin in coina's array
        coin_c: address = self.coins[_coina].swap_for[coina_arr_last_idx]
        # get the bitwise_xor of the pair to retrieve their indexes
        key: uint256 = bitwise_xor(convert(_coina, uint256), convert(coin_c, uint256))
        indexes: uint256 = self.coin_swap_indexes[key]

        # update the pairing's indexes
        if convert(_coina, uint256) < convert(coin_c, uint256):
            # least complicated most readable way of shifting twice to remove the lower order bits
            self.coin_swap_indexes[key] = shift(shift(indexes, -128), 128) + _coinb_idx
        else:
            self.coin_swap_indexes[key] = shift(_coinb_idx, 128) + indexes % 2 ** 128
        # set _coinb_idx in coina's array to coin_c
        self.coins[_coina].swap_for[_coinb_idx] = coin_c

    self.coins[_coina].swap_for[coina_arr_last_idx] = ZERO_ADDRESS

@external
def update_coin_map(_pool: address, _coin_list: address[MAX_COINS], _n_coins: uint256):
    assert self.authorized_registries[msg.sender]
    for i in range(MAX_COINS):
        if i == _n_coins:
            break

        self._register_coin(_coin_list[i])
        # add pool to markets
        i2: uint256 = i + 1
        for x in range(i2, i2 + MAX_COINS):
            if x == _n_coins:
                break

            key: uint256 = bitwise_xor(convert(_coin_list[i], uint256), convert(_coin_list[x], uint256))
            length: uint256 = self.market_counts[key]
            self.markets[key][length] = _pool
            self.market_counts[key] = length + 1

            # register the coin pair
            if length == 0:
                self._register_coin_pair(_coin_list[x], _coin_list[i], key)

@external
def update_coin_map_for_underlying(_pool: address, _coins: address[MAX_COINS], _underlying_coins: address[MAX_COINS], _n_coins: uint256):
    is_finished: bool = False
    base_coin_offset: uint256 = _n_coins - 1
    base_n_coins: uint256 = 0
    for i in range(base_coin_offset, base_coin_offset + MAX_COINS):
        if _underlying_coins[i] == ZERO_ADDRESS:
            base_n_coins = i
            break
        else:
            self._register_coin(_underlying_coins[i])

    for i in range(MAX_COINS):
        if i == base_coin_offset:
            break
        for x in range(MAX_COINS):
            if x == base_n_coins:
                break
            key: uint256 = bitwise_xor(convert(_coins[i], uint256), convert(_underlying_coins[x], uint256))
            length: uint256 = self.market_counts[key]
            self.markets[key][length] = _pool
            self.market_counts[key] = length + 1

            # register the coin pair
            if length == 0:
                self._register_coin_pair(_coins[i], _underlying_coins[x], key)

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
def update_lp_token_mapping(_pool: address, _token: address):
    """
    @notice Associate an LP token with a pool for reverse lookup
    @dev Callback function used by the registry handlers when syncing
    @param _pool Address of the pool
    @param _token Address of the pool's LP token
    """
    assert self.authorized_registries[msg.sender]
    self.get_pool_from_lp_token[_token] = _pool

@external
def update_internal_pool_registry(_pool: address, _incremented_index: uint256):
    """
    @notice Update the registry associated with a pool
    @dev Callback function used by the registry handlers when syncing
    @param _pool Pool to update
    @param _incremented_index Index of the associated registry incremented by 1
    """
    assert self.authorized_registries[msg.sender]
    # if deletion
    if _incremented_index == 0:
        location: uint256 = self.internal_pool_registry[_pool].location
        length: uint256 = self.pool_count - 1
        if location < length:
            # replace _pool with final value in pool_list
            addr: address = self.pool_list[length]
            self.pool_list[location] = addr
            self.internal_pool_registry[addr].location = location

        # delete final pool_list value
        self.internal_pool_registry[_pool] = PoolInfo({registry: _incremented_index, location: 0})
        self.pool_list[length] = ZERO_ADDRESS
        self.pool_count = length
        return

    self.internal_pool_registry[_pool] = PoolInfo({registry: _incremented_index, location: self.pool_count})
    self.pool_list[self.pool_count] = _pool
    self.pool_count += 1

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
def _sync_registry(_index: uint256, _limit: uint256):
        registry: Registry = self.get_registry[_index]
        RegistryHandler(registry.registry_handler).sync_pool_list(_limit)

@internal
def _reset_registry(_index: uint256):
        registry: Registry = self.get_registry[_index]
        RegistryHandler(registry.registry_handler).reset_pool_list()

@external
def sync_registry(_index: uint256, _limit: uint256 = 0):
    """
    @notice Sync a particular registry
    @dev Use _limit to split syncs to avoid hitting gas limit
    @param _index Registry index
    @param _limit Max number of pools to sync
    """
    assert msg.sender == self.admin  # dev: admin-only function
    assert _index < self.registry_length
    self._sync_registry(_index, _limit)

@external
def reset_registry(_index: uint256):
    """
    @notice Reset a particular registry
    @param _index Registry index
    """
    assert msg.sender == self.admin  # dev: admin-only function
    assert _index < self.registry_length
    self._reset_registry(_index)

@external
def reset():
    """
    @notice Resets all registries
    """
    assert msg.sender == self.admin  # dev: admin-only function

    for i in range(MAX_REGISTRIES):
        if i == self.registry_length:
            break
        self._reset_registry(i)

@external
def sync():
    """
    @notice Gets all the pools from a registry that are not currently registered
    """
    assert msg.sender == self.admin  # dev: admin-only function

    for i in range(MAX_REGISTRIES):
        if i == self.registry_length:
            break
        self._sync_registry(i, 0)

@internal
@view
def _get_registry_handler_from_pool(_pool: address) -> address:
    registry_index: uint256 = self.internal_pool_registry[_pool].registry
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
def get_n_underlying_coins(_pool: address) -> uint256:
    return RegistryHandler(self._get_registry_handler_from_pool(_pool)).get_n_underlying_coins(_pool)

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

@external
@view
def get_pool_asset_type(_pool: address) -> uint256:
    return RegistryHandler(self._get_registry_handler_from_pool(_pool)).get_pool_asset_type(_pool)

@external
@view
def get_A(_pool: address) -> uint256:
    return RegistryHandler(self._get_registry_handler_from_pool(_pool)).get_A(_pool)

@external
@view
def get_D(_pool: address) -> uint256:
    return RegistryHandler(self._get_registry_handler_from_pool(_pool)).get_D(_pool)

@external
@view
def get_gamma(_pool: address) -> uint256:
    return RegistryHandler(self._get_registry_handler_from_pool(_pool)).get_gamma(_pool)

@external
@view
def get_virtual_price_from_lp_token(_token: address) -> uint256:
    return RegistryHandler(self._get_registry_handler_from_pool(self.get_pool_from_lp_token[_token])).get_virtual_price_from_lp_token(_token)

