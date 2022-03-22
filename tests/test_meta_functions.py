import pytest
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
