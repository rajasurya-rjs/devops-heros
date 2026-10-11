from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from .database import get_db
from .models import Note
from .schemas import NoteInput, NoteOutput

router = APIRouter(prefix="/api/notes", tags=["Notes"])


def find_note(ident, db):
    note = db.get(Note, ident)
    if note is None:
        raise HTTPException(status_code=404, detail="Note not found")
    return note


@router.get("", response_model=list[NoteOutput])
def list_notes(db: Session = Depends(get_db)):
    return db.scalars(select(Note).order_by(Note.id)).all()


@router.get("/{ident}", response_model=NoteOutput)
def read_note(ident: int, db: Session = Depends(get_db)):
    return find_note(ident, db)


@router.post("", response_model=NoteOutput, status_code=201)
def create_note(body: NoteInput, db: Session = Depends(get_db)):
    note = Note(text=body.text)
    db.add(note)
    db.commit()
    db.refresh(note)
    return note


@router.put("/{ident}", response_model=NoteOutput)
def update_note(ident: int, body: NoteInput, db: Session = Depends(get_db)):
    note = find_note(ident, db)
    note.text = body.text
    db.commit()
    db.refresh(note)
    return note


@router.delete("/{ident}")
def delete_note(ident: int, db: Session = Depends(get_db)):
    note = find_note(ident, db)
    db.delete(note)
    db.commit()
    return {"deleted": True}
