def test_google_login(client, monkeypatch):
    def fake_verify(token, client_id):
        return {
            "sub": "google-123",
            "email": "user@example.com",
            "name": "Test User",
        }

    monkeypatch.setattr("app.api.auth.verify_google_id_token", fake_verify)

    response = client.post("/api/auth/google", json={"id_token": "fake"})
    assert response.status_code == 200
    data = response.json()
    assert data["token"]["access_token"]
    assert data["email"] == "user@example.com"


def test_phone_otp_flow(client):
    send_resp = client.post("/api/auth/phone/send-otp", json={"phone_number": "+1234567890"})
    assert send_resp.status_code == 200

    verify_resp = client.post(
        "/api/auth/phone/verify-otp",
        json={"phone_number": "+1234567890", "otp": "123456"},
    )
    assert verify_resp.status_code == 200
    data = verify_resp.json()
    assert data["token"]["access_token"]
