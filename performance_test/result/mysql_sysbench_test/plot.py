import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import adjust
import re
import sys

# 
csv_files = ["results_have_exorcist50.csv", "results_have_exorcist100.csv", "results_have_exorcist200.csv", "results_no_exorcist.csv"]
labels = ["SI = 50", "SI = 100", "SI = 200", "Baseline"]

# 
columns = ["TPS", "QPS", "P95(ms)"]

#  bin 
bin_ranges = {
    "TPS": np.linspace(47, 64, 30),
    "QPS": np.linspace(940, 1300, 30),
    "P95(ms)": np.linspace(440, 670, 30),
}

def process_column(csv_file, column_name, bins):
    df = pd.read_csv(csv_file)
    values = df[column_name].dropna().astype(float)

    mean_val = values.mean()
    print(f"{csv_file}_{column_name} : {mean_val:.2f}")

    counts, bin_edges = np.histogram(values, bins=bins)

    bin_centers = (bin_edges[:-1] + bin_edges[1:]) / 2
    return bin_centers, counts

def plot_distribution(columns, csv_files, labels):
    for col in columns:
        bins = bin_ranges[col]
        fig = plt.figure(figsize=(6.5, 3.5))
        # fig = plt.figure(figsize=(4.65, 2.5))
        plt.rcParams.update({
            'font.size': 14,           # 
        })
        for i, f in enumerate(csv_files):
            x, y = process_column(f, col, bins)
            plt.plot(x, y, label=labels[i], marker='o')
        # adjust.adjust_box_widths(fig, 0.9)
        plt.xlabel(col)
        plt.ylabel("Count")
        # plt.title(f"mysql {col} Distribution")
        plt.grid(True)
        legend = plt.legend()
        legend.get_frame().set_alpha(0.3)

        plt.tight_layout()
        plt.savefig(f"{col}_distribution_mysql.pdf", bbox_inches='tight', pad_inches=0)
        print(f"[✓] Saved: {col}_distribution.png")

# 
plot_distribution(columns, csv_files, labels)