from client import AirbyteClient

def get_workspace_id(client):
    resp = client._request("GET", "/workspaces")
    return resp["data"][0]["workspaceId"]

if __name__ == "__main__":
    client = AirbyteClient()
    print(get_workspace_id(client))

