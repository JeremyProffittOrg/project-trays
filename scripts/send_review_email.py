#!/usr/bin/env python3
"""Send tray v1 review renders via AWS SES raw email."""

from __future__ import annotations

import base64
import json
import subprocess
import sys
import tempfile
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
SRC = REPO / "renders" / "v1"
# Domain jeremy.ninja is SES-verified; use a real mailbox on that domain.
FROM = "jeremy@jeremy.ninja"
TO = "proffitt.jeremy@gmail.com"
REGION = "us-east-1"

FILES = [
    "00_contact_sheet.png",
    "01_iso_front_right.png",
    "02_iso_front_left.png",
    "03_front.png",
    "04_back.png",
    "05_left.png",
    "06_right.png",
    "07_top.png",
    "08_bottom.png",
    "09_iso_back_left.png",
    "10_iso_back_right.png",
]

BODY = """Project Trays - USB Hub Tray first draft (v1) for review

Envelope: 9 in wide x 6 in deep x 3 in high (228.6 x 152.4 x 76.2 mm)
Walls / floor: 4 mm
Front (one 9 in side): open, with 1/4 in (6.35 mm) bottom ledge
Back (other 9 in side): Anker USB-C hub mount

Hub (ghosted blue in renders): 151 mm L x 20 mm T x 50 mm H
  - Left clearance: 48 mm from outer left (10 x 35 mm wire opening)
  - Right clearance: ~29.6 mm from outer right (min 1/2 in; 10 mm wide x 35 mm deep-from-top slot)
  - Behind hub: 5 mm deep x 15 mm tall wire groove in back wall
  - Hub sits on a 6 mm shelf with side fences + front retainer lip (drop-in from top)
  - Ports face into the tray

Cable pass-throughs on left side of back wall:
  - 3x U-notches, 1/4 in wide x 1/2 in tall, with 1/4 in bottom ledge

Stackable: outer top step + inset bottom foot (3 mm lip, 1.5 mm step, 0.5 mm clearance)

Attachments:
  - 00_contact_sheet.png - all 10 angles on one page
  - 01..10 - individual camera angles

OpenSCAD source: tray_usb_hub_v1.scad
STL export: export/tray_usb_hub_v1.stl

Please mark up what you want changed (hub orientation, clearances, notch count/placement, stacking detail, wall thickness, etc.).
"""


def build_message() -> bytes:
    msg = MIMEMultipart("mixed")
    msg["Subject"] = "Project Trays - USB Hub Tray v1 review (10 angles)"
    msg["From"] = f"Jeremy Proffitt <{FROM}>"
    msg["To"] = TO
    msg["Reply-To"] = "proffitt.jeremy@gmail.com"
    # Ensure envelope Source matches a verified @jeremy.ninja identity.
    msg.attach(MIMEText(BODY, "plain", "utf-8"))

    for fname in FILES:
        path = SRC / fname
        if not path.exists():
            raise FileNotFoundError(path)
        img = MIMEImage(path.read_bytes(), _subtype="png")
        img.add_header("Content-Disposition", "attachment", filename=fname)
        msg.attach(img)

    return msg.as_bytes()


def main() -> int:
    raw = build_message()
    print(f"MIME size: {len(raw)} bytes")

    # Prefer fileb:// payload for send-raw-email
    tmp = Path(tempfile.gettempdir()) / "tray_v1_review_email.eml"
    tmp.write_bytes(raw)
    file_uri = "fileb://" + tmp.as_posix()

    # SES CLI uses --source (API Source). From/Reply-To also live in the MIME headers.
    payload = {"Data": base64.b64encode(raw).decode("ascii")}
    payload_path = Path(tempfile.gettempdir()) / "tray_v1_raw_message.json"
    payload_path.write_text(json.dumps(payload), encoding="utf-8")
    cmd = [
        "aws",
        "ses",
        "send-raw-email",
        "--region",
        REGION,
        "--source",
        FROM,
        "--destinations",
        TO,
        "--raw-message",
        f"file://{payload_path.as_posix()}",
    ]
    print("Running:", " ".join(cmd[:-1]), "file://…")
    proc = subprocess.run(cmd, capture_output=True, text=True)
    sys.stdout.write(proc.stdout or "")
    sys.stderr.write(proc.stderr or "")
    try:
        payload_path.unlink(missing_ok=True)
        tmp.unlink(missing_ok=True)
    except OSError:
        pass
    if proc.returncode != 0:
        print("SES send failed.", file=sys.stderr)
        return proc.returncode
    print("Email sent successfully.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
