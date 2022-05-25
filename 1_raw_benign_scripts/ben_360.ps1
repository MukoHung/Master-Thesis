Find-Item -Index sitecore_master_index `
          -Criteria @{Filter = "StartsWith"; Field = "_fullpath"; Value = "/sitecore/system/modules/PowerShell/" } `
          -First 1 | 
    select -expand "Fields"
