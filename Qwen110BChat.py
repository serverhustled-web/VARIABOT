# SPACE
# https://huggingface.co/spaces/Qwen/Qwen1.5-110B-Chat-demo
import time
import sys
import os
from gradio_client import Client

# Set HF API token and HF repo
yourHFtoken = os.environ.get("HF_TOKEN", "")  # Get token from environment variable
if not yourHFtoken:
    print("Warning: HF_TOKEN environment variable not set. Please set it with your HuggingFace token.")
    print("Usage: export HF_TOKEN=hf_xxxxxxxxxxxxxxxxxxxx")
    sys.exit(1)

repo = "Qwen/Qwen1.5-110B-Chat-demo"


def ConncetLLM(reponame, hftoken):
    print("loading the API gradio client for Qwen1.5-110B-Chat-demo")
    client = Client(reponame, hf_token=hftoken)
    return client


# instantiate the Gradio_client object
client = ConncetLLM(repo, yourHFtoken)

while True:
    userinput = ""
    print("\033[1;30m")  # dark grey
    print(
        "Enter your text (end input with Ctrl+D on Unix or Ctrl+Z on Windows) - type quit! to exit the chatroom:"
    )
    print("\033[38;5;48m")  # User prompt color
    lines = sys.stdin.readlines()
    for line in lines:
        userinput += line + "\n"
    if "quit!" in lines[0].lower():
        print("\033[0mBYE BYE!")
        break
    print("\033[1;30m")  # dark grey
    print("Calling the gradio_client prediction...")
    result = client.submit(
        query=userinput,
        history=[],
        system="You are a helpful assistant.",
        api_name="/model_chat",
    )
    print("\033[38;5;99m")
    final = ""
    for chunk in result:
        if final == "":
            final = chunk[1][0][1]
            print(chunk[1][0][1], end="", flush=True)
        else:
            try:
                print(chunk[1][0][1].replace(final, ""), end="", flush=True)
                final = chunk[1][0][1]
            except (AttributeError, IndexError, TypeError) as e:
                print(f"Warning: Error processing chunk: {e}")
            except Exception as e:
                print(f"Unexpected error in chunk processing: {e}")


# References:
# - Internal: /reference_vault/PRODUCTION_GRADE_STANDARDS.md#error-handling
# - Internal: /reference_vault/ORGANIZATION_STANDARDS.md#file-organization
# - External: Gradio Client Documentation — https://gradio.app/docs/
# - External: HuggingFace Hub — https://huggingface.co/docs/huggingface_hub/
