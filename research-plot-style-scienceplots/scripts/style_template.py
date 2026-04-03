"""Reusable plotting helpers for report-grade scientific figures.

This template enforces a fixed base palette, striped categorical bars,
calmer multi-category colors, restrained sequential heatmaps, PDF-only output,
and readable Chinese/English labels for report workflows.
"""

from __future__ import annotations

import colorsys
from pathlib import Path
from textwrap import fill
from typing import Literal, Mapping, Sequence

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import scienceplots  # noqa: F401
from cycler import cycler
from matplotlib import font_manager as fm
from matplotlib.colors import LinearSegmentedColormap, to_hex, to_rgb

PALETTE = (
    "#66C2A5",
    "#FC8D62",
    "#8DA0CB",
    "#E78AC3",
    "#A6D854",
    "#E5C494",
)

HATCHES = (
    "////",
    "....",
    "xxxx",
    "----",
    "////",
    "....",
)

BAR_EDGE_COLOR = "#4A4A4A"
BAR_WIDTH = 0.42
BAR_HEIGHT = 0.28
SINGLE_COLUMN_FIGSIZE = (3.35, 2.45)
DOUBLE_COLUMN_FIGSIZE = (7.00, 2.80)

CJK_FONT_FALLBACK = (
    "SimSun",
    "NSimSun",
    "STSong",
    "Noto Serif CJK SC",
    "Songti SC",
    "Microsoft YaHei",
    "DejaVu Sans",
)

LATIN_FONT_FALLBACK = (
    "Times New Roman",
    "STIX Two Text",
    "DejaVu Serif",
)

SOFT_LIGHTNESS = (0.72, 0.72, 0.71, 0.74, 0.71, 0.74)
SOFT_SATURATION = (0.34, 0.36, 0.28, 0.24, 0.30, 0.28)


def pick_font(candidates: Sequence[str], default: str) -> str:
    for name in candidates:
        try:
            fm.findfont(name, fallback_to_default=False)
            return name
        except Exception:
            continue
    return default


def wrap_label(text: str, width: int = 8) -> str:
    if width <= 0:
        return str(text)
    return fill(str(text), width=width, break_long_words=False, break_on_hyphens=False)


def normalize_label(
    label: str,
    *,
    label_map: Mapping[str, str] | None = None,
    wrap_width: int = 8,
    replace_underscore: bool = True,
) -> str:
    value = str(label_map.get(label, label) if label_map else label)
    if replace_underscore:
        value = value.replace("_", " ")
    return wrap_label(value, width=wrap_width)


def normalize_labels(
    labels: Sequence[str],
    *,
    label_map: Mapping[str, str] | None = None,
    wrap_width: int = 8,
    replace_underscore: bool = True,
) -> list[str]:
    return [
        normalize_label(
            item,
            label_map=label_map,
            wrap_width=wrap_width,
            replace_underscore=replace_underscore,
        )
        for item in labels
    ]


def soften_color(color: str, *, lightness: float | None = None, saturation: float | None = None) -> str:
    r, g, b = to_rgb(color)
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    if lightness is not None:
        l = max(0.0, min(1.0, lightness))
    if saturation is not None:
        s = max(0.0, min(1.0, saturation))
    return to_hex(colorsys.hls_to_rgb(h, l, s))


def make_soft_palette(
    palette: Sequence[str] = PALETTE,
    *,
    lightness: Sequence[float] = SOFT_LIGHTNESS,
    saturation: Sequence[float] = SOFT_SATURATION,
) -> list[str]:
    colors: list[str] = []
    for i, color in enumerate(palette):
        l = lightness[i % len(lightness)]
        s = saturation[i % len(saturation)]
        colors.append(soften_color(color, lightness=l, saturation=s))
    return colors


def make_heatmap_cmap(
    *,
    neutral: str = "#F7F4EF",
    low: str | None = None,
    high: str | None = None,
) -> LinearSegmentedColormap:
    low_color = low or soften_color(PALETTE[0], lightness=0.82, saturation=0.18)
    high_color = high or soften_color(PALETTE[2], lightness=0.66, saturation=0.28)
    return LinearSegmentedColormap.from_list("muted_heatmap", [neutral, low_color, high_color])


