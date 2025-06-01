import re
import h5py
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from tqdm import tqdm
import os
import sys
from fastdigest import TDigest
import pickle

CHUNK_SIZE = 1_000_000
MAX_SAMPLE = 200_000

def stream_parse_to_hdf5(trace_file, hdf5_file, chunk_size=1_000_000):
    pattern = re.compile(r'\[(\d+)\].*?time=(\d+)\s+num=(\d+)')

    with h5py.File(hdf5_file, "w") as hf:
        cpu_ds = hf.create_dataset("cpu", (0,), maxshape=(None,), dtype='u1', chunks=True)
        time_ds = hf.create_dataset("time", (0,), maxshape=(None,), dtype='u4', chunks=True)
        num_ds = hf.create_dataset("num", (0,), maxshape=(None,), dtype='u4', chunks=True)

        cpu_buf, time_buf, num_buf = [], [], []
        total = 0

        with open(trace_file, "r") as f:
            for line in tqdm(f, desc="Streaming parse"):
                match = pattern.search(line)
                if match:
                    cpu_id, time_val, num_val = map(int, match.groups())
                    cpu_buf.append(cpu_id)
                    time_buf.append(time_val)
                    num_buf.append(num_val)

                    if len(cpu_buf) >= chunk_size:
                        # 
                        next_size = total + len(cpu_buf)
                        cpu_ds.resize((next_size,))
                        time_ds.resize((next_size,))
                        num_ds.resize((next_size,))
                        cpu_ds[total:next_size] = np.array(cpu_buf, dtype='u1')
                        time_ds[total:next_size] = np.array(time_buf, dtype='u4')
                        num_ds[total:next_size] = np.array(num_buf, dtype='u4')

                        total = next_size
                        cpu_buf, time_buf, num_buf = [], [], []

        # Flush remaining data
        if cpu_buf:
            next_size = total + len(cpu_buf)
            cpu_ds.resize((next_size,))
            time_ds.resize((next_size,))
            num_ds.resize((next_size,))
            cpu_ds[total:next_size] = np.array(cpu_buf, dtype='u1')
            time_ds[total:next_size] = np.array(time_buf, dtype='u4')
            num_ds[total:next_size] = np.array(num_buf, dtype='u4')

        print(f"[✓] Streamed and saved {total + len(cpu_buf)} entries to {hdf5_file}")


def parse_and_save_to_hdf5(trace_file, hdf5_file):
    cpu_list = []
    time_list = []
    num_list = []

    pattern = re.compile(r'\[(\d+)\].*?time=(\d+)\s+num=(\d+)')

    with open(trace_file, "r") as f:
        for line in tqdm(f, desc=f"Parsing {trace_file}"):
            match = pattern.search(line)
            if match:
                cpu_id, time_val, num_val = map(int, match.groups())
                cpu_list.append(cpu_id)
                time_list.append(time_val)
                num_list.append(num_val)

    cpu_arr = np.array(cpu_list, dtype=np.uint8)
    time_arr = np.array(time_list, dtype=np.uint32)
    num_arr = np.array(num_list, dtype=np.uint32)

    with h5py.File(hdf5_file, "w") as hf:
        hf.create_dataset("cpu", data=cpu_arr, compression="gzip")
        hf.create_dataset("time", data=time_arr, compression="gzip")
        hf.create_dataset("num", data=num_arr, compression="gzip")
    
    print(f"[✓] Saved to {hdf5_file}, total entries: {len(cpu_arr)}")


