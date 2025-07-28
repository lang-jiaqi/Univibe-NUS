import mysql.connector
from .config import DB_CONFIG

def get_connection():
    """Create a new database connection."""
    return mysql.connector.connect(**DB_CONFIG)
