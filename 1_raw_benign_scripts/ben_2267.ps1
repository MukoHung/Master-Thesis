$error.clear();
Set-StrictMode -Version:Latest
$GLOBAL:ErrorActionPreference               = "Stop"
."$PSCommandPath.vars.ps1"


import-module -NoClobber -Force  "$SCRIPT:DIRECTORY_PATH_OF_pratom_ATOM_NUCLEUS_PROTONS_LOADING\code_to_load_a_directory.ps1"
import-module -NoClobber -Force  "$SCRIPT:DIRECTORY_PATH_OF_pratom_ATOM_NUCLEUS_PROTONS_LOADING\code_to_load_a_file.ps1"
import-module -NoClobber -Force  "$SCRIPT:DIRECTORY_PATH_OF_pratom_ATOM_NUCLEUS_PROTONS_LOADING\get_same_name_file.ps1"
import-module -NoClobber -Force  "$SCRIPT:DIRECTORY_PATH_OF_pratom_ATOM_NUCLEUS_PROTONS_LOADING\pr_everytime.ps1"
import-module -NoClobber -Force  "$SCRIPT:DIRECTORY_PATH_OF_pratom_ATOM_NUCLEUS_PROTONS_LOADING\pr_import_module.ps1"
import-module -NoClobber -Force  "$SCRIPT:DIRECTORY_PATH_OF_pratom_ATOM_NUCLEUS_PROTONS_LOADING\pr_import_module_status.ps1"
import-module -NoClobber -Force  "$SCRIPT:DIRECTORY_PATH_OF_pratom_ATOM_NUCLEUS_PROTONS_LOADING\pr_import_module_status_show.ps1"
import-module -NoClobber -Force  "$SCRIPT:DIRECTORY_PATH_OF_pratom_ATOM_NUCLEUS_PROTONS_LOADING\pr_once.ps1"
import-module -NoClobber -Force  "$SCRIPT:DIRECTORY_PATH_OF_pratom_ATOM_NUCLEUS_PROTONS_LOADING\what_is_loaded.ps1"
import-module -NoClobber -Force  "$SCRIPT:DIRECTORY_PATH_OF_pratom_ATOM_NUCLEUS_PROTONS_LOADING\pr_import_module_status_to_console.ps1"