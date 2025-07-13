# Discord Movie Announcement Generator
# A self-contained script to generate Discord movie announcements from IMDB data

# Clear the console for a clean start
Clear-Host

# Display title
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   Discord Movie Announcement Generator" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Function to parse flexible time input
function Parse-Time {
    param([string]$timeString)
    
    $timeString = $timeString.Trim().ToLower()
    
    # Handle formats like "830pm", "830 pm", "8:30pm", "8:30 pm", "20:30", "8:30"
    $isPM = $timeString.Contains('pm')
    $isAM = $timeString.Contains('am')
    
    # Remove AM/PM indicators
    $timeString = $timeString -replace '\s*(am|pm)\s*', ''
    
    $hours = 0
    $minutes = 0
    
    if ($timeString.Contains(':')) {
        # Format: "8:30" or "20:30"
        $parts = $timeString.Split(':')
        if ($parts.Length -eq 2) {
            $hours = [int]$parts[0]
            $minutes = [int]$parts[1]
        } else {
            throw "Invalid time format: $timeString"
        }
    } elseif ($timeString.Length -eq 3 -or $timeString.Length -eq 4) {
        # Format: "830" or "2030"
        if ($timeString.Length -eq 3) {
            $hours = [int]$timeString.Substring(0, 1)
            $minutes = [int]$timeString.Substring(1, 2)
        } else {
            $hours = [int]$timeString.Substring(0, 2)
            $minutes = [int]$timeString.Substring(2, 2)
        }
    } else {
        throw "Invalid time format: $timeString"
    }
    
    # Handle 12-hour format conversion
    if ($isPM -and $hours -ne 12) {
        $hours += 12
    } elseif ($isAM -and $hours -eq 12) {
        $hours = 0
    } elseif (!$isPM -and !$isAM -and $hours -lt 12 -and $hours -ne 0) {
        # If no AM/PM specified and hour is less than 12, assume PM
        $hours += 12
    }
    
    # Validate the result
    if ($hours -lt 0 -or $hours -gt 23 -or $minutes -lt 0 -or $minutes -gt 59) {
        throw "Invalid time: Hours must be 0-23, minutes must be 0-59. Got: $hours`:$minutes"
    }
    
    return @{Hours = $hours; Minutes = $minutes}
}

# Function to get user input with validation
function Get-UserInput {
    param(
        [string]$Prompt,
        [string]$DefaultValue = "",
        [string[]]$ValidValues = @(),
        [switch]$Required
    )
    
    $input = ""
    do {
        if ($DefaultValue -ne "") {
            $input = Read-Host "$Prompt [default: $DefaultValue]"
            if ($input -eq "") {
                $input = $DefaultValue
            }
        } else {
            $input = Read-Host $Prompt
        }
        
        if ($ValidValues.Length -gt 0 -and $input -notin $ValidValues) {
            Write-Host "Invalid input. Please choose from: $($ValidValues -join ', ')" -ForegroundColor Red
            $input = ""
        }
        
        if ($Required -and $input -eq "") {
            Write-Host "This field is required!" -ForegroundColor Red
        }
    } while ($Required -and $input -eq "")
    
    return $input
}

