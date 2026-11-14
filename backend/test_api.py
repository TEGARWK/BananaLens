"""Verification tests for the FruitLens 3-class Hybrid AI backend."""

import asyncio
import io
import unittest

import numpy as np
from fastapi import UploadFile
from PIL import Image

import main


def _encode_solid_rgb(rgb: tuple[int, int, int]) -> bytes:
    image = Image.new("RGB", (320, 240), color=rgb)
    buffer = io.BytesIO()
    image.save(buffer, format="JPEG")
    return buffer.getvalue()


class BackendHybridApiTest(unittest.TestCase):
    def test_health_check_reports_three_classes(self) -> None:
        payload = main.health_check()
        self.assertEqual(payload["status"], "Server Aktif")
        self.assertEqual(payload["model_file"], main.MODEL_FILENAME)
        self.assertEqual(payload["classes"], ["ripe", "rotten", "unripe"])

    def test_extract_color_features_shape_and_bounds(self) -> None:
        img = np.full((224, 224, 3), fill_value=180, dtype=np.uint8)
        feats = main.extract_color_features(img)
        self.assertEqual(feats.shape, (1, 30))
        self.assertTrue(np.all(np.isfinite(feats)))

    def test_build_hybrid_features_outputs_606_dims(self) -> None:
        img_bytes = _encode_solid_rgb((240, 210, 45))
        features = main.build_hybrid_features(img_bytes)
        self.assertEqual(features.shape, (1, 606))
        self.assertTrue(np.all(np.isfinite(features)))

    def test_predict_endpoint_returns_fruitlens_contract(self) -> None:
        img_bytes = _encode_solid_rgb((240, 210, 45))
        upload = UploadFile(filename="banana.jpg", file=io.BytesIO(img_bytes))
        payload = asyncio.run(main.predict_banana(upload))

        self.assertEqual(payload["status"], "success")
        self.assertEqual(payload["fruit_label"], "banana")
        self.assertIn(payload["raw_class"], ["ripe", "rotten", "unripe"])
        self.assertGreater(payload["confidence"], 0.0)
        self.assertEqual(set(payload["details"].keys()), {"ripe", "rotten", "unripe"})
        self.assertAlmostEqual(sum(payload["details"].values()), 100.0, delta=0.2)

    def test_predict_endpoint_handles_invalid_bytes_gracefully(self) -> None:
        upload = UploadFile(filename="broken.jpg", file=io.BytesIO(b"not-an-image"))
        payload = asyncio.run(main.predict_banana(upload))

        self.assertEqual(payload["status"], "error")
        self.assertTrue(payload["message"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
