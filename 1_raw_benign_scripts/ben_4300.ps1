# let rows: 10
# let lines = from row in 0..rows
#             let spaceCount = rows - row
#             let spaces = " " * spaceCount
#             let stars = "*" * (2 * row + 1)
#             let line = spaces + stars + spaces
#             select line
# lines.join("\r\n")


$rows = 10
$lines = @(
    foreach ($row in 0..$rows)
    {
        $spaceCount = $rows - $row
        $spaces = " " * $spaceCount
        $stars = "*" * (2 * $row + 1)
        $line = $spaces + $stars + $spaces
        $line
    }
)

[System.String]::Join([System.Environment]::NewLine, $lines)