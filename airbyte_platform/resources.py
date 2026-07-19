from client import AirbyteClient
import time

def get_workspace_id(client, name="Default Workspace"):
    resp = client._request("GET", "/workspaces")
    ws = next((w for w in resp["data"] if w["name"] == name), None)
    return ws["workspaceId"] if ws else None 

def get_source_definition_id(client, workspace_id, name):
    resp = client._request("GET", f"/workspaces/{workspace_id}/definitions/sources")
    d = next((x for x in resp["data"] if x["name"] == name), None)
    return d["id"] if d else None

def get_destination_definition_id(client, workspace_id, name):
    resp = client._request("GET", f"/workspaces/{workspace_id}/definitions/destinations")
    d = next((x for x in resp["data"] if x["name"] == name), None)
    return d["id"] if d else None

def get_or_create_source(client, workspace_id, name, definition_id, config):
    resp = client._request("GET", f"/sources?workspaceId={workspace_id}")
    existing = next((s for s in resp["data"] if s["name"] == name), None)
    if existing:
        return existing["sourceId"]
    payload = {
        "name": name,
        "workspaceId": workspace_id,
        "definitionId": definition_id,
        "configuration": config,
    }
    return client._request("POST", "/sources", json=payload)["sourceId"]

def get_or_create_destination(client, workspace_id, name, definition_id, config):
    resp = client._request("GET", f"/destinations?workspaceId={workspace_id}")
    existing = next((d for d in resp["data"] if d["name"] == name), None)    
    if existing:
        return existing["destinationId"]
    payload = {
        "name": name,
        "workspaceId": workspace_id,
        "definitionId": definition_id,
        "configuration": config,
    }
    return client._request("POST", "/destinations", json=payload)["destinationId"]

def get_or_create_connection(client, workspace_id, source_id, destination_id, name):
    resp = client._request("GET", f"/connections?workspaceId={workspace_id}")
    existing = next((c for c in resp["data"] if c["name"] == name), None)
    if existing:
        return existing["connectionId"]
    payload = {
        "name": name,
        "sourceId": source_id,
        "destinationId": destination_id,
        "namespaceDefinition": "destination", 
    }
    return client._request("POST", "/connections", json=payload)["connectionId"]

def trigger_sync(client, connection_id):
    payload = {
        "connectionId": connection_id,
        "jobType": "sync",
    }
    return client._request("POST", "/jobs", json=payload)

def wait_for_sync(client, job_id):
    while True:
        job = client._request("GET", f"/jobs/{job_id}")
        status = job["status"]
        print(f"   job {job_id} : {status}")

        if status in ("succeeded", "failed", "incomplete", "cancelled"):
            return status

        time.sleep(1)                                       
