# app/utils/helpers.py

import os

def get_env_var(key: str, default: str = None) -> str:
    """
    Read environment variable or return default.
    """
    value = os.getenv(key)
    if value is None:
        return default
    return value

def calculate_risk_level(score: float) -> str:
    """
    Example utility to calculate risk level.
    """
    if score < 30:
        return "low"
    elif score < 70:
        return "moderate"
    else:
        return "high"
