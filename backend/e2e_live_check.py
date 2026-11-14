"""Live TCP/HTTP end-to-end verification against a real uvicorn process."""

import io
import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request
import uuid

from PIL import Image

HOST = "127.0.0.1"
PORT = 18000
BASE_URL = f"http://{HOST}:{PORT}"


def _encode_jpeg(rgb: tuple[int, int, int]) -> bytes:
    img = Image.new("RGB", (300, 300), color=rgb)
    buf = io.BytesIO()
    img.save(buf, format="JPEG")
    return buf.getvalue()


def _wait_until_ready(timeout_sec: float = 45.0) -> dict:
    deadline = time.time() + timeout_sec
    last_error = None
    while time.time() < deadline:
        try:
            with urllib.request.urlopen(f"{BASE_URL}/", timeout=2.0) as resp:
                if resp.status == 200:
                    return json.loads(resp.read().decode("utf-8"))
        except Exception as exc:  # noqa: BLE001
            last_error = exc
            time.sleep(0.5)
    raise RuntimeError(f"uvicorn did not become ready in time: {last_error}")


def _post_multipart(image_bytes: bytes) -> dict:
    boundary = f"----FruitLensBoundary{uuid.uuid4().hex}"
    body = (
        f"--{boundary}\r\n"
        'Content-Disposition: form-data; name="file"; filename="sample.jpg"\r\n'
        "Content-Type: image/jpeg\r\n\r\n"
    ).encode("utf-8") + image_bytes + f"\r\n--{boundary}--\r\n".encode("utf-8")

    req = urllib.request.Request(
        f"{BASE_URL}/predict",
        data=body,
        method="POST",
        headers={
            "Content-Type": f"multipart/form-data; boundary={boundary}",
            "Content-Length": str(len(body)),
        },
    )
    with urllib.request.urlopen(req, timeout=15.0) as resp:
        assert resp.status == 200
        return json.loads(resp.read().decode("utf-8"))


def main() -> None:
    backend_dir = os.path.dirname(os.path.abspath(__file__))
    proc = subprocess.Popen(
        [
            sys.executable,
            "-m",
            "uvicorn",
            "main:app",
            "--host",
            HOST,
            "--port",
            str(PORT),
        ],
        cwd=backend_dir,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )

    try:
        health = _wait_until_ready()
        assert health["status"] == "Server Aktif", health
        assert health["classes"] == ["ripe", "rotten", "unripe"], health
        print("[PASS] GET / ->", json.dumps(health, ensure_ascii=False))

        for name, rgb in [
            ("kuning_matang", (245, 215, 50)),
            ("hijau_mentah", (75, 165, 55)),
            ("cokelat_busuk", (45, 30, 20)),
        ]:
            res = _post_multipart(_encode_jpeg(rgb))
            assert res["status"] == "success", res
            assert res["fruit_label"] == "banana", res
            assert set(res["details"].keys()) == {"ripe", "rotten", "unripe"}, res
            print(
                f"[PASS] POST /predict ({name}) -> {res['raw_class']} "
                f"({res['confidence']}%) details={res['details']}"
            )
    finally:
        proc.terminate()
        try:
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait()

    # Verify offline scenario after server shutdown.
    try:
        urllib.request.urlopen(f"{BASE_URL}/", timeout=2.0)
        raise AssertionError("Server should be offline after termination!")
    except urllib.error.URLError:
        print("[PASS] Offline check -> server cleanly unreachable after shutdown")


if __name__ == "__main__":
    main()

