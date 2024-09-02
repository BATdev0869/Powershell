# Power-Browser: Enhanced version with navigation, link handling, and customization.

# Function to get and display the page content
function Get-PageContent {
    param (
        [string]$url
    )

    # Attempt to retrieve the page content
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing
        $content = $response.Content
        
        # Display the page content
        Write-Host "`nPage Content:`n"
        $plainText = $content -replace "<[^>]*>", ""  # Basic HTML tag removal
        Write-Host $plainText
        return $response.Links
    } catch {
        Write-Host "Failed to retrieve content from $url"
    }
}

# Function to navigate to previous pages
function Navigate-Back {
    param (
        [ref]$history,
        [ref]$currentUrl
    )
    
    if ($history.Count -gt 1) {
        $history.Value.Pop()  # Remove the current page
        $currentUrl.Value = $history.Value[-1]
        return $currentUrl.Value
    } else {
        Write-Host "No previous page in history."
        return $null
    }
}

# Start the browser with customization options
function Start-PowerBrowser {
    # Customization
    $bgColor = "Black"
    $fgColor = "White"
    $host.UI.RawUI.BackgroundColor = $bgColor
    $host.UI.RawUI.ForegroundColor = $fgColor
    Clear-Host
    
    Write-Host "Welcome to Power-Browser!"
    Write-Host "Enter a URL (or type 'exit' to quit, 'back' to go to the previous page, 'settings' to customize):"

    $history = New-Object System.Collections.Generic.Stack[string]
    $currentUrl = $null

    while ($true) {
        $url = Read-Host "URL"
        
        if ($url -eq 'exit') {
            break
        } elseif ($url -eq 'back') {
            $url = Navigate-Back -history ([ref]$history) -currentUrl ([ref]$currentUrl)
            if (-not $url) { continue }
        } elseif ($url -eq 'settings') {
            $bgColor = Read-Host "Enter background color (Black, Blue, Cyan, Green, etc.)"
            $fgColor = Read-Host "Enter foreground color (White, Yellow, Red, etc.)"
            $host.UI.RawUI.BackgroundColor = $bgColor
            $host.UI.RawUI.ForegroundColor = $fgColor
            Clear-Host
            Write-Host "Settings updated!"
            continue
        }

        if ($url) {
            $currentUrl = $url
            $history.Push($currentUrl)
            $links = Get-PageContent -url $url

            # Display links and allow user to select one
            if ($links.Count -gt 0) {
                Write-Host "`nLinks found on this page:"
                for ($i = 0; $i -lt $links.Count; $i++) {
                    Write-Host "$($i+1). $($links[$i].Href)"
                }

                $linkChoice = Read-Host "Enter the number of the link to follow (or press Enter to skip):"
                if ($linkChoice -match '^\d+$' -and $linkChoice -le $links.Count) {
                    $url = $links[$linkChoice - 1].Href
                    if ($url -notmatch "^https?://") {
                        $url = [uri]::new($currentUrl, $url).AbsoluteUri
                    }
                    $history.Push($url)
                    Get-PageContent -url $url
                }
            } else {
                Write-Host "No links found on this page."
            }
        } else {
            Write-Host "Please enter a valid URL."
        }

        Write-Host "`nEnter another URL, type 'back', 'settings', or 'exit' to quit:"
    }

    Write-Host "Thank you for using Power-Browser!"
}

# Start the browser
Start-PowerBrowser
