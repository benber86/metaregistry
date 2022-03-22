import pytest

@pytest.mark.parametrize("pools", [("StableRegistry", "0xF178C0b5Bb7e7aBF4e12A4838C7b7c5bA2C623c0"),
                              ("StableFactory", "0x04EcD49246bf5143E43e2305136c46AeB6fAd400"),
                              ("CryptoRegistry", "0xD51a44d3FaE010294C616388b506AcdA1bfAAE46"),
                              ("CryptoFactory", "0x941Eb6F616114e4Ecaa85377945EA306002612FE")])
def test_get_coins(metaregistry, pools):
    pool_type, pool = pools
    coins = metaregistry.get_coins(pool)
    print(f"{pool} ({pool_type}): {coins}")