try {
    # Get movie ID
    $movieId = Get-UserInput -Prompt "Enter IMDB movie ID (e.g., tt0076162)" -Required
    
    # Get cinema choice
    Write-Host ""
    Write-Host "Choose cinema:"
    Write-Host "1. Spooky Cinema"
    Write-Host "2. Obsolete Cinema"
    $cinemaChoice = Get-UserInput -Prompt "Enter choice (1 or 2)" -DefaultValue "2" -ValidValues @("1", "2")
    
    if ($cinemaChoice -eq "1") {
        $cinemaName = "Spooky Cinema"
        $cinemaEmojis = ":vrcJackoLantern::ghost~1: Spooky Cinema Presents... :ghost: :jack_o_lantern:"
    } else {
        $cinemaName = "Obsolete Cinema"
        $cinemaEmojis = "Obsolete Cinema Presents..."
    }
    
    # Get event time
    Write-Host ""
    Write-Host "Enter the event time in any of these formats:"
    Write-Host "- 8:30 PM or 8:30pm (12-hour format)"
    Write-Host "- 20:30 (24-hour format)"
    Write-Host "- 8:30 (assumes PM if before 12)"
    Write-Host "- 830pm or 830 PM (without colon)"
    $eventTime = Get-UserInput -Prompt "Event time" -DefaultValue "8:30 PM"
    
    # Parse time
    try {
        $parsedTime = Parse-Time $eventTime
        $hours = $parsedTime.Hours
        $minutes = $parsedTime.Minutes
        Write-Host "Parsed time: $hours`:$('{0:D2}' -f $minutes) (24-hour format)" -ForegroundColor Green
    } catch {
        Write-Host "Error parsing time: $($_.Exception.Message)" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    # Calculate Unix timestamp
    $currentDate = Get-Date
    $targetDateTime = $currentDate.Date.AddHours($hours).AddMinutes($minutes)
    
    # If the target time is in the past, assume it's for tomorrow
    if ($targetDateTime -lt $currentDate) {
        $targetDateTime = $targetDateTime.AddDays(1)
    }
    
    $unixTimestamp = [int64](($targetDateTime.ToUniversalTime() - (Get-Date '1970-01-01 00:00:00')).TotalSeconds)
    
    Write-Host "Target date/time: $targetDateTime" -ForegroundColor Green
    Write-Host "Unix timestamp: $unixTimestamp" -ForegroundColor Green
    
    # Fetch IMDB data
    Write-Host ""
    Write-Host "Fetching movie data from IMDB..." -ForegroundColor Yellow
    
    $url = "https://www.imdb.com/title/$movieId/"
    $headers = @{'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
    
    $response = Invoke-WebRequest -Uri $url -Headers $headers -ErrorAction Stop
    $html = $response.Content
    
    Write-Host "Successfully fetched IMDB data" -ForegroundColor Green
    
    # Extract movie information
    $title = ''
    $description = ''
    $director = ''
    $runtime = ''
    $rating = ''
    $contentRating = ''
    $actors = @()
    
    # Extract title
    if ($html -match '"name":"([^"]*?)"') {
        $title = $matches[1] -replace '\\u0026apos;', "'" -replace '\\u0026quot;', '"' -replace '\\u0026amp;', '&' -replace '\\u0026#x27;', "'"
    }
    
    # Extract description
    if ($html -match '"description":"([^"]*?)"') {
        $description = $matches[1] -replace '\\u0026apos;', "'" -replace '\\u0026quot;', '"' -replace '\\u0026amp;', '&' -replace '\\u0026#x27;', "'" -replace '&apos;', "'"
    }
    
    # Extract director
    if ($html -match '"director".*?"name":"([^"]*?)"') {
        $director = $matches[1] -replace '\\u0026apos;', "'" -replace '\\u0026quot;', '"' -replace '\\u0026amp;', '&' -replace '\\u0026#x27;', "'"
    }
    
    # Extract runtime
    if ($html -match '"duration":"PT(\d+)H(\d+)M"') {
        $runtime = "$($matches[1])h $($matches[2])m"
    }
    
    # Extract rating
    if ($html -match '"ratingValue":([^,]*)') {
        $rating = $matches[1]
    }
    
    # Extract content rating
    if ($html -match '"contentRating":"([^"]*?)"') {
        $contentRating = $matches[1]
    }
    
    # Extract actors
    if ($html -match '"actor":\[([^\]]*)\]') {
        $actorSection = $matches[1]
        $actorMatches = [regex]::Matches($actorSection, '"name":"([^"]*?)"')
        foreach ($match in $actorMatches[0..2]) {
            if ($match.Success) {
                $actors += $match.Groups[1].Value -replace '\\u0026apos;', "'" -replace '\\u0026quot;', '"' -replace '\\u0026amp;', '&' -replace '\\u0026#x27;', "'"
            }
        }
    }
    
    $starring = $actors -join ', '
    
    Write-Host "Title: $title" -ForegroundColor Cyan
    Write-Host "Director: $director" -ForegroundColor Cyan
    Write-Host "Runtime: $runtime" -ForegroundColor Cyan
    Write-Host "Rating: $rating" -ForegroundColor Cyan
    Write-Host "Content Rating: $contentRating" -ForegroundColor Cyan
    Write-Host "Starring: $starring" -ForegroundColor Cyan
    
    # Search for YouTube trailer
    Write-Host ""
    Write-Host "Searching for YouTube trailer..." -ForegroundColor Yellow
    $searchQuery = "$title trailer"
    $encodedQuery = $searchQuery -replace ' ', '+'
    $youtubeUrl = "https://www.youtube.com/results?search_query=$encodedQuery"
    
    $trailerUrl = ''
    try {
        $youtubeResponse = Invoke-WebRequest -Uri $youtubeUrl -Headers $headers -ErrorAction SilentlyContinue
        if ($youtubeResponse.Content -match '"videoId":"([^"]*?)"') {
            $videoId = $matches[1]
            $trailerUrl = "https://www.youtube.com/watch?v=$videoId"
            Write-Host "Found trailer: $trailerUrl" -ForegroundColor Green
        } else {
            Write-Host "No trailer found, using placeholder" -ForegroundColor Yellow
            $trailerUrl = 'https://www.youtube.com/watch?v=PLACEHOLDER'
        }
    } catch {
        Write-Host "Could not search for trailer, using placeholder" -ForegroundColor Yellow
        $trailerUrl = 'https://www.youtube.com/watch?v=PLACEHOLDER'
    }
    
    # Generate the announcement
    $announcement = @"
$cinemaEmojis
**$title** <t:$unixTimestamp`:F>

"$description"

**Director:** $director
**Starring:** $starring
**Runtime:** $runtime
**Rated:** $contentRating

**When:**  <t:$unixTimestamp`:F>    (Roughly "<t:$unixTimestamp`:R>")
**Where:** $cinemaName in VRChat. Join on WACOMalt when it's time!

Trailer: $trailerUrl
IMDB: <https://www.imdb.com/title/$movieId/>
Rating info and warnings: <https://www.imdb.com/title/$movieId/parentalguide>
@Cozy Cinema Viewers
"@
    
    # Save to file
    $fileName = "$title.txt" -replace '[<>:"/\\|?*]', '_'
    $filePath = "$fileName"
    $announcement | Out-File -FilePath $filePath -Encoding UTF8
    
    Write-Host ""
    Write-Host "=== ANNOUNCEMENT GENERATED ===" -ForegroundColor Green
    Write-Host "File saved as: $fileName" -ForegroundColor Green
    Write-Host ""
    Write-Host "Preview:" -ForegroundColor Yellow
    Write-Host "$announcement" -ForegroundColor White
    
} catch {
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

Write-Host ""
Write-Host "Press Enter to exit..." -ForegroundColor Gray
Read-Host