def compute_dual_stats(dataset1, name1, dataset2, name2, file_name):
    def load_chunks(dataset, name):
        print(f"\nComputing stats for {name}...")
        total = len(dataset)
        all_data = []
        for i in tqdm(range(0, total, CHUNK_SIZE), desc=f"Loading {name} chunks"):
            chunk = dataset[i:i + CHUNK_SIZE]
            all_data.append(chunk)
        full_data = np.concatenate(all_data)
        return full_data

    full1 = load_chunks(dataset1, name1)
    full2 = load_chunks(dataset2, name2)

    max_val = min(np.percentile(full1, 99), np.percentile(full2, 99)) * 1.01
    clipped1 = full1[full1 <= max_val]
    clipped2 = full2[full2 <= max_val]

    def describe(data, label):
        print(f"\n{label} Stats:")
        for k, v in {
            "mean": np.mean(data),
            "min": np.min(data),
            "Q1": np.percentile(data, 25),
            "median": np.median(data),
            "Q3": np.percentile(data, 75),
            "Q99": np.percentile(data, 99),
            "max": np.max(data),
        }.items():
            print(f"{k:>6}: {v:.2f}")

    describe(full1, name1)
    describe(full2, name2)

    # 
    plt.figure(figsize=(6.5, 3.5))
    plt.rcParams.update({
    'font.size': 14,           # 
    })
    if(file_name == "nginx"):
        bins = 140
    else:
        bins = 300
    counts1, bins1 = np.histogram(clipped1, bins=bins, range=(0, max_val))
    counts2, bins2 = np.histogram(clipped2, bins=bins, range=(0, max_val))
    centers = (bins1[:-1] + bins1[1:]) / 2

    plt.plot(centers, counts1, label=name1, color='blue', linewidth=1.5)
    plt.plot(centers, counts2, label=name2, color='red', linewidth=1.5)

    #  Q3 
    q3_1 = np.percentile(full1, 75)
    q3_2 = np.percentile(full2, 75)
    count1_q3 = counts1[np.searchsorted(bins1, q3_1, side='right') - 1]
    count2_q3 = counts2[np.searchsorted(bins2, q3_2, side='right') - 1]

    

    plt.plot([q3_1, q3_1], [0, count1_q3], color='black', linestyle='--', linewidth=1)
    if(file_name == "nginx"):
        plt.text(q3_1*1.0, count1_q3 * 6.4, f'{name1} Q3: {q3_1:.0f}(ns)', color='blue', ha='left')
    else:
        plt.text(q3_1*1.05, count1_q3 * 1.5, f'{name1} Q3: {q3_1:.0f}(ns)', color='blue', ha='left')
    
    plt.plot([q3_2, q3_2], [0, count2_q3], color='black', linestyle='--', linewidth=1)
    plt.text(q3_2*1.05, count2_q3 * 1.05, f'{name2} Q3: {q3_2:.0f}(ns)', color='red', ha='left')

    # plt.title(f"{name1} vs {name2} Distribution (clipped to 99%)")
    plt.xlabel("time(ns)")
    plt.ylabel("Count")
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(f"{file_name}_line_comparison.pdf", pad_inches=0)
    print(f"[✓] Plot saved to {file_name}_line_comparison.pdf")

def compute_dual_stats_tdigest(dataset1, name1, dataset2, name2, dataset3, name3, file_name):
    def build_digest_and_sample(dataset, name, cache_dir="tdigest_cache"):
        os.makedirs(cache_dir, exist_ok=True)
        digest_path = os.path.join(cache_dir, f"{name}_digest.pkl")
        sample_path = os.path.join(cache_dir, f"{name}_sample.npy")

        # 
        if os.path.exists(digest_path) and os.path.exists(sample_path):
            print(f"[✓] Loaded TDigest + sample cache for {name}")
            with open(digest_path, "rb") as f:
                digest = pickle.load(f)
            sample = np.load(sample_path)
            return digest, sample

        print(f"\n[•] Building TDigest for {name}...")
        digest = TDigest()
        sample = np.empty(MAX_SAMPLE, dtype=np.float32)
        sampled_so_far = 0

        total = len(dataset)
        for i in tqdm(range(0, total, CHUNK_SIZE), desc=f"Processing {name}"):
            chunk = dataset[i:i + CHUNK_SIZE]
            for val in chunk:
                digest.update(val)

            # 
            if sampled_so_far < MAX_SAMPLE:
                take = min(MAX_SAMPLE - sampled_so_far, len(chunk))
                sample[sampled_so_far:sampled_so_far + take] = chunk[:take]
                sampled_so_far += take

        sample = sample[:sampled_so_far]

        # 
        with open(digest_path, "wb") as f:
            pickle.dump(digest, f)
        np.save(sample_path, sample)

        print(f"[✓] TDigest + sample cached for {name}")
        return digest, sample

    digest1, sample1 = build_digest_and_sample(dataset1, name1+"_"+file_name)
    digest2, sample2 = build_digest_and_sample(dataset2, name2+"_"+file_name)
    digest3, sample3 = build_digest_and_sample(dataset3, name3+"_"+file_name)

    #  max 
    max_val = min(digest1.percentile(99), digest2.percentile(99), digest3.percentile(99)) * 1.01
    sample1 = sample1[sample1 <= max_val]
    sample2 = sample2[sample2 <= max_val]
    sample3 = sample3[sample3 <= max_val]
    def describe(digest, label):
        print(f"\n{label} TDigest Stats:")
        for k, p in {
            "mean": None,
            "min": 0,
            "Q1": 25,
            "median": 50,
            "Q3": 75,
            "Q99": 99,
            "max": 100,
        }.items():
            if p is not None:
                print(f"{k:>6}: {digest.percentile(p):.2f}")
            else:
                print(f"{k:>6}: approx")

    describe(digest1, name1)
    describe(digest2, name2)
    describe(digest3, name3)

    # 
    plt.figure(figsize=(6.5, 3.5))
    plt.rcParams.update({'font.size': 14})

    bins = 140 if file_name == "nginx" else 300
    counts1, bins1 = np.histogram(sample1, bins=bins, range=(0, max_val))
    counts2, bins2 = np.histogram(sample2, bins=bins, range=(0, max_val))
    counts3, bins3 = np.histogram(sample3, bins=bins, range=(0, max_val))
    centers = (bins1[:-1] + bins1[1:]) / 2

    plt.plot(centers, counts1, label=name1, color='blue', linewidth=1.5)
    plt.plot(centers, counts2, label=name2, color='red', linewidth=1.5)
    plt.plot(centers, counts3, label=name3, color='green', linewidth=1.5)

    q3_1 = digest1.percentile(75)
    q3_2 = digest2.percentile(75)
    q3_3 = digest3.percentile(75)
    count1_q3 = counts1[np.searchsorted(bins1, q3_1, side='right') - 1]
    count2_q3 = counts2[np.searchsorted(bins2, q3_2, side='right') - 1]
    count3_q3 = counts3[np.searchsorted(bins3, q3_3, side='right') - 1]

    plt.plot([q3_1, q3_1], [0, count1_q3], color='black', linestyle='--', linewidth=1)
    offset_factor = 1.6 if file_name == "nginx" else 1.5
    plt.text(q3_1 * 1.0, count1_q3 * offset_factor, f'{name1} Q3: {q3_1:.0f}(ns)', color='blue', ha='left')

    plt.plot([q3_2, q3_2], [0, count2_q3], color='black', linestyle='--', linewidth=1)
    offset_factor = 2.2 if file_name == "nginx" else 3.1
    plt.text(q3_2 * 1.05, count2_q3 * offset_factor, f'{name2} Q3: {q3_2:.0f}(ns)', color='red', ha='left')

    plt.plot([q3_3, q3_3], [0, count3_q3], color='black', linestyle='--', linewidth=1)
    plt.text(q3_3 * 1.05, count3_q3 * 1.05, f'{name3} Q3: {q3_3:.0f}(ns)', color='green', ha='left')

    plt.xlabel("time(ns)")
    plt.ylabel("Count")
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(f"{file_name}_line_comparison.pdf", pad_inches=0)
    print(f"[✓] Plot saved to {file_name}_line_comparison.pdf")


