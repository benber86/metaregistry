import pytest
from brownie import interface
from .utils.constants import (
    FXS_ETH_POOL,
    DYDX_STAKED_POOL,
    LINK_POOL,
    TRICRYPTO_POOL,
    MIM_METAPOOL,
    BBTC_METAPOOL,
)
from .abis import curve_pool, curve_pool_v2


@pytest.mark.parametrize(
    "pools",
    [
        ("StableRegistry", LINK_POOL),
        ("StableFactory", DYDX_STAKED_POOL),
        ("CryptoRegistry", TRICRYPTO_POOL),
        ("CryptoFactory", FXS_ETH_POOL),
    ],
)
def test_get_coins(metaregistry, pools):
    pool_type, pool = pools
    coins = metaregistry.get_coins(pool.address)
    assert coins == pool.coins
    print(f"{pool} ({pool_type}): {coins}")


@pytest.mark.parametrize(
    "pools",
    [
        ("StableRegistry", LINK_POOL),
        ("StableFactory", DYDX_STAKED_POOL),
        ("CryptoRegistry", TRICRYPTO_POOL),
        ("CryptoFactory", FXS_ETH_POOL),
    ],
)
def test_get_n_coins(metaregistry, pools):
    pool_type, pool = pools
    n_coins = metaregistry.get_n_coins(pool.address)
    assert n_coins == pool.n_coins
    print(f"{pool} ({pool_type}): {n_coins}")


@pytest.mark.parametrize(
    "pools",
    [
        ("StableRegistry", MIM_METAPOOL),
        ("StableFactory", BBTC_METAPOOL),
        ("CryptoRegistry", TRICRYPTO_POOL),
        ("CryptoFactory", FXS_ETH_POOL),
    ],
)
def test_get_underlying_coins(metaregistry, pools):
    pool_type, pool = pools
    underlying_coins = metaregistry.get_underlying_coins(pool.address)
    assert underlying_coins == pool.underlying_coins
    print(f"{pool} ({pool_type}): {underlying_coins}")


@pytest.mark.parametrize(
    "pools",
    [
        ("StableRegistry", MIM_METAPOOL),
        ("StableFactory", BBTC_METAPOOL),
        ("CryptoRegistry", TRICRYPTO_POOL),
        ("CryptoFactory", FXS_ETH_POOL),
    ],
)
def test_get_decimals(metaregistry, pools):
    pool_type, pool = pools
    decimals = metaregistry.get_decimals(pool.address)
    assert decimals == pool.decimals
    print(f"{pool} ({pool_type}): {decimals}")


@pytest.mark.parametrize(
    "pools",
    [
        ("StableRegistry", MIM_METAPOOL),
        ("StableFactory", BBTC_METAPOOL),
        ("CryptoRegistry", TRICRYPTO_POOL),
        ("CryptoFactory", FXS_ETH_POOL),
    ],
)
def test_get_underlying_decimals(metaregistry, pools):
    pool_type, pool = pools
    underlying_decimals = metaregistry.get_underlying_decimals(pool.address)
    assert underlying_decimals == pool.underlying_decimals
    print(f"{pool} ({pool_type}): {underlying_decimals}")


@pytest.mark.parametrize(
    "pools",
    [
        ("StableRegistry", MIM_METAPOOL),
        ("StableFactory", BBTC_METAPOOL),
        ("CryptoRegistry", TRICRYPTO_POOL),
        ("CryptoFactory", FXS_ETH_POOL),
    ],
)
def test_balances_and_underlying_balances(metaregistry, pools):
    pool_type, pool = pools

    decimals = metaregistry.get_decimals(pool.address)
    balances = metaregistry.get_balances(pool.address)
    for i, balance in enumerate(balances):
        if decimals[i] > 0:
            assert balance > 0
    print(f"{pool} ({pool_type}): {balances}")

    underlying_decimals = metaregistry.get_underlying_decimals(pool.address)
    underlying_balances = metaregistry.get_underlying_balances(pool.address)
    for i, underlying_balance in enumerate(underlying_balances):
        if underlying_decimals[i] > 0:
            assert underlying_balance > 0
    print(f"{pool} ({pool_type}): {underlying_balances}")


@pytest.mark.parametrize(
    "pools",
    [
        ("StableRegistry", MIM_METAPOOL),
        ("StableFactory", BBTC_METAPOOL),
        ("CryptoRegistry", TRICRYPTO_POOL),
        ("CryptoFactory", FXS_ETH_POOL),
    ],
)
def test_get_lp_token(metaregistry, pools):
    pool_type, pool = pools
    lp_token = metaregistry.get_lp_token(pool.address)
    assert lp_token == pool.lp_token
    print(f"{pool} ({pool_type}): {lp_token}")


@pytest.mark.parametrize(
    "pools",
    [
        ("StableRegistry", MIM_METAPOOL),
        ("StableFactory", BBTC_METAPOOL),
        ("CryptoRegistry", TRICRYPTO_POOL),
        ("CryptoFactory", FXS_ETH_POOL),
    ],
)
def test_get_gauges(metaregistry, pools):
    pool_type, pool = pools
    gauges = metaregistry.get_gauges(pool.address)
    assert gauges == pool.gauges
    print(f"{pool} ({pool_type}): {gauges}")