def apply_style(base_font_size: float = 9.0) -> None:
    plt.style.use(["science", "no-latex"])
    cjk_font = pick_font(CJK_FONT_FALLBACK, "DejaVu Sans")
    latin_font = pick_font(LATIN_FONT_FALLBACK, "DejaVu Serif")
    mpl.rcParams.update(
        {
            "figure.figsize": SINGLE_COLUMN_FIGSIZE,
            "axes.prop_cycle": cycler(color=PALETTE),
            "axes.grid": True,
            "grid.alpha": 0.28,
            "grid.linewidth": 0.35,
            "grid.color": "#B8B8B8",
            "axes.spines.top": False,
            "axes.spines.right": False,
            "axes.linewidth": 0.65,
            "font.family": "serif",
            "font.serif": [cjk_font, *LATIN_FONT_FALLBACK, latin_font],
            "font.sans-serif": [cjk_font, *CJK_FONT_FALLBACK],
            "axes.unicode_minus": False,
            "font.size": base_font_size,
            "axes.labelsize": base_font_size,
            "axes.titlesize": base_font_size,
            "legend.fontsize": base_font_size - 1,
            "legend.frameon": False,
            "xtick.labelsize": base_font_size - 1,
            "ytick.labelsize": base_font_size - 1,
            "pdf.fonttype": 42,
            "ps.fonttype": 42,
            "savefig.format": "pdf",
            "savefig.bbox": "tight",
            "savefig.pad_inches": 0.02,
            "patch.linewidth": 0.55,
            "hatch.linewidth": 0.75,
        }
    )


def make_figure(
    *,
    nrows: int = 1,
    ncols: int = 1,
    span: Literal["single", "double"] = "single",
    sharex: bool = False,
    sharey: bool = False,
):
    if span not in {"single", "double"}:
        raise ValueError("span must be 'single' or 'double'")

    base_width, base_height = SINGLE_COLUMN_FIGSIZE if span == "single" else DOUBLE_COLUMN_FIGSIZE
    fig, axes = plt.subplots(
        nrows=nrows,
        ncols=ncols,
        figsize=(base_width, base_height * nrows),
        sharex=sharex,
        sharey=sharey,
        constrained_layout=True,
    )

    iterable = axes.flat if hasattr(axes, "flat") else (axes,)
    for axis in iterable:
        axis.tick_params(axis="x", labelrotation=0)
        axis.tick_params(axis="y", labelrotation=0)

    return fig, axes


def plot_bar(
    ax: plt.Axes,
    labels: Sequence[str],
    values: Sequence[float],
    *,
    horizontal: bool = False,
    width: float = BAR_WIDTH,
    label_map: Mapping[str, str] | None = None,
    wrap_width: int = 8,
    replace_underscore: bool = True,
    colors: Sequence[str] | None = None,
    alpha: float = 0.88,
):
    positions = list(range(len(labels)))
    show_labels = normalize_labels(
        labels,
        label_map=label_map,
        wrap_width=wrap_width,
        replace_underscore=replace_underscore,
    )
    color_cycle = list(colors or PALETTE)
    draw_colors = [color_cycle[i % len(color_cycle)] for i in positions]
    draw_hatches = [HATCHES[i % len(HATCHES)] for i in positions]

    if horizontal:
        bars = ax.barh(positions, values, height=width, color=draw_colors, edgecolor=BAR_EDGE_COLOR, alpha=alpha)
        ax.set_yticks(positions, show_labels)
    else:
        bars = ax.bar(positions, values, width=width, color=draw_colors, edgecolor=BAR_EDGE_COLOR, alpha=alpha)
        ax.set_xticks(positions, show_labels)

    for bar, hatch in zip(bars, draw_hatches):
        bar.set_hatch(hatch)

    return list(bars)


