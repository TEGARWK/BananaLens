import json
import struct
import sys
import os

def pack_svm_pipeline(src_json_path: str, bin_out_path: str, meta_out_path: str):
    print(f'Reading source parameters from: {src_json_path}')
    with open(src_json_path, 'r', encoding='utf-8') as f:
        d = json.load(f)

    # Layout definition
    tensors_spec = [
        ('cnn_scaler_mean', d['scaler_cnn_mean'], [576]),
        ('cnn_scaler_scale', d['scaler_cnn_scale'], [576]),
        ('pca_mean', d['pca_mean'], [576]),
        ('pca_components', [x for row in d['pca_components'] for x in row], [len(d['pca_components']), len(d['pca_components'][0])]),
        ('hsv_scaler_mean', d['scaler_hsv_mean'], [30]),
        ('hsv_scaler_scale', d['scaler_hsv_scale'], [30]),
        ('support_vectors', [x for row in d['support_vectors'] for x in row], [len(d['support_vectors']), len(d['support_vectors'][0])]),
        ('dual_coef', [x for row in d['dual_coef'] for x in row], [len(d['dual_coef']), len(d['dual_coef'][0])]),
    ]

    offset = 0
    meta_tensors = {}
    all_floats = []

    for name, data_list, shape in tensors_spec:
        length = len(data_list)
        meta_tensors[name] = {
            'offset': offset,
            'length': length,
            'shape': shape
        }
        all_floats.extend(data_list)
        offset += length

    total_floats = len(all_floats)
    print(f'Total floats: {total_floats} ({total_floats * 4} bytes)')

    os.makedirs(os.path.dirname(os.path.abspath(bin_out_path)), exist_ok=True)
    with open(bin_out_path, 'wb') as f:
        f.write(struct.pack(f'<{total_floats}f', *all_floats))

    meta = {
        'version': 1,
        'class_names': d['class_names'],
        'hsv_weight': float(d['hsv_weight']),
        'gamma': float(d['svm_gamma']),
        'n_support': [int(x) for x in d['n_support']],
        'intercept': [float(x) for x in d['intercept']],
        'probA': [float(x) for x in d['probA']],
        'probB': [float(x) for x in d['probB']],
        'total_floats': total_floats,
        'tensors': meta_tensors
    }

    os.makedirs(os.path.dirname(os.path.abspath(meta_out_path)), exist_ok=True)
    with open(meta_out_path, 'w', encoding='utf-8') as f:
        json.dump(meta, f, indent=2)

    print(f'Done! Created:\n - {bin_out_path} ({os.path.getsize(bin_out_path)} bytes)\n - {meta_out_path} ({os.path.getsize(meta_out_path)} bytes)')

if __name__ == '__main__':
    src = sys.argv[1] if len(sys.argv) > 1 else 'baca/baru/svm_pipeline_params.json'
    bin_out = sys.argv[2] if len(sys.argv) > 2 else 'assets/models/svm_pisang_weights.bin'
    meta_out = sys.argv[3] if len(sys.argv) > 3 else 'assets/models/svm_pisang_meta.json'
    pack_svm_pipeline(src, bin_out, meta_out)
