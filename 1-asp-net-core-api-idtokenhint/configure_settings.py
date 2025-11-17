#!/usr/bin/env python3

from __future__ import annotations
import json
from pathlib import Path
from typing import Any, Dict, Optional
import logging
import os
import argparse

'''
Utility functions to load and parse JSON configuration files,
specifically for configuring app settings in an ASP.NET Core Blazor project.
'''

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

def load_json_file(path, encoding = "utf-8"):
    """
    Load and parse a JSON file into a dict.

    Raises:
        FileNotFoundError: if the file does not exist.
        json.JSONDecodeError: if the file contains invalid JSON.
        ValueError: if the parsed JSON is not a dict.
    """
    p = Path(path)
    with p.open("r", encoding=encoding) as f:
        data = json.load(f)

    if not isinstance(data, dict):
        raise ValueError(f"Expected JSON object at top level in {p}, got {type(data).__name__}")
    return data

def safe_load_json_file(path: Path | str, default: Optional[Dict[str, Any]] = None) -> Optional[Dict[str, Any]]:
    """
    Same as load_json_file but returns `default` on common errors and logs them.
    """
    try:
        return load_json_file(path)
    except FileNotFoundError:
        logger.warning("JSON file not found: %s", path)
    except json.JSONDecodeError as exc:
        logger.warning("Invalid JSON in %s: %s", path, exc)
    except ValueError as exc:
        logger.warning("Unexpected JSON structure in %s: %s", path, exc)
    return default

def parse_app_settings_json(file_path, settings_dict, args):
    '''
    Parse the app settings JSON and update the settings_dict with values from dictionary containing 
    DID credentials.
    '''
    verified_id_settings = settings_dict.get("VerifiedID", {})
    
    verified_id_settings["TenantId"] = args["TENANT_ID"]
    verified_id_settings["ClientId"] = args["CLIENT_ID"]
    verified_id_settings["ClientSecret"] = args["CLIENT_SECRET"]
    verified_id_settings["DidAuthority"] = args["DID_AUTH"]
    verified_id_settings["CredentialManifest"] = args["CRED_MANIFEST"]

    with open(file_path, "w") as json_file:
        json.dump(settings_dict, json_file, indent=4)
        logger.info("Updated app settings JSON at %s", file_path)


def get_app_settings_cli():
    parser = argparse.ArgumentParser(description="Configure app settings from CLI args.")
    
    parser.add_argument("--tenantID", required=True, help="Key-value pairs to set in app settings (e.g. TENANT_ID=xxxx)")
    parser.add_argument("--clientID", required=True, help="Key-value pairs to set in app settings (e.g. CLIENT_ID=yyyy)")
    parser.add_argument("--clientSecret", required=True, help="Key-value pairs to set in app settings (e.g. CLIENT_SECRET=zzzz)")
    parser.add_argument("--didAuth", required=True, help="Key-value pairs to set in app settings (e.g. DID_AUTH=aaaa)")
    parser.add_argument("--credManifest", required=True, help="Key-value pairs to set in app settings (e.g. CRED_MANIFEST=bbbb)")
    
    args = parser.parse_args()
    tenant_id = args.tenantID
    client_id = args.clientID
    client_secret = args.clientSecret
    did_auth = args.didAuth
    cred_manifest = args.credManifest  

    return {
        "TENANT_ID": tenant_id,
        "CLIENT_ID": client_id,
        "CLIENT_SECRET": client_secret,
        "DID_AUTH": did_auth,
        "CRED_MANIFEST": cred_manifest
    }

if __name__ == "__main__":
    get_config = get_app_settings_cli()
    file_path = os.path.join(os.path.dirname(__file__), "appsettings.json")
    app_settings = safe_load_json_file(file_path, default={})
    parse_app_settings_json(file_path, app_settings, get_config)
    logger.info("App settings configuration completed.")