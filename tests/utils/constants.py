from dataclasses import dataclass
from typing import Tuple


@dataclass
class Pool:
    address: str
    coins: Tuple[str, str, str, str, str, str, str, str]
    n_coins: int
    underlying_coins: Tuple[str, str, str, str, str, str, str, str]


LINK_POOL = Pool(
    address="0xF178C0b5Bb7e7aBF4e12A4838C7b7c5bA2C623c0",
    coins=(
        "0x514910771AF9Ca656af840dff83E8264EcF986CA",
        "0xbBC455cb4F1B9e4bFC4B73970d360c8f032EfEE6",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
    ),
    n_coins=2,
    underlying_coins=(
        "0x514910771AF9Ca656af840dff83E8264EcF986CA",
        "0xbBC455cb4F1B9e4bFC4B73970d360c8f032EfEE6",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
    ),
)

MIM_METAPOOL = Pool(
    address="0x5a6A4D54456819380173272A5E8E9B9904BdF41B",
    coins=(
        "0x99D8a9C45b2ecA8864373A26D1459e3Dff1e17F3",
        "0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
    ),
    n_coins=2,
    underlying_coins=(
        "0x99D8a9C45b2ecA8864373A26D1459e3Dff1e17F3",
        "0x6B175474E89094C44Da98b954EedeAC495271d0F",
        "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
        "0xdAC17F958D2ee523a2206206994597C13D831ec7",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
    ),
)

DYDX_STAKED_POOL = Pool(
    address="0x04EcD49246bf5143E43e2305136c46AeB6fAd400",
    coins=(
        "0x92D6C1e31e14520e676a687F0a93788B716BEff5",
        "0x65f7BA4Ec257AF7c55fd5854E5f6356bBd0fb8EC",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
    ),
    n_coins=2,
    underlying_coins=(
        "0x92D6C1e31e14520e676a687F0a93788B716BEff5",
        "0x65f7BA4Ec257AF7c55fd5854E5f6356bBd0fb8EC",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
    ),
)

BBTC_METAPOOL = Pool(
    address="0xFbdCA68601f835b27790D98bbb8eC7f05FDEaA9B",
    coins=(
        "0x8751D4196027d4e6DA63716fA7786B5174F04C15",
        "0x075b1bb99792c9E1041bA13afEf80C91a1e70fB3",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
    ),
    n_coins=2,
    underlying_coins=(
        "0x8751D4196027d4e6DA63716fA7786B5174F04C15",
        "0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D",
        "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599",
        "0xfE18be6b3Bd88A2D2A7f928d00292E7a9963CfC6",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
    ),
)

TRICRYPTO_POOL = Pool(
    address="0xD51a44d3FaE010294C616388b506AcdA1bfAAE46",
    coins=(
        "0xdAC17F958D2ee523a2206206994597C13D831ec7",
        "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599",
        "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
    ),
    n_coins=3,
    underlying_coins=(
        "0xdAC17F958D2ee523a2206206994597C13D831ec7",
        "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599",
        "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
    ),
)

FXS_ETH_POOL = Pool(
    address="0x941Eb6F616114e4Ecaa85377945EA306002612FE",
    coins=(
        "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        "0x3432B6A60D23Ca0dFCa7761B7ab56459D9C964D0",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
    ),
    n_coins=2,
    underlying_coins=(
        "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        "0x3432B6A60D23Ca0dFCa7761B7ab56459D9C964D0",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
        "0x0000000000000000000000000000000000000000",
    ),
)