def main():
    if len(sys.argv) != 2:
        print("Usage: python trace_analyze.py <trace_file.txt>")
        sys.exit(1)

    trace_file_type = sys.argv[1]
    trace_file_50 = "trace_"+trace_file_type+"-50.txt"
    trace_file_100 = "trace_"+trace_file_type+"-100.txt"
    trace_file_200 = "trace_"+trace_file_type+"-200.txt"
    if not os.path.exists(trace_file_50):
        print(f"[!] File not found: {trace_file_50}")
        sys.exit(1)
    if not os.path.exists(trace_file_100):
        print(f"[!] File not found: {trace_file_100}")
        sys.exit(1)
    if not os.path.exists(trace_file_200):
        print(f"[!] File not found: {trace_file_200}")
        sys.exit(1)

    base_name_50 = os.path.splitext(trace_file_50)[0]
    hdf5_file_50 = f"{base_name_50}.h5"
    base_name_100 = os.path.splitext(trace_file_100)[0]
    hdf5_file_100 = f"{base_name_100}.h5"
    base_name_200 = os.path.splitext(trace_file_200)[0]
    hdf5_file_200 = f"{base_name_200}.h5"

    if not os.path.exists(hdf5_file_50):
        stream_parse_to_hdf5(trace_file_50, hdf5_file_50)
    else:
        print(f"[✓] Found existing HDF5: {hdf5_file_50}, skipping parse.")

    if not os.path.exists(hdf5_file_100):
        stream_parse_to_hdf5(trace_file_100, hdf5_file_100)
    else:
        print(f"[✓] Found existing HDF5: {hdf5_file_100}, skipping parse.")
    if not os.path.exists(hdf5_file_200):
        stream_parse_to_hdf5(trace_file_100, hdf5_file_200)
    else:
        print(f"[✓] Found existing HDF5: {hdf5_file_200}, skipping parse.")

    with h5py.File(hdf5_file_200, "r") as hf_200, h5py.File(hdf5_file_100, "r") as hf_100, h5py.File(hdf5_file_50,"r") as hf_50:
        #compute_stats(hf["num"], "num")
        # compute_dual_stats(hf_50["time"], "SI = 50",hf_100["time"], "SI = 100", trace_file_type)
        compute_dual_stats_tdigest(hf_50["time"], "SI = 50", hf_100["time"], "SI = 100", hf_200["time"], "SI = 200", trace_file_type)

if __name__ == "__main__":
    main()

