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
