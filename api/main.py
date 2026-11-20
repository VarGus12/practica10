import os
import shutil
from datetime import datetime
from typing import List, Optional

from fastapi import FastAPI, Depends, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, TIMESTAMP, text
from sqlalchemy.orm import sessionmaker, Session, declarative_base

DATABASE_URL = "mysql+pymysql://root:@localhost/practica10"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


class FotoDB(Base):
    __tablename__ = "P10_foto"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    descripcion = Column(String(255), nullable=False)
    ruta_foto = Column(String(255), nullable=False)
    fecha = Column(TIMESTAMP, server_default=text("CURRENT_TIMESTAMP"))


class FotoSchema(BaseModel):
    id: int
    descripcion: str
    ruta_foto: str
    fecha: Optional[datetime]

    class Config:
        from_attributes = True


class FotoResponse(BaseModel):
    msg: str
    foto: FotoSchema


app = FastAPI(title="API Gestión de Imágenes - Práctica 10")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_DIR = "uploads"
TIPOS_PERMITIDOS = ["image/jpeg", "image/png", "image/webp", "image/gif"]

os.makedirs(UPLOAD_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

Base.metadata.create_all(bind=engine)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.post("/fotos", response_model=FotoResponse)
async def subir_foto(
    descripcion: str = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    if descripcion.strip() == "":
        raise HTTPException(status_code=400, detail="La descripción no puede ir vacía")

    if file.content_type not in TIPOS_PERMITIDOS:
        raise HTTPException(status_code=400, detail=f"Tipo de archivo no permitido: {file.content_type}")

    nombre = datetime.now().strftime("%Y%m%d%H%M%S") + "_" + os.path.basename(file.filename).replace(" ", "_")
    ruta_archivo = f"{UPLOAD_DIR}/{nombre}"
    try:
        with open(ruta_archivo, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al guardar imagen: {str(e)}")

    nueva_foto = FotoDB(
        descripcion=descripcion.strip(),
        ruta_foto=ruta_archivo
    )
    db.add(nueva_foto)
    db.commit()
    db.refresh(nueva_foto)

    return {
        "msg": "Foto subida correctamente",
        "foto": nueva_foto
    }


@app.get("/fotos", response_model=List[FotoSchema])
def listar_fotos(db: Session = Depends(get_db)):
    fotos = db.query(FotoDB).order_by(FotoDB.id.desc()).all()
    return fotos
