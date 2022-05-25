$orchestration = '--title "Workflow Orchestration"  -- pwsh.exe -Interactive -NoExit -WorkingDirectory ../../MicroServices/Workflow/Orchestration               -Command dapr run --app-id subpla-workflow-orchestration --dapr-grpc-port 50000 --app-port 3001'
$TechValidation = '--title "Techical Validation"  -- pwsh.exe -Interactive -NoExit -WorkingDirectory ../../MicroServices/Workflow/Processes\TechnicalValidation  -Command dapr run --app-id techvalidation-worker         --dapr-grpc-port 50001 --app-port 5050 --app-protocol grpc'

#$cmd = '-M -w -1 nt ' + $orchestration + '; nt ' + $TechValidation
$cmd = '-w -1 nt ' + $orchestration + '; split-pane ' + $TechValidation
Start-Process wt $cmd
