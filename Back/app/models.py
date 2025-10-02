# app/models.py
from pydantic import BaseModel, constr

class UserRegister(BaseModel):
    username: str
    password: constr(min_length=4, max_length=72)  

class UserLogin(BaseModel):
    username: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
