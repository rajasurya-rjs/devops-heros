from pydantic import BaseModel, ConfigDict, Field, field_validator


class NoteInput(BaseModel):
    model_config = ConfigDict(extra="forbid")
    text: str = Field(min_length=1, max_length=500, strict=True)

    @field_validator("text")
    @classmethod
    def reject_blank(cls, value):
        if not value.strip():
            raise ValueError("A note must contain text")
        return value


class NoteOutput(NoteInput):
    model_config = ConfigDict(from_attributes=True)
    id: int
