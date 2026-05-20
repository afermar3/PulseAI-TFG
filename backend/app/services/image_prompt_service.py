# BASE_REALISTIC_STYLE_PROMPT = """
# Create a high-quality realistic fitness and wellness image for a premium mobile app.

# Style requirements:
# - Photorealistic.
# - Professional lifestyle photography.
# - Modern, clean and elegant composition.
# - Soft natural lighting.
# - Premium fitness/wellness campaign aesthetic.
# - Realistic people, realistic environments and realistic materials.
# - Suitable for a mobile app hero image.
# - Main visual identity: white, black, dark gray and deep red/coral accents.
# - No readable text.
# - No logos.
# - No watermark.
# - No cartoon.
# - No illustration.
# - No anime.
# - No 3D render.
# - No toy look.
# - No fantasy elements.

# The final image must look like a real professional photoshoot, not a drawing.
# """.strip()


# SCREEN_PROMPTS = {
#     "workout": """
# Show a realistic fitness training scene in a modern premium gym.
# A fit young adult is training with focus and motivation, wearing clean modern sportswear.
# The atmosphere should feel energetic, healthy, aspirational and professional.
# Use subtle red/coral accents in clothing or environment details.
# """.strip(),

#     "sleep": """
# Show a realistic sleep and recovery wellness scene.
# A person is resting peacefully in a modern bedroom with premium bedding, soft ambient light and a calm atmosphere.
# The image should feel relaxing, restorative, clean and elegant.
# Use subtle red/coral accents only as small visual details.
# """.strip(),

#     "meal": """
# Show a realistic healthy meal planning scene.
# Fresh ingredients, balanced nutritious food, a clean modern kitchen or table setup.
# The image should feel fresh, premium, healthy and motivating.
# Use subtle red/coral accents through small objects or food color details.
# """.strip(),

#     "coach": """
# Show a realistic AI wellness coach concept for a premium fitness app.
# The scene should combine health, fitness and subtle technology in a realistic way.
# Use a modern human-centered setup, such as a person interacting with a clean digital wellness interface.
# The image should feel intelligent, trustworthy, premium and futuristic without looking like fantasy.
# """.strip(),
# }


# def build_image_prompt(screen: str) -> str:
#     screen_key = screen.lower().strip()

#     if screen_key not in SCREEN_PROMPTS:
#         valid_screens = ", ".join(SCREEN_PROMPTS.keys())
#         raise ValueError(
#             f"Pantalla no válida: '{screen}'. Pantallas válidas: {valid_screens}"
#         )

#     return f"{BASE_REALISTIC_STYLE_PROMPT}\n\nScene:\n{SCREEN_PROMPTS[screen_key]}"