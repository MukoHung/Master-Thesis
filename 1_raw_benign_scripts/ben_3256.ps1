Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted

$taskPath = "\DA"
$workingDir = "G:/DA/ETL/APP/bin"


./register-job.ps1 "A_KIMS.HY_DCDB2CDB_DA" $taskPath "Task1Desription" "A_EXEC" “A_KIMS.HY_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00AM" 10
./register-job.ps1 "A_KIMS.KSMC_DCDB2CDB_DA" $taskPath "Task1Desription2" "A_EXEC" “A_KIMS.KSMC_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00 AM" 10
./register-job.ps1 "A_KIMS.BHC_DCDB2CDB_DA" $taskPath "Task1Desription3" "A_EXEC" “A_KIMS.BHC_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00 AM" 10
./register-job.ps1 "A_KIMS.SKLM_DCDB2CDB_DA" $taskPath "Task1Desription3" "A_EXEC" “A_KIMS.SKLM_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00 AM" 10
./register-job.ps1 "A_KIMS.BRMH_DCDB2CDB_DA" $taskPath "Task1Desription3" "A_EXEC" “A_KIMS.BRMH_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00 AM" 10
./register-job.ps1 "A_KIMS.KIMSKU_DCDB2CDB_DA" $taskPath "Task1Desription3" "A_EXEC" “A_KIMS.KIMSKU_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00 AM" 10
./register-job.ps1 "A_KIMS.KIMSO_DCDB2CDB_DA" $taskPath "Task1Desription3" "A_EXEC" “A_KIMS.KIMSO_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00 AM" 10
./register-job.ps1 "A_KIMS.KIMSK_DCDB2CDB_DA" $taskPath "Task1Desription3" "A_EXEC" “A_KIMS.KIMSK_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00 AM" 10
./register-job.ps1 "A_KIMS.KIMSV_DCDB2CDB_DA" $taskPath "Task1Desription3" "A_EXEC" “A_KIMS.KIMSV_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00 AM" 10
./register-job.ps1 "A_KIMS.KIMSC_DCDB2CDB_DA" $taskPath "Task1Desription3" "A_EXEC" “A_KIMS.KIMSC_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00 AM" 10

./register-job.ps1 "A_KIMS_HIMS2DA_DA" $taskPath "Task1Desription3" "A_EXEC" “A_KIMS_HIMS2DA_DA" $workingDir "01/01/2021 00:00:00 AM" 10
./register-job.ps1 "A_KIMS_CDB2FILE_DA" $taskPath "Task1Desription3" "A_EXEC" “A_KIMS_CDB2FILE_DA" $workingDir "01/01/2021 00:00:00 AM" 10
./register-job.ps1 "A_KIMS_FILE2FILE_DA" $taskPath "Task1Desription3" "A_EXEC" “A_KIMS_FILE2FILE_DA" $workingDir "01/01/2021 00:00:00 AM" 10



./register-job.ps1 "W_KIMS.HY_DCDB2CDB_DA" $taskPath "Task1Desription" "W_EXEC" “W_KIMS.HY_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00 AM" 60
./register-job.ps1 "W_KIMS.KSMC_DCDB2CDB_DA" $taskPath "Task1Desription2" "W_EXEC" “W_KIMS.KSMC_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00 AM" 60
./register-job.ps1 "W_KIMS.BHC_DCDB2CDB_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.BHC_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00 AM" 60
./register-job.ps1 "W_KIMS.SKLM_DCDB2CDB_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.SKLM_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00 AM" 60
./register-job.ps1 "W_KIMS.BRMH_DCDB2CDB_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.BRMH_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSKU_DCDB2CDB_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSKU_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSO_DCDB2CDB_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSO_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSK_DCDB2CDB_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSK_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSV_DCDB2CDB_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSV_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSC_DCDB2CDB_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSC_DCDB2CDB_DA" $workingDir "01/01/2021 00:00:00 AM" 60

