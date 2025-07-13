# Discord Movie Announcement Generator

A self-contained Windows executable that generates Discord movie announcements from IMDB data.

## 📁 Files

- **`MovieAnnouncementGenerator.exe`** - The main executable (36KB)
- **`MovieAnnouncementGenerator.ps1`** - Source PowerShell script
- **`README.md`** - This file

## 🚀 Usage

1. **Run the executable**: Double-click `MovieAnnouncementGenerator.exe`
2. **Enter IMDB movie ID**: For example, `tt0076162`
3. **Choose cinema**: 
   - `1` for Spooky Cinema (with Halloween emojis)
   - `2` or Enter for Obsolete Cinema (default)
4. **Enter event time**: Supports multiple formats:
   - `8:30 PM` or `8:30pm` (12-hour format)
   - `20:30` (24-hour format)
   - `8:30` (assumes PM if before 12)
   - `830pm` or `830 PM` (without colon)
   - Or just press Enter for default `8:30 PM`

## ✨ Features

- **Automatic data fetching** from IMDB
- **YouTube trailer search** and inclusion
- **Flexible time input** with smart defaults
- **Cinema-specific formatting** (Spooky vs Obsolete)
- **Discord timestamp generation** for your timezone
- **File output** as `[Movie Title].txt`
- **Colorful console interface**

## 🔧 Technical Details

- **Built with**: PowerShell + PS2EXE
- **Size**: 36KB
- **Requirements**: Windows with PowerShell support
- **Network**: Requires internet connection for IMDB and YouTube data

## 📋 Output Format

The generated announcement includes:
- Movie title with Discord timestamp
- Movie description
- Director and cast information
- Runtime and rating
- Event details (when/where)
- YouTube trailer link
- IMDB links
- Formatted for Discord posting

## 🎬 Example

```
Obsolete Cinema Presents...
**Hausu** <t:1752453000:F>

"A schoolgirl and six of her classmates travel to her aunt's country home, which turns out to be haunted."

**Director:** Nobuhiko Ôbayashi
**Starring:** Kimiko Ikegami, Miki Jinbo, Kumiko Ôba
**Runtime:** 1h 28m
**Rated:** Not Rated

**When:**  <t:1752453000:F>    (Roughly "<t:1752453000:R>")
**Where:** Obsolete Cinema in VRChat. Join on WACOMalt when it's time!

Trailer: https://www.youtube.com/watch?v=7-u8s49Lv28
IMDB: <https://www.imdb.com/title/tt0076162/>
Rating info and warnings: <https://www.imdb.com/title/tt0076162/parentalguide>
@Cozy Cinema Viewers
```

## 📝 Notes

- The EXE is self-contained and doesn't require PowerShell to be installed
- Generated files are saved in the same directory as the EXE
- Times are automatically converted to Unix timestamps for Discord
- If event time is in the past, it assumes next day
- HTML entities in movie data are properly decoded

---

**Version**: 1.0.0  
**Created**: 2025-07-13  
**Author**: WACOMalt
