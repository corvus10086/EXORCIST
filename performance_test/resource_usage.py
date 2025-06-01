import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import Rectangle
import matplotlib.colors as mcolors

# 
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
types = ["no defense", "SI = 50", "SI = 00", "SI = 200"]  # 4
colors = [
    (0.8, 0.6, 0.6),  # 
    (0.6, 0.8, 0.6),  # 
    (0.6, 0.6, 0.8),  # 
    (0.8, 0.8, 0.6),  # 
]
dark_colors = [
    (0.6, 0.2, 0.2),  # 
    (0.2, 0.6, 0.2),  # 
    (0.2, 0.2, 0.6),  # 
    (0.6, 0.6, 0.2),  # 
]
# 
bar_width = 0.15
x = np.arange(len(categories))  # x


# 
def add_hatch(ax, bars, hatch_density=5):
    for bar in bars:
        bar.set_hatch("//")
        bar.set_edgecolor((0, 0, 0, 0.3))
        bar.set_linewidth(0.8)
        # # 
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
     HSV V
    factor  0.6 ~ 0.8
    """
    h, s, v = mcolors.rgb_to_hsv(color)
    v *= factor  # 
    return mcolors.hsv_to_rgb((h, s, v))


# 
fig, ax = plt.subplots()

# 
for i in range(len(types)):


    #  x + i
    bars = ax.bar(
        x + i * bar_width,
        [val[i] for val in values],
        width=bar_width,
        label=types[i],
        color=colors[i],  # 
        edgecolor=dark_colors[i],   # 
        linewidth=0.8,
        hatch='//'
    )  # )

    # add_hatch(ax, bars)

    # for bar in bars:
    #     height = bar.get_height()
    #     ax.text(bar.get_x() + bar.get_width()/2.+0.04,
    #             height + 0.9,  # 
    #             f'{height:.1f}',  # 
    #             ha='center',
    #             va='bottom',
    #             rotation=90,  # 
    #             rotation_mode='anchor',
    #             fontsize=9,
    #             color='black')

# x
ax.set_xticks(x + bar_width * (len(types) - 1) / 2)  # 
ax.set_xticklabels(categories)

#  y 
_, y_max = ax.get_ylim()

# #  y  10% 
# ax.set_ylim(top=y_max * 1.08)

# ax.set_xlabel('benchspec')
ax.set_ylabel("score")

# plt.xticks(rotation=45, ha='right')
# 
# ax.legend(title='sampling period')
fig.set_size_inches(14, 2.6)
plt.tight_layout()
plt.rcParams.update(
    {
        "font.size": 17,  # 
    }
)
# 
# ax.legend(title='sampling period', bbox_to_anchor=(0.5, 1))
# legend = plt.legend(bbox_to_anchor=(0.7, 0.65),fontsize=12,)
legend = plt.legend(
    fontsize=12,
)
legend.get_frame().set_alpha(0.3)

plt.savefig("resource_usage.pdf", dpi=300, bbox_inches="tight")
