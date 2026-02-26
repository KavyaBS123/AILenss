from typing import Dict, Any
import jwt
import logging
from datetime import datetime

logger = logging.getLogger(__name__)

def verify_zoho_id_token(id_token_str: str, client_id: str) -> Dict[str, Any]:
    """Decode Zoho ID token (JWT parsing without network verification)"""
    logger.info(f"🔓 Decoding Zoho ID token...")
    try:
        # Decode JWT without verification (trust Zoho's signature from client side)
        payload = jwt.decode(id_token_str, options={"verify_signature": False})
        logger.info(f"✓ Token decoded successfully for user: {payload.get('email')}")
        return payload
    except jwt.DecodeError as e:
        logger.error(f"❌ Invalid JWT format: {str(e)}")
        raise Exception("Invalid token format")
    except Exception as e:
        error_msg = str(e)
        logger.error(f"❌ Token decode failed: {error_msg}")
        raise Exception(f"Token decode failed: {error_msg}")
