import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import Rectangle
import matplotlib.colors as mcolors

# 设置数据
categories = [
    "600.perlnbench_s",
    "602.gcc_s",
    "605.mcf_s",
    "620.omnetpp_s",
    "623.xalancbmk_s",
    "625.x264_s",
    "631.deepsjeng_s",
    "641.leela_s",
    "648.exchange2_s",
    "657.xz_s",
]

values = [
    [10.8, 8.55, 8.65, 9.49],
    [12.9, 11.4, 12.0, 12.3],
    [9.10, 7.81, 8.26, 8.58],
    [5.08, 4.59, 4.73, 4.87],
    [9.72, 6.79, 7.86, 8.52],
    [16.0, 13.4, 13.6, 14.4],
    [5.20, 5.02, 5.03, 5.12],
    [5.78, 5.57, 5.60, 5.69],
    [15.1, 15.2, 15.1, 15.2],
    [7.45, 7.17, 7.18, 7.24],
    # [8.98, 7.92, 8.17, 8.48],
]
types = ["no defense", "SI = 50", "SI = 00", "SI = 200"]  # 每个类别中的4种类型
colors = [
    (0.8, 0.6, 0.6),  # 淡红
    (0.6, 0.8, 0.6),  # 淡绿
    (0.6, 0.6, 0.8),  # 淡蓝
    (0.8, 0.8, 0.6),  # 淡黄
]
dark_colors = [
    (0.6, 0.2, 0.2),  # 深红
    (0.2, 0.6, 0.2),  # 深绿
    (0.2, 0.2, 0.6),  # 深蓝
    (0.6, 0.6, 0.2),  # 深黄
]
# 设置柱状图的宽度和位置
bar_width = 0.15
x = np.arange(len(categories))  # 基础x轴位置


# 创建纹理的函数
def add_hatch(ax, bars, hatch_density=5):
    for bar in bars:
        bar.set_hatch("//")
        bar.set_edgecolor((0, 0, 0, 0.3))
        bar.set_linewidth(0.8)
        # # 手动添加更精细的斜线纹理
        # for i in range(hatch_density):
        #     x = bar.get_x()
        #     y = bar.get_y()
        #     width = bar.get_width()
        #     height = bar.get_height()
        #     line_x = x + width * i / hatch_density
        #     line = Rectangle((line_x, y), 0, height,
        #                     angle=45,
        #                     color='black',
        #                     alpha=0.3,
        #                     linewidth=0.5)
        #     ax.add_patch(line)


def darken_color(color, factor=0.7):
    """
    用 HSV 色彩空间降低亮度（V）来加深颜色，保持原色调。
    factor 越小越暗，通常设置为 0.6 ~ 0.8。
    """
    h, s, v = mcolors.rgb_to_hsv(color)
    v *= factor  # 降低亮度
    return mcolors.hsv_to_rgb((h, s, v))


# 创建图形
fig, ax = plt.subplots()

# 绘制每个类型的柱子
for i in range(len(types)):


    # 在 x + 偏移位置绘制第i种类型的柱子
    bars = ax.bar(
        x + i * bar_width,
        [val[i] for val in values],
        width=bar_width,
        label=types[i],
        color=colors[i],  # 淡色填充
        edgecolor=dark_colors[i],   # 纹理颜色为深色
        linewidth=0.8,
        hatch='//'
    )  # 边框粗细)

    # add_hatch(ax, bars)

    # for bar in bars:
    #     height = bar.get_height()
    #     ax.text(bar.get_x() + bar.get_width()/2.+0.04,
    #             height + 0.9,  # 稍微抬高标签
    #             f'{height:.1f}',  # 显示一位小数
    #             ha='center',
    #             va='bottom',
    #             rotation=90,  # 垂直显示
    #             rotation_mode='anchor',
    #             fontsize=9,
    #             color='black')

# 设置x轴标签
ax.set_xticks(x + bar_width * (len(types) - 1) / 2)  # 调整标签位置到柱组中间
ax.set_xticklabels(categories)

# 获取当前最大 y 值
_, y_max = ax.get_ylim()

# # 设置新 y 轴上限，留出 10% 空间
# ax.set_ylim(top=y_max * 1.08)

# ax.set_xlabel('benchspec')
ax.set_ylabel("score")

# plt.xticks(rotation=45, ha='right')
# 添加图例
# ax.legend(title='sampling period')
fig.set_size_inches(14, 2.6)
plt.tight_layout()
plt.rcParams.update(
    {
        "font.size": 17,  # 设置所有字体大小
    }
)
# 调整图例位置
# ax.legend(title='sampling period', bbox_to_anchor=(0.5, 1))
# legend = plt.legend(bbox_to_anchor=(0.7, 0.65),fontsize=12,)
legend = plt.legend(
    fontsize=12,
)
legend.get_frame().set_alpha(0.3)

plt.savefig("resource_usage.pdf", dpi=300, bbox_inches="tight")
