import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter
import re
import sys

# 文件名列表（可以修改或从命令行传入）
csv_files = ["results_have_exorcist50.csv", "results_have_exorcist100.csv","results_have_exorcist200.csv", "results_no_exorcist.csv"]
labels = ["SI = 50", "SI = 100", "SI = 200","Baseline"]

def parse_value(val):
    # 去除逗号，转数字
    val = str(val).strip().lower().replace(",", "")
    if "k" in val:
        return float(val.replace("k", "")) * 1000
    elif "ms" in val:
        return float(val.replace("ms", ""))
    return float(val)

def process_column(csv_file, column_name, bins):
    df = pd.read_csv(csv_file)
    df[column_name] = df[column_name].apply(parse_value)
    counts, bin_edges = np.histogram(df[column_name], bins=bins)
    bin_centers = (bin_edges[:-1] + bin_edges[1:]) / 2
    return bin_centers, counts

def plot_lines(csv_files, column, bins, labels, title, xlabel, output):
    fig = plt.figure(figsize=(6.5, 3.5))
    # fig = plt.figure(figsize=(4.65, 2.5))
    plt.rcParams.update({
    'font.size': 14,           # 设置所有字体大小
    })
    for i, f in enumerate(csv_files):
        x, y = process_column(f, column, bins)
        plt.plot(x, y, label=labels[i], marker='o')
    plt.xlabel(xlabel)
    plt.ylabel("Count")
    # plt.title(title)
    plt.grid(True)
    legend = plt.legend()
    legend.get_frame().set_alpha(0.3)
    if(column == "Requests/sec"):
        plt.gca().xaxis.set_major_formatter(FuncFormatter(lambda x, _:f"{x/1000:.1f}k"))
    plt.tight_layout()
    plt.savefig(output, bbox_inches='tight', pad_inches=0)
    print(f"[✓] Plot saved: {output}")

# 参数配置
bins_requests = np.linspace(42000, 44000, 20)
bins_latency = np.linspace(3.3, 3.4, 10)

# 绘图
plot_lines(csv_files, "Requests/sec", bins_requests, labels, "nginx Requests/sec Distribution", "Requests/sec", "requests_distribution_nginx.pdf")
plot_lines(csv_files, "P95Latency", bins_latency, labels, "nginx P95 Latency Distribution", "P95 Latency (ms)", "latency_distribution_nginx.pdf")
