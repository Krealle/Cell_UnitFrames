# Cell - Unit Frames

[![Discord](https://img.shields.io/discord/1062050991664529498?label=Discord&color=5865F2)](https://discord.gg/C5STjYRsCD)

[![Patreon](https://img.shields.io/badge/Patreon-F96854?style=for-the-badge&logo=patreon&logoColor=white)](https://www.patreon.com/vollmerino)

Plugin for the amazing AddOn **[Cell](https://www.curseforge.com/wow/addons/cell)** that adds various unit frames.

Simply head into the **Layouts** tab in **Cell** to start customizing your frames.

## Units currently available

- **Player**
- **Target**
- **TargetTarget**
- **Focus**
- **Pet**
- **Boss**

## Features

The widget/indicator system differs from the original **Cell**, and as such won't support native indicators.

Most of the common indicators are supported, but it's still a work in progress.

### Custom Formats

**Health Text**, **Power Text** and **Custom Text** supports custom formats, expressed as tags.

These can be combined in any order to create the desired format.

- `[curhp:short] | [curhp:per]` to produce `120k | 100.00%`.
- `[curhp]/[maxhp]` to produce `80000/120000`.

There is also support for conditional prefixes and suffixes. Simply add a `>` or `<` before or after the tag and the text preceding or following the tag will be used as the prefix or suffix respectively. Only showing when the tag is active.

- ` [target< «] [name]` to produce `Sylvanas Windrunner « Bob`.
- `[name] [» >target]` to produce `Bob » Sylvanas Windrunner`.

Write **`/cuf tags`** in the chat to see a list of all available tags.

Feel like a useful tag is missing, or simply have a niche request? Feel free to make a feature request or even a PR!

You can also create your own custom tags on the fly via snippets.

Check out https://github.com/Krealle/Cell_UnitFrames/blob/master/Snippets/AddCustomTag.lua for an example.

## Click-Casting

Click-Casting is fully supported, and can be toggled on/off on a per-unit basis.

## Snippets

This plugin fully supports **Cell**'s snippet system!

These two Callbacks can be used with `Cell:RegisterCallback()`

`CUF_AddonLoaded` - Fired when the addon is fully loaded, before Frames & Widgets are initialized.

`CUF_FramesInitialized` - Fired when all Frames & Widgets are initialized.

Check out https://github.com/Krealle/Cell_UnitFrames/tree/master/Snippets for example usage.

## API

This plugin provides custom API that can be used to easily perform various actions.

Check out https://github.com/Krealle/Cell_UnitFrames/tree/master/API for further documentation.

## Issues / Feature Requests

Please report any issues or feature requests over on [GitHub](https://github.com/Krealle/Cell_UnitFrames/issues).

## Localization

Want to help translate the AddOn? Head over to [CurseForge](https://legacy.curseforge.com/wow/addons/cell-unit-frames/localization).
