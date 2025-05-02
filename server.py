# file: server.py
from flask import Flask, request, jsonify
from docx import Document
from minio import Minio
import uuid
import io

app = Flask(__name__)

# Inisialisasi MinIO Client
minio_client = Minio(
    endpoint="storage-api.sman16bekasi.id",  # ganti dengan endpoint MinIO kamu
    access_key="4ormnVvuMMJy5A84wnUL",    # ganti dengan access key kamu
    secret_key="SY9xregkSVUrf2O08lZpXsYzkhg1peB6r2yho4J7",    # ganti dengan secret key kamu
    secure=True                # True jika pakai https
)

BUCKET_NAME = "dokumen"

def upload_to_minio(image_data, content_type):
    filename = f"{uuid.uuid4()}.png"  # bisa pakai jpg/png tergantung mime
    image_io = io.BytesIO(image_data)
    image_size = len(image_data)

    minio_client.put_object(
        bucket_name=BUCKET_NAME,
        object_name=filename,
        data=image_io,
        length=image_size,
        content_type=content_type
    )

    return f"https://storage-api.sman16bekasi.id/{BUCKET_NAME}/{filename}"  # sesuaikan URL MinIO kamu

def extract_text_and_images(cell):
    html_parts = []

    for para in cell.paragraphs:
        # Tambahkan teks
        if para.text.strip():
            html_parts.append(f"<p>{para.text.strip()}</p>")

        # Tambahkan gambar dalam paragraf (inline shape)
        for run in para.runs:
            drawing_elements = run._element.findall('.//{http://schemas.openxmlformats.org/drawingml/2006/main}blip')
            for blip in drawing_elements:
                r_embed = blip.attrib.get('{http://schemas.openxmlformats.org/officeDocument/2006/relationships}embed')
                if r_embed:
                    image_part = cell.part.related_parts[r_embed]
                    image_data = image_part.blob
                    image_url = upload_to_minio(image_data, image_part.content_type)
                    html_parts.append(f"<img src='{image_url}' />")
    return "".join(html_parts)

@app.route("/parse-docx", methods=["POST"])
def parse_docx():
    file = request.files.get("file")
    if not file:
        return {"error": "No file"}, 400

    doc = Document(file)
    soal_list = []

    for i, row in enumerate(doc.tables[0].rows):
        if i == 0:
            continue
        cells = row.cells
        soal_data = {}
        for idx, key in enumerate(['soal', 'a', 'b', 'c', 'd', 'e', 'jawaban']):
            contents = extract_text_and_images(cells[idx])
            soal_data[key] = contents
        soal_list.append(soal_data)

    return jsonify(soal_list)

if __name__ == "__main__":
    app.run(port=5000)
