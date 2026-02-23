def test_protected_me(client, monkeypatch):
    def fake_verify(token, client_id):
        return {
            "sub": "google-999",
            "email": "me@example.com",
            "name": "Me User",
        }

    monkeypatch.setattr("app.api.auth.verify_google_id_token", fake_verify)

    login = client.post("/api/auth/google", json={"id_token": "fake"})
    assert login.status_code == 200
    token = login.json()["token"]["access_token"]

    me = client.get("/api/users/me", headers={"Authorization": f"Bearer {token}"})
    assert me.status_code == 200
    assert me.json()["email"] == "me@example.com"
