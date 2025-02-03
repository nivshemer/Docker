& scp -i "C:\Users\QAVM\Documents\git-hub\id_rsa" -r ubuntu@100.110.120.73:/home/ubuntu/version.txt c:\Environments\dev21
& scp -i "C:\Users\QAVM\Documents\git-hub\id_rsa" -r ubuntu@100.110.120.71:/home/ubuntu/version.txt c:\Environments\dev30
& scp -i "C:\Users\QAVM\Documents\git-hub\id_rsa" -r ubuntu@100.110.120.82:/home/ubuntu/version.txt c:\Environments\qa21
& scp -i "C:\Users\QAVM\Documents\git-hub\id_rsa" -r ubuntu@100.110.120.83:/home/ubuntu/version.txt c:\Environments\qa30
& scp -i "C:\Users\QAVM\Documents\git-hub\id_rsa" -r ubuntu@100.110.120.91:/home/ubuntu/version.txt c:\Environments\demo

function Remove-LastLines {
  param (
      [string]$FilePath,
      [int]$LinesToRemove
  )

  # Read the content of the file
  $content = Get-Content -Path $FilePath

  # Remove the last specified number of lines
  $newContent = $content[0..($content.Count - $LinesToRemove - 1)]

  # Write the updated content back to the file
  $newContent | Set-Content -Path $FilePath
}

function Transform-VersionFile {
  param (
      [string]$FilePath
  )

  # Read the content of the file
  $content = Get-Content -Path $FilePath

  # Define an empty array to store the transformed lines
  $output = @()

  # Process each line in the content
  foreach ($line in $content) {
      # Replace spaces with HTML entities
      $line = $line -replace '\s+', ' ' -replace '^(.*?) (.*?) (Up.*)$', '<tr><td>$1</td> <td>$2</td> <td>$3</td></tr>'

      # Add the line to the output array
      $output += $line
  }

  # Join the lines with newline characters
  $newContent = $output -join "`n"

  # Write the transformed content back to the file
  Set-Content -Path $FilePath -Value $newContent
  Remove-LastLines -FilePath $FilePath -LinesToRemove 16
}

function Replace-ContentInIndexHTML {
  param (
      [string]$IndexHTMLPath,
      [string]$VersionTXTPath,
      [int]$LineFrom,
      [int]$LineTo
  )

  # Define the line numbers for start and end of replacement
  $startLine = $LineFrom
  $endLine = $LineTo

  # Read the content of version.txt
  $versionContent = Get-Content -Path $VersionTXTPath

  # Read the content of index.html
  $htmlContent = Get-Content -Path $IndexHTMLPath

  # Loop through the lines of version.txt and replace corresponding lines in index.html
  $lineCounter = 0
  foreach ($line in $versionContent) {
      $htmlContent[$startLine + $lineCounter] = $line
      $lineCounter++
      if ($startLine + $lineCounter -gt $endLine) {
          break
      }
  }

  # Write the updated content back to index.html
  $htmlContent | Set-Content -Path $IndexHTMLPath
}

# Call the function with the file path as an argument
Transform-VersionFile -FilePath "c:\Environments\dev21\version.txt"
Transform-VersionFile -FilePath "c:\Environments\dev30\version.txt"
Transform-VersionFile -FilePath "c:\Environments\qa21\version.txt"
Transform-VersionFile -FilePath "c:\Environments\qa30\version.txt"
Transform-VersionFile -FilePath "c:\Environments\demo\version.txt"

Replace-ContentInIndexHTML -IndexHTMLPath "C:\Environments\index.html" -VersionTXTPath "c:\Environments\dev21\version.txt" -LineFrom 80 -LineTo 91
Replace-ContentInIndexHTML -IndexHTMLPath "C:\Environments\index.html" -VersionTXTPath "c:\Environments\dev30\version.txt" -LineFrom 106 -LineTo 117
Replace-ContentInIndexHTML -IndexHTMLPath "C:\Environments\index.html" -VersionTXTPath "c:\Environments\qa21\version.txt" -LineFrom 132 -LineTo 143
Replace-ContentInIndexHTML -IndexHTMLPath "C:\Environments\index.html" -VersionTXTPath "c:\Environments\qa30\version.txt" -LineFrom 158 -LineTo 169
Replace-ContentInIndexHTML -IndexHTMLPath "C:\Environments\index.html" -VersionTXTPath "c:\Environments\demo\version.txt" -LineFrom 184 -LineTo 194
