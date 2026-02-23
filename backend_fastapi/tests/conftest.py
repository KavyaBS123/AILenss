import pytest
from fastapi.testclient import TestClient
from sqlmodel import SQLModel, Session
from app.core.database import engine, get_session
from main import app


def override_get_session():
    with Session(engine) as session:
        yield session


@pytest.fixture(scope="session", autouse=True)
def prepare_database():
    SQLModel.metadata.create_all(engine)
    yield
    SQLModel.metadata.drop_all(engine)


@pytest.fixture(scope="session")
def client():
    app.dependency_overrides[get_session] = override_get_session
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()
