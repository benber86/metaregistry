from brownie import Contract
import json
import os

with open(
    os.path.join(os.path.dirname(os.path.realpath(__file__)), "CurvePool.json"), "r"
) as fp:
    CURVE_V1_ABI = json.load(fp)
with open(
    os.path.join(os.path.dirname(os.path.realpath(__file__)), "CurvePoolV2.json"), "r"
) as fp:
    CURVE_V2_ABI = json.load(fp)


def curve_pool(_pool: str) -> Contract:
    return Contract.from_abi(name="CurveV1", address=_pool, abi=CURVE_V1_ABI)


def curve_pool_v2(_pool: str) -> Contract:
    return Contract.from_abi(name="CurveV2", address=_pool, abi=CURVE_V2_ABI)
