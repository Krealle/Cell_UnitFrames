# Cell - Unit Frames

Plugin for the amazing AddOn [Cell](https://www.curseforge.com/wow/addons/cell) that adds various unit frames.

## Units currently available

- **Player**
- **Target**
- **TargetTarget**
- **Focus**
- **Pet**

## Features

The widget/indicator system differs from the original Cell, and as such won't support native indicators.

Most of the common indicators are supported, but it's still a work in progress.

### Custom Formats

**Health Text** and **Power Text** supports custom formats, expressed as tags.

These can be combined in any order to create the desired format.

- `[cur:short] | [cur:per]` to produce `120k | 100.00%`.
- `[cur]/[max]` to produce `80000/120000`.

#### Valid Tags

```
[cur] - Displays the current amount.
[cur:short] - Displays the current amount as a shortvalue.
[cur:per] - Displays the current amount as a percentage.
[cur:per-short] - Displays the current amount as a percentage without decimals.

[max] - Displays the maximum amount.
[max:short] - Displays the maximum amount as a shortvalue.

[abs] - Displays the amount of absorbs.
[abs:short] - Displays the amount of absorbs as a shortvalue.
[abs:per] - Displays the absorbs as a percentage.
[abs:per-short] - Displays the absorbs as a percentage without decimals.

[cur:abs] - Displays the current amount and absorbs.
[cur:abs-short] - Displays the current amount and absorbs as shortvalues.
[cur:abs:per] - Displays the current amount and absorbs as percentages.
[cur:abs:per-short] - Displays the current amount and absorbs as percentages without decimals.

[cur:abs:merge] - Displays the sum of the current amount and absorbs.
[cur:abs:merge:short] - Displays the sum of the current amount and absorbs as a shortvalue.
[cur:abs:merge:per] - Displays the sum of the current amount and absorbs as a percentage.
[cur:abs:merge:per-short] - Displays the sum of the current amount and absorbs as a percentage without decimals.

[def] - Displays the deficit.
[def:short] - Displays the deficit as a shortvalue.
[def:per] - Displays the deficit as a percentage.
[def:per-short] - Displays the deficit as a percentage without decimals.
```

## Issues / Feature Requests

Please report any issues or feature requests over [here](https://github.com/Krealle/Cell_UnitFrames/issues).
