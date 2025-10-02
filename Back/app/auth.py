# app/auth.py
from datetime import datetime, timedelta
from jose import jwt
from passlib.context import CryptContext

SECRET_KEY = "supersecretkey"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

pwd_context = CryptContext(schemes=["argon2"], deprecated="auto")

def _normalize_password_to_72(password: str) -> str:

    if password is None:
        password = ""
    pw = password.strip()

    b = pw.encode("utf-8")
    if len(b) <= 72:
        return pw

    b72 = b[:72]
    try:
        pw72 = b72.decode("utf-8")
    except UnicodeDecodeError:
        pw72 = b72.decode("utf-8", "ignore")
    return pw72

def hash_password(password: str):
 
    pw_safe = _normalize_password_to_72(password)

    if len(pw_safe.encode("utf-8")) > 72:
        raise ValueError("Contraseña excede 72 bytes tras normalización.")
    return pwd_context.hash(pw_safe)

def verify_password(plain_password: str, hashed_password: str):
    pw_safe = _normalize_password_to_72(plain_password)
    return pwd_context.verify(pw_safe, hashed_password)

def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=15))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
