""" from pydantic import BaseModel


class GenerateScreenImageRequest(BaseModel):
    screen: str
    force_regenerate: bool = False


class GenerateScreenImageResponse(BaseModel):
    screen: str
    prompt: str
    image_path: str
    image_url: str
    cached: bool """