import runpod

def handler(job):
    return {
        "message": "Builder test successful",
        "input": job["input"]
    }

runpod.serverless.start({"handler": handler})