def annotate_bar_values_clamped(
    ax: plt.Axes,
    bars: Sequence,
    *,
    horizontal: bool,
    fmt: str = "{:.3f}",
    pad: float = 0.01,
    fontsize: float = 8.0,
) -> None:
    if horizontal:
        _, xmax = ax.get_xlim()
        for bar in bars:
            value = float(bar.get_width())
            y = bar.get_y() + bar.get_height() / 2
            x_text = value + pad
            ha = "left"
            if x_text > xmax - pad:
                x_text = xmax - pad
                ha = "right"
            ax.text(x_text, y, fmt.format(value), va="center", ha=ha, fontsize=fontsize)
    else:
        _, ymax = ax.get_ylim()
        for bar in bars:
            value = float(bar.get_height())
            x = bar.get_x() + bar.get_width() / 2
            y_text = value + pad
            va = "bottom"
            if y_text > ymax - pad:
                y_text = ymax - pad
                va = "top"
            ax.text(x, y_text, fmt.format(value), va=va, ha="center", fontsize=fontsize)


def _spread_with_min_gap(values: np.ndarray, min_gap: float) -> np.ndarray:
    out = values.copy()
    order = np.argsort(out)
    for i in range(1, len(order)):
        cur = order[i]
        prev = order[i - 1]
        if out[cur] - out[prev] < min_gap:
            out[cur] = out[prev] + min_gap
    return out


def scatter_labels_no_leader(
    ax: plt.Axes,
    x: Sequence[float],
    y: Sequence[float],
    labels: Sequence[str],
    *,
    label_map: Mapping[str, str] | None = None,
    wrap_width: int = 10,
    min_gap: float = 0.004,
    x_shift_even: float = 0.9,
    x_shift_odd: float = 0.6,
    fontsize: float = 8.0,
) -> None:
    x_arr = np.asarray(x, dtype=float)
    y_arr = np.asarray(y, dtype=float)
    y_lbl = _spread_with_min_gap(y_arr, min_gap=min_gap)

    for i, raw_label in enumerate(labels):
        txt = normalize_label(raw_label, label_map=label_map, wrap_width=wrap_width)
        dx = x_shift_even if i % 2 == 0 else x_shift_odd
        ax.text(
            x_arr[i] + dx,
            y_lbl[i],
            txt,
            va="center",
            ha="left",
            fontsize=fontsize,
            bbox={"boxstyle": "round,pad=0.12", "fc": "white", "ec": "#DDDDDD", "alpha": 0.85},
            zorder=4,
        )


def save_pdf(fig: plt.Figure, output: str | Path) -> Path:
    out = Path(output)
    if out.suffix.lower() != ".pdf":
        raise ValueError("Only PDF output is allowed.")
    out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(out, format="pdf")
    plt.close(fig)
    return out


if __name__ == "__main__":
    apply_style(base_font_size=9.5)

    fig, axes = make_figure(nrows=1, ncols=2, span="double")

    labels = ["gongcun", "tymo", "vodana", "lena"]
    label_map = {
        "gongcun": "宫村浩气",
        "tymo": "TYMO",
        "vodana": "VODANA",
        "lena": "LENA",
    }
    scores = np.array([68.77, 68.47, 65.63, 59.58])

    soft_colors = make_soft_palette()[:4]
    bars = plot_bar(axes[0], labels, scores, label_map=label_map, wrap_width=8, colors=soft_colors)
    axes[0].set_ylim(0, 80)
    annotate_bar_values_clamped(axes[0], bars, horizontal=False, fmt="{:.2f}", pad=0.6, fontsize=8.5)
    axes[0].set_ylabel("Weighted score")

    heat_values = np.array(
        [
            [67.9, 75.1, 69.8, 50.0],
            [70.0, 75.4, 69.4, 55.4],
            [46.8, 71.5, 75.4, 50.0],
            [50.0, 80.0, 62.6, 50.0],
        ]
    )
    cmap = make_heatmap_cmap()
    im = axes[1].imshow(heat_values, cmap=cmap, aspect="auto", vmin=45, vmax=85)
    axes[1].set_xticks(range(4), ["Safety", "Durability", "Hair impact", "Odor"])
    axes[1].set_yticks(range(4), [label_map[x] for x in labels])
    for row in range(heat_values.shape[0]):
        for col in range(heat_values.shape[1]):
            axes[1].text(col, row, f"{heat_values[row, col]:.1f}", ha="center", va="center", fontsize=8.0)
    fig.colorbar(im, ax=axes[1], fraction=0.05, pad=0.03)

    out = save_pdf(fig, "style_template_demo.pdf")
    print(f"Saved: {out}")