@pytest.mark.parametrize(
    "pools",
    [
        ("StableRegistry", MIM_METAPOOL),
        ("StableFactory", BBTC_METAPOOL),
        ("CryptoRegistry", TRICRYPTO_POOL),
        ("CryptoFactory", FXS_ETH_POOL),
    ],
)
def test_is_meta(metaregistry, pools):
    pool_type, pool = pools
    is_meta = metaregistry.is_meta(pool.address)
    assert is_meta == pool.is_meta
    print(f"{pool} ({pool_type}): {is_meta}")


@pytest.mark.parametrize(
    "pools",
    [
        ("StableRegistry", MIM_METAPOOL),
        ("StableFactory", BBTC_METAPOOL),
        ("CryptoRegistry", TRICRYPTO_POOL),
        ("CryptoFactory", FXS_ETH_POOL),
    ],
)
def test_get_pool_name(metaregistry, pools):
    pool_type, pool = pools
    pool_name = metaregistry.get_pool_name(pool.address)
    assert pool_name == pool.name
    print(f"{pool} ({pool_type}): {pool_name}")


@pytest.mark.parametrize(
    "pools",
    [
        ("StableRegistry", MIM_METAPOOL, 1),
        ("StableFactory", BBTC_METAPOOL, 1),
        ("CryptoRegistry", TRICRYPTO_POOL, 2),
        ("CryptoFactory", FXS_ETH_POOL, 2),
    ],
)
def test_get_pool_fees(metaregistry, pools):
    pool_type, pool, version = pools
    pool_fees = metaregistry.get_fees(pool.address)
    if version == 1:
        contract = curve_pool(pool.address)
        fees = [contract.fee(), contract.admin_fee()] + [0] * 8
    else:
        contract = curve_pool_v2(pool.address)
        fees = [
            contract.fee(),
            contract.admin_fee(),
            contract.mid_fee(),
            contract.out_fee(),
        ] + [0] * 6
    assert pool_fees == fees
    print(f"{pool} ({pool_type}): {pool_fees}")


@pytest.mark.parametrize(
    "pools",
    [
        ("StableRegistry", MIM_METAPOOL, 1),
        ("StableFactory", BBTC_METAPOOL, 1),
        ("CryptoRegistry", TRICRYPTO_POOL, 2),
        ("CryptoFactory", FXS_ETH_POOL, 2),
    ],
)
def test_get_admin_balances(metaregistry, pools):
    pool_type, pool, version = pools
    pool_admin_balances = metaregistry.get_admin_balances(pool.address)
    balances = metaregistry.get_balances(pool.address)
    # TODO : verify actual amounts
    for i, balance in enumerate(balances):
        if balance > 0:
            assert pool_admin_balances[i] >= 0
    print(f"{pool} ({pool_type}): {pool_admin_balances}")


@pytest.mark.parametrize(
    "pools",
    [
        ("StableRegistry", MIM_METAPOOL),
        ("StableFactory", BBTC_METAPOOL),
        ("CryptoRegistry", TRICRYPTO_POOL),
        ("CryptoFactory", FXS_ETH_POOL),
    ],
)
def test_get_pool_asset_type(metaregistry, pools):
    pool_type, pool = pools
    asset_type = metaregistry.get_pool_asset_type(pool.address)
    assert asset_type == pool.asset_type
    print(f"{pool} ({pool_type}): {asset_type}")


@pytest.mark.parametrize(
    "pools",
    [
        ("StableRegistry", MIM_METAPOOL, 1),
        ("StableFactory", BBTC_METAPOOL, 1),
        ("CryptoRegistry", TRICRYPTO_POOL, 2),
        ("CryptoFactory", FXS_ETH_POOL, 2),
    ],
)
def test_get_pool_parameters(metaregistry, pools):
    pool_type, pool, version = pools
    a = metaregistry.get_A(pool.address)
    d = metaregistry.get_D(pool.address)
    gamma = metaregistry.get_gamma(pool.address)
    assert a > 0
    if version == 1:
        assert d == 0
        assert gamma == 0
    else:
        assert d > 0
        assert gamma > 0


@pytest.mark.parametrize(
    "pools",
    [
        ("StableRegistry", MIM_METAPOOL, 1),
        ("StableFactory", BBTC_METAPOOL, 1),
        ("CryptoRegistry", TRICRYPTO_POOL, 2),
        ("CryptoFactory", FXS_ETH_POOL, 2),
    ],
)
def test_get_pool_from_lp_token(metaregistry, pools):
    pool_type, pool, version = pools
    assert pool.address == metaregistry.get_pool_from_lp_token(pool.lp_token)


@pytest.mark.parametrize(
    "pools",
    [
        ("StableRegistry", MIM_METAPOOL, 1),
        ("StableFactory", BBTC_METAPOOL, 1),
        ("CryptoRegistry", TRICRYPTO_POOL, 2),
        ("CryptoFactory", FXS_ETH_POOL, 2),
    ],
)
def test_get_virtual_price_from_lp_token(metaregistry, pools):
    pool_type, pool, version = pools
    assert metaregistry.get_virtual_price_from_lp_token(pool.lp_token) > 0
