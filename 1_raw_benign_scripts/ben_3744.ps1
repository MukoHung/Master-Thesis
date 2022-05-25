#УМНОЕ УДАЛЕНИЕ РЕЗЕРВНЫХ КОПИЙ
#настройки скрипта
$path = “C:\test\”; #Каталог с резервными копиями
$isnof = 5; #колличество файлов которые нельзя удалять (от 1 до 99)
$days = 5; #Удалять старше Х дней
$nof = (get-childitem $path -recurse '*backup*.bak').length; #получаем колличество файлов в каталоге с резервными копиями. Установлен фильтр для файлов в имени которых присутствует "backup" и расширением ".bak"
if ($nof -le $isnof -or $nof -gt 100)
{
echo 'Удаление не требуется'
exit
}
else
{
FORFILES /p $path /s /m *backup*.bak /d -$days /c "CMD /c del /Q @FILE"
echo 'удалено'
}