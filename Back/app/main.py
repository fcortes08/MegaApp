# app/main.py
from fastapi import FastAPI, HTTPException
from datetime import timedelta
from app.models import UserRegister, UserLogin, Token
from app import auth, database

app = FastAPI()

@app.post("/registro")
def registro(user: UserRegister):
    if user.username in database.fake_users_db:
        raise HTTPException(status_code=400, detail="Usuario ya existe")
    try:
        hashed_password = auth.hash_password(user.password)
    except ValueError as e:

        raise HTTPException(status_code=400, detail=f"Error en contraseña: {str(e)}")
    database.fake_users_db[user.username] = {
        "username": user.username,
        "password": hashed_password
    }
    return {"msg": "Usuario registrado correctamente"}

@app.post("/login", response_model=Token)
def login(user: UserLogin):
    db_user = database.fake_users_db.get(user.username)
    if not db_user or not auth.verify_password(user.password, db_user["password"]):
        raise HTTPException(status_code=401, detail="Credenciales inválidas")
    access_token_expires = timedelta(minutes=auth.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"sub": user.username},
        expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@app.post("/reset")
def reset_db():
    database.fake_users_db.clear()
    return {"msg": "Base de datos (fake) limpiada"}
