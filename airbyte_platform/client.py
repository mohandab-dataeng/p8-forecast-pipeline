# ----- client.py -----

# Description: connexion à l'api de airbyte automatisé pour tout les scripts suivants

# --- Librairies ---

import os
import requests
from dotenv import load_dotenv
from requests.adapters import HTTPAdapter, Retry

# --- Recuperation des credentials .env ---

load_dotenv()

# --- Shema de connexion ---

class AirbyteClient:
    def __init__(self):
        self.base_url = "http://localhost:8000/api/public/v1"
        self.session = requests.Session()
        retries = Retry(total=3, backoff_factor=1, status_forcelist=[500, 502, 503])
        self.session.mount("http://", HTTPAdapter(max_retries=retries))
        self._authenticate()

    def _authenticate(self):
        resp = self.session.post(
            f"{self.base_url}/applications/token",
            json={
                "client_id": os.environ["CLIENT_ID"],
                "client_secret": os.environ["CLIENT_SECRET"],
                "grant-type": "client_credentials",
            },
        )
        resp.raise_for_status()
        token = resp.json()["access_token"]
        self.session.headers["Authorization"] = f"Bearer {token}"

    def _request(self, method, path, **kwargs):

        resp = self.session.request(method, f"{self.base_url}{path}", **kwargs)
        resp.raise_for_status()
        return resp.json()

if __name__ == "__main__":
    client = AirbyteClient()
    print("Auth OK :", client.session.headers.get("Authorization")[:20], "...")