function Test-Url($Target) {
  $result = $null;
  try {
    $result = Invoke-Webrequest -Uri $Target -MaximumRedirection 0 -UseBasicParsing -ErrorAction SilentlyContinue
  } catch {}
  return $result | `
    Select-Object @{name='Result';expression={$mark}}, `
                  @{name='Target';expression={$Target}}, `
				          StatusCode, `
				          @{name='Redirect';expression={if (($_.StatusCode -gt 300) -And ($_.StatusCode -lt 399)) { $result.Headers["Location"] } else { $null }}}
}

function Test-Redirect ($Target, $Expected) {
  $iterator = 0;
  $currentUrl = $Target;

  while ($true) {
    $result = Test-Url($currentUrl);
    if (($result.StatusCode -gt 300) -And ($result.StatusCode -lt 399)) {
      $currentUrl = $result.Redirect
      $iterator = $iterator + 1
    } else {
      break
    }
  }

  $mark = 'Fail'
  if ($result.StatusCode -eq 200) {
    if ($Expected -eq $currentUrl) {
      $mark = 'Pass'
    }
  }

  return $result | Select-Object @{name='Result';expression={$mark}}, @{name='Target';expression={$Target}}, @{name='Expected';expression={$Expected}}, StatusCode, @{name='Actual';expression={$currentUrl}}, @{name='Redirects'; expression={$iterator}}
}

Test-Redirect -Target 'http://amido.com' -Expected 'https://www.amido.com/'
Test-Redirect -Target 'http://www.amido.com' -Expected 'https://www.amido.com/'
Test-Redirect -Target 'http://www.amido.co.uk' -Expected 'https://www.amido.com/' 