import pytest
import random
import itertools
from brownie import interface

from .abis import stable_factory, stable_registry, crypto_factory, crypto_registry
from .utils.constants import ADDRESS_ZERO


def test_get_coin_indices(metaregistry):
    registries = [
        stable_factory(),
        stable_registry(),
        crypto_factory(),
        crypto_registry(),
    ]

    for i, registry in enumerate(registries):
        for pool_index in range(
            registry.pool_count()
        ):  # range(min(10, registry.pool_count())):
            pool = registry.pool_list(pool_index)

            is_meta = metaregistry.is_meta(pool)
            pool_coins = [
                coin for coin in metaregistry.get_coins(pool) if coin != ADDRESS_ZERO
            ]

            base_combinations = list(itertools.combinations(pool_coins, 2))
            all_combinations = base_combinations
            if is_meta:
                underlying_coins = [
                    coin
                    for coin in metaregistry.get_underlying_coins(pool)
                    if coin != ADDRESS_ZERO
                ]
                all_combinations = all_combinations + [
                    (pool_coins[0], coin) for coin in underlying_coins
                ]

            for combination in all_combinations:
                if combination[0] == combination[1]:
                    continue
                metaregistry_output = metaregistry.get_coin_indices(
                    pool, combination[0], combination[1]
                )
                if i >= 2:
                    indices = registry.get_coin_indices(
                        pool, combination[0], combination[1]
                    )
                    actual_output = (indices[0], indices[1], False)
                else:
                    actual_output = registry.get_coin_indices(
                        pool, combination[0], combination[1]
                    )

                assert actual_output == metaregistry_output
