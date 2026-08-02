import runpod

def handler(job):
    return {
        "message": "Hello from RunPod!"
    }

runpod.serverless.start({"handler": handler})