./register-job.ps1 "W_KIMS.HY_HIMS2DA_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.HY_HIMS2DA_DA" $workingDir "01/01/2021 00:10:00 AM" 60
./register-job.ps1 "W_KIMS.KSMC_HIMS2DA_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KSMC_HIMS2DA_DA" $workingDir "01/01/2021 00:10:00 AM" 60
./register-job.ps1 "W_KIMS.BHC_HIMS2DA_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.BHC_HIMS2DA_DA" $workingDir "01/01/2021 00:10:00 AM" 60
./register-job.ps1 "W_KIMS.SKLM_HIMS2DA_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.SKLM_HIMS2DA_DA" $workingDir "01/01/2021 00:10:00 AM" 60
./register-job.ps1 "W_KIMS.BRMH_HIMS2DA_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.BRMH_HIMS2DA_DA" $workingDir "01/01/2021 00:10:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSKU_HIMS2DA_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSKU_HIMS2DA_DA" $workingDir "01/01/2021 00:10:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSO_HIMS2DA_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSO_HIMS2DA_DA" $workingDir "01/01/2021 00:10:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSK_HIMS2DA_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSK_HIMS2DA_DA" $workingDir "01/01/2021 00:10:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSV_HIMS2DA_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSV_HIMS2DA_DA" $workingDir "01/01/2021 00:10:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSC_HIMS2DA_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSC_HIMS2DA_DA" $workingDir "01/01/2021 00:10:00 AM" 60


./register-job.ps1 "W_KIMS.HY_CDB2FILE_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.HY_CDB2FILE_DA" $workingDir "01/01/2021 00:20:00 AM" 60
./register-job.ps1 "W_KIMS.KSMC_CDB2FILE_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KSMC_CDB2FILE_DA" $workingDir "01/01/2021 00:20:00 AM" 60
./register-job.ps1 "W_KIMS.BHC_CDB2FILE_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.BHC_CDB2FILE_DA" $workingDir "01/01/2021 00:20:00 AM" 60
./register-job.ps1 "W_KIMS.SKLM_CDB2FILE_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.SKLM_CDB2FILE_DA" $workingDir "01/01/2021 00:20:00 AM" 60
./register-job.ps1 "W_KIMS.BRMH_CDB2FILE_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.BRMH_CDB2FILE_DA" $workingDir "01/01/2021 00:20:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSKU_CDB2FILE_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSKU_CDB2FILE_DA" $workingDir "01/01/2021 00:20:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSO_CDB2FILE_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSO_CDB2FILE_DA" $workingDir "01/01/2021 00:20:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSK_CDB2FILE_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSK_CDB2FILE_DA" $workingDir "01/01/2021 00:20:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSV_CDB2FILE_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSV_CDB2FILE_DA" $workingDir "01/01/2021 00:20:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSC_CDB2FILE_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSC_CDB2FILE_DA" $workingDir "01/01/2021 00:20:00 AM" 60


./register-job.ps1 "W_KIMS.HY_FILE2FILE_DA"     $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.HY_FILE2FILE_DA" $workingDir "01/01/2021 00:30:00 AM" 60
./register-job.ps1 "W_KIMS.KSMC_FILE2FILE_DA"   $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KSMC_FILE2FILE_DA" $workingDir "01/01/2021 00:30:00 AM" 60
./register-job.ps1 "W_KIMS.BHC_FILE2FILE_DA"    $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.BHC_FILE2FILE_DA" $workingDir "01/01/2021 00:30:00 AM" 60
./register-job.ps1 "W_KIMS.SKLM_FILE2FILE_DA"   $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.SKLM_FILE2FILE_DA" $workingDir "01/01/2021 00:30:00 AM" 60
./register-job.ps1 "W_KIMS.BRMH_FILE2FILE_DA"   $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.BRMH_FILE2FILE_DA" $workingDir "01/01/2021 00:30:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSKU_FILE2FILE_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSKU_FILE2FILE_DA" $workingDir "01/01/2021 00:30:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSO_FILE2FILE_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSO_FILE2FILE_DA" $workingDir "01/01/2021 00:30:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSK_FILE2FILE_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSK_FILE2FILE_DA" $workingDir "01/01/2021 00:30:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSV_FILE2FILE_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSV_FILE2FILE_DA" $workingDir "01/01/2021 00:30:00 AM" 60
./register-job.ps1 "W_KIMS.KIMSC_FILE2FILE_DA" $taskPath "Task1Desription3" "W_EXEC" “W_KIMS.KIMSC_FILE2FILE_DA" $workingDir "01/01/2021 00:30:00 AM" 60