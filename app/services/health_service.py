# app/services/health_service.py

import requests
from typing import Dict
from app.utils.helpers import get_env_var

API_BASE_URL = get_env_var("EXTERNAL_API_URL", "https://example.com/api")

def get_health_data(user_id: str) -> Dict:
    """
    Fetch health data for a user from an external API.
    """
    try:
        response = requests.get(f"{API_BASE_URL}/user/{user_id}/health")
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        return {"error": str(e)}
