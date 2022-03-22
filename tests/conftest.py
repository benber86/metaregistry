import pytest
from brownie import interface, MetaRegistry, StableRegistry, CryptoRegistry, StableFactory, CryptoFactory


@pytest.fixture(scope="session")
def alice(accounts):
    yield accounts[1]


@pytest.fixture(scope="session")
def bob(accounts):
    yield accounts[2]


@pytest.fixture(scope="session")
def charlie(accounts):
    yield accounts[3]


@pytest.fixture(scope="session")
def dave(accounts):
    yield accounts[4]


@pytest.fixture(scope="session")
def erin(accounts):
    yield accounts[5]


@pytest.fixture(scope="session")
def owner(accounts):
    yield accounts[0]


@pytest.fixture(scope="module")
def metaregistry(owner):
    yield MetaRegistry.deploy(owner, {"from": owner})


@pytest.fixture(scope="module")
def stable_registry_handler(owner, metaregistry):
    handler = StableRegistry.deploy(metaregistry, 0, {"from": owner})
    metaregistry.add_registry_by_address_provider_id(0, handler, {"from": owner})
    yield handler


@pytest.fixture(scope="module")
def stable_factory_handler(owner, metaregistry):
    handler = StableFactory.deploy(metaregistry, 3, {"from": owner})
    metaregistry.add_registry_by_address_provider_id(3, handler, {"from": owner})
    yield handler


@pytest.fixture(scope="module")
def crypto_registry_handler(owner, metaregistry):
    handler = CryptoRegistry.deploy(metaregistry, 5, {"from": owner})
    metaregistry.add_registry_by_address_provider_id(5, handler, {"from": owner})
    yield handler


@pytest.fixture(scope="module")
def crypto_factory_handler(owner, metaregistry):
    handler = CryptoFactory.deploy(metaregistry, 6, {"from": owner})
    metaregistry.add_registry_by_address_provider_id(6, handler, {"from": owner})
    yield handler


@pytest.fixture(scope="module", autouse=True)
def sync_registries(metaregistry,
                    stable_factory_handler,
                    stable_registry_handler,
                    crypto_factory_handler,
                    crypto_registry_handler,
                    owner):
    metaregistry.sync({"from": owner})

